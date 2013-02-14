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

// RSSI Update frequency
#define RSSI_UPDATE_FREQUENCY_HERTZ 1
#define MAX_RSSI_SAMPLES 3
#define PROXIMITY_THRESHOLD_ON 67
#define PROXIMITY_THRESHOLD_OFF 60

@interface BLELeashDemoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *transmitPowerLabel;

@property (weak, nonatomic) IBOutlet UILabel *rssiPowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *pathLossLabel;

@property (nonatomic, strong) dispatch_source_t rssiUpdateClock;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@property (nonatomic) NSInteger transmitPower;

@property (nonatomic, strong) NSMutableArray *filterRSSI;

@property (nonatomic) BOOL alarmCharacteristicDiscovered;
@end

@implementation BLELeashDemoViewController


-(NSMutableArray *)filterRSSI
{
    if (_filterRSSI == nil)
    {
        _filterRSSI = [NSMutableArray arrayWithCapacity:MAX_RSSI_SAMPLES];
    }
    return _filterRSSI;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(dispatch_source_t)rssiUpdateClock
{
    if (! _rssiUpdateClock)
    {
        _rssiUpdateClock = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, dispatch_get_main_queue());
        
        dispatch_source_set_event_handler(_rssiUpdateClock, ^{
            
            // read rssi value
            [self.transmitPowerService.peripheral readRSSI];
            
        });
        
        dispatch_resume(_rssiUpdateClock);
    }
    return _rssiUpdateClock;
}








-(void)discoverServiceCharacteristics : (CBService *)service
{
    
    BOOL discoverIssued = [[self class]discoverServiceCharacteristics:service];
    if (discoverIssued)
    {
        
       self.statusLabel.textColor = [UIColor greenColor];
       self.statusLabel.text = @"Discovering service characteristics.";
       [self.activityIndicator startAnimating];
        
    }
    else
    {
        DLog(@"Failed to discover characteristic, peripheral not connected.");
        [[self class]setPeripheral:service.peripheral ConnectionStatus:self.statusLabel];
    }
    
}

-(void)readCharacteristic: (NSString *)uuid forService:(CBService *)service
{
    BOOL readIssued = NO;
    
    readIssued = [[self class]readCharacteristic:uuid forService:service];
    if (readIssued)
    {
        self.statusLabel.textColor = [UIColor greenColor];
        self.statusLabel.text = @"Reading Characteristic.";
        [self.activityIndicator startAnimating];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
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


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_source_cancel(self.rssiUpdateClock);
    self.rssiUpdateClock = nil;
    
    self.transmitPowerService.peripheral.delegate = nil;
    self.immediateAlertService.peripheral.delegate = nil;

    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)enableAlarm: (BOOL) enable
{
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
        DLog(@"Error State: Expected Body Sensor Characteristic  %@ Not Available.",ALERT_LEVEL_CHARACTERISTIC);
        
    }
    else
    {
        if ([self.immediateAlertService.peripheral isConnected])
        {
            //  self.peripheralStatusLabel.textColor = [UIColor greenColor];
            //  self.peripheralStatusLabel.text = @"Reading Characteristic.";
            //  [self.peripheralStatusSpinner startAnimating];
            
            char value = enable ? 1 : 0;
            NSData *data = [NSData dataWithBytes:&value length:1 ];
           
            [self.immediateAlertService.peripheral writeValue:data
                        forCharacteristic:self.immediateAlertService.characteristics[index] type:CBCharacteristicWriteWithoutResponse ];
                
            
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
    if (!error)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSMIT_POWER_LEVEL_CHARACTERISTIC ]])
        {
            signed char TXLevel;
            [characteristic.value getBytes:&TXLevel length:1];
            
            self.transmitPower = TXLevel;
            
            self.transmitPowerLabel.text = [NSString stringWithFormat:@"Transmit Power (dBm)= %i",self.transmitPower];
        }
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
    
    // [self.peripheralStatusSpinner stopAnimating];
    [[self class]setPeripheral:peripheral ConnectionStatus:self.statusLabel];
    
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
