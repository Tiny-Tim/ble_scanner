//
//  BLEDiscoveredDevicesTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDiscoveredDevicesTVC.h"
#import "CBUUID+StringExtraction.h"

#define ADVERTISEMENT_ROW 3

@interface BLEDiscoveredDevicesTVC ()

@property (nonatomic, strong) NSMutableArray *sections;

@end

@implementation BLEDiscoveredDevicesTVC

@synthesize deviceRecord = _deviceRecord;

@synthesize sections = _sections;

-(NSMutableArray*) sections
{
    if (_sections == nil)
    {
        // first array holds labels, 2nd array holds data
        _sections = [NSMutableArray arrayWithObjects:
                     [NSMutableArray array],
                     [NSMutableArray array], nil];
    }
    
    return _sections;
}


-(BLEDiscoveryRecord *)deviceRecord
{
        
    return _deviceRecord;
}


-(void)updateTableData: (BLEDiscoveryRecord *)deviceRecord
{
    NSMutableArray *deviceInfo = [NSMutableArray array];
    NSMutableArray *cellLabel = [NSMutableArray array];
    
    // add the device name - index 0
    if (deviceRecord.peripheral.name == nil)
    {
        [deviceInfo addObject:@""];
    }
    else
    {
        [deviceInfo addObject:deviceRecord.peripheral.name];
    }
    [cellLabel addObject:@"Name"];
    
    // add the UUID - index 1
    CFUUIDRef uuid = deviceRecord.peripheral.UUID;
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    NSString *uuid_string = CFBridgingRelease(s);
    [deviceInfo addObject:uuid_string];
    [cellLabel addObject:@"UUID"];
    
    // add RSSI - index 2
    NSString *rssiString = [[NSString alloc]initWithFormat:@"%i",[deviceRecord.rssi shortValue]];
    [deviceInfo addObject:rssiString];
    [cellLabel addObject:@"RSSI"];
    
    // add placeholder for Advertisement Label
    [deviceInfo addObject:@""];
    [cellLabel addObject:@"ADVERTISEMENT"];
    
    NSEnumerator *enumerator = [deviceRecord.advertisementData keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject]))
    {
        if ([key isKindOfClass:[NSString class]])
        {
            NSLog(@"Advertising key: %@",key);
            id value = [deviceRecord.advertisementData objectForKey:key];
            if ([value isKindOfClass:[NSString class]])
            {
                [deviceInfo addObject:value];
                [cellLabel addObject:key];
            }
            else if ([value isKindOfClass:[NSArray class]])
            {
                NSArray *valueData = (NSArray *)value;
                for (id item in valueData)
                {
                    if ([item isKindOfClass:[CBUUID class]])
                    {
                       
                        [deviceInfo addObject:[item representativeString]];
                        [cellLabel addObject:key];
                    }
                }

            }
            else
            {
                
            }
            
        }
    }


    // finally add placeholder for the connect button
    [deviceInfo addObject:@""];
    [cellLabel addObject:@"Connect"];
    
    
    // add peripheral item data to section array
    [[self.sections objectAtIndex:0] addObject:cellLabel];
    [[self.sections objectAtIndex:1] addObject:deviceInfo];
    
}


-(void)setDeviceRecord:(BLEDiscoveryRecord *)deviceRecord
{
    _deviceRecord =deviceRecord;
    
    [self updateTableData: deviceRecord];
    [self.tableView reloadData];
    
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // this gets the array of labels, each element in this array corresponds to a device
    NSUInteger numberSections = [[self.sections objectAtIndex:0] count];
    NSLog(@"Number of sections, i.e discovered devices, in discovered device table: %i",numberSections);
    // Return the number of sections.
    return numberSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // access the array which had labels for each peripheral;
    NSArray *deviceItems = [self.sections objectAtIndex:0];
    
    NSUInteger numRowsSection = [[deviceItems objectAtIndex:section] count];
    
    NSLog(@"Setting row count in discovered device table %d",numRowsSection);
    return numRowsSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"DeviceContent";
    static NSString *AdvertisementCellIdentifier = @"Advertisement";
    static NSString *ConnectCellIdentifier = @"Connect";
    
    
    // get the label and data array which correspond to the section
    NSArray *labels = [[self.sections objectAtIndex:0] objectAtIndex:indexPath.section];
    
    NSArray *data = [[self.sections objectAtIndex:1] objectAtIndex:indexPath.section];
    if (indexPath.row == ADVERTISEMENT_ROW)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:AdvertisementCellIdentifier forIndexPath:indexPath];
        
    }
    else if (indexPath.row == ([data count]-1))
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ConnectCellIdentifier forIndexPath:indexPath];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.detailTextLabel.text = [data objectAtIndex:indexPath.row];
        cell.textLabel.text = [labels objectAtIndex:indexPath.row];
        
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did Select Row invoked");
    
}

@end
