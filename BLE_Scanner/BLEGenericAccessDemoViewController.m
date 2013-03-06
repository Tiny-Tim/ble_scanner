//
//  BLEGenericAccessDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/15/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEGenericAccessDemoViewController.h"
#include "ServiceAndCharacteristicMacros.h"
#import "CBUUID+StringExtraction.h"

@interface BLEGenericAccessDemoViewController ()

// Label which displays peripheral status and activity.
@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

// Spinner activity indicator which is active when device is being accessed.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *peripheralStatusSpinner;

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *appearanceValueLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;




@end

@implementation BLEGenericAccessDemoViewController

#pragma mark- View Controller Lifecycle

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
 * Method Name:  viewDidLoad
 *
 * Description:  Initializes controller when instantiated.
 *               
 *   Ensures characteristics for service have been discovered. If any mandatory characteristic is not found then a discovery of all characteristics for the service is inititiated.
 *
 * Parameter(s): None
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.statusLabel = self.peripheralStatusLabel;
    self.statusSpinner = self.peripheralStatusSpinner;
    
    // set the peripheral delegate to self
    self.genericAccessProfileService.peripheral.delegate =self;
    
    self.deviceNameLabel.text= @"Device Name:  Unavailable";
    
    BOOL foundDeviceName = NO;
    BOOL foundAppearance = NO;
    for (CBCharacteristic * characteristic in self.genericAccessProfileService.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_NAME_CHARACTERISTIC  ]])
        {
            foundDeviceName = YES;
        }
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:APPEARANCE_CHARACTERISTIC  ]])
        {
            foundAppearance = YES;
        }
    }
    
    if (!(foundDeviceName && foundAppearance))
    {
        [self discoverServiceCharacteristics:self.genericAccessProfileService];
    }
    else
    {
        [self readCharacteristic:DEVICE_NAME_CHARACTERISTIC forService:self.genericAccessProfileService] ;
        [self readCharacteristic:APPEARANCE_CHARACTERISTIC forService:self.genericAccessProfileService] ;
    }
    
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"didUpdateNotificationStateForCharacteristic invoked");
}


#define APPEARANCE_ENUMERATIONS @"http://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.gap.appearance.xml"
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
    [self displayPeripheralConnectStatus:self.genericAccessProfileService.peripheral];
    
    if (!error)
    {
        DLog(@"Characteristic value  updated.");
        
        // Determine which characteristic was updated
        /* Updated value for heart rate measurement received */
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_NAME_CHARACTERISTIC ]])
        {
            NSString *deviceName;
            deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            DLog(@"Device Name Name = %@", deviceName);
            self.deviceNameLabel.text = [NSString stringWithFormat: @"Device Name:  %@",deviceName];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:APPEARANCE_CHARACTERISTIC ]])
        {
            DLog(@"Updating Appearance Bytes");
            const uint8_t *reportData = [characteristic.value bytes];
            NSUInteger appearanceValue = 0;
            appearanceValue = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[0]));
            DLog(@"Appearance value %u",appearanceValue);
            self.appearanceValueLabel.text = [NSString stringWithFormat:@"Appearance Value= %u",appearanceValue];
            
            NSURL * webPage = [NSURL URLWithString:APPEARANCE_ENUMERATIONS];
            NSURLRequest *request = [NSURLRequest requestWithURL:webPage];
            
            self.webView.hidden = NO;
            dispatch_queue_t downloadQueue = dispatch_queue_create("download", NULL);
            dispatch_async(downloadQueue, ^{
                
                [self.webView  loadRequest:request];
                
            });

        }
    }
    else
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_NAME_CHARACTERISTIC ]])
        {
            DLog(@"Error updating characteristic:  %@",error.description);
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            NSLog(@"uuidString:  %@",uuidString);
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:APPEARANCE_CHARACTERISTIC ]])
        {
            self.webView.hidden = YES;
            self.appearanceValueLabel.text = @"Appearance Value:  ERROR - Not Readable";
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
    DLog(@"didDiscoverCharacteristicsForService invoked");
    
    [self.peripheralStatusSpinner stopAnimating];
    [self displayPeripheralConnectStatus:self.genericAccessProfileService.peripheral];
    
    if (error == nil)
    {
        // iterate through the characteristics and take approproate actions
        for (CBCharacteristic *characteristic in service.characteristics )
        {
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            NSLog(@"uuidString:  %@",uuidString);
            if ([uuidString localizedCompare:DEVICE_NAME_CHARACTERISTIC] == NSOrderedSame)
            {
                // read the device name location
                DLog(@"Reading Device Name  Characteristic: %@",CBUUIDDeviceNameString);
                
                /* Read device name */
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
                {
                    [peripheral readValueForCharacteristic:characteristic];
                }
             
            }
            else if ([uuidString localizedCompare:APPEARANCE_CHARACTERISTIC] == NSOrderedSame)
            {
                // read the device name location
                DLog(@"Reading Appearance  Characteristic: %@",APPEARANCE_CHARACTERISTIC);
                
                /* Read Appearance */
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:APPEARANCE_CHARACTERISTIC]])
                {
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
    else
    {
        DLog(@"Error encountered reading characterstics for GAT service %@",error.description);
    }
}


@end
