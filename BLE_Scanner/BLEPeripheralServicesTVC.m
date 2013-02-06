//
//  BLEServicesViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/4/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEPeripheralServicesTVC.h"
#import "CBUUID+StringExtraction.h"
#import "BLEPeripheralCharacteristicsTVC.h"

@interface BLEPeripheralServicesTVC ()

// controls NSLogging
@property (nonatomic) BOOL debug;


// CBService which is being processed to retrieve characteristics
@property (nonatomic, strong)CBService *pendingServiceForCharacteristic;



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
    _debug = YES;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.debug) NSLog(@"Entering viewWillAppear in BLEPeripheralServicesTVC");
    NSString *titleString = [[NSString alloc]initWithFormat: @"%@ Services",self.deviceRecord.friendlyName];
    self.title = titleString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Discover characteristics for Service
-(void)discoverCharacteristicsForService: (CBService *) service
{
    if (service.peripheral && [service.peripheral isConnected])
    {
        if (service.peripheral.delegate == nil)
        {
            service.peripheral.delegate = self;
        }
        
      //  self.centralManagerStatus.textColor = [UIColor greenColor];
      //  self.centralManagerStatus.text = @"Discovering characteristics for services.";
      //  [self.centralManagerActivityIndicator startAnimating];
        [service.peripheral discoverCharacteristics:nil forService:service];
    }
}



// Retrieve the characteristics for a specified service and segue to the characteristic table view controller
-(void)getCharacteristicsForService: (CBService *)service sender:(id)sender
{
    if (self.debug) NSLog(@"getCharacteristicsForService invoked in BLEPeripheralServicesTVC");
    
    self.pendingServiceForCharacteristic = service;
    
    if (service.characteristics)
    {
        // characteristics have been cached in service, just segue
        [self performSegueWithIdentifier:@"ShowCharacteristics" sender:self];
    }
    else
    {
        // get the characteristics from the service which will be returned from the peripheral delegate 
        service.peripheral.delegate = self;
        [self discoverCharacteristicsForService:service];
    }
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
    
    cell.detailTextLabel.text = [service.UUID representativeString];
    
    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowCharacteristics"])
    {
        if (self.debug) NSLog(@"Segueing to Show Characteristics");
        if ([segue.destinationViewController isKindOfClass:[BLEPeripheralCharacteristicsTVC class]])
        {
            BLEPeripheralCharacteristicsTVC *destination = segue.destinationViewController;
            
            destination.characteristics = self.pendingServiceForCharacteristic.characteristics;
            
        }
    }

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


// Accessory button is used to segue to characteristic data via CentralManager delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Accessory button tapped in PeripheralServicesTVC");
    // the service corresponds to the indexPath.section item in peripheral.services array
    CBService * service = [self.deviceRecord.peripheral.services objectAtIndex:indexPath.section];
    [self getCharacteristicsForService:service sender:self];
    

}


#pragma mark - CBPeripheralDelegate


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverCharacteristicsForService invoked");
    
   // [self.centralManagerActivityIndicator stopAnimating];
   // self.centralManagerStatus.textColor = [UIColor blackColor];
   // self.centralManagerStatus.text = @"Idle";
    if (error == nil)
    {
        // segue to BLEPeripheralCharacteristicsTVC
        [self performSegueWithIdentifier:@"ShowCharacteristics" sender:self];
    }
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverDescriptorsForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverIncludedServicesForService invoked");
}




- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateNotificationStateForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateValueForCharacteristic invoked");
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateValueForDescriptor invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didWriteValueForCharacteristic invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (self.debug) NSLog(@"didWriteValueForDescriptor invoked");
}


- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.debug) NSLog(@"peripheralDidUpdateRSSI invoked");
}



@end
