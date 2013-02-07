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


@interface BLEServicesManagerViewController ()

// controls NSLogging
@property (nonatomic) BOOL debug;

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
static NSSet *_demoServces; 

// static initializer
+(void)initialize
{
   _demoServces = [NSSet setWithObjects:@"1802", @"180F",@"FFE0", nil ]; 
}


- (IBAction)demosButton:(UIBarButtonItem *)sender
{
    if (self.debug) NSLog(@"Demos button tapped.");
    
    // segue to demo list view controller
     [self performSegueWithIdentifier:@"ShowDemoList" sender:self];
    
}


-(void)setDeviceRecord:(BLEPeripheralRecord *)deviceRecord
{
    // set the property
    _deviceRecord = deviceRecord;
    
    // the peripheral's services have been set at this point, determine if demos exist for any of the services
    for (CBService *service in _deviceRecord.peripheral.services)
    {
        NSString *uuidString = [service.UUID representativeString];
        
        if ([_demoServces containsObject:uuidString])
        {
            //enable the demo button in the tool bar
            [self.toolbarItems[0] setEnabled:YES];
            break;
        }
    }
    
}


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
    _debug = YES;
	// Do any additional setup after loading the view.
    
    if ([self.deviceRecord.peripheral isConnected])
    {
        self.statusDetailLabel.text = @"Connected";
    }
    else
    {
        self.statusDetailLabel.text = @"Unconnected";
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ServiceList"])
    {
        if (self.debug) NSLog(@"Segueing to Show Service List");
        if ([segue.destinationViewController isKindOfClass:[BLEPeripheralServicesTVC class]])
        {
            BLEPeripheralServicesTVC  *destination = segue.destinationViewController;
            
            destination.delegate = self;
            destination.deviceRecord = self.deviceRecord;
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowCharacteristics"])
    {
        if (self.debug) NSLog(@"Segueing to Show Characteristics");
        if ([segue.destinationViewController isKindOfClass:[BLEPeripheralCharacteristicsTVC class]])
        {
            BLEPeripheralCharacteristicsTVC *destination = segue.destinationViewController;
            
            destination.characteristics = self.pendingServiceForCharacteristic.characteristics;
            
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowDemoList"])
    {
        if (self.debug) NSLog(@"Segueing to Show Demo List");
        if ([segue.destinationViewController isKindOfClass:[BLEDemoDispatcherViewController  class]])
        {
           // BLEServiceDemoDispatcherViewController *destination = segue.destinationViewController;
            
          //  destination.characteristics = self.pendingServiceForCharacteristic.characteristics;
            
        }
    }
    
}

#pragma mark - BLEServicesManagerDelegate
// Retrieve the characteristics for a specified service and segue to the characteristic table view controller
-(void)getCharacteristicsForService: (CBService *)service sender:(id)sender
{
    if (self.debug) NSLog(@"getCharacteristicsForService invoked in BLEPeripheralServicesTVC");
    
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
    if (self.debug) NSLog(@"didDiscoverCharacteristicsForService invoked");
    
    
    [self.statusActivityIndicator stopAnimating];
    self.statusDetailLabel.textColor = [UIColor blackColor];
    
    
    if ([peripheral isConnected])
    {
       self.statusDetailLabel.text = @"Connected"; 
    }
    else
    {
        self.statusDetailLabel.text = @"Unconnected"; 
    }
   
   
    if (error == nil)
    {
        // segue to BLEPeripheralCharacteristicsTVC
        [self performSegueWithIdentifier:@"ShowCharacteristics" sender:self];
    }
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverDescriptorsForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverIncludedServicesForService invoked");
}




- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateNotificationStateForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateValueForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateValueForDescriptor invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didWriteValueForCharacteristic invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (self.debug) NSLog(@"didWriteValueForDescriptor invoked");
}


- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.debug) NSLog(@"peripheralDidUpdateRSSI invoked");
}





@end
