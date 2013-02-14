//
//  BLEKeyPressDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/8/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDemoViewController.h"

@interface BLEKeyPressDemoViewController : BLEDemoViewController
@property (nonatomic, strong) CBService * keyPressedService;
@end
