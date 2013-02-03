//
//  BLEDetailCellData.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/2/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEDetailCellData : NSObject

@property (nonatomic, strong) NSString *textLabelText;

@property (nonatomic, strong) NSString *detailTextLabelText;

-(void)setLabelText: (NSString *)textLabel andDetailText:(NSString *)detailText;
@end
