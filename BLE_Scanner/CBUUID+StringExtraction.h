//
//  CBUUID+StringExtraction.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/30/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBUUID (StringExtraction)
- (NSString *)representativeString;
@end
