//
//  BLEDeviceInformationDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/12/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDeviceInformationDemoViewController.h"
#include "ServiceAndCharacteristicMacros.h"
#import "CBUUID+StringExtraction.h"

@interface BLEDeviceInformationDemoViewController ()

// Label which displays peripheral status and activity.
@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

// Spinner activity indicator which is active when device is being accessed.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *peripheralStatusSpinner;

@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel;

@property (weak, nonatomic) IBOutlet UILabel *modelNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *firmwareRevisionLabel;

@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *hardwareRevisionLabel;

@property (weak, nonatomic) IBOutlet UILabel *softwareRevisionLabel;

@property (nonatomic, readonly)NSSet *readCharacteristics;

@end

@implementation BLEDeviceInformationDemoViewController

@synthesize readCharacteristics = _readCharacteristics;

#pragma mark- Properties


// set of characteristics which can be read for this service
-(NSSet *)readCharacteristics
{
    if (! _readCharacteristics)
    {
        _readCharacteristics = [NSSet setWithObjects:MANUFACTURER_NAME_STRING_CHARACTERISTIC, MODEL_NUMBER_STRING_CHARACTERISTIC, FIRMWARE_REVISION_STRING_CHARACTERISTIC, SERIAL_NUMBER_STRING_CHARACTERISTIC,HARDWARE_REVISION_STRING_CHARACTERISTIC,SOFTWARE_REVISION_STRING_CHARACTERISTIC, nil];
    }
    
    return _readCharacteristics;
}

#pragma mark- Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.statusLabel = self.peripheralStatusLabel;
    self.statusSpinner = self.peripheralStatusSpinner;
    
    // set the peripheral delegate to self
    self.deviceInformationService.peripheral.delegate =self;
    
    self.manufacturerLabel.text = @"";
    self.firmwareRevisionLabel.text = @"";
    self.modelNumberLabel.text = @"";
    self.serialNumberLabel.text = @"";
    self.hardwareRevisionLabel.text = @"";
    self.softwareRevisionLabel.text = @"";
    
    BOOL foundManufacturerName = NO;
    BOOL foundFirmwareRevision = NO;
    BOOL foundModelNumber = NO;
    BOOL serialNumberFound = NO;
    BOOL hardwareRevisionFound = NO;
    BOOL softwareRevisionFound = NO;
    
    for (CBCharacteristic * characteristic in self.deviceInformationService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:MANUFACTURER_NAME_STRING_CHARACTERISTIC  ]])
        {
            foundManufacturerName = YES;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:MODEL_NUMBER_STRING_CHARACTERISTIC  ]])
        {
            foundModelNumber = YES;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FIRMWARE_REVISION_STRING_CHARACTERISTIC  ]])
        {
            foundFirmwareRevision = YES;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SERIAL_NUMBER_STRING_CHARACTERISTIC  ]])
        {
            serialNumberFound = YES;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HARDWARE_REVISION_STRING_CHARACTERISTIC  ]])
        {
            hardwareRevisionFound = YES;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SOFTWARE_REVISION_STRING_CHARACTERISTIC  ]])
        {
            softwareRevisionFound = YES;
        }
            
    }
    
    if ( ! (foundManufacturerName && foundModelNumber &&
            foundFirmwareRevision && serialNumberFound &&
            hardwareRevisionFound && softwareRevisionFound))
    {
        [self discoverServiceCharacteristics:self.deviceInformationService];
    }
    else
    {
        [self readCharacteristic:MANUFACTURER_NAME_STRING_CHARACTERISTIC forService:self.deviceInformationService] ;
        [self readCharacteristic:MODEL_NUMBER_STRING_CHARACTERISTIC forService:self.deviceInformationService];
        [self readCharacteristic:FIRMWARE_REVISION_STRING_CHARACTERISTIC forService:self.deviceInformationService];
        [self readCharacteristic:SERIAL_NUMBER_STRING_CHARACTERISTIC forService:self.deviceInformationService];
        [self readCharacteristic:HARDWARE_REVISION_STRING_CHARACTERISTIC forService:self.deviceInformationService];
        [self readCharacteristic:SOFTWARE_REVISION_STRING_CHARACTERISTIC forService:self.deviceInformationService];
    }
}


/*
 *
 * Method Name:  viewWillDisappear
 *
 * Description:  Ensure view controller is not being updated when not in view.
 *
 * Parameter(s): animated - system parameter controlling view transition
 *
 */
-(void) viewWillDisappear:(BOOL)animated
{
    self.deviceInformationService.peripheral.delegate = nil;
    
    [super viewWillDisappear:animated];
    
}



#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didUpdateNotificationStateForCharacteristic invoked");
}


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
    
    [self.peripheralStatusSpinner stopAnimating];
    [self displayPeripheralConnectStatus:self.deviceInformationService.peripheral];
    
    if (!error)
    {
        DLog(@"Characteristic value  updated.");
        
        // Determine which characteristic was updated
        /* Updated value for heart rate measurement received */
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:MANUFACTURER_NAME_STRING_CHARACTERISTIC ]])
        {
            NSString *manufacturer;
            manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            DLog(@"Manufacturer Name = %@", manufacturer);
            self.manufacturerLabel.text = [NSString stringWithFormat: @"Manufacturer:  %@",manufacturer];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:MODEL_NUMBER_STRING_CHARACTERISTIC ]])
        {
            NSString *model;
            model = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            DLog(@"Model Number = %@", model);
            self.modelNumberLabel.text = [NSString stringWithFormat: @"Model Number:  %@",model];
            
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FIRMWARE_REVISION_STRING_CHARACTERISTIC ]])
        {
            NSString *fwRevision;
            fwRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            DLog(@"Firmware Revision = %@", fwRevision);
            self.firmwareRevisionLabel.text = [NSString stringWithFormat: @"Firmware Revision:  %@",fwRevision];
            
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SERIAL_NUMBER_STRING_CHARACTERISTIC ]])
        {
            NSString *serialNumber;
            serialNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            DLog(@"Serial Number = %@", serialNumber);
            self.serialNumberLabel.text = [NSString stringWithFormat: @"Serial Number:  %@",serialNumber];
            
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HARDWARE_REVISION_STRING_CHARACTERISTIC ]])
        {
            NSString *hwRevision;
            hwRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            DLog(@"Hardware Revision = %@", hwRevision);
            self.hardwareRevisionLabel.text = [NSString stringWithFormat: @"Hardware Revision:  %@",hwRevision];
            
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SOFTWARE_REVISION_STRING_CHARACTERISTIC ]])
        {
            NSString *swRevision;
            swRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            DLog(@"Software Revision = %@", swRevision);
            self.softwareRevisionLabel.text = [NSString stringWithFormat: @"Software Revision:  %@",swRevision];
        }
    }
    else
    {
        DLog(@"Error reading characteristic: %@", error.description);
    };
    
    [self displayPeripheralConnectStatus:self.deviceInformationService.peripheral];
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
    DLog(@"didDiscoverCharacteristicsForService invoked");
    
    [self.peripheralStatusSpinner stopAnimating];
    [self displayPeripheralConnectStatus:self.deviceInformationService.peripheral];
    
    if (error == nil)
    {
        // iterate through the characteristics and take approproate actions
        for (CBCharacteristic *characteristic in service.characteristics )
        {
            
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            
            if ([self.readCharacteristics containsObject:uuidString])
            {
                [self readCharacteristic:uuidString forService:service];
            }
        }
    }
    else
    {
        DLog(@"Error encountered reading characterstics for heart rate service %@",error.description);
    }
}


@end
