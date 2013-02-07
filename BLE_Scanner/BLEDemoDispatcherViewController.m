//
//  BLEDemoDispatcherViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/7/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEDemoDispatcherViewController.h"

@interface BLEDemoDispatcherViewController ()

- (IBAction)serviceButtonTapped:(UIButton *)sender;

@end

@implementation BLEDemoDispatcherViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)serviceButtonTapped:(UIButton *)sender
{
    
    if ([sender.titleLabel.text hasPrefix:@"1802"])
    {
        NSLog(@"Immediate Alert Service Selected");
    }
}

@end