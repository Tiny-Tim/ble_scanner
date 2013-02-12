//
//  BLEHeartRateDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/11/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEHeartRateDemoViewController.h"
#import "CBUUID+StringExtraction.h"
#include "ServiceAndCharacteristicMacros.h"

@interface BLEHeartRateDemoViewController ()

// NSLogging control
@property (nonatomic) BOOL debug;

// ImageView for heart beat animation
@property (weak, nonatomic) IBOutlet UIImageView *heartBeatImage;

// Label which displays peripheral status and activity.
@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

// Spinner activity indicator which is active when device is being accessed.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *peripheralStatusSpinner;

// Displays the numeric heart rate value in beats per minute
@property (weak, nonatomic) IBOutlet UILabel *heartRateMeasureLabel;

// Last measurement received from device
@property (nonatomic)NSUInteger lastMeasurement;

// state variable which indicates whether heart beat animation is active
@property (nonatomic)BOOL animationStarted;

// holds the heart beat animation image frames
@property (nonatomic, strong) NSArray *heartBeatAnimationFrames;


@property (weak, nonatomic) IBOutlet UILabel *energyExpendedLabel;

@property (weak, nonatomic) IBOutlet UILabel *sensorContactStatusLabel;

@property (nonatomic) BOOL sensorContactStatusAvailable;

@property (nonatomic) BOOL sensorContactState;

@end

@implementation BLEHeartRateDemoViewController

@synthesize sensorContactState = _sensorContactState;
@synthesize sensorContactStatusAvailable = _sensorContactStatusAvailable;


#pragma mark- Properties


-(void)setSensorContactStatusAvailable:(BOOL)sensorContactStatus
{
    _sensorContactStatusAvailable = sensorContactStatus;
    if (! _sensorContactStatusAvailable)
    {
        self.sensorContactStatusLabel.text = @"Sensor Contact Status: Unavailable";
    }
}

-(void)setSensorContactState:(BOOL)sensorContact
{
    if (_sensorContactState != sensorContact)
    {
        _sensorContactState = sensorContact;
        
        if (self.sensorContactStatusAvailable)
        {
            if (_sensorContactState)
            {
               self.sensorContactStatusLabel.text = @"Sensor Contact Status: Good";
            }
            else
            {
                self.sensorContactStatusLabel.text = @"Sensor Contact Status: Poor/No Contact";
            }
        }
    }
}


/*
 *
 * Method Name:  setLastMeasurement
 *
 * Description:  Setter for lastMeasurement which also updates UI when changed
 *
 * Parameter(s): lastMeasurement - new value for property
 *
 */
-(void)setLastMeasurement:(NSUInteger)lastMeasure
{
    if (_lastMeasurement != lastMeasure)
    {
        _lastMeasurement = lastMeasure;
        
        //Update UI 
        self.heartRateMeasureLabel.text = [NSString stringWithFormat:@"Heart Rate:  %i",lastMeasure];
        
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // initialize debug,animation, and last read measurement state variables
    self.debug = YES;
    
    self.animationStarted = NO;
    
    self.lastMeasurement = 0;
    
    // clear the UI measurement label
    self.heartRateMeasureLabel.text = @"";
     
    // clear the sensor contact label
    self.sensorContactStatusLabel.text = @"";
    
    // set the peripheral delegate to self
    self.heartRateService.peripheral.delegate =self;
    
    // set up the animation image data
    [self setupHeartBeatAnimation];
    
    // display the peripheral connection status
    [self setConnectionStatus];
    
    // subscribe for notifications to changes of heart rate
    [self enableForHeartRateMeasurementNotifications: YES];
    
    
}


/*
 *
 * Method Name:  viewWillDisappear
 *
 * Description:  Ensure view controller is not being updated when not in view.
 *
 * Parameter(s): animated - system parameter controlling view transition
 *
 */
-(void) viewWillDisappear:(BOOL)animated
{
    self.heartRateService.peripheral.delegate = nil;
    
    [self stopHeartBeatAnimation];
    
    [self enableForHeartRateMeasurementNotifications: NO];
    
    [super viewWillDisappear:animated];
    
}


// template code
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark- Private Methods

/*
 *
 * Method Name:  setConnectionStatus
 *
 * Description:  Sets the connection status label to indicate peripheral connect status.
 *
 * Parameter(s): None
 *
 */
-(void)setConnectionStatus
{
    if ([self.heartRateService.peripheral isConnected])
    {
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Connected";
    }
    else
    {
        self.peripheralStatusLabel.textColor = [UIColor redColor];
        self.peripheralStatusLabel.text = @"Unconnected";
    }
}


-(void)discoverHeartRateMeasurementServiceCharacteristic
{
    if ([self.heartRateService.peripheral isConnected])
    {
        // discover keyPressed service characteristic
        CBUUID *UUUID = [CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC];
        NSArray *heartRateServiceUUID = [NSArray arrayWithObject:UUUID];
        
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Discovering service characteristics.";
        [self.peripheralStatusSpinner startAnimating];
        
        [self.heartRateService.peripheral discoverCharacteristics:heartRateServiceUUID
                                                        forService:self.heartRateService];
    }
    else
    {
        if (self.debug) NSLog(@"Failed to discover characteristic, peripheral not connected.");
        [self setConnectionStatus];
    }
    
}



-(void)enableForHeartRateMeasurementNotifications : (BOOL) enable
{
    // Check to see if peripheral has retrieved characteristics
    if (self.heartRateService.characteristics)
    {
        NSUInteger index = [self.heartRateService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            CBCharacteristic *characteristic = (CBCharacteristic *)obj;
            
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            if ([uuidString localizedCompare:HEART_RATE_MEASUREMENT_CHARACTERISTIC] == NSOrderedSame)
            {
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound)
        {
            [self discoverHeartRateMeasurementServiceCharacteristic];
        }
        else
        {
            if ([self.heartRateService.peripheral isConnected])
            {
                // sign up for notifications
                [self.heartRateService.peripheral setNotifyValue:enable forCharacteristic:self.heartRateService.characteristics[index]];
                
            }
        }
    }
    else
    {
        [self discoverHeartRateMeasurementServiceCharacteristic];
    }
}



-(void)startHeartBeatAnimation
{
    self.heartBeatImage.animationImages = self.heartBeatAnimationFrames;
    self.heartBeatImage.animationDuration = 0.6;
    [self.heartBeatImage startAnimating];
    self.animationStarted = YES;
}


-(void)stopHeartBeatAnimation
{
    [self.heartBeatImage stopAnimating];
    self.heartBeatImage.animationImages = nil;
    self.animationStarted = NO;
    
    // display a non-moving heart image until device begins sending measurements
    self.heartBeatImage.image = self.heartBeatAnimationFrames[0];
}

-(void)setupHeartBeatAnimation
{
    int numberOfFrames = 10;
    NSMutableArray *imagesArray = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    for (int i=0; i<numberOfFrames; i++)
    {
        int imageIndex = i+1;
        [imagesArray addObject:[UIImage imageNamed:
                                [NSString stringWithFormat:@"heartbeat-%d (dragged).tiff", imageIndex]]];
        
    }
    
    self.heartBeatAnimationFrames = [imagesArray copy];
    
    // display a non-moving heart image until device begins sending measurements
    self.heartBeatImage.image = self.heartBeatAnimationFrames[0];
    
}



/*
 *
 * Method Name:  processHeartRateMeasurement
 *
 * Description:  Processes the heart rate measurement received from the device. Animations are started if needed and the heart rate measurement may be further processed if needed by the application.
 *
 * Parameter(s): beatsPerMinute - the heart rate measurement in beats per minute
 *
 */
-(void)processHeartRateMeasurement: (NSUInteger) beatsPerMinute
{
    // start heart beat animation if idle
    if (! self.animationStarted)
    {
        [self startHeartBeatAnimation];
    }
    
    // Updating this property will also update the UI if needed
    self.lastMeasurement = beatsPerMinute;
    
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
 * Description:  The usual characteristic reading functionality associated with this CBPeripheralDelegate method. Identifies which characteristic is being updated and then handles processing the data.
 *
 * Parameter(s): peripheral - the peripheral sending the data
 *               characteristic - the chracteristic being updated
 *               error - any error generated during the updating of the characteristic
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        if (self.debug) NSLog(@"Characteristic value  updated.");
        
        // Determine which characteristic was updated
        /* Updated value for heart rate measurement received */
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC]])
        {
            const uint8_t *reportData = [characteristic.value bytes];
            NSUInteger bpm = 0;
            
            NSUInteger flag = reportData[0];
            NSLog(@"flag = %i",flag);
            
            // least sig bit of first byte encodes whether measurement is 1 or 2 bytes
            if ((reportData[0] & 0x01) == 0)
            {
                /* uint8 bpm */
                bpm = reportData[1];
            }
            else
            {
                /* uint16 bpm */
                bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
            }
            if (self.debug) NSLog(@"Heart Rate Measurement Rcvd: %i",bpm);
            [self processHeartRateMeasurement:bpm];
            
            // Determine if sensor contact information is available
            if ( (reportData[0] & 0x04) != 0)
            {
                self.sensorContactStatusAvailable = YES;
                // contact info is available, retrieve it
                self.sensorContactState = ( (reportData[0] & 0x02) != 0);
                
            }
            else
            {
                self.sensorContactStatusAvailable = NO;
            }
        }
    }
    else
    {
        NSLog(@"Error reading characteristic: %@", error.description);
    };
    
    [self setConnectionStatus];
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
    
    [self.peripheralStatusSpinner stopAnimating];
    [self setConnectionStatus];
    
    if (error == nil)
    {
        if (self.debug) NSLog(@"Subscribing to key pressed notifications");
        [self enableForHeartRateMeasurementNotifications: YES];
    }
}


@end
