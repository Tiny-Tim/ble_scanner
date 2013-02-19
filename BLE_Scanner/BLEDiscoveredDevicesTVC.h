//
//  BLEDiscoveredDevicesTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPeripheralRecord.h"
#import "BLECentralManagerDelegate.h"



@interface BLEDiscoveredDevicesTVC : UITableViewController <UISplitViewControllerDelegate,CBPeripheralDelegate>


//Toggle the connect button label corresponding to a discovered device which has either been connected or disconnected by the user.
-(void)toggleConnectionState : (CBPeripheral *)peripheral;

-(void)synchronizeConnectionStates;

@property (nonatomic, weak)id< BLECentralManagerDelegate>delegate;

// List of discovered BLEPeripheralRecords
@property (nonatomic, strong) NSArray *discoveredPeripherals;
@end
