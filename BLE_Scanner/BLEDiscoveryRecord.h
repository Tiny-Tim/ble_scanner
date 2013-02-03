//
//  BLEDiscoveryRecord.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface BLEDiscoveryRecord : NSObject

@property (nonatomic, strong)CBPeripheral *peripheral;
@property (nonatomic, strong)CBCentralManager *central;
@property (nonatomic, strong)NSDictionary * advertisementData;
@property (nonatomic, strong)NSNumber *rssi;

@property (nonatomic, strong)NSArray *advertisementItems;

-(id)initWithCentral: (CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral * )peripheral withAdvertisementData:(NSDictionary *)advertisementData
            withRSSI:(NSNumber *)RSSI;


@end
