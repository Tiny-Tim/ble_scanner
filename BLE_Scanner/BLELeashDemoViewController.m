//
//  BLELeashDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/13/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLELeashDemoViewController.h"
#include "ServiceAndCharacteristicMacros.h"
#import "CBUUID+StringExtraction.h"


#define PROXIMITY_THRESHOLD_ON 70
#define PROXIMITY_THRESHOLD_OFF 60

@interface BLELeashDemoViewController ()

// displays TX Power read from device
@property (weak, nonatomic) IBOutlet UILabel *transmitPowerLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentAlertLevelLabel;

@property (nonatomic, readwrite)BOOL transmitPowerAvailable;

// displays RSSI 
@property (weak, nonatomic) IBOutlet UILabel *rssiPowerLabel;

// displays computed path loss
@property (weak, nonatomic) IBOutlet UILabel *pathLossLabel;

// Drives the sampling of RSSI values 
@property (nonatomic, strong) dispatch_source_t rssiUpdateClock;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

// integer value of TXPower
@property (nonatomic) NSInteger transmitPower;

// RSSI samples which are smoothed (averaged) to help with spiked readings
@property (nonatomic, strong) NSMutableArray *filterRSSI;

// State variable indicating that immediate alarm has been discovered 
@property (nonatomic, readwrite) BOOL alarmCharacteristicDiscovered;

@property (nonatomic, readwrite)NSUInteger currentAlert;
@end

@implementation BLELeashDemoViewController

#pragma mark- Properties

-(void)setCurrentAlert:(NSUInteger)currentAlertValue
{
    _currentAlert = currentAlertValue;
    
    if (_currentAlert == LOW_ALERT_VALUE)
    {
        self.currentAlertLevelLabel.text = @"Current Alert Tone= Low";
    }
    else if (_currentAlert == HIGH_ALERT_VALUE)
    {
        self.currentAlertLevelLabel.text = @"Current Alert Tone= High";
    }
}


// Small array holding RSSI samples to be smoothed.

#define MAX_RSSI_SAMPLES 3
-(NSMutableArray *)filterRSSI
{
    if (_filterRSSI == nil)
    {
        _filterRSSI = [NSMutableArray arrayWithCapacity:MAX_RSSI_SAMPLES];
    }
    return _filterRSSI;
}


// Sampling clock for reading RSSI values
// RSSI Update frequency
#define RSSI_UPDATE_FREQUENCY_HERTZ 1
-(dispatch_source_t)rssiUpdateClock
{
    if (! _rssiUpdateClock)
    {
        _rssiUpdateClock = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, dispatch_get_main_queue());
        
        dispatch_source_set_event_handler(_rssiUpdateClock, ^{
            
            // read rssi value
            [self.transmitPowerService.peripheral readRSSI];
            
            if (self.transmitPowerAvailable)
            {
                 [self readCharacteristic:TRANSMIT_POWER_LEVEL_CHARACTERISTIC forService:self.transmitPowerService];
            }
            
        });
        
        dispatch_resume(_rssiUpdateClock);
    }
    return _rssiUpdateClock;
}



- (IBAction)changeAlertValue
{
    if (self.currentAlert ==LOW_ALERT_VALUE)
    {
        self.currentAlert = HIGH_ALERT_VALUE;
    }
    else
    {
        self.currentAlert=LOW_ALERT_VALUE;
    }
}


#pragma mark- Controller Lifecycle
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
 * Description:  Initializes controller. 
 *    
 *     Starts a timer which samples RSSI values that are returned by the device.
 *      Ensures all characteristics of the service have been discovered, otherwise discovers all mandatory haracteristics.
 *
 * Parameter(s): None
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.transmitPowerAvailable = NO;
    
    self.currentAlert = LOW_ALERT_VALUE;
    
    self.statusLabel = self.peripheralStatusLabel;
    self.statusSpinner = self.activityIndicator;
    
    self.transmitPowerLabel.text = @"";
    self.rssiPowerLabel.text = @"";
    
    self.alarmCharacteristicDiscovered = NO;
  
    self.transmitPower=0;
    
    // set the peripheral delegate to self
    self.transmitPowerService.peripheral.delegate =self;
    self.immediateAlertService.peripheral.delegate = self;
    
    BOOL foundTransmitPower = NO;
    BOOL foundAlert = NO;
    dispatch_source_set_timer(self.rssiUpdateClock, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC / RSSI_UPDATE_FREQUENCY_HERTZ, 1ull * NSEC_PER_SEC/100);
    
    // determine if ALERT_LEVEL_CHARACTERISTIC has been discovered
    for (CBCharacteristic * characteristic in self.immediateAlertService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ALERT_LEVEL_CHARACTERISTIC ]])
        {
            foundAlert = YES;
        }
    }
    
    if (! foundAlert)
    {
        [self discoverServiceCharacteristics:self.immediateAlertService];
    }
    else
    {
        self.alarmCharacteristicDiscovered = YES;
    }
    
    for (CBCharacteristic * characteristic in self.transmitPowerService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSMIT_POWER_LEVEL_CHARACTERISTIC ]])
        {
            foundTransmitPower = YES;
            self.transmitPowerAvailable = YES;
        }
    }
    
    if (! foundTransmitPower)
    {
        [self discoverServiceCharacteristics:self.transmitPowerService];
    }
    else
    {
         [self readCharacteristic:TRANSMIT_POWER_LEVEL_CHARACTERISTIC forService:self.transmitPowerService];
    }
    
}


// Nil references as needed and shut down timers when view disappears
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_source_cancel(self.rssiUpdateClock);
    self.rssiUpdateClock = nil;
    
    self.transmitPowerService.peripheral.delegate = nil;
    self.immediateAlertService.peripheral.delegate = nil;

}


#pragma mark- Private Methods

/*
 *
 * Method Name:  enableAlarm
 *
 * Description:  Turn immediate alarm on and off.
 *
 * Parameter(s): enable - boolean indicationg desired on/off state
 *
 */
-(void)enableAlarm: (BOOL) enable
{
    static BOOL alarmState = YES;
    
    NSUInteger index = [self.immediateAlertService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        CBCharacteristic *characteristic = (CBCharacteristic *)obj;
        
        NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
        if ([uuidString localizedCompare:ALERT_LEVEL_CHARACTERISTIC ] == NSOrderedSame)
        {
            return YES;
        }
        return NO;
    }];
    
    if (index == NSNotFound)
    {
        DLog(@"Error State: Expected Characteristic:  %@ Not Available.",ALERT_LEVEL_CHARACTERISTIC);
        
    }
    else
    {
        if ([self.immediateAlertService.peripheral isConnected])
        {
                        
            char value = enable ? self.currentAlert : NO_ALERT_VALUE;
            NSData *data = [NSData dataWithBytes:&value length:1 ];
           
            // Apple Bug in CBPeripheralManager does not correctly process CBCharacteristicWriteWithoutResponse
           // [self.immediateAlertService.peripheral writeValue:data
           //             forCharacteristic:self.immediateAlertService.characteristics[index] type:CBCharacteristicWriteWithoutResponse ];
            
            if ( (value == 0) && (alarmState==YES))
            {
                // turn alarm off initially to ensure its off.. then only turn off when its on
                alarmState = NO;
                [self.immediateAlertService.peripheral writeValue:data
                                            forCharacteristic:self.immediateAlertService.characteristics[index] type:CBCharacteristicWriteWithResponse ];
            }
            else if (value != 0)
            {
                // always write to peripheral to turn on alarm since updates increase the alarm time
                alarmState = YES;
                [self.immediateAlertService.peripheral writeValue:data
                                                forCharacteristic:self.immediateAlertService.characteristics[index] type:CBCharacteristicWriteWithResponse ];
                
            }
                
            
        }
    }
}



#pragma mark - CBPeripheralDelegate


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
    [self.activityIndicator stopAnimating];
    [self displayPeripheralConnectStatus: peripheral];
    
    if (!error)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSMIT_POWER_LEVEL_CHARACTERISTIC ]])
        {
            signed char TXLevel;
            [characteristic.value getBytes:&TXLevel length:1];
            
            self.transmitPower = TXLevel;
            
            self.transmitPowerLabel.text = [NSString stringWithFormat:@"Transmit Power (dBm)= %i",self.transmitPower];
            self.transmitPowerAvailable = YES;
        }
    }
    else
    {
        DLog(@"Error occurred updating characteristic: %@", error.description);
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
    DLog(@"didDiscoverCharacteristicsForService invoked");
    
    [self.activityIndicator stopAnimating];
    [self displayPeripheralConnectStatus: peripheral];
    
    if (error == nil)
    {
        if ([[[service.UUID representativeString]uppercaseString]localizedCompare:Tx_POWER_SERVICE ] == NSOrderedSame)
        {
            // iterate through the characteristics and take appropriate actions
            for (CBCharacteristic *characteristic in service.characteristics )
            {
                NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
                [self readCharacteristic:uuidString forService:self.transmitPowerService];
                
            }
        }
        else if ([[[service.UUID representativeString]uppercaseString]localizedCompare:IMMEDIATE_ALERT_SERVICE ] == NSOrderedSame)
        {
            self.alarmCharacteristicDiscovered = YES;
        }
        
    }
    else
    {
        DLog(@"Error encountered reading characterstics for heart rate service %@",error.description);
    }
    
}


/*
 *
 * Method Name:  peripheralDidUpdateRSSI
 *
 * Description:  Process (smooth) RSSI values when periodically read.
 *               Toggles immediate alarm on/off depending upon path loss thresholds.
 *
 * Parameter(s): See Core Bluetooth Documentation.
 *
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!error)
    {
        DLog(@"RSSI Updated");
        
        self.rssiPowerLabel.text = [NSString stringWithFormat:@"Updated RSSI (dBm): %i", [peripheral.RSSI shortValue]];
        
        if ([self.filterRSSI count] ==  MAX_RSSI_SAMPLES)
        {
            [self.filterRSSI removeObjectAtIndex:0];
        }
        
        [self.filterRSSI addObject:peripheral.RSSI];
        
        NSInteger total=0;
        for (NSNumber *value in self.filterRSSI)
        {
            total += [value shortValue];
        }
        
        double averageRSSI = (double)total / [self.filterRSSI count];
        
        double pathLoss = (double)self.transmitPower - averageRSSI;
        self.pathLossLabel.text = [NSString stringWithFormat:@"Path Loss = %f",pathLoss];
        
        if ((pathLoss) > PROXIMITY_THRESHOLD_ON)
        {
            
            DLog(@"Turn alarm on");
            if (self.alarmCharacteristicDiscovered)
            {
                [self enableAlarm:YES];
            }
            
        }
        if ((pathLoss) < PROXIMITY_THRESHOLD_OFF)
        {
            
            DLog(@"Turn alarm off");
            if (self.alarmCharacteristicDiscovered)
            {
                [self enableAlarm:NO];
            }
        }
    }
}

@end
