//
//  BLEDiscoveryRecord.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDiscoveryRecord.h"
#import "BLEDetailCellData.h"
#import "CBUUID+StringExtraction.h"

@implementation BLEDiscoveryRecord


@synthesize advertisementItems = _advertisementItems;


-(void)setAdvertisementItems:(NSArray *)advertisementItems
{
    _advertisementItems = advertisementItems;
}

-(NSArray *)advertisementItems
{
    if (_advertisementItems == nil)
    {
        _advertisementItems = [NSArray array];
    }
    
    return _advertisementItems;
}


-(void)processAdvertisementData
{
    NSMutableArray *adInfo = [NSMutableArray array];
    BLEDetailCellData *row;
    
    // process advertisement data
    NSEnumerator *enumerator = [self.advertisementData keyEnumerator];
    id key;
    while ((key = [enumerator nextObject]))
    {
        if ([key isKindOfClass:[NSString class]])
        {
            NSLog(@"Advertising key: %@",key);
            id value = [self.advertisementData objectForKey:key];
            if ([value isKindOfClass:[NSString class]])
            {
                // both key and value are NSStrings
                row = [[BLEDetailCellData alloc] init];
                [row setLabelText:key andDetailText:value];
                [adInfo addObject:row];
            }
            else if ([value isKindOfClass:[NSArray class]])
            {
                NSArray *valueData = (NSArray *)value;
                for (id item in valueData)
                {
                    if ([item isKindOfClass:[CBUUID class]])
                    {
                        // both key and value are NSStrings
                        row = [[BLEDetailCellData alloc] init];
                        [row setLabelText:key andDetailText:[item representativeString]];
                        [adInfo addObject:row];
                    }
                }
            }
            else
            {
                // do nothing for now
            }
        }
    }
    
    self.advertisementItems = [adInfo copy];

}


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
        
        [self processAdvertisementData];
    }
    
    return self;
}

@end
