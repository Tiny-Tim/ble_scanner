//
//  BLEDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/14/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEDemoViewController : UIViewController  <CBPeripheralDelegate>

// Description:  Sets the connection status label to indicate peripheral connect status.
-(void)displayPeripheralConnectStatus : (CBPeripheral *)peripheral;

// Description:  Discovcer all characteristics for specified service
-(void)discoverServiceCharacteristics : (CBService *)service;


// Description:  reads a specified characteristic for a specified service. It is the caller's responsibility to ensure the characteristic has been discovered.
-(void)readCharacteristic: (NSString *)uuid forService:(CBService *)service;

// Label which displays peripheral status and activity.
@property (weak, nonatomic)  UILabel *statusLabel;

// Spinner activity indicator which is active when device is being accessed.
@property (weak, nonatomic)  UIActivityIndicatorView *statusSpinner;

@end
