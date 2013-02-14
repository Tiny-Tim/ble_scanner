//
//  BLEServicesViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/4/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEPeripheralServicesTVC.h"
#import "CBUUID+StringExtraction.h"

@interface BLEPeripheralServicesTVC ()

@end

@implementation BLEPeripheralServicesTVC

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"Entering viewWillAppear in BLEPeripheralServicesTVC");
    NSString *titleString = [[NSString alloc]initWithFormat: @"%@ Services",self.deviceRecord.friendlyName];
    self.title = titleString;
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
    return [self.deviceRecord.peripheral.services count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ServiceData";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"Service UUID";
    CBService *service = [self.deviceRecord.peripheral.services objectAtIndex:indexPath.section];
    
    cell.detailTextLabel.text = [[service.UUID representativeString]uppercaseString];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


// Accessory button is used to segue to characteristic data via CentralManager delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Accessory button tapped in PeripheralServicesTVC");
    // the service corresponds to the indexPath.section item in peripheral.services array
    CBService * service = [self.deviceRecord.peripheral.services objectAtIndex:indexPath.section];
    
    [self.delegate getCharacteristicsForService:service sender:self];
    // NEW:  invoke a method on the containing view controller to get characteristics for service
    
   // [self getCharacteristicsForService:service sender:self];
    

}




@end
