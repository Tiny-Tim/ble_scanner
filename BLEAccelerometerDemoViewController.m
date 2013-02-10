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

#define MAX_PLOT_ITEMS 5

// sample rate, e.g 1 sample/second  (.1 hz --> 10 seconds between samples)
#define SAMPLE_CLOCK_FREQUENCY_HERTZ 1

@interface BLEAccelerometerDemoViewController ()
@property (nonatomic)BOOL debug;

@property (nonatomic, strong) dispatch_source_t sampleClock;

@property (nonatomic,strong) dispatch_queue_t synchronizingQueue;

@property (nonatomic, strong) NSMutableArray *accelerationPlotX;
@property (nonatomic, strong) NSMutableArray *accelerationPlotY;
@property (nonatomic, strong) NSMutableArray *accelerationPlotZ;

@property (nonatomic, strong) NSNumber *accelerometerXNotification;

@property (nonatomic, strong) NSNumber *accelerometerYNotification;

@property (nonatomic, strong) NSNumber *accelerometerZNotification;
@end

@implementation BLEAccelerometerDemoViewController

@synthesize accelerationPlotX = _accelerationPlotX;


-(NSNumber *)accelerometerXNotification
{
    if (_accelerometerXNotification == nil)
    {
        _accelerometerXNotification = [NSNumber numberWithChar:0];
    }
    
    return _accelerometerXNotification;
}


-(NSNumber *)accelerometerYNotification
{
    if (_accelerometerYNotification == nil)
    {
        _accelerometerYNotification = [NSNumber numberWithChar:0];
    }
    
    return _accelerometerYNotification;
}

-(NSNumber *)accelerometerZNotification
{
    if (_accelerometerZNotification == nil)
    {
        _accelerometerZNotification = [NSNumber numberWithChar:0];
    }
    
    return _accelerometerZNotification;
}

-(dispatch_queue_t) synchronizingQueue
{
    if (! _synchronizingQueue)
    {
        _synchronizingQueue = dispatch_queue_create("acceleration_queue", NULL);
        
    }
    
    return _synchronizingQueue;
}

-(dispatch_source_t)sampleClock
{
    if (! _sampleClock)
    {
        _sampleClock = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, self.synchronizingQueue);
       

        dispatch_source_set_event_handler(_sampleClock, ^{
            
            dispatch_async(self.synchronizingQueue, ^{
                
                // copy the accleration data into the plotting data structure
                NSNumber *latestXValue = [self.accelerometerXNotification copy];
                NSNumber *latestYValue = [self.accelerometerYNotification copy];
                NSNumber *latestZValue = [self.accelerometerZNotification copy];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([self.accelerationPlotX count] <  MAX_PLOT_ITEMS)
                    {
                        [self.accelerationPlotX addObject:latestXValue];
                    }
                    else
                    {
                        [self.accelerationPlotX removeObjectAtIndex:0];
                        [self.accelerationPlotX addObject:latestXValue];
                    }
                    
                    if ([self.accelerationPlotY count] <  MAX_PLOT_ITEMS)
                    {
                        [self.accelerationPlotY addObject:latestYValue];
                    }
                    else
                    {
                        [self.accelerationPlotY removeObjectAtIndex:0];
                        [self.accelerationPlotY addObject:latestYValue];
                    }
                    
                    if ([self.accelerationPlotZ count] <  MAX_PLOT_ITEMS)
                    {
                        [self.accelerationPlotZ addObject:latestZValue];
                    }
                    else
                    {
                        [self.accelerationPlotZ removeObjectAtIndex:0];
                        [self.accelerationPlotZ addObject:latestZValue];
                    }
                    
                    
                    // Update the plot
                    NSUInteger maxIndex = MIN([self.accelerationPlotX count], [self.accelerationPlotY count]);
                    maxIndex = MIN(maxIndex, [self.accelerationPlotZ count]);
                    for (NSUInteger index =0; index < maxIndex; index++)
                    {
                        NSLog(@"Acc Values: %i   %i  %i",
                              [self.accelerationPlotX[index] charValue],
                              [self.accelerationPlotY[index] charValue],
                              [self.accelerationPlotZ[index] charValue]);
                    }
                    
                });
                
            });
        });
        
        dispatch_resume(_sampleClock);
        
    }
    
    return _sampleClock;
}


-(NSMutableArray *)accelerationPlotX
{
    if (_accelerationPlotX == nil)
    {
        _accelerationPlotX = [NSMutableArray arrayWithCapacity:MAX_PLOT_ITEMS];
    }
    return _accelerationPlotX;
}

-(NSMutableArray *)accelerationPlotY
{
    if (_accelerationPlotY == nil)
    {
        _accelerationPlotY = [NSMutableArray arrayWithCapacity:MAX_PLOT_ITEMS];
    }
    return _accelerationPlotY;
}


-(NSMutableArray *)accelerationPlotZ
{
    if (_accelerationPlotZ == nil)
    {
        _accelerationPlotZ = [NSMutableArray arrayWithCapacity:MAX_PLOT_ITEMS];
    }
    return _accelerationPlotZ;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}



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

-(void)enableAccelerometer : (BOOL) enable
{
    // get the characteristic out of the chracteristic array
    NSUInteger index = [self.accelerometerService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        CBCharacteristic *characteristic = (CBCharacteristic *)obj;
        
        NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
        if ([uuidString localizedCompare:TI_ENABLE_ACCELEROMETER] == NSOrderedSame)
        {
            return YES;
        }
        return NO;
    }];
    
    if (index != NSNotFound)
    {
        CBCharacteristic *enableAccelerometer = self.accelerometerService.characteristics[index];
        
        char value = enable ? 1 : 0;
        NSData *data = [NSData dataWithBytes:&value length:1 ];
        
        
        [self.accelerometerService.peripheral writeValue:data forCharacteristic:enableAccelerometer type:CBCharacteristicWriteWithoutResponse];
    };
}


-(void)enableNotifications : (BOOL) enable
{
    // just iterate over the short characteristic arrray and process the desired characteristics
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
        
        if (processedX && processedY && processedZ) break;
            
    }
    
}


-(void)subscribeForAccelerationNotifications
{
    if (! self.accelerometerService.characteristics)
    {
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
        [self subscribeForAccelerationNotifications];
    }
   
}




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
           // NSLog(@"X axis: %i",value);
        }
        else if ([uuidString localizedCompare:TI_ACCELEROMETER_Y_VALUE] == NSOrderedSame)
        {
            dispatch_async(self.synchronizingQueue, ^{
            self.accelerometerYNotification = [NSNumber numberWithChar:value];
            });
          //   NSLog(@"Y axis: %i",value);
        }
        else if ([uuidString localizedCompare:TI_ACCELEROMETER_Z_VALUE] == NSOrderedSame)
        {
            dispatch_async(self.synchronizingQueue, ^{
            self.accelerometerZNotification = [NSNumber numberWithChar:value];
            });
         //   NSLog(@"Z axis: %i",value);
            
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
