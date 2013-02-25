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


// CBCharacteristic being processed to retrieve descriptors
@property (nonatomic, strong) CBCharacteristic *pendingCharacteristicForDescriptor;
@end

@implementation BLEPeripheralCharacteristicsTVC

#pragma mark- View Controller Lifecycle
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

}


#pragma mark - Table view data source

#define ROWS_PER_SECTION 5

// Each section is a unique characteristic
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.characteristics count];
}

// Displaying 5 items of information about each characteristic
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return  ROWS_PER_SECTION;
}

/*
 *
 * Method Name:  tableView:cellForRowAtIndexPath
 *
 * Description:  Displays the content for each cell in the table. Each cell corresponds to an informational item about a characteristic.
 *
 * Parameter(s): tableView - the table being processed
 *               indexPath - corresponding section and row for the table cell
 *
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShowCharacteristic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CBCharacteristic * characteristic = self.characteristics[indexPath.section];
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Parent Service";
            cell.detailTextLabel.text = [[characteristic.service.UUID representativeString]uppercaseString];
            break;
            
        case 1:
            cell.textLabel.text = @"Characteristic UUID";
            cell.detailTextLabel.text = [[characteristic.UUID representativeString]uppercaseString];
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

// Handle row selection if needed
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // empty
}

#pragma mark - CBPeripheralDelegate

// A characteristic value was updated in response to a read or notification request
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"CBPeripheralDelegate didUpdateValueForCharacteristic invoked");
    if (! error)
    {
        DLog(@"Characteristic value updated for characteristic %@",[characteristic.UUID representativeString]);
        
        // get characteristic out of array that has the same UUID
        BOOL (^test)(id obj, NSUInteger idx, BOOL *stop);
        CBUUID *target = characteristic.UUID;
        NSString *targetString = [[target representativeString]uppercaseString];
        
        test = ^(id obj, NSUInteger idx, BOOL *stop)
        {
            CBCharacteristic *item_characteristic = (CBCharacteristic *)obj;
            CBUUID *uuid = item_characteristic.UUID;
            NSString *uuidString = [[uuid representativeString]uppercaseString];
            
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
            index=[indexes indexGreaterThanIndex: index];
        }
        
        [self.tableView reloadData];
        
    }
    else
    {
        DLog(@"Error updating characteristic: %@",error.description);
        DLog(@"Characteristic UUID %@",[characteristic.UUID representativeString]);
    }
    
}

@end
