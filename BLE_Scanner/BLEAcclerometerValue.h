//
//  BLEAcclerometerValue.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/10/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>


// Wrapper class for triaxial accelerometer data
@interface BLEAcclerometerValue : NSObject

@property (nonatomic) CGFloat xAxisValue;

@property (nonatomic) CGFloat yAxisValue;

@property (nonatomic) CGFloat zAxisValue;

-(id) initWithX :(CGFloat)xValue withY:(CGFloat)yValue withZ:(CGFloat)zValue;

-(id)init;
@end
