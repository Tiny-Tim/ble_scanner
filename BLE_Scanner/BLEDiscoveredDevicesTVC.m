//
//  BLEDiscoveredDevicesTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDiscoveredDevicesTVC.h"
//#import "CBUUID+StringExtraction.h"
#import "BLEConnectButtonCell.h"
#import "BLEDetailCellData.h"


// A label embedded in the data which displays ADVERTISING DATA in the table
//#define ADVERTISEMENT_ROW 4
#define NAME_LABEL  @"Name:  "
#define UUID_LABEL @"UUID:  "
#define CONNECTED_LABEL @"Connected: "
#define RSSI_LABEL @"RSSI:  "
#define SERVICES_LABEL @"SERVICES:  "

@interface BLEDiscoveredDevicesTVC ()


// The model for this table view controller
@property (nonatomic, strong)NSMutableArray *deviceRecords;

// data structure conatining lables for rows in table
@property (nonatomic, strong) NSMutableArray *sections;

// controls NSLogging
@property (nonatomic) BOOL debug;


- (IBAction)connectButton:(UIButton *)sender;


@end

@implementation BLEDiscoveredDevicesTVC

@synthesize sections = _sections;
@synthesize deviceRecords = _deviceRecords;


-(NSMutableArray *)deviceRecords
{
    if (_deviceRecords == nil)
    {
        _deviceRecords = [NSMutableArray array];
    }
    
    return _deviceRecords;
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

- (IBAction)connectButton:(UIButton*)sender
{
    UITableViewCell *owningCell;
    NSIndexPath *indexPath;
    BLEDiscoveryRecord * record;
    
    if (self.debug) NSLog(@"Connect Button pressed.");
    
    // the sender is the button
    // sender super view is the content view of the cell
    // sender super super is the table cell
    if ( [[[sender superview]superview] isKindOfClass:[UITableViewCell class]])
    {
        owningCell = (UITableViewCell*)[[sender superview]superview];
        
        // retrieve the indexPath
        indexPath = [self.tableView indexPathForCell:owningCell];
        if (self.debug) NSLog(@"Section index:  %i",indexPath.section);
        // get the device record
        record = [self.deviceRecords objectAtIndex:indexPath.section];
    
    
        // retrieve the current title of the button
        NSString *buttonTitle = sender.currentTitle;
        if ( [buttonTitle localizedCompare:@"Connect"]== NSOrderedSame)
        {
            // Ask the CBCentralManager to connect to the device 
            [self.delegate connectPeripheral:record.peripheral sender:owningCell];
            
            // At this point only the connection request has been made, we don't know if the connection was successful. Stay in the same view until the result of the connection request is known.
            
        }
        else if ([buttonTitle localizedCompare:@"Disconnect"] == NSOrderedSame)
        {
            if (self.debug) NSLog(@"Button pressed with Disconnect title");
            // Ask the CBCentralManager to connect to the device
            [self.delegate disconnectPeripheral:record.peripheral sender:owningCell];

        }
               
    }
        
}


// Update the information presented to the user as the peripheral becomes connected or changes state
-(NSMutableArray *)updateDeviceLabelsForDevice:(BLEDiscoveryRecord *)deviceRecord
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


//Invoked when a BLE peripheral is discovered
-(void)deviceDiscovered: (BLEDiscoveryRecord *)deviceRecord
{
       
    // add the deviceRecord to the list of discovered devices
    [self.deviceRecords addObject:deviceRecord];
    
    // this array will be added to section
    NSMutableArray *deviceInfo; 
    
    deviceInfo = [self updateDeviceLabelsForDevice:deviceRecord];
    
    
    // add peripheral item data to section array
    [[self.sections objectAtIndex:0] addObject:deviceInfo];
    
    [self.tableView reloadData];
    
}

-(void)awakeFromNib
{
    [super awakeFromNib];
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

    // preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
     _debug = YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        BLEDiscoveryRecord *record = (BLEDiscoveryRecord *)obj;
        CFUUIDRef uuid = record.peripheral.UUID;
        
        if ( CFEqual(target, uuid))
        {
            return YES;
        }
        return NO;
    };
    
    NSIndexSet *indexes = [self.deviceRecords indexesOfObjectsPassingTest:test];
    
     //if (self.debug) NSLog(@"indexes: %@", indexes);
    
    // swap the button lablels
    NSUInteger sectionIndex=[indexes firstIndex];
  
    NSString *currentTitle;
    while(sectionIndex != NSNotFound)
    {
        // the index represents the section number which corresponds to the peripheral
        NSMutableArray *data; 
        BLEDiscoveryRecord *record = [self.deviceRecords objectAtIndex:sectionIndex];
        
        // update device data information
        data = [self updateDeviceLabelsForDevice:record];
        [[self.sections objectAtIndex:0] replaceObjectAtIndex:sectionIndex withObject:data];
        
        //if (self.debug) NSLog(@"row = %i",indexPath.row);
       
        // get the current title from the custom cell dictionary
        currentTitle = [BLEConnectButtonCell getButtonTitle:record.dictionaryKey];
        
        if ( [currentTitle localizedCompare:@"Connect"] == NSOrderedSame)
        {
            [BLEConnectButtonCell setButtonTitle:(@"Disconnect") AtKey:record.dictionaryKey];
            
        }
        else
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
    return [self.deviceRecords count];
}


// Number rows in section equals the number of peripheral properties in the sections array being displayed + the number of advertisement items being displayed.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // access the array which had labels for each peripheral - corresponds to peripheral properties + ad label + button
    NSArray *deviceItems = [self.sections objectAtIndex:0];

    // access the device record for the section
    BLEDiscoveryRecord * record = [self.deviceRecords objectAtIndex:section];
    
    // ADVERTISEMENT_ROW = number of peripheral properties + number of advertisement items
    NSUInteger numRowsSection = [[deviceItems objectAtIndex:section]count]+ [record.advertisementItems count] ;
    
    
    //if (self.debug) NSLog(@"Setting row count in discovered device table %d",numRowsSection);
    return numRowsSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"DeviceContent";
    static NSString *AdvertisementCellIdentifier = @"Advertisement";
    static NSString *ConnectCellIdentifier = @"Connect";
    
    //if (self.debug) NSLog(@"Index= %i",indexPath.row);
    
    // get the labels which correspond to the peripheral    
    NSArray *labelData = [[self.sections objectAtIndex:0] objectAtIndex:indexPath.section];
    // access the device record for the section
    BLEDiscoveryRecord * record = [self.deviceRecords objectAtIndex:indexPath.section];

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
     if (self.debug) NSLog(@"Did Select Row invoked");
    
}


// Accessory button handler
// Perform a matching test with the path index to identify what peripheral (section) and row is associated with the accessory button and then dispatch the execution of the handler to back to the central view controller.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.debug) NSLog(@"Accessory button tapped");
    
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
    BLEDiscoveryRecord * record= [self.deviceRecords objectAtIndex:indexPath.section];
   
    
    if (indexPath.row < (deviceLabelCount - 2))
    {
        // accessory button corresponds to a peripheral property - whihc is where we expect to find the service label we are looking for
        NSString *itemLabel = deviceLabels[indexPath.row];
        if ( [itemLabel localizedCompare:SERVICES_LABEL] == NSOrderedSame)
        {
            //match for Services row as expected dispatch handler
            [self.delegate displayServicesForPeripheral:record sender:self];
        }
        else
        {
            NSLog(@"Accessory button selected for row not expecting to have an accessory button.");
        }
    }
    else
    {
        NSLog(@"Accessory button selected for row not expecting to have an accessory button.");
    }
   
}

@end
