//
//  BLECentralManagerClientProtocol.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/17/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLECentralManagerClientProtocol <NSObject>

-(void)peripheralConnectStateChanged:(CBPeripheral *)peripheral;


@end
