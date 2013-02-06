//
//  BLEPeripheralCharacteristicsTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/5/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEPeripheralCharacteristicsTVC.h"
#import "CBUUID+StringExtraction.h"

@interface BLEPeripheralCharacteristicsTVC ()

@property (nonatomic) BOOL debug;

// CBCharacteristic being processed to retrieve descriptors
@property (nonatomic, strong) CBCharacteristic *pendingCharacteristicForDescriptor;
@end

@implementation BLEPeripheralCharacteristicsTVC

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
    _debug = YES;

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

-(void)logCharacteristicData: (CBCharacteristic *)characteristic
{
    NSLog(@"Logging characteristic data");
    NSLog(@"Parent Service: %@",[characteristic.service.UUID representativeString]);
    NSLog(@"Characteristic UUID: %@",[characteristic.UUID representativeString]);
    if (characteristic.value)
    {
        NSLog(@"0x %@",[characteristic.value description]);
    }
    else
    {
        if (characteristic.properties & CBCharacteristicPropertyRead)
        {
            NSLog(@"characteristic value is readable but uread");
        }
        else
        {
            NSLog(@"characteristic value is not readable");

        }
    }

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [self.characteristics count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShowCharacteristic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CBCharacteristic * characteristic = self.characteristics[indexPath.section];
    if (self.debug) [self logCharacteristicData:characteristic];
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Parent Service";
            cell.detailTextLabel.text = [characteristic.service.UUID representativeString];
            break;
            
        case 1:
            cell.textLabel.text = @"Characteristic UUID";
            cell.detailTextLabel.text = [characteristic.UUID representativeString];
            break;
          
        case 2:
            cell.textLabel.text = @"Characteristic Property";
            
            cell.detailTextLabel.text = [[NSString alloc]initWithFormat: @"0x%x",characteristic.properties];
            break;
            
        case 3:
            cell.textLabel.text = @"Value";
            if (characteristic.value)
            {
                cell.detailTextLabel.text = [@"0x" stringByAppendingString:[characteristic.value description]];
            }
            else
            {
                if (characteristic.properties & CBCharacteristicPropertyRead)
                {
                    characteristic.service.peripheral.delegate = self;
                
                    [characteristic.service.peripheral readValueForCharacteristic:characteristic];
                }
                else
                {
                    cell.detailTextLabel.text = @"Not Readable";
                }
            }
            break;
            
        case 4:
            cell.textLabel.text = @"Descriptors";
            cell.detailTextLabel.text = @"";
            break;
            
        default:
            break;
    }
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
    *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"CBPeripheralDelegate didUpdateValueForCharacteristic invoked");
    if (! error)
    {
        NSLog(@"Characteristic value updated for characteristic %@",[characteristic.UUID representativeString]);
        
        NSLog(@"Logging characteristic data in parameter");
        [self logCharacteristicData:characteristic];
        NSLog(@" ");
        NSLog(@"Logging characteristic data in list");
        // get characteristic out of array that has the same UUID
        
        BOOL (^test)(id obj, NSUInteger idx, BOOL *stop);
        CBUUID *target = characteristic.UUID;
        NSString *targetString = [target representativeString];
        
        test = ^(id obj, NSUInteger idx, BOOL *stop)
        {
            CBCharacteristic *item_characteristic = (CBCharacteristic *)obj;
            CBUUID *uuid = item_characteristic.UUID;
            NSString *uuidString = [uuid representativeString];
            
            if ([targetString localizedCompare:uuidString] == NSOrderedSame)
            {
                return YES;
            }
            return NO;
        };
        
        NSIndexSet *indexes = [self.characteristics indexesOfObjectsPassingTest:test];
        NSUInteger index=[indexes firstIndex];
        while(index != NSNotFound)
        {
            [self logCharacteristicData:self.characteristics[index]];
            index=[indexes indexGreaterThanIndex: index];
        }
        
        [self.tableView reloadData];
        
    }
    else
    {
        NSLog(@"Error updating characteristic: %@",error.description);
        NSLog(@"Characteristic UUID %@",[characteristic.UUID representativeString]);
    }
    
   // [self.tableView reloadData];
}

@end
