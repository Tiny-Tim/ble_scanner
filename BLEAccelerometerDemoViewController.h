//
//  BLEAccelerometerDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/9/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEAccelerometerDemoViewController : UIViewController <CBPeripheralDelegate>

@property (nonatomic, strong) CBService * accelerometerService;
@end
