//
//  BLE_ScannerTests.m
//  BLE_ScannerTests
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLE_ScannerTests.h"


@implementation BLE_ScannerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    viewController = [[BLEViewController alloc]init];
    
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
    viewController = nil;
}

- (void)testExample
{
     STAssertTrue(YES, @"Unit tests are  implemented yet in BLE_ScannerTests");
    
    CBPeripheral *peripheral = [[CBPeripheral alloc]init];
    
   
    
    NSLog(@"peripheral description %@",[peripheral description]);
    
}

@end
