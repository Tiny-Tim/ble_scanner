//
//  BLEDiscoveryRecord.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDiscoveryRecord.h"

@implementation BLEDiscoveryRecord

-(id)initWithCentral     : (CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral * )peripheral
    withAdvertisementData:(NSDictionary *)advertisementData
                 withRSSI:(NSNumber *)RSSI
{
    if (self = [super init])
    {
        self.central = central;
        self.peripheral = peripheral;
        self.advertisementData = advertisementData;
        self.rssi = RSSI;
    }
    
    return self;
}

@end
