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


// toggle NSLog off/on
@property (nonatomic) BOOL debug;
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
 * Method Name:  setConnectionStatus
 *
 * Description:  Sets the connection status label to indicate peripheral connect status.
 *
 * Parameter(s): None
 *
 */
-(void)setConnectionStatus
{
    if ([self.keyPressedService.peripheral isConnected])
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


-(void)discoverKeyPressedServiceCharacteristic
{
    if ([self.keyPressedService.peripheral isConnected])
    {
        // discover keyPressed service characteristic
        CBUUID *UUUID = [CBUUID UUIDWithString:TI_KEY_PRESSED_STATE_CHARACTERISTIC];
        NSArray *keyPressedServiceUUID = [NSArray arrayWithObject:UUUID];
        
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Discovering service characteristics.";
        [self.statusActivityIndicator startAnimating];
        self.keyPressedService.peripheral.delegate =self;
        [self.keyPressedService.peripheral discoverCharacteristics:keyPressedServiceUUID
                                                     forService:self.keyPressedService];
    }
    else
    {
        if (self.debug) NSLog(@"Failed to discover characteristic, peripheral not connected.");
        [self setConnectionStatus];
    }
    
}



-(void)subscribeForButtonNotifications
{
    // Check to see if peripheral has retrieved characteristics
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
            [self discoverKeyPressedServiceCharacteristic];
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
        [self discoverKeyPressedServiceCharacteristic];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _debug = YES;

    [self setConnectionStatus];
    
    [self subscribeForButtonNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateNotificationStateForCharacteristic invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   
    
    if (!error)
    {
        if (self.debug) NSLog(@"Characteristic value  updated.");
        
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
    
    [self.statusActivityIndicator stopAnimating];
    [self setConnectionStatus];
    
    if (error == nil)
    {
        if (self.debug) NSLog(@"Subscribing to key pressed notifications");
        [self subscribeForButtonNotifications];
    }
}

@end
