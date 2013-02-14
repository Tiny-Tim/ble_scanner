//
//  BLEDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/14/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDemoViewController.h"
#import "CBUUID+StringExtraction.h"

@interface BLEDemoViewController ()

@end

@implementation BLEDemoViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
+(void)setPeripheral : (CBPeripheral *)peripheral ConnectionStatus :(UILabel *)statusLabel
{
    if ([peripheral isConnected])
    {
        statusLabel.textColor = [UIColor greenColor];
        statusLabel.text = @"Connected";
    }
    else
    {
        statusLabel.textColor = [UIColor redColor];
        statusLabel.text = @"Unconnected";
    }
}


+(BOOL)discoverServiceCharacteristics : (CBService *)service
{
    BOOL isConnected = NO;
    isConnected = [service.peripheral isConnected];
    if (isConnected)
    {
        [service.peripheral discoverCharacteristics:nil
                                         forService:service];
    }
    return isConnected;
}


+(BOOL)readCharacteristic: (NSString *)uuid forService:(CBService *)service
{
    BOOL readIssued = NO;
    if (service.characteristics)
    {
        NSUInteger index = [service.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            CBCharacteristic *characteristic = (CBCharacteristic *)obj;
            
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            if ([uuidString localizedCompare:uuid ] == NSOrderedSame)
            {
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound)
        {
            DLog(@"Error State: Expected Body Sensor Characteristic  %@ Not Available.",uuid);
            
        }
        else
        {
            if ([service.peripheral isConnected])
            {
                //  self.peripheralStatusLabel.textColor = [UIColor greenColor];
                //  self.peripheralStatusLabel.text = @"Reading Characteristic.";
                //  [self.peripheralStatusSpinner startAnimating];
                [service.peripheral readValueForCharacteristic:service.characteristics[index]];
                readIssued = YES;
                
            }
        }
    }
    else
    {
        DLog(@"Error State: Expected Body Sensor Characteristic %@ Not Available.",uuid);
        
    }

    return readIssued;
}
@end
