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


// ---- Properties provided by Central upon discovery ----

// the discovered peripheral
@property (nonatomic, strong)CBPeripheral *peripheral;

// the central manager which discovered the peripheral
@property (nonatomic, strong)CBCentralManager *central;

// the advertisement data received during discovery
@property (nonatomic, strong)NSDictionary * advertisementData;

// the received signal srength indicator at discovery time
@property (nonatomic, strong)NSNumber *rssi;

// ---- Application specific properties ----

// This is an application specific key which is used to link the discovered peripheral with a Connect/Disconnect button on a table cell. 
@property (nonatomic, readonly)NSNumber *dictionaryKey;


// a list of advertising data items parsed pulled from the advertisementData dictionary
@property (nonatomic, strong)NSArray *advertisementItems;


// a screen friendly name (if obtainable) for referencing the peripheral
// in priority order: peripheral name, name found in advertising data, UUID String, nil
@property (nonatomic, strong)NSString *friendlyName;



// ---- API Methods ----

-(id)initWithCentral: (CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral * )peripheral withAdvertisementData:(NSDictionary *)advertisementData
            withRSSI:(NSNumber *)RSSI;



@end
