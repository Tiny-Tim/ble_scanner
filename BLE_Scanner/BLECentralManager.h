//
//  BLECentralManager.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/4/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLECentralManagerDelegate <NSObject>

-(void)connectPeripheral: (CBPeripheral *)peripheral sender:(id)sender;
-(void)disconnectPeripheral: (CBPeripheral *)peripheral sender:(id)sender;

-(void)displayServicesForPeripheral: (BLEPeripheralRecord *)deviceRecord sender:(id)sender;

@end
