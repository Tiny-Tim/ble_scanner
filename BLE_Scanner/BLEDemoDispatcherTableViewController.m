//
//  BLEDemoDispatcherTableViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 3/8/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDemoDispatcherTableViewController.h"
#import "BLEBatteryServiceDemoViewController.h"
#import "CBUUID+StringExtraction.h"
#import "BLEKeyPressDemoViewController.h"
#import "BLEAccelerometerDemoViewController.h"
#import "BLEHeartRateDemoViewController.h"
#include "ServiceAndCharacteristicMacros.h"
#import "BLEDeviceInformationDemoViewController.h"
#import "BLELeashDemoViewController.h"
#import "BLEGenericAccessDemoViewController.h"


#define INITIAL_DEMO_ARRAY_CAPACITY 5
#define ELECTRONIC_LEASH_KEY @"7777"


@interface BLEDemoDispatcherTableViewController ()

@property(nonatomic, strong)NSMutableArray *peripheralDemoServices;

@property(nonatomic, strong)NSDictionary *demoLabels;
@end

@implementation BLEDemoDispatcherTableViewController

-(NSDictionary *)demoLabels
{
    if (_demoLabels == nil)
    {
        // object,key nil terminated
        _demoLabels = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"Generic Access Profile", GENERIC_ACCESS_PROFILE,
                       @"Device Information Service", DEVICE_INFORMATION_SERVICE,
                       @"Heart Rate Service", HEART_RATE_MEASUREMENT_SERVICE,
                       @"Battery Service", BATTERY_SERVICE,
                       @"Electronic Leash", ELECTRONIC_LEASH_KEY,
                       @"Key Fob Accelerometer", TI_KEYFOB_ACCELEROMETER_SERVICE,
                       @"Key Fob Key Press",TI_KEYFOB_KEYPRESSED_SERVICE,
                       nil];
    }
    return _demoLabels;
}

-(NSMutableArray *)peripheralDemoServices
{
    if (_peripheralDemoServices == nil)
    {
        _peripheralDemoServices = [NSMutableArray arrayWithCapacity:INITIAL_DEMO_ARRAY_CAPACITY];
    }
    
    return _peripheralDemoServices;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self synchDemosWithDevice];

}

/*
 *
 * Method Name:  prepareForSegue
 *
 * Description:  Handles the segue to BLEPeripheralServices
 *
 * Parameter(s): segue - the seque which is imminent
 *               sender - the orignination of the segue request
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DLog(@"Preparing to segue from DemoDispatcherTVC");
    
    if ([segue.identifier isEqualToString:@"Battery Service"])
    {
        DLog(@"Segueing to Battery Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEBatteryServiceDemoViewController class]])
        {
            BLEBatteryServiceDemoViewController  *destination = segue.destinationViewController;
            
            destination.batteryService = [self getService:BATTERY_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString: @"Generic Access Profile"])
    {
        DLog(@"Segueing to Generic Access Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEGenericAccessDemoViewController class]])
        {
            
            BLEGenericAccessDemoViewController *destination = segue.destinationViewController;
            destination.genericAccessProfileService= [self getService:GENERIC_ACCESS_PROFILE forPeripheral:self.peripheral];
        }
    }
    
    else if ([segue.identifier isEqualToString:@"Key Fob Key Press"])
    {
        DLog(@"Segueing to KeyPress Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEKeyPressDemoViewController class]])
        {
            
            BLEKeyPressDemoViewController *destination = segue.destinationViewController;
            destination.keyPressedService= [self getService:TI_KEYFOB_KEYPRESSED_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString:@"Key Fob Accelerometer"])
    {
        DLog(@"Segueing to Accelerometer Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEAccelerometerDemoViewController class]])
        {
            BLEAccelerometerDemoViewController *destination = segue.destinationViewController;
            destination.accelerometerService = [self getService:TI_KEYFOB_ACCELEROMETER_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString:@"Heart Rate Service"])
    {
        DLog(@"Segueing to Heart Rate Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEHeartRateDemoViewController class]])
        {
            BLEHeartRateDemoViewController *destination = segue.destinationViewController;
            destination.heartRateService = [self getService:HEART_RATE_MEASUREMENT_SERVICE forPeripheral:self.peripheral];
            // destination.centralManagerDelegate = self.centralManagerDelegate;
        }
    }
    else if ([segue.identifier isEqualToString:@"Device Information Service"])
    {
        DLog(@"Segueing to Device Information Demo");
        if ([segue.destinationViewController isKindOfClass:[BLEDeviceInformationDemoViewController class]])
        {
            BLEDeviceInformationDemoViewController *destination = segue.destinationViewController;
            destination.deviceInformationService = [self getService:DEVICE_INFORMATION_SERVICE forPeripheral:self.peripheral];
        }
    }
    else if ([segue.identifier isEqualToString:@"Electronic Leash"])
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


/*
 *
 * Method Name:  synchDemosWithDevice
 *
 * Description:  Identify peripheral services which match demo services. Construct an array containing labels 
 * for demo services supported by the peripheral which will be the source of data for the table view.
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
                if ([UUIDString localizedCaseInsensitiveCompare:Tx_POWER_SERVICE] == NSOrderedSame)
                {
                    transmitPowerFound = YES;
                    break;
                    
                }
                else if ([UUIDString localizedCaseInsensitiveCompare:IMMEDIATE_ALERT_SERVICE] == NSOrderedSame)
                {
                    immediateAlertFound = YES;
                    break;
                    
                }
                else
                {
                    matchFound = YES;
                    break;
                }
            }
            
            
        }
        
        if (matchFound)
        {
            [self.peripheralDemoServices addObject: demoServiceID];
            
        }
    }
    
    if (transmitPowerFound && immediateAlertFound)
    {
        [self.peripheralDemoServices addObject:ELECTRONIC_LEASH_KEY];

    }
    
    
    
}



#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    DLog(@"Number of Demo Rows:  %d", [self.peripheralDemoServices count]);
    return [self.peripheralDemoServices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DemoSelectorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.demoLabels objectForKey:[self.peripheralDemoServices objectAtIndex:indexPath.row]];
    
    DLog(@"Row: %d",indexPath.row);
    DLog(@"Cell Label = %@",cell.textLabel.text);
    
    // Configure the cell...
    
    return cell;
}





#pragma mark - Table view delegate


// Accessory button handler
// Perform a matching test with the path index to identify what peripheral (section) and row is associated with the accessory button and then dispatch the execution of the handler to back to the central view controller.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
     [self performSegueWithIdentifier:[self.demoLabels objectForKey:[self.peripheralDemoServices objectAtIndex:indexPath.row]] sender:self.peripheral];
}



@end
