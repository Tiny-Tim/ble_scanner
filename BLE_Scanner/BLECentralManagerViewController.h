//
//  BLEViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPeripheralRecord.h"
#import "BLEDiscoveredDevicesTVC.h"

@interface BLECentralManagerViewController : UIViewController
                           < CBCentralManagerDelegate,
                                CBPeripheralDelegate,
                            BLECentralManagerDelegate >


@end
