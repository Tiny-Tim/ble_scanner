//
//  BLEHeartRateDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/11/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEHeartRateDemoViewController : UIViewController <CBPeripheralDelegate>


@property (nonatomic, strong) CBService *heartRateService;
@end
