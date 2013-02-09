//
//  BLEAccelerometerDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/9/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEAccelerometerDemoViewController.h"

@interface BLEAccelerometerDemoViewController ()
@property (nonatomic)BOOL debug;
@end

@implementation BLEAccelerometerDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _debug = YES;
    
    if (self.debug) NSLog(@"Entering Acclerometer Demo viewDidLoad");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
