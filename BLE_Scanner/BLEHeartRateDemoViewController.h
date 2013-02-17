//
//  BLEHeartRateDemoViewController.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/11/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDemoViewController.h"
#import "BLECentralManagerDelegate.h"
#import "BLECentralManagerClientProtocol.h"


@interface BLEHeartRateDemoViewController : BLEDemoViewController<BLECentralManagerClientProtocol>

// Heart Rate Measurement Service - model for the controller
@property (nonatomic, strong) CBService *heartRateService;

// reference to central manager used connect and disconnect peripheral
@property (nonatomic, strong)id<BLECentralManagerDelegate>centralManagerDelegate;


-(void)peripheralConnectStateChanged:(CBPeripheral *)peripheral;

@end
