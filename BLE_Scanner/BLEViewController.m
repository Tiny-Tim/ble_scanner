//
//  BLEViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEViewController.h"

@interface BLEViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanBarButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;
@property (weak, nonatomic) IBOutlet UILabel *scanStatus;
@property (strong, nonatomic) CBCentralManager *centralManager;

@property (nonatomic) BOOL scanForAllServices;

@property (nonatomic) BOOL debug;

@property (nonatomic) BOOL scanState;
@end

@implementation BLEViewController


#pragma mark - Properties

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
                self.scanStatus.text = @"Scanning for all services.";
                [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            }
            else
            {
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



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.debug) NSLog(@"Preparing to segue to ServiceList from SvanControl");
    BLEScanControlTVC *scanConfigure;
    
    if ([segue.identifier isEqualToString:@"ConfigureScan"])
    {
        
        if ([segue.destinationViewController isKindOfClass:[BLEScanControlTVC class]])
        {
            scanConfigure = segue.destinationViewController;
            scanConfigure.delegate = self;
            
        }
    }
}


#pragma mark -  BLEScanControlDelegate


-(void) scanForAllServices: (id)sender
{
    if (self.debug) NSLog(@"scan for all services delegate method invoked");
    // set scan control to scan for all services
    self.scanForAllServices = YES;
}



#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (self.debug) NSLog(@"Central Manager Delegate DidUpdate State Invoked");
    self.hostBluetoothStatus.text = [[self class ] getCBCentralStateName: self.centralManager.state];
    
}

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
    
    
}

@end
