//
//  BLEViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEViewController.h"
#import "BLEDiscoveredDevicesTVC.h"

@interface BLEViewController ()

// initiate scanning
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanBarButton;

// animate when scanning
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanActivityIndicator;

// displays CBCentralManager status (role of iphone/ipad)
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;

// label which displays stopped or scanning
@property (weak, nonatomic) IBOutlet UILabel *scanStatus;

// CBCentral Manager 
@property (strong, nonatomic) CBCentralManager *centralManager;

// reference to embedded discovered device list table view controller
@property (nonatomic, strong) BLEDiscoveredDevicesTVC *discoveredDeviceList;

// flag which holds current scan configuration state (scan for all services or for specific services)
@property (nonatomic) BOOL scanForAllServices;

// controls NSLogging
@property (nonatomic) BOOL debug;

// flag indicating whether scanning is currently active
@property (nonatomic) BOOL scanState;
@end

@implementation BLEViewController


#pragma mark - Properties

// toggle button, initiate scanning if not scanning or stops scanning if scanning
- (IBAction)scanButton
{
    if (! self.scanState)
    {
        
        if (self.centralManager.state == CBCentralManagerStatePoweredOn)
        {
            self.scanState = YES;  // scanning
            self.scanBarButton.title = @"Stop";
            
            if (self.debug) NSLog(@"Starting scan...");
            
            if (self.scanForAllServices)
            {
                
                self.scanStatus.textColor = [UIColor greenColor];
                self.scanStatus.text = @"Scanning for all services.";
                
                [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            }
            else
            {
                self.scanStatus.textColor = [UIColor greenColor];
                self.scanStatus.text = @"Scanning for specified services.";
                // scan only for services specified by user
                
                // tbd fix this to pass in array of services
                [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            }
            [self.scanActivityIndicator startAnimating];
        }
        else
        {
            if (self.debug) NSLog(@"Scan request not executed, central manager not in powered on state");
            if (self.debug) NSLog(@"Central Manager state: %@",[ [self class] getCBCentralStateName: self.centralManager.state]);
        }
    }
    else  // stop scanning
    {
        if (self.debug) NSLog(@"Scan stopped");
        [self.scanActivityIndicator stopAnimating];
        self.scanStatus.textColor = [UIColor blackColor];
        self.scanStatus.text = @"Stopped";
        if (self.centralManager.state == CBCentralManagerStatePoweredOn)
        {
            [self.centralManager stopScan];
        }

        self.scanBarButton.title = @"Scan";
        self.scanState = NO;
    }
    
}


#pragma mark - Helper Functions

// Converts CBCentralManagerState to a string... implement as a category on CBCentralManagerState?
+(NSString *)getCBCentralStateName:(CBCentralManagerState) state
{
    NSString *stateName;
    
    switch (state) {
        case CBCentralManagerStatePoweredOn:
            stateName = @"Bluetooth Powered On - Ready";
            break;
        case CBCentralManagerStateResetting:
            stateName = @"Resetting";
            break;
            
        case CBCentralManagerStateUnsupported:
            stateName = @"Unsupported";
            break;
            
        case CBCentralManagerStateUnauthorized:
            stateName = @"Unauthorized";
            break;
            
        case CBCentralManagerStatePoweredOff:
            stateName = @"Bluetooth Powered Off";
            break;
            
        default:
            stateName = @"Unknown";
            break;
    }
    return stateName;
}


#pragma - Controller Lifecycle

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialize central manager providing self as its delegate
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // default is to scan for all services if scan is not configured
    _scanForAllServices = YES;
    
    _scanState = NO;  // not scanning
    
    _debug = YES;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Seque to either the embedded discovered services table view controller or to scan control table view controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.debug) NSLog(@"Preparing to segue from ScanControl");
    BLEScanControlTVC *scanConfigure;
    
    if ([segue.identifier isEqualToString:@"ConfigureScan"])
    {
        if (self.debug) NSLog(@"Segueing to Configure Scan");
        if ([segue.destinationViewController isKindOfClass:[BLEScanControlTVC class]])
        {
            scanConfigure = segue.destinationViewController;
            scanConfigure.delegate = self;
            
        }
    }
    else if ([segue.identifier isEqualToString:@"DiscoveredDevices"])
    {
        if (self.debug) NSLog(@"Segueing to Discovered Devices");
          if ([segue.destinationViewController isKindOfClass:[BLEDiscoveredDevicesTVC class]])
          {
              self.discoveredDeviceList = segue.destinationViewController;
          }
    }
}


#pragma mark -  BLEScanControlDelegate

// Scan for all services unless services list is not nil. If services are provided then scan just for those services.
-(void) scanForServices: (NSArray *)services sender:(id)sender
{
    if (self.debug) NSLog(@"scan for all services delegate method invoked");
    // set scan control to scan for all services
    self.scanForAllServices = YES;
    
    // fix when implemented
    if (services != nil)
    {
       // self.scanForAllServices = NO;
    }
    
   
}



#pragma mark - CBCentralManagerDelegate
// CBCentralManager state changed
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (self.debug) NSLog(@"Central Manager Delegate DidUpdate State Invoked");
   
    
    
    if (self.centralManager.state ==CBCentralManagerStatePoweredOn)
    {
        self.hostBluetoothStatus.textColor = [UIColor greenColor];
    }
    else if ( (self.centralManager.state == CBCentralManagerStateUnknown) ||
              (self.centralManager.state == CBCentralManagerStateResetting) )
        
    {
        self.hostBluetoothStatus.textColor = [UIColor blackColor];
    }
    else
    {
        self.hostBluetoothStatus.textColor = [UIColor redColor];
    }
    
    self.hostBluetoothStatus.text = [[self class ] getCBCentralStateName: self.centralManager.state];
    
    
}


// A peripheral was discovered during scan.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (self.debug) NSLog(@"A peripheral was discovered during scan.");
    
    // log the peripheral name
    if (self.debug) NSLog(@"Peripheral Name:  %@",peripheral.name);
    
    // log the peripheral UUID
    CFUUIDRef uuid = peripheral.UUID;
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    NSString *uuid_string = CFBridgingRelease(s);
    if (self.debug)  NSLog(@"Peripheral UUID: %@",uuid_string);
    
    
    // create a UUID from the NSString
    CFUUIDRef uuidCopy = CFUUIDCreateFromString (NULL, CFBridgingRetain(uuid_string));
    
                                      
    BOOL areEqual = CFEqual(uuid, uuidCopy);
    if (self.debug) NSLog(@"Copmaring 2 UUIDs result: %@", areEqual ? @"YES" : @"NO" ) ;
        
    // log the advertisement keys
    if (self.debug) NSLog(@"Logging advertisement keys descriptions");
    NSArray *keys = [advertisementData allKeys];
    for (id key in keys)
    {
        if ([key isKindOfClass:[NSString class]])
        {
            id value = [advertisementData objectForKey:key];
            
            if (self.debug) NSLog(@"advertisement key:  %@  value:  %@",key, [value description]);
        }
    }
    
    // log the rssi value
    if (self.debug) NSLog(@"RSSI value: %i", [RSSI shortValue]);
    
    BLEDiscoveryRecord *discoveryRecord = [[BLEDiscoveryRecord alloc] initWithCentral:central didDiscoverPeripheral:peripheral withAdvertisementData:advertisementData withRSSI:RSSI];
    
    // add the discovered peripheral to the list of discovered peripherals
    [self.discoveredDeviceList deviceDiscovered:discoveryRecord];
}

@end
