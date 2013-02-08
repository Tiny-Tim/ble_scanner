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

// Label which displays peripheral status and activity.
@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

// Spinner activity indicator whihc is active when device is being accessed.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *peripheralStatusSpinner;

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
 * Method Name:  setConnectionStatus
 *
 * Description:  Sets the connection status label to indicate peripheral connect status.
 *
 * Parameter(s): None
 *
 */
-(void)setConnectionStatus
{
    if ([self.batteryService.peripheral isConnected])
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


/*
 *
 * Method Name:  discoverBatteryCharacteristic
 *
 * Description:  Gets the battery chracteristic from the peripheral
 *
 * Parameter(s): <#parameters#>
 *
 */
-(void)discoverBatteryCharacteristic
{
    if ([self.batteryService.peripheral isConnected])
    {
        // discover battery service characteristic
        CBUUID *UUUID = [CBUUID UUIDWithString:BATTERY_LEVEL_CHARACTERISTIC];
        NSArray *batteryServiceUUID = [NSArray arrayWithObject:UUUID];
        
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Discovering service characteristics.";
        [self.peripheralStatusSpinner startAnimating];
        self.batteryService.peripheral.delegate =self;
        [self.batteryService.peripheral discoverCharacteristics:batteryServiceUUID
                                                     forService:self.batteryService];
    }
    else
    {
        if (self.debug) NSLog(@"Failed to discover characteristic, peripheral not connected.");
        [self setConnectionStatus];
    }
    
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
            [self discoverBatteryCharacteristic];
        }
        else
        {
            if ([self.batteryService.peripheral isConnected])
            {
                // read battery level
                self.batteryService.peripheral.delegate = self;
                self.peripheralStatusLabel.textColor = [UIColor greenColor];
                self.peripheralStatusLabel.text = @"Reading battery level.";
                [self.peripheralStatusSpinner startAnimating];
                [self.batteryService.peripheral readValueForCharacteristic:self.batteryService.characteristics[index]];
            }
            else
            {
                if (self.debug) NSLog(@"Failed to read characteristic, peripheral not connected.");
                [self setConnectionStatus];
            }
            
        }
    }
    else // Need to discover characteristic then read the battery value
    {
        [self discoverBatteryCharacteristic];
    }
}


/*
 *
 * Method Name:  viewDidLoad
 *
 * Description:  Complete setup of view controller.
 *
 * Parameter(s): None.
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _debug = YES;
    
    [self setConnectionStatus];
    
    [self readBatteryLevel];
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBPeripheralDelegate


/*
 *
 * Method Name:  peripheral:didUpdateValueForCharacteristic:error
 *
 * Description:  CBPeripheralDelegate method invoked when chracteristic is read or error occurs when reading characteristic.
 *
 * Parameter(s): See CBPeripheralDelegate documentation.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    [self.peripheralStatusSpinner stopAnimating];
    [self setConnectionStatus];
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
        if (self.debug) NSLog(@"Reading battery level");
        [self readBatteryLevel];
    }
    
    
}


@end
