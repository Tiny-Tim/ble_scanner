//
//  BLEAcclerometerValue.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/10/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEAcclerometerValue.h"

@implementation BLEAcclerometerValue

// default initilization
-(id)init
{
    self =  [super init];
    self.xAxisValue = 0;
    self.yAxisValue = 0;
    self.zAxisValue = 0;
    
    return self;
}

// initializer with specified values
-(id) initWithX:(CGFloat)xValue withY:(CGFloat)yValue withZ:(CGFloat)zValue
{
    self = [self init];
    
    self.xAxisValue = xValue;
    self.yAxisValue = yValue;
    self.zAxisValue = zValue;
    
    return self;
    
}

@end
