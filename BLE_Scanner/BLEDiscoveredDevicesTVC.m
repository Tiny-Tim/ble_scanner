//
//  BLEDiscoveredDevicesTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDiscoveredDevicesTVC.h"
#import "BLEConnectButtonCell.h"
#import "BLEDetailCellData.h"
#import "BLEPeripheralServicesTVC.h"
#import "BLECentralManagerViewController.h"


// A label embedded in the data which displays ADVERTISING DATA in the table
//#define ADVERTISEMENT_ROW 4
#define NAME_LABEL  @"Name:  "
#define UUID_LABEL @"UUID:  "
#define CONNECTED_LABEL @"Connected: "
#define RSSI_LABEL @"RSSI:  "
#define SERVICES_LABEL @"SERVICES:  "

@interface BLEDiscoveredDevicesTVC ()


// The model for this table view controller
//@property (nonatomic, strong)NSMutableArray *deviceRecords;

// data structure containing labels for rows in table
@property (nonatomic, strong) NSMutableArray *sections;


- (IBAction)connectButton:(UIButton *)sender;

// management of the UISplitViewController button and popover
@property (strong,nonatomic) UIPopoverController* masterPopoverController;
@end

@implementation BLEDiscoveredDevicesTVC

@synthesize sections = _sections;
@synthesize discoveredPeripherals = _discoveredPeripherals;



#pragma mark- Properties

-(NSArray *)discoveredPeripherals
{
    if (_discoveredPeripherals == nil)
    {
        _discoveredPeripherals = [NSMutableArray array];
    }
    
    return _discoveredPeripherals;
}

-(void)setDiscoveredPeripherals:(NSArray *)discoveredPeripherals
{
    _discoveredPeripherals = discoveredPeripherals;
    if (_discoveredPeripherals)
    {
        
        // set up the sections
        for (BLEPeripheralRecord *record in discoveredPeripherals)
        {
            // this array will be added to section
            NSMutableArray *deviceInfo;
            //
            deviceInfo = [self updateDeviceLabelsForDevice:record];
            [[self.sections objectAtIndex:0] addObject:deviceInfo];
        }
        
        [self.tableView reloadData];
    }
}


// DiscoveredDevicesTVC model.
// 
//
// Sections is the data structure for the table where each section corresponds to a discovered peripheral. The array has two elements:
//    index 0 - an array which has an element for each discovered peripheral.
//             - each element in the array holds an BLEDetailCell object which has the text for the textLabel and detailTextLabel text.
//
// The counts of the element arrays varies by the information the discovered device provides.
-(NSMutableArray*) sections
{
    if (_sections == nil)
    {
        _sections = [NSMutableArray arrayWithObjects:
                     [NSMutableArray array], nil];
    }
    
    return _sections;
}


#pragma mark- Actions
- (IBAction)connectButton:(UIButton*)sender
{
    UITableViewCell *owningCell;
    NSIndexPath *indexPath;
    BLEPeripheralRecord * record;
    
    DLog(@"Connect Button pressed.");
    
    // the sender is the button
    // sender super view is the content view of the cell
    // sender super super is the table cell
    if ( [[[sender superview]superview] isKindOfClass:[UITableViewCell class]])
    {
        owningCell = (UITableViewCell*)[[sender superview]superview];
        
        // retrieve the indexPath
        indexPath = [self.tableView indexPathForCell:owningCell];
        DLog(@"Section index:  %i",indexPath.section);
        // get the device record
        record = [self.discoveredPeripherals objectAtIndex:indexPath.section];
    
    
        // retrieve the current title of the button
        NSString *buttonTitle = sender.currentTitle;
        if ( [buttonTitle localizedCompare:@"Connect"]== NSOrderedSame)
        {
            // Ask the CBCentralManager to connect to the device 
            [self.delegate connectPeripheral:record sender:owningCell];
            
            // At this point only the connection request has been made, we don't know if the connection was successful. Stay in the same view until the result of the connection request is known.
            
        }
        else if ([buttonTitle localizedCompare:@"Disconnect"] == NSOrderedSame)
        {
            DLog(@"Button pressed with Disconnect title");
            // Ask the CBCentralManager to connect to the device
            [self.delegate disconnectPeripheral:record sender:owningCell];

        }
               
    }
        
}


#pragma mark- Private Methods

// Update the information presented to the user as the peripheral becomes connected or changes state
-(NSMutableArray *)updateDeviceLabelsForDevice:(BLEPeripheralRecord *)deviceRecord
{
    NSMutableArray *deviceInfo = [NSMutableArray arrayWithCapacity:15];
    
    // add the device name
    [deviceInfo addObject:NAME_LABEL];
    
    // add the UUID
    [deviceInfo addObject:UUID_LABEL];
    
    // display connection state
    [deviceInfo addObject:CONNECTED_LABEL];
    
    // add RSSI
    [deviceInfo addObject:RSSI_LABEL];
    
    // display a Services row unless the peripheral is disconnected AND services is nil
    if ( ([deviceRecord.peripheral isConnected]) || (deviceRecord.peripheral.services) )
    {
        // show the Services Row
        [deviceInfo addObject:SERVICES_LABEL];
    }
    
    
    // add placeholder for Advertisement Label
    [deviceInfo addObject:@"ADVERTISEMENT"];
    
    // finally add placeholder for the connect button
    [deviceInfo addObject:@""];
    
    return deviceInfo;
}

#pragma mark- View Controller Lifecycle

-(void)awakeFromNib
{
    [super awakeFromNib];
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DLog(@"Preparing to segue from DiscoveredDevices");
    
    if ([segue.identifier isEqualToString:@"ShowServices"])
    {
        DLog(@"Segueing to Show Services");
        if ([segue.destinationViewController isKindOfClass:[BLEPeripheralServicesTVC class]])
        {
           BLEPeripheralServicesTVC *destination = segue.destinationViewController;
            
            // find the device record containing the peripheral in sender argument
            if ([sender isKindOfClass:[CBPeripheral class]])
            {
                CBPeripheral *peripheral = (CBPeripheral *)sender;
                destination.peripheral = peripheral;
                destination.centralManagerDelegate = self.delegate;
            }
        }
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Public Methods

/*
 *
 * Method Name:  synchronizeConnectionStates
 *
 * Description:  The button title should aways be the opposite of the conection state of the peripheral. For example, if the peripheral is connected the button title should display Disconnect which allows the user to initiate disconnecting the peripheral.  
 *
 * Parameter(s): <#parameters#>
 *
 */
-(void)synchronizeConnectionStates
{
    NSString *currentTitle;
    BOOL tableNeedsUpdating = NO;
    
    for (BLEPeripheralRecord *record in self.discoveredPeripherals)
    {
        // get the current title from the custom cell dictionary
        currentTitle = [BLEConnectButtonCell getButtonTitle:record.dictionaryKey];
        
        if (record.peripheral == nil)
        {
            // the peripheral has become disconnected
            
            if ( [currentTitle localizedCompare:@"Connect"] != NSOrderedSame)
            {
                // set the button title to Connect
                [BLEConnectButtonCell setButtonTitle:(@"Connect") AtKey:record.dictionaryKey];
                tableNeedsUpdating = YES;
            }
        }
        else if ([record.peripheral isConnected])
        {
            if ( [currentTitle localizedCompare:@"Disconnect"] != NSOrderedSame)
            {
                [BLEConnectButtonCell setButtonTitle:(@"Disconnect") AtKey:record.dictionaryKey];
                tableNeedsUpdating = YES;
            }

        }
        else if (! [record.peripheral isConnected])
        {
            if ( [currentTitle localizedCompare:@"Connect"] != NSOrderedSame)
            {
                // set the button title to Connect
                [BLEConnectButtonCell setButtonTitle:(@"Connect") AtKey:record.dictionaryKey];
                tableNeedsUpdating = YES;
            }
        }
    }
    
    if (tableNeedsUpdating)
    {
        [self.tableView reloadData];
    }
}



//Toggle the connect button label corresponding to a discovered device which has either been connected or disconnected by the user.
-(void)toggleConnectionState : (CBPeripheral *)peripheral;
{
    // find all of the peripherals which match the parameter using UUID as the key
    // for each corresponding device toggle the button so that connect -> disconnect or disconnect -> connect
    
    BOOL (^test)(id obj, NSUInteger idx, BOOL *stop);
    CFUUIDRef target = peripheral.UUID;
    test = ^(id obj, NSUInteger idx, BOOL *stop)
    {
        BLEPeripheralRecord *record = (BLEPeripheralRecord *)obj;
        CFUUIDRef uuid = record.peripheral.UUID;
        
        if ( CFEqual(target, uuid))
        {
            return YES;
        }
        return NO;
    };
    
    NSIndexSet *indexes = [self.discoveredPeripherals indexesOfObjectsPassingTest:test];
    
     //DLog(@"indexes: %@", indexes);
    
    // swap the button labels
    NSUInteger sectionIndex=[indexes firstIndex];
  
    NSString *currentTitle;
    while(sectionIndex != NSNotFound)
    {
        // the index represents the section number which corresponds to the peripheral
        NSMutableArray *data; 
        BLEPeripheralRecord *record = [self.discoveredPeripherals objectAtIndex:sectionIndex];
        
        // update device data information
        data = [self updateDeviceLabelsForDevice:record];
        [[self.sections objectAtIndex:0] replaceObjectAtIndex:sectionIndex withObject:data];
       
        // get the current title from the custom cell dictionary
        currentTitle = [BLEConnectButtonCell getButtonTitle:record.dictionaryKey];
        
        if ( ([currentTitle localizedCompare:@"Connect"] == NSOrderedSame) &&
            ([record.peripheral isConnected]) )
        {
            [BLEConnectButtonCell setButtonTitle:(@"Disconnect") AtKey:record.dictionaryKey];
            
        }
        else  if ( ([currentTitle localizedCompare:@"Disconnect"] == NSOrderedSame) &&
                  (![record.peripheral isConnected]) )
        {
            [BLEConnectButtonCell setButtonTitle:(@"Connect") AtKey:record.dictionaryKey];
        }
        
        sectionIndex=[indexes indexGreaterThanIndex: sectionIndex];
    }
        
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // one section per discovered device
    return [self.discoveredPeripherals count];
}


// Number rows in section equals the number of peripheral properties in the sections array being displayed + the number of advertisement items being displayed.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numRowsSection;
    
    if ([self.discoveredPeripherals count] > 0)
    {
    // access the array which had labels for each peripheral - corresponds to peripheral properties + ad label + button
    NSArray *deviceItems = [self.sections objectAtIndex:0];

    // access the device record for the section
    BLEPeripheralRecord * record = [self.discoveredPeripherals objectAtIndex:section];
    
    // ADVERTISEMENT_ROW = number of peripheral properties + number of advertisement items
    numRowsSection = [[deviceItems objectAtIndex:section]count]+ [record.advertisementItems count] ;
    }
    else
    {
        numRowsSection = 0;
    }
    
    //DLog(@"Setting row count in discovered device table %d",numRowsSection);
    return numRowsSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"DeviceContent";
    static NSString *AdvertisementCellIdentifier = @"Advertisement";
    static NSString *ConnectCellIdentifier = @"Connect";
    
    //DLog(@"Index= %i",indexPath.row);
    
    // get the labels which correspond to the peripheral    
    NSArray *labelData = [[self.sections objectAtIndex:0] objectAtIndex:indexPath.section];
    // access the device record for the section
    BLEPeripheralRecord * record = [self.discoveredPeripherals objectAtIndex:indexPath.section];

    NSUInteger buttonRow = [labelData count] + [record.advertisementItems count] - 1;
    if (indexPath.row == [labelData count]-2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:AdvertisementCellIdentifier forIndexPath:indexPath];
        
    }
    else if (indexPath.row == buttonRow)
    {
        BLEConnectButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:ConnectCellIdentifier forIndexPath:indexPath];
        
        NSString *title = [BLEConnectButtonCell getButtonTitle:record.dictionaryKey];
        [buttonCell.connectDisconnectButton setTitle:title forState:UIControlStateNormal];
        [buttonCell.connectDisconnectButton setTitle:title forState:UIControlStateHighlighted];
        
        cell = buttonCell;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
                       
        // correlate the row index to the data item being displayed
        
        // if row index < ADVERTISEMENT_ROW then peripheral properties are bing displayed
        if( indexPath.row < [labelData count]-2)
        {
            // get the label from the label array and match it to a peripheral invocation
            cell.textLabel.text = [labelData objectAtIndex:indexPath.row];
            
            if ([cell.textLabel.text localizedCompare:NAME_LABEL] == NSOrderedSame)
            {
                if (record.peripheral.name)
                {
                    cell.detailTextLabel.text = record.peripheral.name;
                }
                else
                {
                    cell.detailTextLabel.text= @"";
                }
            }
            else if ([cell.textLabel.text localizedCompare:UUID_LABEL] == NSOrderedSame)
            {
                NSString *uuid_string;
                CFUUIDRef uuid = record.peripheral.UUID;
                if (uuid)
                {
                    CFStringRef s = CFUUIDCreateString(NULL, uuid);
                    uuid_string = CFBridgingRelease(s);
                }
                else
                {
                    // no UUID provided in discovery
                    uuid_string = @"";
                }
                
                cell.detailTextLabel.text = uuid_string;
                
            }
            else if ([cell.textLabel.text localizedCompare:CONNECTED_LABEL] == NSOrderedSame)
            {
                cell.detailTextLabel.text = [record.peripheral isConnected] ? @"YES" : @"NO";
            }
            else if ([cell.textLabel.text localizedCompare:RSSI_LABEL] == NSOrderedSame)
            {
                cell.detailTextLabel.text = [[NSString alloc]initWithFormat:@"%i",[record.rssi shortValue]];
            }
            else if ([cell.textLabel.text localizedCompare:SERVICES_LABEL] == NSOrderedSame)
            {
                // add an accessory view disclosure indicator if the device is connected or if Services in non-nil
                if ([record.peripheral isConnected] || record.peripheral.services)
                {
                    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                }
                
                cell.detailTextLabel.text=@"";
            }
            
        }
        else if ( (indexPath.row < buttonRow) && (indexPath.row > ([labelData count]-2)) )
        {
            // display the advertisement items
            NSUInteger adIndex = indexPath.row + 1 - [labelData count];
            
            BLEDetailCellData *data= record.advertisementItems[adIndex];
            
            cell.textLabel.text = data.textLabelText;
            cell.detailTextLabel.text = data.detailTextLabelText;
        }
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     DLog(@"Did Select Row invoked");
    
}


// Accessory button handler
// Perform a matching test with the path index to identify what peripheral (section) and row is associated with the accessory button and then dispatch the execution of the handler to back to the central view controller.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Accessory button tapped");
    
    // the section corresponds to a unique peripheral
    
    // row numbers between 0 and less than the count of items in the data label array within Section can be matched to a particular peripheral property.
    
    // a row number equal to data label count corresponds to the Advertising Label
    
    // then next N rows after the advertsing label are advertisng data items, where N is the count of the advertising item array in the peripheral's device discovery record
    
    // any row after the advertising items correspond to a button or buttons added which initiate actions on the peripheral.
    
    // current design only supports accessory buttons for the section item. Validate and then dispatch.
    
    // access the label data for the peripheral
    NSArray *deviceItems = [self.sections objectAtIndex:0];
    NSArray *deviceLabels = [deviceItems objectAtIndex:indexPath.section];
    
    NSUInteger deviceLabelCount = [deviceLabels count];
    BLEPeripheralRecord * record= [self.discoveredPeripherals objectAtIndex:indexPath.section];
   
    
    if (indexPath.row < (deviceLabelCount - 2))
    {
        // accessory button corresponds to a peripheral property - which is where we expect to find the service label we are looking for
        NSString *itemLabel = deviceLabels[indexPath.row];
        if ( [itemLabel localizedCompare:SERVICES_LABEL] == NSOrderedSame)
        {
            //match for Services row as expected dispatch handler
            record.peripheral.delegate = self;
            [record.peripheral discoverServices:nil];
        }
        else
        {
            DLog(@"Accessory button selected for row not expecting to have an accessory button.");
        }
    }
    else
    {
        DLog(@"Accessory button selected for row not expecting to have an accessory button.");
    }
   
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
    
 //   [self.centralManagerActivityIndicator stopAnimating];
 //   self.centralManagerStatus.textColor = [UIColor blackColor];
 //   self.centralManagerStatus.text = @"Idle";
    
    if (error == nil)
    {
        // segue to BLEPeripheralServicesTVC - set sender as peripheral which can then be found in the list of devices
        [self performSegueWithIdentifier:@"ShowServices" sender:peripheral];
    }
    else
    {
        DLog(@"Error in didDiscoverServices: %@",error.description);
    }
}


#pragma mark- UISplitViewControllerDelegate


// When the split view controller rotates from a landscape to portrait orientation,
// it normally hides one of its view controllers. When that happens, it calls this
// method to coordinate the addition of a button to the toolbar (or navigation bar)
// of the remaining custom view controller. If you want the soon-to-be hidden view
// controller to be displayed in a popover, you must implement this method and use
// it to add the specified button to your interface.

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    DLog(@"willHideView controller invoked");
    UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:0];
    
    barButtonItem.title = navigationController.topViewController.title;
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = pc;
}

// When the view controller rotates from a portrait to landscape orientation, it
// shows its hidden view controller once more. If you added the specified button
// to your toolbar to facilitate the display of the hidden view controller in a
// popover, you must implement this method and use it to remove that button.
-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    DLog(@"splitViewController:willShowViewController invoked");
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
     self.masterPopoverController = nil;
    
}



@end
