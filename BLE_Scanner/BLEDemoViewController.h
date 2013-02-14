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

-(void)displayPeripheralConnectStatus : (CBPeripheral *)peripheral;

-(void)discoverServiceCharacteristics : (CBService *)service;

-(void)readCharacteristic: (NSString *)uuid forService:(CBService *)service;

// Label which displays peripheral status and activity.
@property (weak, nonatomic)  UILabel *statusLabel;

// Spinner activity indicator which is active when device is being accessed.
@property (weak, nonatomic)  UIActivityIndicatorView *statusSpinner;

@end
