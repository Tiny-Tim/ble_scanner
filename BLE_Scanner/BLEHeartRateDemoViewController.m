//
//  BLEHeartRateDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/11/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEHeartRateDemoViewController.h"
#import "CBUUID+StringExtraction.h"
#include "ServiceAndCharacteristicMacros.h"

@interface BLEHeartRateDemoViewController ()

@property (nonatomic) BOOL debug;

@property (weak, nonatomic) IBOutlet UIImageView *heartBeatImage;

// Label which displays peripheral status and activity.
@property (weak, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

// Spinner activity indicator which is active when device is being accessed.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *peripheralStatusSpinner;

@property (weak, nonatomic) IBOutlet UILabel *heartRateMeasureLabel;

@property (nonatomic)NSUInteger lastMeasurement;

@property (nonatomic)BOOL animationStarted;

@end

@implementation BLEHeartRateDemoViewController

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
 * Method Name:  setConnectionStatus
 *
 * Description:  Sets the connection status label to indicate peripheral connect status.
 *
 * Parameter(s): None
 *
 */
-(void)setConnectionStatus
{
    if ([self.heartRateService.peripheral isConnected])
    {
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Connected";
    }
    else
    {
        self.peripheralStatusLabel.textColor = [UIColor redColor];
        self.peripheralStatusLabel.text = @"Unconnected";
    }
}


-(void)discoverHeartRateMeasurementServiceCharacteristic
{
    if ([self.heartRateService.peripheral isConnected])
    {
        // discover keyPressed service characteristic
        CBUUID *UUUID = [CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC];
        NSArray *heartRateServiceUUID = [NSArray arrayWithObject:UUUID];
        
        self.peripheralStatusLabel.textColor = [UIColor greenColor];
        self.peripheralStatusLabel.text = @"Discovering service characteristics.";
        [self.peripheralStatusSpinner startAnimating];
        
        [self.heartRateService.peripheral discoverCharacteristics:heartRateServiceUUID
                                                        forService:self.heartRateService];
    }
    else
    {
        if (self.debug) NSLog(@"Failed to discover characteristic, peripheral not connected.");
        [self setConnectionStatus];
    }
    
}





-(void)enableForHeartRateMeasurementNotifications : (BOOL) enable
{
    // Check to see if peripheral has retrieved characteristics
    if (self.heartRateService.characteristics)
    {
        NSUInteger index = [self.heartRateService.characteristics indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            CBCharacteristic *characteristic = (CBCharacteristic *)obj;
            
            NSString *uuidString = [[characteristic.UUID representativeString] uppercaseString];
            if ([uuidString localizedCompare:HEART_RATE_MEASUREMENT_CHARACTERISTIC] == NSOrderedSame)
            {
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound)
        {
            [self discoverHeartRateMeasurementServiceCharacteristic];
        }
        else
        {
            if ([self.heartRateService.peripheral isConnected])
            {
                // sign up for notifications
                [self.heartRateService.peripheral setNotifyValue:enable forCharacteristic:self.heartRateService.characteristics[index]];
                
            }
        }
    }
    else
    {
        [self discoverHeartRateMeasurementServiceCharacteristic];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _debug = YES;
    
    _animationStarted = NO;
    
    self.lastMeasurement = 0;
    
    self.heartRateMeasureLabel.text = @"";
    
    self.heartRateService.peripheral.delegate =self;
    
    int numberOfFrames = 10;
    NSMutableArray *imagesArray = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    for (int i=0; i<numberOfFrames; i++)
    {
        int imageIndex = i+1;
        [imagesArray addObject:[UIImage imageNamed:
                                [NSString stringWithFormat:@"heartbeat-%d (dragged).tiff", imageIndex]]];
        
    }
    
    self.heartBeatImage.animationImages = imagesArray;
    self.heartBeatImage.animationDuration = 0.6;
   
    
    [self setConnectionStatus];
    
    [self enableForHeartRateMeasurementNotifications: YES];
    
    
}



-(void) viewWillDisappear:(BOOL)animated
{
    self.heartRateService.peripheral.delegate = nil;
    
    [self.heartBeatImage stopAnimating];
    
    [self enableForHeartRateMeasurementNotifications: NO];
    
    [super viewWillDisappear:animated];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.debug) NSLog(@"didUpdateNotificationStateForCharacteristic invoked");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    
    if (!error)
    {
        if (self.debug) NSLog(@"Characteristic value  updated.");
        
        const uint8_t *reportData = [characteristic.value bytes];
        uint16_t bpm = 0;
        
        if ((reportData[0] & 0x01) == 0)
        {
            /* uint8 bpm */
            bpm = reportData[1];
        }
        else
        {
            /* uint16 bpm */
            bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
        }
        
        NSLog(@"Heart Rate Measurement Rcvd: %i",bpm);
        if (! self.animationStarted)
        {
            self.animationStarted = YES;
            if (bpm < 20) bpm = 20;
            [self.heartBeatImage startAnimating];
        }
        if (bpm != self.lastMeasurement)
        {
            self.lastMeasurement = bpm;
             if (bpm < 20) bpm = 20;
            
            self.heartRateMeasureLabel.text = [NSString stringWithFormat:@"Heart Rate:  %i",bpm];
           
        }
    }
    
    [self setConnectionStatus];
    
}


/*
 *
 * Method Name:  peripheral:didDiscoverCharacteristicsForService:error
 *
 * Description:  CBPeripheralDelegate method invoked when chracteristic is discovered or error occurs when reading characteristic.
 *
 * Parameter(s): See CBPeripheralDelegate documentation.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (self.debug) NSLog(@"didDiscoverCharacteristicsForService invoked");
    
    [self.peripheralStatusSpinner stopAnimating];
    [self setConnectionStatus];
    
    if (error == nil)
    {
        if (self.debug) NSLog(@"Subscribing to key pressed notifications");
        [self enableForHeartRateMeasurementNotifications: YES];
    }
}


@end
