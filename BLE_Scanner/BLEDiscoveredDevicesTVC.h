//
//  BLEDiscoveredDevicesTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDiscoveryRecord.h"

@protocol BLEDiscoveredDevicesDelegate

-(void)connectPeripheral: (CBPeripheral *)peripheral sender:(id)sender;
-(void)disconnectPeripheral: (CBPeripheral *)peripheral sender:(id)sender;

@end

@interface BLEDiscoveredDevicesTVC : UITableViewController

// Invoke to add a discovered device to the model
-(void)deviceDiscovered: (BLEDiscoveryRecord *)deviceRecord;

//Toggle the connect button label corresponding to a discovered device which has either been connected or disconnected by the user.
-(void)toggleConnectButtonLabel : (CBPeripheral *)peripheral;


@property (nonatomic, weak)id< BLEDiscoveredDevicesDelegate>delegate;
@end
