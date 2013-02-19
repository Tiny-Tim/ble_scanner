//
//  BLECentralManagerClientProtocol.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/17/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Used to get callbacks from Central Manager when a peripheral's connction status has changed, generally in response to a connect or disconnect request made to the Central Manager
@protocol BLECentralManagerClientProtocol <NSObject>

-(void)peripheralConnectStateChanged:(CBPeripheral *)peripheral;


@end
