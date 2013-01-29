//
//  BLEScanControlTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEServiceListTVC.h"


@protocol BLEScanControlDelegate


-(void) scanForAllServices: (id)sender;

@end


@interface BLEScanControlTVC : UITableViewController <BLEServiceListDelegate>


@property (nonatomic, weak)id< BLEScanControlDelegate>delegate;
@end
