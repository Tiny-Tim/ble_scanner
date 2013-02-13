//
//  BLETransmitPowerDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/13/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLETransmitPowerDemoViewController.h"
#include "ServiceAndCharacteristicMacros.h"
#import "CBUUID+StringExtraction.h"

@interface BLETransmitPowerDemoViewController ()
// NSLogging control
@property (nonatomic) BOOL debug;

@property (weak, nonatomic) IBOutlet UILabel *transmitPowerLabel;
@end

@implementation BLETransmitPowerDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


/*
 *
 * Method Name:  setConnectionStatus
 *
 * Description:  Sets the connection status label to indicate peripheral connect status.
 *
 * Parameter(s): None
 *
 */
-(void)setConnectionStatus
{
    if ([self.transmitPowerService.peripheral isConnected])
    {
       // self.peripheralStatusLabel.textColor = [UIColor greenColor];
      //  self.peripheralStatusLabel.text = @"Connected";
    }
    else
    {
       // self.peripheralStatusLabel.textColor = [UIColor redColor];
       // self.peripheralStatusLabel.text = @"Unconnected";
    }
}




-(void)discoverServiceCharacteristics
{
    if ([self.transmitPowerService.peripheral isConnected])
    {
        
       // self.peripheralStatusLabel.textColor = [UIColor greenColor];
      //  self.peripheralStatusLabel.text = @"Discovering service characteristics.";
      //  [self.peripheralStatusSpinner startAnimating];
        
        [self.transmitPowerService.peripheral discoverCharacteristics:nil
                                        forService:self.transmitPowerService];
        
    }
    else
    {
        if (self.debug) NSLog(@"Failed to discover characteristic, peripheral not connected.");
        [self setConnectionStatus];
    }
    
}

-(void)readCharacteristic: (NSString *)uuid
{
    // determine if the required characteristic has been discovered, if not then discover it
    if (self.transmitPowerService.characteristics)
    {
        NSUInteger index = [self.transmitPowerService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            CBCharacteristic *characteristic = (CBCharacteristic *)obj;
            
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            if ([uuidString localizedCompare:uuid ] == NSOrderedSame)
            {
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound)
        {
            NSLog(@"Error State: Expected Body Sensor Characteristic  %@ Not Available.",uuid);
            
        }
        else
        {
            if ([self.transmitPowerService.peripheral isConnected])
            {
              //  self.peripheralStatusLabel.textColor = [UIColor greenColor];
              //  self.peripheralStatusLabel.text = @"Reading Characteristic.";
              //  [self.peripheralStatusSpinner startAnimating];
                [self.transmitPowerService.peripheral readValueForCharacteristic:self.transmitPowerService.characteristics[index]];
                
            }
        }
    }
    else
    {
        NSLog(@"Error State: Expected Body Sensor Characteristic %@ Not Available.",uuid);
        
    }
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.transmitPowerLabel.text = @"";
    
    self.debug = YES;
    
    // set the peripheral delegate to self
    self.transmitPowerService.peripheral.delegate =self;
    
    BOOL foundTransmitPower = NO;
    
    
    for (CBCharacteristic * characteristic in self.transmitPowerService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSMIT_POWER_LEVEL_CHARACTERISTIC   ]])
        {
            foundTransmitPower = YES;
        }
    }
    
    if (! foundTransmitPower)
    {
        [self discoverServiceCharacteristics];
    }
    else
    {
         [self readCharacteristic:TRANSMIT_POWER_LEVEL_CHARACTERISTIC];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBPeripheralDelegate


/*
 *
 * Method Name:  didUpdateValueForCharacteristic
 *
 * Description:  The usual characteristic reading functionality associated with this CBPeripheralDelegate method. Identifies which characteristic is being updated and then handles processing the data.
 *
 * Parameter(s): peripheral - the peripheral sending the data
 *               characteristic - the chracteristic being updated
 *               error - any error generated during the updating of the characteristic
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSMIT_POWER_LEVEL_CHARACTERISTIC ]])
        {
            signed char TXLevel;
            [characteristic.value getBytes:&TXLevel length:1];
            
            signed int powerLevel = TXLevel;
            
            self.transmitPowerLabel.text = [NSString stringWithFormat:@"Transmit Power (dBm)= %i",powerLevel];
        }
    }
}

/*
 *
 * Method Name:  peripheral:didDiscoverCharacteristicsForService:error
 *
 * Description:  CBPeripheralDelegate method invoked when chracteristic is discovered or error occurs when reading characteristic.
 *
 * Parameter(s): See CBPeripheralDelegate documentation.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverCharacteristicsForService invoked");
    
   // [self.peripheralStatusSpinner stopAnimating];
    [self setConnectionStatus];
    
    if (error == nil)
    {
        // iterate through the characteristics and take appropriate actions
        for (CBCharacteristic *characteristic in service.characteristics )
        {
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            [self readCharacteristic:uuidString];
            
        }
        
    }
    else
    {
        NSLog(@"Error encountered reading characterstics for heart rate service %@",error.description);
    }
}

@end
