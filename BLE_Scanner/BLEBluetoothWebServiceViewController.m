//
//  BLEBluetoothWebServiceViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/15/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEBluetoothWebServiceViewController.h"

@interface BLEBluetoothWebServiceViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

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
    
    self.webView.delegate = self;
    
    NSURL * webPage = [NSURL URLWithString:@"http://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx?SortField=AssignedNumber&SortDir=Asc"];
    [self.activityIndicator startAnimating];
    NSURLRequest *request = [NSURLRequest requestWithURL:webPage];
    
    [self.webView loadRequest:request];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.webView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UIWebViewDelegate Protocol
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog(@"Web page loaded");
    [self.activityIndicator stopAnimating];
}
@end
