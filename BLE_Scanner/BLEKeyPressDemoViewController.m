//
//  BLEKeyPressDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/8/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEKeyPressDemoViewController.h"
#import "CBUUID+StringExtraction.h"
#include "ServiceAndCharacteristicMacros.h"

@interface BLEKeyPressDemoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *leftButtonImage;

@property (weak, nonatomic) IBOutlet UIImageView *rightButtonImage;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

@property (nonatomic, strong) UIImage *redLEDImage;

@property (nonatomic, strong)UIImage *whiteLEDImage;

@end

@implementation BLEKeyPressDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(UIImage *)redLEDImage
{
    if (_redLEDImage == nil)
    {
         NSString *redLEDfilePath = [[NSBundle mainBundle] pathForResource:@"redLed" ofType:@"png"];
        _redLEDImage = [UIImage imageWithContentsOfFile:redLEDfilePath];
    }
    
    return _redLEDImage;
}


-(UIImage *)whiteLEDImage
{
    if (_whiteLEDImage == nil)
    {
        NSString *whiteLEDfilePath = [[NSBundle mainBundle] pathForResource:@"whiteLed" ofType:@"png"];
        _whiteLEDImage = [UIImage imageWithContentsOfFile:whiteLEDfilePath];
    }
    
    return _whiteLEDImage;
}


/*
 *
 * Method Name:  discoverServiceCharacteristics
 *
 * Description:  Issues comand to discover characteristics for service and updates UI with discovery status.
 *
 * Parameter(s): service - service for which characteristics are being discovered
 *
 */
-(void)discoverServiceCharacteristics : (CBService *)service
{
    
    BOOL discoverIssued = [[self class]discoverServiceCharacteristics:service];
    if (discoverIssued)
    {
        
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Discovering service characteristics.";
        [self.statusActivityIndicator startAnimating];
        
    }
    else
    {
        DLog(@"Failed to discover characteristic, peripheral not connected.");
        [[self class]setPeripheral:service.peripheral ConnectionStatus:self.peripheralStatusLabel];
    }
    
}




-(void)subscribeForButtonNotifications
{
    
    if (self.keyPressedService.characteristics)
    {
        NSUInteger index = [self.keyPressedService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            CBCharacteristic *characteristic = (CBCharacteristic *)obj;
            
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            if ([uuidString localizedCompare:TI_KEY_PRESSED_STATE_CHARACTERISTIC] == NSOrderedSame)
            {
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound)
        {
            DLog(@"Error State: Expected Characteristic  %@ Not Available.",TI_KEY_PRESSED_STATE_CHARACTERISTIC);
        }
        else
        {
            if ([self.keyPressedService.peripheral isConnected])
            {
                // sign up for notifications
                self.keyPressedService.peripheral.delegate = self;
                [self.keyPressedService.peripheral setNotifyValue:YES forCharacteristic:self.keyPressedService.characteristics[index]];
                
            }
        }
    }
    else
    {
        DLog(@"Error State: Expected Characteristic  %@ Not Available.",TI_KEY_PRESSED_STATE_CHARACTERISTIC);
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.keyPressedService.peripheral.delegate =self;
   
    [[self class]setPeripheral:self.keyPressedService.peripheral ConnectionStatus:self.peripheralStatusLabel];
    
    BOOL keyPressedFound = NO;
    for (CBCharacteristic * characteristic in self.keyPressedService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TI_KEY_PRESSED_STATE_CHARACTERISTIC ]])
        {
            keyPressedFound = YES;
        }
    }
    
    if ( keyPressedFound)
    {
         [self subscribeForButtonNotifications];
    }
    else
    {
        // discover service characteristics
        [self discoverServiceCharacteristics:self.keyPressedService];
    }

    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        DLog(@"didUpdateNotificationStateForCharacteristic invoked");
    }
    else
    {
        DLog(@"Error occurred in didUpdateNotificationStateForCharacteristic: %@", error.description);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   
    
    if (!error)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TI_KEY_PRESSED_STATE_CHARACTERISTIC ]])
        {
            DLog(@"Characteristic value  updated.");
            
            unsigned char buttonValue;
            
            [characteristic.value getBytes:&buttonValue length:1];
            
            if (buttonValue == 0)
            {
                self.leftButtonImage.image = self.whiteLEDImage;
                self.rightButtonImage.image = self.whiteLEDImage;
                
            }
            else if (buttonValue == 1 )
            {
                self.leftButtonImage.image = self.redLEDImage;
                self.rightButtonImage.image = self.whiteLEDImage;
                
            }
            else if (buttonValue == 2)
            {
                self.leftButtonImage.image = self.whiteLEDImage;
                self.rightButtonImage.image = self.redLEDImage;
            }
            else if (buttonValue == 3)
            {
                self.leftButtonImage.image = self.redLEDImage;
                self.rightButtonImage.image = self.redLEDImage;
                
            }
        }
        
    }
    else
    {
        DLog(@"Error Updating Characteristic: %@",error.description);
    }
    
    [[self class]setPeripheral:self.keyPressedService.peripheral ConnectionStatus:self.peripheralStatusLabel];

    
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
    
    [self.statusActivityIndicator stopAnimating];
    [[self class]setPeripheral:self.keyPressedService.peripheral ConnectionStatus:self.peripheralStatusLabel];

    
    if (error == nil)
    {
        DLog(@"Subscribing to key pressed notifications");
        [self subscribeForButtonNotifications];
    }
    else
    {
        DLog(@"Error Discovering Characteristics: %@",error.description);
    }
}

@end
