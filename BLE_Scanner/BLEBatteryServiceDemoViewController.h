//
//  BLEBatteryServiceDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/7/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDemoViewController.h"

@interface BLEBatteryServiceDemoViewController : BLEDemoViewController

// Model for the controller - the batteryService being demonstrated.
@property (nonatomic, strong) CBService* batteryService;
@end
