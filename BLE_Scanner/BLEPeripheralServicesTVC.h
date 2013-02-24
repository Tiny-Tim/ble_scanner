//
//  BLEPeripheralServicesTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/4/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLECentralManagerDelegate.h"


@interface BLEPeripheralServicesTVC : UITableViewController <CBPeripheralDelegate>

// Model for the view controller
@property (nonatomic, strong)CBPeripheral *peripheral ;

// reference to central manager used connect and disconnect peripheral
@property (nonatomic, strong)id<BLECentralManagerDelegate>centralManagerDelegate;


@end
