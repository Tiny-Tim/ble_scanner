//
//  BLEConnectedDeviceTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/31/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEConnectedDeviceTVC : UITableViewController <CBPeripheralDelegate>

// The model for this controller is a single connected peripheral
@property (nonatomic, copy)CBPeripheral *connectedPeripheral;
@end
