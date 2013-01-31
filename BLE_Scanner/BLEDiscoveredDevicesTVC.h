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

@interface BLEDiscoveredDevicesTVC : UITableViewController

// Invoke to add a discovered device to the model
-(void)deviceDiscovered: (BLEDiscoveryRecord *)deviceRecord;


@end
