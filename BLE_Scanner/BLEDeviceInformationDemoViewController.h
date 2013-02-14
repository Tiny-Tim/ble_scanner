//
//  BLEDeviceInformationDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/12/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDemoViewController.h"


@interface BLEDeviceInformationDemoViewController : BLEDemoViewController

@property (nonatomic, strong) CBService * deviceInformationService;
@end
