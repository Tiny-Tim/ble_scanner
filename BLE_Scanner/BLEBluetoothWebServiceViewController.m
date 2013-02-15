//
//  BLEBluetoothWebServiceViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/15/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEBluetoothWebServiceViewController.h"

@interface BLEBluetoothWebServiceViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BLEBluetoothWebServiceViewController

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
  //  NSURL * webPage = [NSURL URLWithString:@"http://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx"];
    
    NSURL * webPage = [NSURL URLWithString:@"https://developer.bluetooth.org"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:webPage];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
