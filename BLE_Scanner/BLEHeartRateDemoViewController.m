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

#define MEASUREMENT_IS_TWO_BYTES 1
#define CONTACT_SUPPORTED 2
#define CONTACT_SUPPORTED_NOT_DETECTED 2
#define CONTACT_SUPPORTED_DETECTED 6
#define ENERGY_EXPENDED_PRESENT 8
#define RR_INTERVAL_PRESENT 16

@interface BLEHeartRateDemoViewController ()

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

// label for reporting expended energy level
@property (weak, nonatomic) IBOutlet UILabel *energyExpendedLabel;

// label for reporting sensor contact status
@property (weak, nonatomic) IBOutlet UILabel *sensorContactStatusLabel;

// state variable indicating whether device reports sensor contact status
@property (nonatomic) BOOL sensorContactStatusAvailable;

//current value of sensor contact state 
@property (nonatomic) BOOL sensorContactState;

// state variable indicating whether expended energy has ever been reported
@property (nonatomic) BOOL energyExpendedStatusAvailable;

// expended energy level in Joules
@property (nonatomic) NSUInteger energyExpended;

@property (weak, nonatomic) IBOutlet UILabel *bodySensorLocationLabel;


// Displays the number of heart rate updates
@property (weak, nonatomic) IBOutlet UILabel *updateCountLabel;

@property (nonatomic, readwrite) NSUInteger updateCount;

@end

@implementation BLEHeartRateDemoViewController

@synthesize sensorContactState = _sensorContactState;
@synthesize sensorContactStatusAvailable = _sensorContactStatusAvailable;
@synthesize energyExpendedStatusAvailable = _energyExpendedStatusAvailable;
@synthesize energyExpended = _energyExpended;


#pragma mark- Actions

#define CONNECT_STRING     @"Connect"
#define DISCONNECT_STRING  @"Disconnect"




#pragma mark- Properties


/*
 *
 * Method Name:  setEnergyExpendedStatusAvailable
 *
 * Description:  Setter for corresponding property which also updates UI when not available.
 *
 * Parameter(s): energyExpendedStatus - status reported by device
 *
 */
-(void)setEnergyExpendedStatusAvailable:(BOOL)energyExpendedStatus
{
    _energyExpendedStatusAvailable = energyExpendedStatus;
    if (! _energyExpendedStatusAvailable)
    {
        self.energyExpendedLabel.text = @"Energy expended data not available.";
    }
}


/*
 *
 * Method Name:  setEnergyExpended
 *
 * Description:  Setter for the energy expended data value. Updates the UI when data changes.
 *
 * Parameter(s): energyExpended - energy expended in Joules as reported by device
 *
 */
-(void)setEnergyExpended:(NSUInteger)energyExpended
{
    if (_energyExpended != energyExpended)
    {
        _energyExpended = energyExpended;
        
        if (self.energyExpendedStatusAvailable)
        {
            self.energyExpendedLabel.text = [NSString stringWithFormat:@"Energy expended (Joules):  %i",_energyExpended];
        }
    }
}


/*
 *
 * Method Name:  setSensorContactStatusAvailable
 *
 * Description:  Setter for contact status property.
 *
 * Parameter(s): sensorContactStatus - status as reported by device
 *
 */
-(void)setSensorContactStatusAvailable:(BOOL)sensorContactStatus
{
    _sensorContactStatusAvailable = sensorContactStatus;
    if (! _sensorContactStatusAvailable)
    {
        self.sensorContactStatusLabel.text = @"Sensor Contact Status: Unavailable";
        
    }
}


/*
 *
 * Method Name:  setSensorContactState
 *
 * Description:  Setter for contact state property.
 *
 * Parameter(s): sensorContact - sensor contact state as reported by device.
 *
 */
-(void)setSensorContactState:(BOOL)sensorContact
{
    
    _sensorContactState = sensorContact;
    
    if (_sensorContactState)
    {
        self.sensorContactStatusLabel.text = @"Sensor Contact Status: Good";
    }
    else
    {
        self.sensorContactStatusLabel.text = @"Sensor Contact Status: Poor/No Contact";
    }
    
    
}



/*
 *
 * Method Name:  setLastMeasurement
 *
 * Description:  Setter for lastMeasurement which also updates UI 
 * Parameter(s): lastMeasurement - new value for property
 *
 */
-(void)setLastMeasurement:(NSUInteger)lastMeasure
{
    
    _lastMeasurement = lastMeasure;
        
    //Update UI 
    self.heartRateMeasureLabel.text = [NSString stringWithFormat:@"Heart Rate:  %i",lastMeasure];
        
    
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
 * Description:  Perform initilizations for view controller.
 *
 * Parameter(s): None
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.statusLabel = self.peripheralStatusLabel;
    self.statusSpinner = self.peripheralStatusSpinner;
    
    // set the peripheral delegate to self
    self.heartRateService.peripheral.delegate =self;
    
    // initialize debug,animation, and last read measurement state variables
    self.animationStarted = NO;
    
    // clear the UI measurement label
    self.heartRateMeasureLabel.text = @"";
     
    // clear the sensor contact label
    self.sensorContactStatusLabel.text = @"";
    
    self.bodySensorLocationLabel.text = @"";
    
    self.energyExpendedStatusAvailable = NO;

    self.updateCount = 0;
    self.updateCountLabel.text = [NSString stringWithFormat:@"Heart Rate Updates: %u",self.updateCount];
    // set up the animation image data
    [self setupHeartBeatAnimation];
    
    // display the peripheral connection status
    [self displayPeripheralConnectStatus:self.heartRateService.peripheral];

    
    
    // It is unknown whether all of the chracteristics for the service have been discovered or only a subset at this point depending upon the entries in service.characteristics.
    // We'll look for the services we need and if any are missing then (re)discover all of them
    BOOL foundHeartRateMeasurement = NO;
    BOOL foundBodySensor = NO;
    for (CBCharacteristic *characteristic in self.heartRateService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC]])
        {
            foundHeartRateMeasurement = YES;
            
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BODY_SENSOR_LOCATION_CHARACTERISTIC ]])
        {
            foundBodySensor = YES;
        }
        
        if ( foundHeartRateMeasurement  &&  foundBodySensor)
        {
            break;
        }
    }
    if ( ! ( foundHeartRateMeasurement  &&  foundBodySensor))
    {
        // (re)discover characteristics for the service and drive the workflow from the peripheral delegate didDiscoverCharacteristicsForServiceMethod
        [self discoverHeartRateMeasurementServiceCharacteristics];
    }
    else
    {
        [self enableForHeartRateMeasurementNotifications: YES];
        [self readCharacteristic:BODY_SENSOR_LOCATION_CHARACTERISTIC forService:self.heartRateService];
    }
    
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



#pragma mark- Private Methods


// Description:  Sets the connection status label to indicate peripheral connect status.
-(void)displayPeripheralConnectStatus : (CBPeripheral *)peripheral
{
    [super displayPeripheralConnectStatus:peripheral];
    
    
}



/*
 *
 * Method Name:  discoverHeartRateMeasurementServiceCharacteristics
 *
 * Description:  Discover, or re-discover all of the heart rate service characteristics.
 *
 * Parameter(s): 
 *
 */
-(void)discoverHeartRateMeasurementServiceCharacteristics 
{
    if ([self.heartRateService.peripheral isConnected])
    {
        
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Discovering service characteristics.";
        [self.peripheralStatusSpinner startAnimating];
        
        [self.heartRateService.peripheral discoverCharacteristics:nil
                                                        forService:self.heartRateService];
    }
    else
    {
        DLog(@"Failed to discover characteristic, peripheral not connected.");
        [self displayPeripheralConnectStatus:self.heartRateService.peripheral];

    }
}


/*
 *
 * Method Name:  enableForHeartRateMeasurementNotifications
 *
 * Description:  Enables or disables notification of heart rate measurements.
 *
 * Parameter(s): enable- boolean where Yes enables notifications and NO disables notifications
 *
 */
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
             DLog(@"Error State: Expected Heart Rate Measurement Characteristic Not Available.");
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
        DLog(@"Error State: Expected Heart Rate Measurement Characteristic Not Available.");
    }
}

// start the animation of the heart beat image
-(void)startHeartBeatAnimation
{
    self.heartBeatImage.animationImages = self.heartBeatAnimationFrames;
    self.heartBeatImage.animationDuration = 0.6;
    [self.heartBeatImage startAnimating];
    self.animationStarted = YES;
}

//stop the animation of the heart beat
-(void)stopHeartBeatAnimation
{
    [self.heartBeatImage stopAnimating];
    self.heartBeatImage.animationImages = nil;
    self.animationStarted = NO;
    
    // display a non-moving heart image until device begins sending measurements
    self.heartBeatImage.image = self.heartBeatAnimationFrames[0];
}

/*
 *
 * Method Name:  setupHeartBeatAnimation
 *
 * Description:  Sets up the image array containing the image frames used for animating the heart beat animation. Sets the initial image in the iage view to the first frame but does not start animation. Animation begins when a heart rate measurement is returned by the device.
 *
 * Parameter(s): None
 *
 */
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
    
    self.updateCount += 1;
    self.updateCountLabel.text = [NSString stringWithFormat:@"Heart Rate Updates:  %u",self.updateCount];
}


/*
 *
 * Method Name:  processExpendedEnergyData
 *
 * Description:  Processes the expended energy data value returned from the device.
 *
 * Parameter(s): reportData - raw data read from the characteristic
 *
 */
-(void)processExpendedEnergyData :(const uint8_t *)reportData
{
    // Check to see if expended energy is being reported. It is reported periodically.
    if ( (reportData[0] & ENERGY_EXPENDED_PRESENT) != 0)
    {
        self.energyExpendedStatusAvailable = YES;
        // read the expended energy data
        self.energyExpended = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[2]));
    }

    
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didUpdateNotificationStateForCharacteristic invoked");
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
    
    [self.peripheralStatusSpinner stopAnimating];
    [self displayPeripheralConnectStatus:self.heartRateService.peripheral];

    
    if (!error)
    {
        DLog(@"Characteristic value  updated.");
        
        // Determine which characteristic was updated
        /* Updated value for heart rate measurement received */
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC]])
        {
            const uint8_t *reportData = [characteristic.value bytes];
            NSUInteger bpm = 0;
            
            NSUInteger flag = reportData[0];
            DLog(@"flag = %i",flag);
            
            // least sig bit of first byte encodes whether measurement is 1 or 2 bytes
            if ((reportData[0] & MEASUREMENT_IS_TWO_BYTES))
            {
                /* uint16 bpm */
                bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
                
            }
            else
            {
                /* uint8 bpm */
                bpm = reportData[1];
            }
            
            DLog(@"Heart Rate Measurement Rcvd: %i",bpm);
            [self processHeartRateMeasurement:bpm];
            
            // Determine if sensor contact information is available
            if ( (reportData[0] & CONTACT_SUPPORTED) )
            {
                self.sensorContactStatusAvailable = YES;
                // contact info is available, retrieve it
                if ( (reportData[0] & CONTACT_SUPPORTED_DETECTED) == CONTACT_SUPPORTED_DETECTED)
                {
                    self.sensorContactState = YES;
                }
                else
                {
                    self.sensorContactState = NO;
                }
            }
            else
            {
                self.sensorContactStatusAvailable = NO;
            }
            
            [self processExpendedEnergyData:reportData];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BODY_SENSOR_LOCATION_CHARACTERISTIC ]])
        {
            NSData * updatedValue = characteristic.value;
            uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
            if(dataPointer)
            {
                uint8_t location = dataPointer[0];
                NSString*  locationString;
                switch (location)
                {
                    case 0:
                        locationString = @"Other";
                        break;
                    case 1:
                        locationString = @"Chest";
                        break;
                    case 2:
                        locationString = @"Wrist";
                        break;
                    case 3:
                        locationString = @"Finger";
                        break;
                    case 4:
                        locationString = @"Hand";
                        break;
                    case 5:
                        locationString = @"Ear Lobe";
                        break;
                    case 6:
                        locationString = @"Foot";
                        break;
                    default:
                        locationString = @"Reserved";
                        break;
                }
                DLog(@"Body Sensor Location = %@ (%d)", locationString, location);
                self.bodySensorLocationLabel.text = [NSString stringWithFormat:@"Body Sensor Location = %@",locationString];
            }

        }
    }
    else
    {
        DLog(@"Error reading characteristic: %@", error.description);
    };
    
    [self displayPeripheralConnectStatus:self.heartRateService.peripheral];

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
    DLog(@"didDiscoverCharacteristicsForService invoked");
    
    [self.peripheralStatusSpinner stopAnimating];
    [self displayPeripheralConnectStatus:self.heartRateService.peripheral];

    
    if (error == nil)
    {
        // iterate through the characteristics and take approproate actions
        for (CBCharacteristic *characteristic in service.characteristics )
        {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC]])
            {
                DLog(@"Subscribing to heart rate measurement notifications");
                [self enableForHeartRateMeasurementNotifications: YES];

            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BODY_SENSOR_LOCATION_CHARACTERISTIC ]])
            {
                // read the body sensor location
                DLog(@"Reading Body Sensor Location");
                [self readCharacteristic:BODY_SENSOR_LOCATION_CHARACTERISTIC forService:self.heartRateService];
            }
        }
        
    }
    else
    {
        DLog(@"Error encountered reading characterstics for heart rate service %@",error.description);
    }
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    DLog(@"Central unsubscribed from characteristic");
}


-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    DLog(@"Peripheral Did Invalidate Services invoked.");
    
    //stop the animation
    [self stopHeartBeatAnimation];
    // display the peripheral connection status
    [self displayPeripheralConnectStatus:self.heartRateService.peripheral];
}

@end
