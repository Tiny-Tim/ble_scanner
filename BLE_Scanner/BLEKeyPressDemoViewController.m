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

@property (weak, nonatomic) IBOutlet UILabel *leftButtonCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightButtonCountLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

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
            //[self discoverBatteryCharacteristic];
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


-(void)setLed: (UIImageView *)led ToState:(BOOL)state
{
    NSString *redLEDfilePath;
    NSString *whiteLEDfilePath;
    
    redLEDfilePath =  [[NSBundle mainBundle] pathForResource:@"redLed" ofType:@"png"];
    whiteLEDfilePath =  [[NSBundle mainBundle] pathForResource:@"whiteLed" ofType:@"png"];
    if (state)
    {
        led.image = [UIImage imageWithContentsOfFile:redLEDfilePath];
    }
    else
    {
        led.image = [UIImage imageWithContentsOfFile:whiteLEDfilePath];
    }
}

- (IBAction)leftTestButton
{
    static BOOL toggle = YES;
    NSString *redLEDfilePath;
    NSString *whiteLEDfilePath;
    
    redLEDfilePath =  [[NSBundle mainBundle] pathForResource:@"redLed" ofType:@"png"];
    whiteLEDfilePath =  [[NSBundle mainBundle] pathForResource:@"whiteLed" ofType:@"png"];
    
    UIImage *redLED = [UIImage imageWithContentsOfFile:redLEDfilePath];
    UIImage *whiteLED = [UIImage imageWithContentsOfFile:whiteLEDfilePath];
    
    if (toggle)
    {
        self.leftButtonImage.image =redLED;
    }
    else
    {
        self.leftButtonImage.image = whiteLED;
    }
    
    toggle = ! toggle;
        
}

- (IBAction)rightTestButton {
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
            [self setLed: self.leftButtonImage ToState:NO];
            [self setLed: self.rightButtonImage ToState:NO];
        }
        else if (buttonValue == 1 )
        {
            [self setLed: self.leftButtonImage ToState:YES];
            [self setLed: self.rightButtonImage ToState:NO];
        }
        else if (buttonValue == 2)
        {
            [self setLed: self.leftButtonImage ToState:NO];
            [self setLed: self.rightButtonImage ToState:YES];

        }
        else if (buttonValue == 3)
        {
            [self setLed: self.leftButtonImage ToState:YES];
            [self setLed: self.rightButtonImage ToState:YES];
            
        }
            
    }
    
}


@end
