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

@property (weak, nonatomic) IBOutlet UISwitch *subscribeSwitch;

- (IBAction)subscribeForSwitchNotifications:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

@property (nonatomic, strong) UIImage *onLEDImage;

@property (nonatomic, strong)UIImage *whiteLEDImage;

@property (nonatomic, strong) UIApplication *application;

@end

@implementation BLEKeyPressDemoViewController

#pragma mark- Properties

-(UIApplication *)application
{
    if (_application == nil)
    {
        _application = [UIApplication sharedApplication];
    }
    
    return _application;
}


// Red LED image used to signal button is pressed.
-(UIImage *)onLEDImage
{
    if (_onLEDImage == nil)
    {
        NSString *LEDfilePath = [[NSBundle mainBundle] pathForResource:@"yellowLed" ofType:@"png"];
        _onLEDImage = [UIImage imageWithContentsOfFile:LEDfilePath];
    }
    
    return _onLEDImage;
}


// White LED image used to signal button is not pressed.
-(UIImage *)whiteLEDImage
{
    if (_whiteLEDImage == nil)
    {
        NSString *whiteLEDfilePath = [[NSBundle mainBundle] pathForResource:@"whiteLed" ofType:@"png"];
        _whiteLEDImage = [UIImage imageWithContentsOfFile:whiteLEDfilePath];
    }
    
    return _whiteLEDImage;
}


// Switch handler for subscribing to notifications of key presses.
- (IBAction)subscribeForSwitchNotifications:(UISwitch *)sender
{
    if (sender.on)
    {
        [self subscribeForButtonNotifications:YES];
    }
    else
    {
        [self subscribeForButtonNotifications:NO];
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


// General setup and initializations whihc occur when controller is instantiated
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.statusLabel = self.peripheralStatusLabel;
    self.statusSpinner = self.statusActivityIndicator;
    
    self.keyPressedService.peripheral.delegate =self;
    
    [self displayPeripheralConnectStatus:self.keyPressedService.peripheral];
    
    BOOL keyPressedFound = NO;
    for (CBCharacteristic * characteristic in self.keyPressedService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TI_KEY_PRESSED_STATE_CHARACTERISTIC ]])
        {
            keyPressedFound = YES;
        }
    }
    
    // Enable user switch for subscribing to notifications for key presses
    if ( keyPressedFound)
    {
        self.subscribeSwitch.enabled = YES;
    }
    else
    {
        // discover service characteristics
        [self discoverServiceCharacteristics:self.keyPressedService];
    }
}


#pragma mark- Private Methods

/*
 *
 * Method Name:  subscribeForButtonNotifications
 *
 * Description:  subscribe for notification from device whenever a button on the device is pressed.
 *
 * Parameter(s): None
 *
 */
-(void)subscribeForButtonNotifications: (BOOL)enable
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
                [self.keyPressedService.peripheral setNotifyValue:enable forCharacteristic:self.keyPressedService.characteristics[index]];
            }
        }
    }
    else
    {
        DLog(@"Error State: Expected Characteristic  %@ Not Available.",TI_KEY_PRESSED_STATE_CHARACTERISTIC);
    }
}


/*
 *
 * Method Name:  postNotification
 *
 * Description:  Post a local notification if the user presses a button while the app is in the background
 *
 * Parameter(s): alertMessage - the message to display in the alert
 *
 */
-(void)postNotification:(NSString *)alertMessage
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif)
    {
        localNotif.alertBody = alertMessage;
        localNotif.soundName  = UILocalNotificationDefaultSoundName;
        [self.application presentLocalNotificationNow:localNotif];
    }
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


/*
 *
 * Method Name:  didUpdateValueForCharacteristic
 *
 * Description:  Updates UI by toggling LED colors when buttons are pressed or released on device.
 *
 * Parameter(s): See core bluetooth doc.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *alertMessage=nil;
    if (!error)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TI_KEY_PRESSED_STATE_CHARACTERISTIC ]])
        {
            DLog(@"Characteristic value  updated.");
            
            unsigned char buttonValue;
            
            [characteristic.value getBytes:&buttonValue length:1];
            
            // both buttons not pressed
            if (buttonValue == 0)
            {
                self.leftButtonImage.image = self.whiteLEDImage;
                self.rightButtonImage.image = self.whiteLEDImage;
                
            }
            else if (buttonValue == 1 )
            {
                // left button pressed
                self.leftButtonImage.image = self.onLEDImage;
                self.rightButtonImage.image = self.whiteLEDImage;
                alertMessage = @"Key Fob Button Press: Left Button";
                
            }
            else if (buttonValue == 2)
            {
                // right button pressed
                self.leftButtonImage.image = self.whiteLEDImage;
                self.rightButtonImage.image = self.onLEDImage;
                alertMessage = @"Key Fob Button Press: Right Button";
            }
            else if (buttonValue == 3)
            {
                // both buttons pressed
                self.leftButtonImage.image = self.onLEDImage;
                self.rightButtonImage.image = self.onLEDImage;
                alertMessage = @"Key Fob Button Press: Both Buttons Pressed";
            }
            
            // Post an local notification if button pressed and app is in the background
            if ( (self.application.applicationState == UIApplicationStateBackground) && (alertMessage != nil) )
            {
                [self postNotification:alertMessage];
                DLog(@"%@",alertMessage);
            }
        }
    }
    else
    {
        DLog(@"Error Updating Characteristic: %@",error.description);
    }
    
    [self displayPeripheralConnectStatus:self.keyPressedService.peripheral];
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
    [self displayPeripheralConnectStatus:self.keyPressedService.peripheral];

    if (error == nil)
    {
        DLog(@"Enabling subscriptions to key pressed notifications");
        self.subscribeSwitch.enabled = YES;
        
    }
    else
    {
        DLog(@"Error Discovering Characteristics: %@",error.description);
    }
}


@end
