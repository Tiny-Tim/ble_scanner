//
//  BLEDiscoveryRecord.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/29/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEPeripheralRecord.h"
#import "BLEDetailCellData.h"
#import "CBUUID+StringExtraction.h"

@implementation BLEPeripheralRecord

@synthesize advertisementItems = _advertisementItems;

@synthesize dictionaryKey = _dictionaryKey;

@synthesize friendlyName = _friendlyName;


// Used to generate a unique dictionary key (per session), count is incremented with each discovered peripheral
static NSInteger recordCount=1;


// generate the key
-(NSNumber *)dictionaryKey
{
    if (_dictionaryKey == nil)
    {
        _dictionaryKey = [NSNumber numberWithInteger:recordCount];
        recordCount++;
    }
        
    return _dictionaryKey;
}

// setter for advertisement items
-(void)setAdvertisementItems:(NSArray *)advertisementItems
{
    _advertisementItems = advertisementItems;
}

// getter for advertisement items
-(NSArray *)advertisementItems
{
    if (_advertisementItems == nil)
    {
        _advertisementItems = [NSArray array];
    }
    return _advertisementItems;
}


-(NSString *)friendlyName
{
    if (_friendlyName == nil)
    {
        if ( (self.peripheral.name) && ([self.peripheral.name localizedCompare:@""] != NSOrderedSame) )
        {
            // string is not nil and string is not empty
            NSString *whitespaceTrimmed = [self.peripheral.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([whitespaceTrimmed length] > 0)
            {
                _friendlyName = self.peripheral.name;
                return _friendlyName;
            }
        }
        
        // peripheral.name not a viable friendly name, check the advertising data
        // see if an advertising key contains a substring of "localname" case insensitive
        for (BLEDetailCellData * item in self.advertisementItems)
        {
            NSRange range;
            
            range = [item.textLabelText rangeOfString:@"localname" options: NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
            {
                // found the substring use the corresponding detailtextlabel as the friendly name
                _friendlyName = item.detailTextLabelText;
                return _friendlyName;
            }
        }
        
        // last option is to use the device UUID if available
        if (self.peripheral.UUID)
        {
            NSString *uuid_string;
            CFUUIDRef uuid = self.peripheral.UUID;
            if (uuid)
            {
                CFStringRef s = CFUUIDCreateString(NULL, uuid);
                uuid_string = CFBridgingRelease(s);
            }
            else
            {
                // no UUID provided in discovery
                uuid_string = @"";
            }
            
            _friendlyName = uuid_string;
            return _friendlyName;
        }
    }
    
    return _friendlyName;

}



// process the advertisement data and place content in advertiementItems list
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


// Invoked by Central when a device is discovered
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
    
    NSLog(@"Friendly Name: %@",self.friendlyName);
    
    return self;
}

@end
