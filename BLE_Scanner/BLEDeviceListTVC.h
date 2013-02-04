//
//  BLEServiceListTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLEServiceListDelegate

-(void) scanForServices: (NSArray *)services sender:(id)sender;

@end

@interface BLEDeviceListTVC : UITableViewController

@property (nonatomic, weak)id< BLEServiceListDelegate >delegate;

@end
