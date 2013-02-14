//
//  BLEAccelerometerDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/9/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDemoViewController.h"

@interface BLEAccelerometerDemoViewController : BLEDemoViewController

@property (nonatomic, strong) CBService * accelerometerService;
@end
