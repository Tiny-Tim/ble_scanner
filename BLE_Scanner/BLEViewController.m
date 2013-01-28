//
//  BLEViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEViewController.h"

@interface BLEViewController ()
- (IBAction)scanButton;
- (IBAction)stopScanButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;
@property (weak, nonatomic) IBOutlet UILabel *scanStatus;
@property (strong, nonatomic) CBCentralManager *centralManager;

@end

@implementation BLEViewController

#pragma mark - Properties

- (IBAction)scanButton {
}

- (IBAction)stopScanButton {
}

#pragma mark - Helper Functions
+(NSString *)getCBCentralStateName:(CBCentralManagerState) state
{
    NSString *stateName;
    
    switch (state) {
        case CBCentralManagerStatePoweredOn:
            stateName = @"Bluetooth Powered On - Ready";
            break;
        case CBCentralManagerStateResetting:
            stateName = @"Resetting";
            break;
            
        case CBCentralManagerStateUnsupported:
            stateName = @"Unsupported";
            break;
            
        case CBCentralManagerStateUnauthorized:
            stateName = @"Unauthorized";
            break;
            
        case CBCentralManagerStatePoweredOff:
            stateName = @"Bluetooth Powered Off";
            break;
            
        default:
            stateName = @"Unknown";
            break;
    }
    return stateName;
}


#pragma - Controller Lifecycle

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialize central manager providing self as its delegate
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - CBCentralManagerDelegate



- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Central Manager Delegate DidUpdate State Invoked");
    self.hostBluetoothStatus.text = [[self class ] getCBCentralStateName: self.centralManager.state];
    
}

@end
