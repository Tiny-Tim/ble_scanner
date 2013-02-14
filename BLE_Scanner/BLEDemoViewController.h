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

+(void)setPeripheral : (CBPeripheral *)peripheral ConnectionStatus :(UILabel *)statusLabel;

+(BOOL)discoverServiceCharacteristics : (CBService *)service;

+(BOOL)readCharacteristic: (NSString *)uuid forService:(CBService *)service;

@end
