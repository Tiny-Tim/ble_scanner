//
//  BLEBluetoothWebServiceViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/15/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEBluetoothWebServiceViewController.h"
#include "ServiceAndCharacteristicMacros.h"

@interface BLEBluetoothWebServiceViewController ()<UIWebViewDelegate>

// Webview outlet
@property (weak, nonatomic) IBOutlet UIWebView *webView;

// Activity indicator for page load
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

/*
 *
 * Method Name:  viewDidLoad
 *
 * Description:  Initializes controller when instantiated and loads the Bluetooth Developer Portal page containing registered services.
 *
 * Parameter(s): None
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    
    NSURL * webPage = [NSURL URLWithString:BLUETOOTH_DEVELOPER_PORTAL_REGISTERED_SERVICES];
    NSURLRequest *request = [NSURLRequest requestWithURL:webPage];
    [self.activityIndicator startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("download", NULL);
    dispatch_async(downloadQueue, ^{
        
        [self.webView loadRequest:request];
        
    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.webView.delegate = nil;
}



#pragma mark- UIWebViewDelegate Protocol

// Page loaded stop the activity indicator
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog(@"Web page loaded");
    [self.activityIndicator stopAnimating];
}
@end
