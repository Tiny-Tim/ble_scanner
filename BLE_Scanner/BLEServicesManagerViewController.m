//
//  BLEServicesManagerViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/5/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEServicesManagerViewController.h"
#import "BLEPeripheralServicesTVC.h"
#import "BLEPeripheralCharacteristicsTVC.h"
#import "CBUUID+StringExtraction.h"
#import "BLEDemoDispatcherViewController.h"

#include "ServiceAndCharacteristicMacros.h"

@interface BLEServicesManagerViewController ()

// label for status updating used when retreieving characteristics
@property (weak, nonatomic) IBOutlet UILabel *statusHeadingLabel;

// displays current activity
@property (weak, nonatomic) IBOutlet UILabel *statusDetailLabel;

// spinner which activates when peripheral being accessed
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusActivityIndicator;

// CBService which is being processed to retrieve characteristics
@property (nonatomic, strong)CBService *pendingServiceForCharacteristic;


- (IBAction)demosButton:(UIBarButtonItem *)sender;

@end

@implementation BLEServicesManagerViewController

@synthesize deviceRecord = _deviceRecord;



// class variable which is a set of known services for which a demo exists
static NSSet *_demoServices;

// static initializer
+(void)initialize
{
   _demoServices = [NSSet setWithObjects:
                    GENERIC_ACCESS_PROFILE,
                    IMMEDIATE_ALERT_SERVICE,
                    Tx_POWER_SERVICE,
                    DEVICE_INFORMATION_SERVICE,
                    HEART_RATE_MEASUREMENT_SERVICE,
                    BATTERY_SERVICE,
                    TI_KEYFOB_ACCELEROMETER_SERVICE,
                    TI_KEYFOB_KEYPRESSED_SERVICE,
                    nil ];
}


#pragma mark- Actions
- (IBAction)demosButton:(UIBarButtonItem *)sender
{
    DLog(@"Demos button tapped.");
    
    // segue to demo list view controller
     [self performSegueWithIdentifier:@"ShowDemoList" sender:self];
    
}


#pragma mark- Properties

// Setter for deviceRecord - the model for the controller
-(void)setDeviceRecord:(BLEPeripheralRecord *)deviceRecord
{
    // set the property
    _deviceRecord = deviceRecord;
    
    // the peripheral's services have been set at this point, determine if demos exist for any of the services
    for (CBService *service in _deviceRecord.peripheral.services)
    {
        NSString *uuidString = [[service.UUID representativeString]uppercaseString];
        
        if ([_demoServices containsObject:uuidString])
        {
            //enable the demo button in the tool bar
            [self.toolbarItems[0] setEnabled:YES];
            break;
        }
    }
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



- (void)viewDidLoad
{
    [super viewDidLoad];	
    [self setConnectionStatus];    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 *
 * Method Name:  prepareForSegue
 *
 * Description:  Seques to next scene in response to user action
 *
 * Parameter(s): seque - segue to execute
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ServiceList"])
    {
        DLog(@"Segueing to Show Service List");
        if ([segue.destinationViewController isKindOfClass:[BLEPeripheralServicesTVC class]])
        {
            BLEPeripheralServicesTVC  *destination = segue.destinationViewController;
            
            destination.delegate = self;
            destination.deviceRecord = self.deviceRecord;
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowCharacteristics"])
    {
        DLog(@"Segueing to Show Characteristics");
        if ([segue.destinationViewController isKindOfClass:[BLEPeripheralCharacteristicsTVC class]])
        {
            BLEPeripheralCharacteristicsTVC *destination = segue.destinationViewController;
            
            destination.characteristics = self.pendingServiceForCharacteristic.characteristics;
            
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowDemoList"])
    {
        DLog(@"Segueing to Show Demo List");
        if ([segue.destinationViewController isKindOfClass:[BLEDemoDispatcherViewController  class]])
        {
            BLEDemoDispatcherViewController *destination = segue.destinationViewController;
            
            destination.deviceRecord = self.deviceRecord;
            destination.demoServices = _demoServices;
        }
    }
    
}

#pragma mark- Private Methods

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
    if ([self.deviceRecord.peripheral isConnected])
    {
        self.statusDetailLabel.textColor = [UIColor greenColor];
        self.statusDetailLabel.text = @"Connected";
    }
    else
    {
        self.statusDetailLabel.textColor = [UIColor redColor];
        self.statusDetailLabel.text = @"Unconnected";
    }
}


// Discover characteristics for Service
-(void)discoverCharacteristicsForService: (CBService *) service
{
    if (service.peripheral && [service.peripheral isConnected])
    {
        if (service.peripheral.delegate == nil)
        {
            service.peripheral.delegate = self;
        }
        
        self.statusDetailLabel.textColor = [UIColor greenColor];
        self.statusDetailLabel.text = @"Discovering service characteristics.";
        [self.statusActivityIndicator startAnimating];
        [service.peripheral discoverCharacteristics:nil forService:service];
    }
}



#pragma mark - BLEServicesManagerDelegate


// Retrieve the characteristics for a specified service and segue to the characteristic table view controller
-(void)getCharacteristicsForService: (CBService *)service sender:(id)sender
{
    DLog(@"getCharacteristicsForService invoked in BLEPeripheralServicesTVC");
    
    self.pendingServiceForCharacteristic = service;
    
    if (service.characteristics)
    {
        // characteristics have been cached in service, just segue
        [self performSegueWithIdentifier:@"ShowCharacteristics" sender:self];
    }
    else
    {
        // get the characteristics from the service which will be returned from the peripheral delegate
        service.peripheral.delegate = self;
        [self discoverCharacteristicsForService:service];
    }
}



#pragma mark - CBPeripheralDelegate


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    DLog(@"didDiscoverCharacteristicsForService invoked");
    
    [self.statusActivityIndicator stopAnimating];
    self.statusDetailLabel.textColor = [UIColor blackColor];
    
     [self setConnectionStatus];
    
    if (error == nil)
    {
        // segue to BLEPeripheralCharacteristicsTVC
        [self performSegueWithIdentifier:@"ShowCharacteristics" sender:self];
    }
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didDiscoverDescriptorsForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    DLog(@"didDiscoverIncludedServicesForService invoked");
}




- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didUpdateNotificationStateForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didUpdateValueForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    DLog(@"didUpdateValueForDescriptor invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didWriteValueForCharacteristic invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    DLog(@"didWriteValueForDescriptor invoked");
}


- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    DLog(@"peripheralDidUpdateRSSI invoked");
}



@end
