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
-(void)displayPeripheralConnectStatus : (CBPeripheral *)peripheral
{
    if ([peripheral isConnected])
    {
        self.statusLabel.textColor = [UIColor greenColor];
        self.statusLabel.text = @"Connected";
    }
    else
    {
        self.statusLabel.textColor = [UIColor redColor];
        self.statusLabel.text = @"Unconnected";
    }
}


-(void)discoverServiceCharacteristics : (CBService *)service
{
    
    BOOL isConnected = [service.peripheral isConnected];
    if (isConnected)
    {
        self.statusLabel.textColor = [UIColor greenColor];
        self.statusLabel.text = @"Discovering service characteristics.";
        [self.statusSpinner startAnimating];
        [service.peripheral discoverCharacteristics:nil
                                         forService:service];
    }
    else
    {
        DLog(@"Failed to discover characteristic, peripheral not connected.");
        [self displayPeripheralConnectStatus:service.peripheral ];

    }
   
}


-(void)readCharacteristic: (NSString *)uuid forService:(CBService *)service
{
   
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
            DLog(@"Error State: Expected Characteristic  %@ Not Available.",uuid);
            
        }
        else
        {
            if ([service.peripheral isConnected])
            {
                self.statusLabel.textColor = [UIColor greenColor];
                self.statusLabel.text = @"Reading Characteristic.";
                [self.statusSpinner startAnimating];
                [service.peripheral readValueForCharacteristic:service.characteristics[index]];
            }
        }
    }
    else
    {
        DLog(@"Error State: Expected Characteristic %@ Not Available.",uuid);
        
    }
 
}
@end