//
//  BLEConnectedDeviceTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/31/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEConnectedDeviceTVC.h"

@interface BLEConnectedDeviceTVC ()

// The model for this view controller - list of connected peripherals
@property (nonatomic, strong)NSMutableArray *connectedPeripherals;
@end

@implementation BLEConnectedDeviceTVC


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(NSMutableArray *)connectedPeripherals
{
    if (_connectedPeripherals == nil)
    {
        _connectedPeripherals = [NSMutableArray array];
    }
    
    return _connectedPeripherals;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Add peripheral to the list of connected peripherals
-(void)addPeripheral:(CBPeripheral *)peripheral
{
    [self.connectedPeripherals addObject:peripheral];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.connectedPeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConnectedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CBPeripheral *peripheral = self.connectedPeripherals[indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    CFUUIDRef uuid = peripheral.UUID;
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    NSString *uuid_string = CFBridgingRelease(s);
    cell.detailTextLabel.text = uuid_string;
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
