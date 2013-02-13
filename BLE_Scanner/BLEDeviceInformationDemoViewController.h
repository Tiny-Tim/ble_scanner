//
//  BLEDeviceInformationDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/12/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface BLEDeviceInformationDemoViewController : UIViewController  <CBPeripheralDelegate>

@property (nonatomic, strong) CBService * deviceInformationService;
@end
