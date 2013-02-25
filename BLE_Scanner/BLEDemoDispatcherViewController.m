//
//  BLEDemoDispatcherViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/7/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDemoDispatcherViewController.h"
#import "BLEBatteryServiceDemoViewController.h"
#import "CBUUID+StringExtraction.h"
#import "BLEKeyPressDemoViewController.h" 
#import "BLEAccelerometerDemoViewController.h"
#import "BLEHeartRateDemoViewController.h"
#include "ServiceAndCharacteristicMacros.h"
#include "BLEDeviceInformationDemoViewController.h"
#include "BLELeashDemoViewController.h"
#include "BLEGenericAccessDemoViewController.h"

@interface BLEDemoDispatcherViewController ()

// Button handler
- (IBAction)serviceButtonTapped:(UIButton *)sender;

- (IBAction)leashButtonHandler;

@property (weak, nonatomic) IBOutlet UIButton *leashButton;

// Collection of buttons on the UI VIew
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *buttonCollection;

@end


@implementation BLEDemoDispatcherViewController

@synthesize demoServices = _demoServices;

#pragma mark- Actions

// Dedicated (unique) button for transitioning to demo which uses two services.
- (IBAction)leashButtonHandler
{
    [self performSegueWithIdentifier:@"ShowLeashDemo" sender:self];
}


/*
 *
 * Method Name:  serviceButtonTapped
 *
 * Description:  Handler for demo button tapp on the UI. Identifies the corresponding demo controller by parsing the button title text.
 *
 * Parameter(s): The button tapped.
 *
 */
- (IBAction)serviceButtonTapped:(UIButton *)sender
{
    
    if ([sender.titleLabel.text hasPrefix:GENERIC_ACCESS_PROFILE])
    {
        DLog(@"Generic Access Profile Service Selected");
        [self performSegueWithIdentifier:@"ShowGenericAccessDemo" sender:self];
    }
    else if ([sender.titleLabel.text hasPrefix:BATTERY_SERVICE])
    {
        DLog(@"Battery Service Selected");
        
        [self performSegueWithIdentifier:@"ShowBatteryDemo" sender:self];
        
    }
    else if ([sender.titleLabel.text hasPrefix:TI_KEYFOB_KEYPRESSED_SERVICE])
    {
        DLog(@"Key Pressed Service Selected");
        
        [self performSegueWithIdentifier:@"ShowKeyPressDemo" sender:self];
        
    }
    else if ([sender.titleLabel.text hasPrefix:TI_KEYFOB_ACCELEROMETER_SERVICE])
    {
        DLog(@"Accelerometer Service Selected");
        
        [self performSegueWithIdentifier:@"ShowAccelerometerDemo" sender:self];
        
    }
    else if ([sender.titleLabel.text hasPrefix:HEART_RATE_MEASUREMENT_SERVICE])
    {
        DLog(@"Heart Rate Service Selected");
        
        [self performSegueWithIdentifier:@"ShowHeartRateDemo" sender:self];
        
    }
    else if ([sender.titleLabel.text hasPrefix:DEVICE_INFORMATION_SERVICE])
    {
        DLog(@"Device Information Service Selected");
        
        [self performSegueWithIdentifier:@"ShowDeviceInformationDemo" sender:self];
        
    }
}


#pragma mark- Properties

// copy the demo services set which is used to configure demo buttons in UI
-(void)setDemoServices:(NSSet *)demoServices
{
    _demoServices = [demoServices copy];
}



#pragma mark- View Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


// Usual initializations.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // disable demo buttons for services this peripheral does not offer
    [self synchDemosWithDevice];
}

/*
 *
 * Method Name:  prepareForSegue
 *
 * Description:  Segue to a view controller which presents a demo of the service corresponding to the segue name.
 *
 * Parameter(s): segue - the segue which corresponds to the demo controller
 *               sender - initiator of the segue
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowBatteryDemo"])
    {
        DLog(@"Segueing to Battery Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEBatteryServiceDemoViewController class]])
        {
            BLEBatteryServiceDemoViewController  *destination = segue.destinationViewController;
            
            destination.batteryService = [self getService:BATTERY_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowGenericAccessDemo"])
    {
        DLog(@"Segueing to Generic Access Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEGenericAccessDemoViewController class]])
        {
            
            BLEGenericAccessDemoViewController *destination = segue.destinationViewController;
            destination.genericAccessProfileService= [self getService:GENERIC_ACCESS_PROFILE forPeripheral:self.peripheral];
        }
    }

    else if ([segue.identifier isEqualToString:@"ShowKeyPressDemo"])
    {
        DLog(@"Segueing to KeyPress Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEKeyPressDemoViewController class]])
        {
            
            BLEKeyPressDemoViewController *destination = segue.destinationViewController;
            destination.keyPressedService= [self getService:TI_KEYFOB_KEYPRESSED_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowAccelerometerDemo"])
    {
        DLog(@"Segueing to Accelerometer Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEAccelerometerDemoViewController class]])
        {
            BLEAccelerometerDemoViewController *destination = segue.destinationViewController;
            destination.accelerometerService = [self getService:TI_KEYFOB_ACCELEROMETER_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowHeartRateDemo"])
    {
        DLog(@"Segueing to Heart Rate Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEHeartRateDemoViewController class]])
        {
            BLEHeartRateDemoViewController *destination = segue.destinationViewController;
            destination.heartRateService = [self getService:HEART_RATE_MEASUREMENT_SERVICE forPeripheral:self.peripheral];
           // destination.centralManagerDelegate = self.centralManagerDelegate;
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowDeviceInformationDemo"])
    {
        DLog(@"Segueing to Device Information Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEDeviceInformationDemoViewController class]])
        {
            BLEDeviceInformationDemoViewController *destination = segue.destinationViewController;
            destination.deviceInformationService = [self getService:DEVICE_INFORMATION_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowLeashDemo"])
    {
        DLog(@"Segueing to Leash Demo");
        if ([segue.destinationViewController isKindOfClass:[BLELeashDemoViewController class]])
        {
            BLELeashDemoViewController *destination = segue.destinationViewController;
            destination.transmitPowerService = [self getService:Tx_POWER_SERVICE forPeripheral:self.peripheral];
            destination.immediateAlertService = [self getService:IMMEDIATE_ALERT_SERVICE forPeripheral:self.peripheral];
        }
    }
}

#pragma mark- Prvate Methods

/*
 *
 * Method Name:  configureDemoButton:enablement
 *
 * Description:  Enables or disables UI button depending if device implements the service. If the device does not implement the service there can be no demo.
 *
 * Parameter(s): serviceID - the UUID of the device service which is usedto match to the demo button
 *               value - boolean which set the enable property on the UI Button
 *
 */
-(void)configureDemoButton:(NSString *)serviceID enablement:(BOOL)value
{
    // find the demo button
    for (UIButton *button in self.buttonCollection)
    {
        NSString *buttonText = button.titleLabel.text;
        if ([buttonText hasPrefix:serviceID])
        {
            button.enabled = value;
            break;
        }
    }
}


/*
 *
 * Method Name:  synchDemosWithDevice
 *
 * Description:  Identify peripheral services which match demo services. Disable any demo service button not implemented by the device. 
 *
 * Parameter(s): None.
 *
 */
-(void)synchDemosWithDevice
{
        
    // iterate over all of the demo services
    NSEnumerator *enumerator = [self.demoServices objectEnumerator];
    NSString *demoServiceID;
    
    BOOL transmitPowerFound = NO;
    BOOL immediateAlertFound = NO;
    
    while ((demoServiceID = [enumerator nextObject]))
    {
        bool matchFound = NO;
        // does device implement demo service?
        for (CBService *service in self.peripheral.services)
        {
            NSString *UUIDString = [[service.UUID representativeString]uppercaseString];
            if ([UUIDString localizedCompare:demoServiceID] == NSOrderedSame)
            {
                matchFound = YES;
                break;
            }
            
            if ([UUIDString localizedCompare:Tx_POWER_SERVICE] == NSOrderedSame)
            {
                transmitPowerFound = YES;
            }
            
            if ([UUIDString localizedCompare:IMMEDIATE_ALERT_SERVICE] == NSOrderedSame)
            {
                immediateAlertFound = YES;
            }
        }
        
        if (!matchFound)
        {
            // disable corresponding demo button
            [self configureDemoButton:demoServiceID enablement:NO];
        }
        else
        {
            // enable corresponding demo button
            [self configureDemoButton:demoServiceID enablement:YES];
        }
    }
    
    if (transmitPowerFound && immediateAlertFound)
    {
        self.leashButton.enabled = YES;
    }
    else
    {
        self.leashButton.enabled = NO;
    }
       
}


/*
 *
 * Method Name:  getService: forPeripheral
 *
 * Description:  Finds the service in the peripheral's array of services which corresponds to the provided parameters.
 *
 *  Returns - the requested service or nil if service not found.
 *
 * Parameter(s): serviceIdentifier - string representation of the  service UUID
 *               peripheral - the peripheral to search for the service
 *
 */
-(CBService *)getService: (NSString *)serviceIdentifier forPeripheral:(CBPeripheral *)peripheral
{
    CBService *selectedService = nil;
    for (CBService *service in peripheral.services)
    {
        NSString *uuidString = [service.UUID representativeString];
        
        if ([[uuidString uppercaseString] localizedCompare:serviceIdentifier] == NSOrderedSame)
        {
            selectedService = service;
            break;
        }
    }

    return selectedService;
}


@end