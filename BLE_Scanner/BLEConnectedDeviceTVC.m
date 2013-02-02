//
//  BLEConnectedDeviceTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/31/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEConnectedDeviceTVC.h"


//----------------------------------

@interface BLEConnectedDeviceTableRow : NSObject

@property(nonatomic, strong) NSString *titleLabelText;
@property (nonatomic, strong) NSString *titleLabelData;

 
@end

@implementation BLEConnectedDeviceTableRow



@end


//----------------------------------
@interface BLEConnectedDeviceTVC ()

@property(nonatomic, copy) NSArray *dataSource;

@end

@implementation BLEConnectedDeviceTVC

@synthesize connectedPeripheral = _connectedPeripheral;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


// Generate the row data for the table where each row contians a label and data for the peripheral
-(void)updateDataSource
{
    NSMutableArray * peripheralData = [NSMutableArray array];
    
    //Display the properties first
    
    // Name
    BLEConnectedDeviceTableRow *row = [[BLEConnectedDeviceTableRow alloc] init];
    row.titleLabelText = @"Name: ";
    row.titleLabelData = self.connectedPeripheral.name;
    [peripheralData addObject:row];
    
    // UUID
    row = [[BLEConnectedDeviceTableRow alloc] init];
    row.titleLabelText = @"UUID:  ";
    
    CFUUIDRef uuid = self.connectedPeripheral.UUID;
    if (uuid)
    {
        CFStringRef s = CFUUIDCreateString(NULL, uuid);
        NSString *uuid_string = CFBridgingRelease(s);
        row.titleLabelData = uuid_string;
    }
    else
    {
        // no UUID provided in discovery
         row.titleLabelData = @"";
    }
    [peripheralData addObject:row];
    
    // RSSI
    
    //
    
    self.dataSource = [peripheralData copy];
    
}


-(void)setConnectedPeripheral:(CBPeripheral *)connectedPeripheral
{
    _connectedPeripheral = connectedPeripheral;
    
    // set up the data source for the table view
    [self updateDataSource];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConnectedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BLEConnectedDeviceTableRow *rowData = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = rowData.titleLabelText;
    cell.detailTextLabel.text = rowData.titleLabelData;
    
        
    
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


#pragma mark - CBPeripheralDelegate

@end
