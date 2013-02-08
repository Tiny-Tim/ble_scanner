//
//  BLEDemoDispatcherViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/7/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPeripheralRecord.h"

@interface BLEDemoDispatcherViewController : UIViewController


// Model for the view controller
@property (nonatomic, strong)BLEPeripheralRecord *deviceRecord ;


// Set of services for which demos exist
@property (nonatomic, copy)NSSet *demoServices;
@end
