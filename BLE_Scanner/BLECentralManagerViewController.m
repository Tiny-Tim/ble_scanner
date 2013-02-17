//
//  BLEViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLECentralManagerViewController.h"
#import "BLEPeripheralServicesTVC.h"
#import "BLEServicesManagerViewController.h"


@interface BLECentralManagerViewController ()

// initiate scanning
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanBarButton;

// animate when central manager scanning, connecting, etc.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *centralManagerActivityIndicator;

// displays CBCentralManager status (role of iphone/ipad)
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;

// label which displays central manager activity
@property (weak, nonatomic) IBOutlet UILabel *centralManagerStatus;

// CBCentral Manager 
@property (strong, nonatomic) CBCentralManager *centralManager;

// reference to embedded discovered device list table view controller
@property (nonatomic, strong) BLEDiscoveredDevicesTVC *discoveredDeviceList;

// flag indicating whether scanning is currently active
@property (nonatomic) BOOL scanState;

// list of connected peripherals
@property (nonatomic, strong)NSMutableArray *connectedPeripherals;

// selected connected peripheral to display
@property (nonatomic, strong)CBPeripheral *selectedPeripheral;

// peripheral record which is being processed for services
@property (nonatomic, strong)BLEPeripheralRecord *displayServiceTarget;

@end

@implementation BLECentralManagerViewController

#pragma mark- Actions

// User cancels connect request
- (IBAction)stopConnect:(id)sender
{
    [self.centralManager cancelPeripheralConnection:self.selectedPeripheral];
    
    NSArray *toolbarItems = self.toolbarItems;
    [[toolbarItems objectAtIndex:[toolbarItems count]-1]setEnabled:NO];
    
    [self.centralManagerActivityIndicator stopAnimating];
    self.centralManagerStatus.textColor = [UIColor blackColor];
    self.centralManagerStatus.text = @"Idle";
    
}


// toggle button, initiate scanning if not scanning or stops scanning if scanning
- (IBAction)scanButton
{
    if (! self.scanState)
    {
        if (self.centralManager.state == CBCentralManagerStatePoweredOn)
        {
            self.scanState = YES;  // scanning
            self.scanBarButton.title = @"Stop";
            
            DLog(@"Starting scan...");
            
            self.centralManagerStatus.textColor = [UIColor greenColor];
            self.centralManagerStatus.text = @"Scanning for all services.";
                
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            
            [self.centralManagerActivityIndicator startAnimating];
        }
        else
        {
            DLog(@"Scan request not executed, central manager not in powered on state");
            DLog(@"Central Manager state: %@",[ [self class] getCBCentralStateName: self.centralManager.state]);
        }
    }
    else  // stop scanning
    {
        DLog(@"Scan stopped");
        [self.centralManagerActivityIndicator stopAnimating];
        self.centralManagerStatus.textColor = [UIColor blackColor];
        self.centralManagerStatus.text = @"Idle";
        if (self.centralManager.state == CBCentralManagerStatePoweredOn)
        {
            [self.centralManager stopScan];
        }
        
        self.scanBarButton.title = @"Scan";
        self.scanState = NO;
    }
}


#pragma mark - Properties


-(NSMutableArray *)connectedPeripherals
{
    if (_connectedPeripherals == nil)
    {
        _connectedPeripherals = [NSMutableArray array];
    }
    
    return _connectedPeripherals;
}




#pragma mark - Private Functions

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


// Cpnnect to specified peripheral if not already connected
-(void) connectToPeripheralDevice : (CBPeripheral *)peripheral
{
   
    // Implement checks before connecting, i.e. already connected
    if (peripheral && ! [peripheral isConnected])
    {
        NSArray *toolbarItems = self.toolbarItems;
        [[toolbarItems objectAtIndex:[toolbarItems count]-1]setEnabled:YES];
        DLog(@"CBCentralManager connecting to peripheral");
        self.centralManagerStatus.textColor = [UIColor greenColor];
        self.centralManagerStatus.text = @"Connecting to peripheral.";
        [self.centralManagerActivityIndicator startAnimating];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    else if (peripheral)
    {
        DLog(@"Request for CentralManager to connect to a connected peripheral ignored.");
    }
    else
    {
        DLog(@"Request to connect CentralManager to nil peripheral pointer ignored.");
    }
        
}


// Discover services for peripheral and update UI activity indicators
-(void) discoverPeripheralServices : (CBPeripheral *)peripheral
{
    // Implement checks before connecting, i.e. already connected
    if (peripheral &&  [peripheral isConnected])
    {
        if (peripheral.delegate == nil)
        {
            peripheral.delegate = self;
        }
        
        self.centralManagerStatus.textColor = [UIColor greenColor];
        self.centralManagerStatus.text = @"Discovering peripheral services.";
        [self.centralManagerActivityIndicator startAnimating];
        // Discover all services
        [peripheral discoverServices:nil];
        
    }
    else
    {
        DLog(@"Request to discover peripheral services not executed");
    }
}





// Disconnect a peripheral from Central after ensuring peripheal is in connected state
-(void) disconnectPeripheralDevice:(CBPeripheral *)peripheral
{
    // Ensure peripheral is connected
    if (peripheral && [peripheral isConnected])
    {
        DLog(@"CBCentralManager disconnecting peripheral");
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    else if (peripheral)
    {
        DLog(@"Request for CentralManager to disconnect an unconnected peripheral ignored.");
    }
    else
    {
        DLog(@"Request to disconnect CentralManager to nil peripheral pointer ignored.");
    }
}


// synchronize connected peripherals with button states
// if a connected peripheral is disconnected by the system, remove it from the list
// and update button labels to allow it to be re-connected
-(void)synchronizeConnectedPeripherals
{
    NSArray *peripheralList = [self.connectedPeripherals copy];
    for (CBPeripheral *peripheral in peripheralList)
    {
        if (! peripheral.isConnected)
        {
            // remove from list and update buttons in discovered devices
            [self.connectedPeripherals removeObject:peripheral];
            [self.discoveredDeviceList toggleConnectionState:peripheral];
        }
    }
    
    // update the table to reflect change of peripheral state
    [self.discoveredDeviceList.tableView reloadData];
}

#pragma - Controller Lifecycle

-(void)awakeFromNib
{
    [super awakeFromNib];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initialize central manager providing self as its delegate
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    _scanState = NO;  // not scanning
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"Entering viewWillAppear Central Manager View Controller");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Seque to either the embedded discovered services table view controller or to scan control table view controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DLog(@"Preparing to segue from ScanControl");

    if ([segue.identifier isEqualToString:@"DiscoveredDevices"])
    {
        DLog(@"Segueing to Discovered Devices");
          if ([segue.destinationViewController isKindOfClass:[BLEDiscoveredDevicesTVC class]])
          {
              self.discoveredDeviceList = segue.destinationViewController;
              self.discoveredDeviceList.delegate = self;
          }
    }
    else if ([segue.identifier isEqualToString:@"ShowServices"])
    {
        DLog(@"Segueing to Show Services");
        if ([segue.destinationViewController isKindOfClass:[BLEServicesManagerViewController class]])
        {
            BLEServicesManagerViewController *destination = segue.destinationViewController;
            
            destination.deviceRecord = self.displayServiceTarget;
           
            
        }
    }
}


#pragma mark - BLECentralManagerDelegate

// Request to connect Central Manager to peripheral from list of discovered device peripherals
-(void)connectPeripheral: (CBPeripheral *)peripheral sender:(id)sender;
{
    self.selectedPeripheral = peripheral;
    self.centralManagerStatus.text = @"Connecting to peripheral";
    [self connectToPeripheralDevice:peripheral];
}


// Request to disconnect Central Manager from peripheral
-(void)disconnectPeripheral: (CBPeripheral *)peripheral sender:(id)sender
{
    self.centralManagerStatus.text = @"Disconnecting peripheral";
    [self disconnectPeripheralDevice:peripheral];

}

// Display services for peripheral information and segue to services table view controller
-(void)getServicesForPeripheral: (BLEPeripheralRecord *)deviceRecord sender:(id)sender;
{
    DLog(@"getServicesForPeripheral invoked on BLECentralManagerDelegate ");
   
    // Processing can only get here if the device is connected or if the device is disconnected and services have been cached. Display the cached service list if it exists in all cases. If no cache services exist and device is connected then retrieve services from peripheral.
    
    // save selected device for use in prepare for segue 
    self.displayServiceTarget = deviceRecord;
    
    // cached services are saved in the CBPeripheral object
    // checking for cached services is postponed until here so that segueing can occur from this view controller
    if (deviceRecord.peripheral.services)
    {
        // segue to service list view controller
        [self performSegueWithIdentifier:@"ShowServices" sender:self];
    }
    else
    {
        // get the services from the peripheral which will be returned via the peripheral delegate
        [self discoverPeripheralServices:deviceRecord.peripheral];
    }
}



#pragma mark - CBCentralManagerDelegate
// CBCentralManager state changed
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    DLog(@"Central Manager Delegate DidUpdate State Invoked");
    
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
    DLog(@"A peripheral was discovered during scan.");
    
    // log the peripheral name
    DLog(@"Peripheral Name:  %@",peripheral.name);
    
    // log the peripheral UUID
    CFUUIDRef uuid = peripheral.UUID;
    if (uuid)
    {
        CFStringRef s = CFUUIDCreateString(NULL, uuid);
        NSString *uuid_string = CFBridgingRelease(s);
         DLog(@"Peripheral UUID: %@",uuid_string);
    }
    else
    {
        DLog(@"Discovered peripheral provided no UUID on initial discovery");
    }
    
    
    // create a UUID from the NSString
 //   CFUUIDRef uuidCopy = CFUUIDCreateFromString (NULL, CFBridgingRetain(uuid_string));
 //   BOOL areEqual = CFEqual(uuid, uuidCopy);
 //   DLog(@"Comparing 2 UUIDs result: %@", areEqual ? @"YES" : @"NO" ) ;
        
    // log the advertisement keys
    DLog(@"Logging advertisement keys descriptions");
    NSArray *keys = [advertisementData allKeys];
    for (id key in keys)
    {
        if ([key isKindOfClass:[NSString class]])
        {
            id value = [advertisementData objectForKey:key];
            
            DLog(@"advertisement key:  %@  value:  %@",key, [value description]);
        }
    }
    
    if (RSSI)
    {
        // log the rssi value
        DLog(@"RSSI value: %i", [RSSI shortValue]);
    }
    else
    {
        DLog(@"Discovered peripheral data did not include RSSI");
    }
    
    BLEPeripheralRecord *discoveryRecord = [[BLEPeripheralRecord alloc] initWithCentral:central didDiscoverPeripheral:peripheral withAdvertisementData:advertisementData withRSSI:RSSI];
    
    // add the discovered peripheral to the list of discovered peripherals
    [self.discoveredDeviceList deviceDiscovered:discoveryRecord];
    
    
}

//Invoked whenever a connection is succesfully created with the peripheral.
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // display idle status for Central
    [self.centralManagerActivityIndicator stopAnimating];
    self.centralManagerStatus.textColor = [UIColor blackColor];
    self.centralManagerStatus.text = @"Idle";
   
    DLog(@"Connected to peripheral");
    
    [self.connectedPeripherals addObject:peripheral];
   
    // toggle connect button label in corresponding discovered devices table view row
    [self.discoveredDeviceList toggleConnectionState:peripheral];
    
    NSArray *toolbarItems = self.toolbarItems;
    [[toolbarItems objectAtIndex:[toolbarItems count]-1]setEnabled:NO];
    
}

//Invoked whenever an existing connection with the peripheral is torn down.
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (! error)
    {
        DLog(@"Peripheral succssfully disconnected.");
        
        // Normally, following a successful connection the periphral is just removed from the peripheral list and the connect button label is toggled. However, if the user manually cancels the connect attempt, the canceled peripheral will not be in the list and the toggleConnection state should not be called.
        
        // we can tell if the peripheral was removed by examining the array count before and after removal
        
        NSUInteger preRemovalCount = [self.connectedPeripherals count];
        
        DLog(@"Pre-removal connected count %d",preRemovalCount);
        // remove peripheral from connected list
        [self.connectedPeripherals removeObject:peripheral];
    
        // display idle status for Central
        self.centralManagerStatus.text = @"idle";
        
        DLog(@"Post-removal connected count %d",[self.connectedPeripherals count]);
        
        if (preRemovalCount > [self.connectedPeripherals count])
        {
           // toggle connect button label in corresponding discovered devices table view row
           [self.discoveredDeviceList toggleConnectionState:peripheral];
        }
    
    }
    else 
    {
        DLog(@"Error disconnecting: %@",[error localizedDescription]);
        
        // This could occur for several reasons, a connection may have ben dropped by the system without the user initiating a disconnect, or a disconnect request could fail.
        
        // The course of action is to synch the state of the connected peripherals in the connected peripheral list and their corresponding connect/disconnect buttons in the discovered peripheral list.
        [self synchronizeConnectedPeripherals];
        
    }
    
}


//Invoked whenever the central manager fails to create a connection with the peripheral.
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DLog(@"Failed to connect to peripheral");
}


//Invoked when the central manager retrieves the list of peripherals currently connected to the system.
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    DLog(@"Central Manager didRetrieveConnectedPeripherals invoked.");
}


//Invoked when the central manager retrieves the list of known peripherals.
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    DLog(@"Central Manager didRetrievePeripherals invoked.");
}


#pragma mark - CBPeripheralDelegate



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didDiscoverDescriptorsForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
     DLog(@"didDiscoverIncludedServicesForService invoked");
}


// Invoked upon completion of a -[discoverServices:] request.
//
//If successful, "error" is nil and discovered services, if any, have been merged into the "services" property of the peripheral. If unsuccessful, "error" is set with the encountered failure.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    DLog(@"didDiscoverServices invoked");
    
    [self.centralManagerActivityIndicator stopAnimating];
    self.centralManagerStatus.textColor = [UIColor blackColor];
    self.centralManagerStatus.text = @"Idle";

    if (error == nil)
    {
        // segue to BLEPeripheralServicesTVC
        [self performSegueWithIdentifier:@"ShowServices" sender:self];
    }
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
