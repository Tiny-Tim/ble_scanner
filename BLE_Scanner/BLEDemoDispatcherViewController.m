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
#include "ServiceAndCharacteristicMacros.h"

@interface BLEDemoDispatcherViewController ()

// Button handler
- (IBAction)serviceButtonTapped:(UIButton *)sender;

// Collection of buttons on the UI VIew
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *buttonCollection;

@property (nonatomic) BOOL debug;
@end

@implementation BLEDemoDispatcherViewController

@synthesize demoServices = _demoServices;


// copy the demo services set which is used to configure demo buttons in UI
-(void)setDemoServices:(NSSet *)demoServices
{
    _demoServices = [demoServices copy];
}

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
    
    while ((demoServiceID = [enumerator nextObject]))
    {
        bool matchFound = NO;
        // does device implement demo service?
        for (CBService *service in self.deviceRecord.peripheral.services)
        {
            NSString *UUIDString = [[service.UUID representativeString]uppercaseString];
            if ([UUIDString localizedCompare:demoServiceID] == NSOrderedSame)
            {
                matchFound = YES;
                break;
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
       
}


// Usual initializations.
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _debug = YES;
    
    // disable demo buttons for services this peripheral does not offer
    [self synchDemosWithDevice];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if ([sender.titleLabel.text hasPrefix:IMMEDIATE_ALERT_SERVICE])
    {
        if (self.debug) NSLog(@"Immediate Alert Service Selected");
    }
    else if ([sender.titleLabel.text hasPrefix:BATTERY_SERVICE])
    {
         if (self.debug) NSLog(@"Battery Service Selected");
        
        [self performSegueWithIdentifier:@"ShowBatteryDemo" sender:self];

    }
    else if ([sender.titleLabel.text hasPrefix:TI_KEYFOB_KEYPRESSED_SERVICE])
    {
        if (self.debug) NSLog(@"Key Pressed Service Selected");
        
        [self performSegueWithIdentifier:@"ShowKeyPressDemo" sender:self];
         
    }
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
        if (self.debug) NSLog(@"Segueing to Battery Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEBatteryServiceDemoViewController class]])
        {
            BLEBatteryServiceDemoViewController  *destination = segue.destinationViewController;
            
            for (CBService *service in _deviceRecord.peripheral.services)
            {
                NSString *uuidString = [service.UUID representativeString];
                
                if ([[uuidString uppercaseString] localizedCompare:BATTERY_SERVICE] == NSOrderedSame)
                {
                    destination.batteryService = service;
                    break;
                }
            }
            
            if (! destination.batteryService)
            {
                NSLog(@"Crash coming... expected battery service not found");
            }
            
        }

    }
    else if ([segue.identifier isEqualToString:@"ShowKeyPressDemo"])
    {
        if (self.debug) NSLog(@"Segueing to KeyPress Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEKeyPressDemoViewController class]])
        {
            BLEKeyPressDemoViewController *destination = segue.destinationViewController;
            for (CBService *service in _deviceRecord.peripheral.services)
            {
                NSString *uuidString = [service.UUID representativeString];
                
                if ([[uuidString uppercaseString] localizedCompare:TI_KEYFOB_KEYPRESSED_SERVICE] == NSOrderedSame)
                {
                    destination.keyPressedService = service;
                    break;
                }
            }

            
        }
        
        
    }
}

@end