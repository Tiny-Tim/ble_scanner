//
//  BLEBatteryServiceDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/7/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEBatteryServiceDemoViewController.h"
#import "CBUUID+StringExtraction.h"
#include "ServiceAndCharacteristicMacros.h"


@interface BLEBatteryServiceDemoViewController ()

// Unsigned integer representation of battery level
@property (nonatomic)NSUInteger batteryLevel;

// UIProgressView used to display battery life percentage
@property (weak, nonatomic) IBOutlet UIProgressView *batteryMeter;

//Label which displays battery life percentage as an integer
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;

// toggle NSLog off/on
@property (nonatomic) BOOL debug;

@end

@implementation BLEBatteryServiceDemoViewController


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
 * Method Name:  readBatteryLevel
 *
 * Description:  Reads the battery level characteristic if the characteristic has been discovered. If the characteristic has not been discovered then a discovery request is invoked and the peripheral delegate for this controller will invoke this method once the characteristic is obtained.
 *
 * Parameter(s): None
 *
 */
-(void)readBatteryLevel
{
  //  CBCharacteristic *batteryLevelCharacteristic= nil;;
    
    // Check to see if peripheral has retrieved characteristics
    if (self.batteryService.characteristics)
    {
        
        NSUInteger index = [self.batteryService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            CBCharacteristic *characteristic = (CBCharacteristic *)obj;
            
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            if ([uuidString localizedCompare:BATTERY_LEVEL_CHARACTERISTIC] == NSOrderedSame)
            {
                return YES;
                
            }
            return NO;
        
        }];
        
        if (index == NSNotFound)
        {
            // read battery service characteristic
            CBUUID *UUUID = [CBUUID UUIDWithString:BATTERY_LEVEL_CHARACTERISTIC];
            NSArray *batteryServiceUUID = [NSArray arrayWithObject:UUUID];
            
            self.batteryService.peripheral.delegate =self;
            [self.batteryService.peripheral discoverCharacteristics:batteryServiceUUID
                                                         forService:self.batteryService];
        }
        else
        {
            // read battery level
            self.batteryService.peripheral.delegate = self;
            [self.batteryService.peripheral readValueForCharacteristic:self.batteryService.characteristics[index]];
            
        }
                
    }
    else // Need to discover characteristic then read the battery value
    {
        // read battery service characteristic
        CBUUID *UUUID = [CBUUID UUIDWithString:BATTERY_LEVEL_CHARACTERISTIC];
        NSArray *batteryServiceUUID = [NSArray arrayWithObject:UUUID];
        
        self.batteryService.peripheral.delegate =self;
        [self.batteryService.peripheral discoverCharacteristics:batteryServiceUUID
                                                    forService:self.batteryService];
    }
        
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _debug = YES;
    
    [self readBatteryLevel];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBPeripheralDelegate

//Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        if (self.debug) NSLog(@"Characteristic value read updated.");
        
        unsigned char batteryValue;
        
       [characteristic.value getBytes:&batteryValue length:1];
        
        self.batteryLevel = (NSUInteger)batteryValue;
        if (self.debug) NSLog(@"Battery level read: %i",self.batteryLevel);
        self.batteryMeter.progress = (float)self.batteryLevel /100.0;
        self.batteryLevelLabel.text = [NSString  stringWithFormat: @"%i%%",self.batteryLevel];
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverCharacteristicsForService invoked");
    
    
    //[self.statusActivityIndicator stopAnimating];
    //self.statusDetailLabel.textColor = [UIColor blackColor];
    
    
//    if ([peripheral isConnected])
//    {
//        self.statusDetailLabel.text = @"Connected";
//    }
//    else
//    {
//        self.statusDetailLabel.text = @"Unconnected";
//    }
    
    
    if (error == nil)
    {
        if (self.debug) NSLog(@"Reading battery level");
        [self readBatteryLevel];
    }
    
    
}


@end
