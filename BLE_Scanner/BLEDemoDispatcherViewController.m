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

@interface BLEDemoDispatcherViewController ()

- (IBAction)serviceButtonTapped:(UIButton *)sender;

@property (nonatomic) BOOL debug;
@end

@implementation BLEDemoDispatcherViewController

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
    _debug = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)serviceButtonTapped:(UIButton *)sender
{
    
    if ([sender.titleLabel.text hasPrefix:@"1802"])
    {
        if (self.debug) NSLog(@"Immediate Alert Service Selected");
    }
    else if ([sender.titleLabel.text hasPrefix:@"180F"])
    {
         if (self.debug) NSLog(@"Battery Service Selected");
        
         // make sure battery service is offered by device
        // (TBD - don't offer this button choice if not there)
        
        [self performSegueWithIdentifier:@"ShowBatteryDemo" sender:self];

    }
}


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
                
                if ([[uuidString uppercaseString] localizedCompare:@"180F"] == NSOrderedSame)
                {
                    destination.batteryService = service;
                    break;
                }
            }
            
            if (! destination.batteryService)
            {
                NSLog(@"Crash coming... expected service not found");
            }
            
        }

    }
}

@end