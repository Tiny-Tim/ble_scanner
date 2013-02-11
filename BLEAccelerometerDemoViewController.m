//
//  BLEAccelerometerDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/9/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEAccelerometerDemoViewController.h"
#include "ServiceAndCharacteristicMacros.h"
#import "CBUUID+StringExtraction.h"
#import <dispatch/dispatch.h>
#import "BLEAcclerometerValue.h"
#import "BLEGraphView.h"


#define MAX_PLOT_ITEMS 100

// sample rate for acceleromter data, e.g 10 sample/second  
#define SAMPLE_CLOCK_FREQUENCY_HERTZ 10

@interface BLEAccelerometerDemoViewController ()

// control NSLogging
@property (nonatomic)BOOL debug;

// pointer to graph plot view
@property (strong, nonatomic) IBOutlet BLEGraphView *graphView;

// time which drives the sampling of accelerometer data
@property (nonatomic, strong) dispatch_source_t sampleClock;

// ensures that accelerometer data writes and reads are thread safe
@property (nonatomic,strong) dispatch_queue_t synchronizingQueue;

// holds accelerometer sampled data values
@property (nonatomic, strong) NSMutableArray *accelerationPlot;

// X axis accelerometer component read from device
@property (nonatomic, strong) NSNumber *accelerometerXNotification;

// Y axis accelerometer component read from device
@property (nonatomic, strong) NSNumber *accelerometerYNotification;

// Z axis accelerometer component read from device
@property (nonatomic, strong) NSNumber *accelerometerZNotification;
@end

@implementation BLEAccelerometerDemoViewController

@synthesize accelerationPlot = _accelerationPlot;


#pragma mark - Properties

// Getter - lazy instantiation and 0 value initialization
-(NSNumber *)accelerometerXNotification
{
    if (_accelerometerXNotification == nil)
    {
        _accelerometerXNotification = [NSNumber numberWithChar:0];
    }
    return _accelerometerXNotification;
}


// Getter - lazy instantiation and 0 value initialization
-(NSNumber *)accelerometerYNotification
{
    if (_accelerometerYNotification == nil)
    {
        _accelerometerYNotification = [NSNumber numberWithChar:0];
    }
    return _accelerometerYNotification;
}


// Getter - lazy instantiation and 0 value initialization
-(NSNumber *)accelerometerZNotification
{
    if (_accelerometerZNotification == nil)
    {
        _accelerometerZNotification = [NSNumber numberWithChar:0];
    }
    return _accelerometerZNotification;
}


// Create the synchronizing queue for reading and writing acceleometer values 
-(dispatch_queue_t) synchronizingQueue
{
    if (! _synchronizingQueue)
    {
        _synchronizingQueue = dispatch_queue_create("acceleration_queue", NULL);
    }
    return _synchronizingQueue;
}


/*
 *
 * Method Name:  sampleClock
 *
 * Description:  Provides sampling functionality of the accelerometer data received from the peripheral device. The sampling timer runs on the synchronizing queue. Accelerometer data obtained from the device is copied to a temporary location on the synchronizing queue as well which provides thread safe reading and writing of the device data. Accelerometer data is then moved into the plottng data structure and plotted using the main dispatch queue.
 *
 * Parameter(s): None
 *
 */
-(dispatch_source_t)sampleClock
{
    if (! _sampleClock)
    {
        _sampleClock = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, self.synchronizingQueue);
        
        dispatch_source_set_event_handler(_sampleClock, ^{
            
            dispatch_async(self.synchronizingQueue, ^{
                CGFloat x, y, z;
                
                // clip,scale and apply zero offest to uncalibrated accelerometer data
                x = (CGFloat)[[self.accelerometerXNotification copy] charValue];
                x = [self clipValue:x toCeiling:X_CALIBRATION_SCALE];
                x =  x/ X_CALIBRATION_SCALE + X_CALIBRATION_OFFSET;
                
                y = (CGFloat)[[self.accelerometerYNotification copy] charValue];
                y = [self clipValue:y toCeiling:Y_CALIBRATION_SCALE];
                y =  y/ Y_CALIBRATION_SCALE + Y_CALIBRATION_OFFSET;
                
                z = (CGFloat)[[self.accelerometerZNotification copy] charValue];
                z = [self clipValue:z toCeiling:Z_CALIBRATION_SCALE];
                z =  z/ Z_CALIBRATION_SCALE + Z_CALIBRATION_OFFSET;
                
                BLEAcclerometerValue *value = [[BLEAcclerometerValue alloc]
                                               initWithX:x withY:y withZ:z];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Add accelerometer reading to plot array, throwing out oldest data if necessary. The array provides a history of the accelerometer data for plotting. Default history length is 10 seconds when sampled at 10 hz.
                    if ([self.accelerationPlot count] ==  MAX_PLOT_ITEMS)
                    {
                        [self.accelerationPlot removeObjectAtIndex:0];
                    }
                    
                    [self.accelerationPlot addObject:value];
                    
                    // Plot the accelerometer data
                    self.graphView.accelerationData = self.accelerationPlot;
                    self.graphView.maxDataPoints = MAX_PLOT_ITEMS;
                    
                });
            });
        });
        
        dispatch_resume(_sampleClock);
    }
    return _sampleClock;
}


// Lazily initialize the array which holds sampled accelerometer data
-(NSMutableArray *)accelerationPlot
{
    if (_accelerationPlot == nil)
    {
        _accelerationPlot = [NSMutableArray arrayWithCapacity:MAX_PLOT_ITEMS];
    }
    return _accelerationPlot;
}


#pragma mark- Private Helper Methods


/*
 *
 * Method Name:  clipValue
 *
 * Description:  Clips accelerometer data values to max and min limits for plotting
 *
 * Parameter(s): value: accelerometer value
 *               limit: the clip ceiling
 *
 */
-(CGFloat) clipValue: (CGFloat)value toCeiling:(CGFloat) limit
{
    CGFloat clipped = value;
    if (clipped > limit) clipped = limit;
    if (clipped < -limit) clipped = -limit;
    
    return clipped;
}


/*
 *
 * Method Name:  discoverAccelerometerServiceCharacteristics
 *
 * Description:  Initiates and configures peripheral for discovering and reading acceleromter characteristics
 *
 * Parameter(s): None
 *
 */
-(void)discoverAccelerometerServiceCharacteristics
{
    if ([self.accelerometerService.peripheral isConnected])
    {
        // discover accelerometer service characteristics
        CBUUID *UUUID = [CBUUID UUIDWithString:TI_KEYFOB_ACCELEROMETER_SERVICE];
        NSArray *accelerometerServiceUUID = [NSArray arrayWithObject:UUUID];
        
        // self.peripheralStatusLabel.textColor = [UIColor greenColor];
        // self.peripheralStatusLabel.text = @"Discovering service characteristics.";
        // [self.statusActivityIndicator startAnimating];
        
        [self.accelerometerService.peripheral discoverCharacteristics:accelerometerServiceUUID
                                                           forService:self.accelerometerService];
    }
    else
    {
        if (self.debug) NSLog(@"Failed to discover characteristic, peripheral not connected.");
        // [self setConnectionStatus];
    }
    
}


/*
 *
 * Method Name:  enableAccelerometer
 *
 * Description:  Enables or disables accelerometer on the device according to enable parameter.
 *
 * Parameter(s): enable - YES enables accelerometer, NO disables acceleromter
 *
 */
-(void)enableAccelerometer : (BOOL) enable
{
    // get the characteristic out of the chracteristic array
    NSUInteger index = [self.accelerometerService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        CBCharacteristic *characteristic = (CBCharacteristic *)obj;
        
        // Get the enable/disable characteristic from the listof characteristics
        NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
        if ([uuidString localizedCompare:TI_ENABLE_ACCELEROMETER] == NSOrderedSame)
        {
            return YES;
        }
        return NO;
    }];
    
    // Either enable or disable accelerometer using the characteristic
    if (index != NSNotFound)
    {
        CBCharacteristic *enableAccelerometer = self.accelerometerService.characteristics[index];
        
        char value = enable ? 1 : 0;
        NSData *data = [NSData dataWithBytes:&value length:1 ];
        
        
        [self.accelerometerService.peripheral writeValue:data forCharacteristic:enableAccelerometer type:CBCharacteristicWriteWithoutResponse];
    };
}



/*
 *
 * Method Name:  enableNotifications
 *
 * Description:  Suscribes for accelerometer notifications which occur when the device updates accelerometer readings
 *
 * Parameter(s): enable  YES-enables notifications, NO- disables notifications
 *
 */
-(void)enableNotifications : (BOOL) enable
{
    // just iterate over the short characteristic array and process the desired characteristics
    BOOL processedX = NO;
    BOOL processedY = NO;
    BOOL processedZ = NO;
    
    for (CBCharacteristic * characteristic in self.accelerometerService.characteristics)
    {
        NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
        if ([uuidString localizedCompare:TI_ACCELEROMETER_X_VALUE] == NSOrderedSame)
        {
            
            [self.accelerometerService.peripheral setNotifyValue:enable forCharacteristic:characteristic];
            processedX = YES;
        }
        else if ([uuidString localizedCompare:TI_ACCELEROMETER_Y_VALUE] == NSOrderedSame)
        {
            [self.accelerometerService.peripheral setNotifyValue:enable forCharacteristic:characteristic];
            processedY = YES;
            
        }
        else if ([uuidString localizedCompare:TI_ACCELEROMETER_Z_VALUE] == NSOrderedSame)
        {
            [self.accelerometerService.peripheral setNotifyValue:enable forCharacteristic:characteristic];
            processedZ = YES;
            
        }
        
        // stop looking for enable characteristics after all three accleration components have been set
        if (processedX && processedY && processedZ) break;
    }
}


/*
 *
 * Method Name:  enableAccelerometerAndSubscribeForAccelerationNotifications
 *
 * Description:  Performs two principal functions, namely enabling the acceleromter (turning it on) and additionally subscribes for notifications notifying the controller when accelerometer data has changed. If the chracteristics have not been read, they are first discovered and the peripheral delegate function didDiscoverCharacteristicsForService then issues commands to turn on the accelerometer and subscribes the controller for notifications.
 *
 * Parameter(s): None
 *
 */
-(void)enableAccelerometerAndSubscribeForAccelerationNotifications
{
    if (! self.accelerometerService.characteristics)
    {
        // read the chracteristics - the delegate method didDiscoverCharacteristicsForService will then issue the enableAcccelerometer and notification commands.
        [self discoverAccelerometerServiceCharacteristics];
    }
    else
    {
        // turn on accelerometer
        [self enableAccelerometer: YES];
        
        // ask for accelerometer data notifications
        [self enableNotifications:YES];
    }
}



#pragma mark- View Controller Lifecycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


/*
 *
 * Method Name:  viewDidLoad
 *
 * Description:  Set up the view before it coes on screen by configuring the sampling timer and reading the acceleromter characteristics. Once the characteristics are read, enable the acceleromter and subscribe for notifications when accelerometer data changes on the device.
 *
 * Parameter(s): None
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
     self.accelerometerService.peripheral.delegate = self;
    
    _debug = YES;
    
    if (self.debug) NSLog(@"Entering Acclerometer Demo viewDidLoad");
    
    dispatch_source_set_timer(self.sampleClock, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC / SAMPLE_CLOCK_FREQUENCY_HERTZ, 1ull * NSEC_PER_SEC/100);
  

    // Check to see if the characteristics for the accelerometer service have been discovered
    if ( self.accelerometerService )
    {
        // Turn the accelerometer on and subscribe for notifications
        // Use the peripheral delegate to chain functionality if characteristics have not been discovered, and to enable and subscribe as needed
        // discover the characteristics
        [self enableAccelerometerAndSubscribeForAccelerationNotifications];
    }
   
}



/*
 *
 * Method Name:  viewWillDisappear
 *
 * Description:  Stop processing accelerometer data when view is not visible. Stop the sampling timer, disable the accelerometer on the device and unsubscribe from notifications.
 *
 * Parameter(s): animated is the UIKit view parameter passed up to parent view.
 *
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_source_cancel(self.sampleClock);
    self.sampleClock = nil;
    
      
    [self enableAccelerometer:NO];
    [self enableNotifications:NO];
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateNotificationStateForCharacteristic invoked");
}



/*
 *
 * Method Name:  didUpdateValueForCharacteristic
 *
 * Description:  Handles arrival of new acceleromter data from device.
 *
 * Parameter(s): peripheral- peripheral that sent the data
 *               characteristic - chracreristic containing data corresponding to x,y, or z axial accelerometer
 *               error - any error encountered when reading data
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (!error)
    {
        char value;
        
      //  if (self.debug) NSLog(@"Characteristic value  updated.");
        // determine which characteristic
        NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
        
        [characteristic.value getBytes:&value length:1];
        
        if ([uuidString localizedCompare:TI_ACCELEROMETER_X_VALUE] == NSOrderedSame)
        {
             dispatch_async(self.synchronizingQueue, ^{
            self.accelerometerXNotification = [NSNumber numberWithChar:value];
             });
        }
        else if ([uuidString localizedCompare:TI_ACCELEROMETER_Y_VALUE] == NSOrderedSame)
        {
            dispatch_async(self.synchronizingQueue, ^{
            self.accelerometerYNotification = [NSNumber numberWithChar:value];
            });
        
        }
        else if ([uuidString localizedCompare:TI_ACCELEROMETER_Z_VALUE] == NSOrderedSame)
        {
            dispatch_async(self.synchronizingQueue, ^{
            self.accelerometerZNotification = [NSNumber numberWithChar:value];
            });
        }
    }
    else
    {
        NSLog(@"Error occurred reading characteristic: %@",error.description);
    }
}


/*
 *
 * Method Name:  peripheral:didDiscoverCharacteristicsForService:error
 *
 * Description:  CBPeripheralDelegate method invoked when chracteristic is discovered or error occurs when reading characteristic.
 *
 * Parameter(s): See CBPeripheralDelegate documentation.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverCharacteristicsForService invoked");
    
    // turn on accelerometer
    [self enableAccelerometer: YES];
    
    // ask for accelerometer data notifications
    [self enableNotifications:YES];
}


@end
