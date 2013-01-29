//
//  BLEViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEViewController.h"

@interface BLEViewController ()
- (IBAction)scanButton;
- (IBAction)stopScanButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;
@property (weak, nonatomic) IBOutlet UILabel *scanStatus;
@property (strong, nonatomic) CBCentralManager *centralManager;

@property (nonatomic) BOOL scanForAllServices;

@end

@implementation BLEViewController

#pragma mark - Properties

- (IBAction)scanButton
{
    if (self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        NSLog(@"Starting scan...");
        
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
        NSLog(@"Scan request not executed, central manager not in powered on state");
        NSLog(@"Central Manager state: %@",[ [self class] getCBCentralStateName: self.centralManager.state]);
    }
    
}

- (IBAction)stopScanButton
{
    NSLog(@"Scan stopped");
    [self.scanActivityIndicator stopAnimating];
    self.scanStatus.text = @"Stopped";
    if (self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        [self.centralManager stopScan];
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
    
    _scanForAllServices = NO;
    
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
    //NSLog(@"Preparing to segue to ServiceList from SvanControl");
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
    NSLog(@"scan for all services delegate method invoked");
    // set scan control to scan for all services
    self.scanForAllServices = YES;
}



#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Central Manager Delegate DidUpdate State Invoked");
    self.hostBluetoothStatus.text = [[self class ] getCBCentralStateName: self.centralManager.state];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"A peripheral was discovered during scan.");
    
    // log the peripheral name
    NSLog(@"Peripheral Name:  %@",peripheral.name);
    
    // log the peripheral UUID
   // CFUUIDRef uuid = peripheral.UUID;
   // CFStringRef     uuidString      = NULL;
  //  uuidString = CFUUIDCreateString(NULL, uuid);
   // NSLog(@"Peripheral UUID: %@",uuidString);
    
    
    // log the advertisement keys
    NSLog(@"Logging advertisement keys descriptions");
    NSArray *keys = [advertisementData allKeys];
    for (id key in keys)
    {
        if ([key isKindOfClass:[NSString class]])
        {
            NSLog(@"advertisement key:  %@",key);
            id value = [advertisementData objectForKey:key];
            NSLog(@"advertisement value description %@", [value description]);
        }
        
    }
    
    // log the rssi value
    NSLog(@"RSSI value: %i", [RSSI shortValue]);
    
    
}

@end
