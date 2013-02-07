//
//  BLEBatteryServiceDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/7/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEBatteryServiceDemoViewController.h"
#import "CBUUID+StringExtraction.h"

#define BATTERY_LEVEL @"2A19"
@interface BLEBatteryServiceDemoViewController ()

@property (nonatomic)NSUInteger batteryLevel;
@property (weak, nonatomic) IBOutlet UIProgressView *batteryMeter;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;

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


-(void)readBatteryLevel
{
    CBCharacteristic *batteryLevelCharacteristic= nil;;
    
    // Check to see if peripheral has retrieved characteristics
    if (self.batteryService.characteristics)
    {
        // check to see if battery measurement characteristic is in the array
        for (CBCharacteristic *characteristic in self.batteryService.characteristics)
        {
            NSString *uuidString = [characteristic.UUID representativeString];
            if ([uuidString localizedCompare:BATTERY_LEVEL])
            {
                batteryLevelCharacteristic = characteristic;
                break;
            }
        }
        
    }
    
    if (batteryLevelCharacteristic)
    {
        // read battery level
        self.batteryService.peripheral.delegate = self;
        [self.batteryService.peripheral readValueForCharacteristic:batteryLevelCharacteristic];
    }
    else
    {
        // read service characteristics
    }
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
        NSLog(@"Characteristic value read updated.");
        
        unsigned char batteryValue;
        
       [characteristic.value getBytes:&batteryValue length:1];
        
        self.batteryLevel = (NSUInteger)batteryValue;
        NSLog(@"Battery level read: %i",self.batteryLevel);
        self.batteryMeter.progress = (float)self.batteryLevel /100.0;
        self.batteryLevelLabel.text = [NSString  stringWithFormat: @"%i%%",self.batteryLevel];
        
    }
}

@end
