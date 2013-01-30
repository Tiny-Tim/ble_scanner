//
//  BLEDiscoveredDevicesTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDiscoveredDevicesTVC.h"

@interface BLEDiscoveredDevicesTVC ()

@property (nonatomic, strong)NSMutableArray *discoveredDevices;
@end

@implementation BLEDiscoveredDevicesTVC

@synthesize deviceRecord = _deviceRecord;
@synthesize discoveredDevices = _discoveredDevices;


-(NSArray *)discoveredDevices
{
    if (! _discoveredDevices)
    {
        _discoveredDevices = [NSMutableArray array];
    }
    return _discoveredDevices;
}


-(void)setDiscoveredDevices:(NSMutableArray *)discoveredDevices
{
    _discoveredDevices = discoveredDevices;
    
}
-(BLEDiscoveryRecord *)deviceRecord
{
        
    return _deviceRecord;
}

-(void)setDeviceRecord:(BLEDiscoveryRecord *)deviceRecord
{
    _deviceRecord =deviceRecord;
    [self.discoveredDevices addObject:_deviceRecord];
    
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



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    NSLog(@"Setting row count in discovered device table %d",[self.discoveredDevices count]);
    return [self.discoveredDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DiscoDevice Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell textLabel with UUID
    BLEDiscoveryRecord *deviceRecord = ( BLEDiscoveryRecord *)[self.discoveredDevices objectAtIndex:indexPath.row];
    CBPeripheral * peripheral = deviceRecord.peripheral;
    CFUUIDRef uuid = peripheral.UUID;
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    NSString *uuid_string = CFBridgingRelease(s);
    cell.textLabel.text = uuid_string;
    
    // check the peripheral name, if not null set the detailtextLabel
    if (peripheral.name)
    {
        cell.detailTextLabel.text = peripheral.name;
    }
    else
    {
        // Check the advertisement data for a name
         NSArray *keys = [deviceRecord.advertisementData allKeys];
        if ([keys containsObject:CBAdvertisementDataLocalNameKey])
        {
            cell.detailTextLabel.text = (NSString *)[deviceRecord.advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        }
        
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did Select Row invoked");
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
