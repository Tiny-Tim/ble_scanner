//
//  BLEServiceListTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLEServiceListDelegate

-(void) scanForServices: (NSArray *)services : (id)sender;

@end

@interface BLEServiceListTVC : UITableViewController

@property (nonatomic, weak)id< BLEServiceListDelegate >delegate;

@end
