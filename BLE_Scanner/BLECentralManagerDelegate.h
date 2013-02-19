//
//  BLECentralManagerDelegate.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/4/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEPeripheralRecord.h"


// Protocol implemented by Central Manage which enables downstream view controllers to request peripheral connect and disconnect actions.
@protocol BLECentralManagerDelegate <NSObject>

-(void)connectPeripheral: (CBPeripheral *)peripheral sender:(id)sender;
-(void)disconnectPeripheral: (CBPeripheral *)peripheral sender:(id)sender;

@end
