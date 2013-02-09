//
//  BLEAccelerometerDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/9/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEAccelerometerDemoViewController.h"
#import <dispatch/dispatch.h>

#define MAX_PLOT_ITEMS 3

// sample rate, e.g 1 sample/second  (.1 hz --> 10 seconds between samples)
#define SAMPLE_CLOCK_FREQUENCY_HERTZ .2

@interface BLEAccelerometerDemoViewController ()
@property (nonatomic)BOOL debug;

@property (nonatomic, strong) dispatch_source_t sampleClock;

@property (nonatomic,strong) dispatch_queue_t synchronizingQueue;

@property (nonatomic, strong) NSMutableArray *accelerationPlotX;

@property (nonatomic, strong) NSNumber *accelerometerXNotification;
@end

@implementation BLEAccelerometerDemoViewController

@synthesize accelerationPlotX = _accelerationPlotX;


-(dispatch_queue_t) synchronizingQueue
{
    if (! _synchronizingQueue)
    {
        _synchronizingQueue = dispatch_queue_create("acceleration_queue", NULL);
        
    }
    
    return _synchronizingQueue;
}

-(dispatch_source_t)sampleClock
{
    if (! _sampleClock)
    {
        _sampleClock = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, self.synchronizingQueue);
       

        dispatch_source_set_event_handler(_sampleClock, ^{
            
            dispatch_async(self.synchronizingQueue, ^{
                
                // copy the accleration data into the plotting data structure
                NSNumber *latestValue = [self.accelerometerXNotification copy];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([self.accelerationPlotX count] <  MAX_PLOT_ITEMS)
                    {
                        [self.accelerationPlotX addObject:latestValue];
                    }
                    else
                    {
                        [self.accelerationPlotX removeObjectAtIndex:0];
                        [self.accelerationPlotX addObject:latestValue];
                    }
                    
                    // Update the plot
                    NSLog(@"Added value %i",[latestValue unsignedIntegerValue]);
                    
                });
                
            });
        });
        
        dispatch_resume(_sampleClock);
        
    }
    
    return _sampleClock;
}


-(NSMutableArray *)accelerationPlotX
{
    if (_accelerationPlotX == nil)
    {
        _accelerationPlotX = [NSMutableArray arrayWithCapacity:MAX_PLOT_ITEMS];
    }
    return _accelerationPlotX;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}


dispatch_source_t one_second_timer;
//dispatch_source_t three_second_timer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _debug = YES;
    
    if (self.debug) NSLog(@"Entering Acclerometer Demo viewDidLoad");
    
    dispatch_source_set_timer(self.sampleClock, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC / SAMPLE_CLOCK_FREQUENCY_HERTZ, 1ull * NSEC_PER_SEC/100);
   // dispatch_queue_t dataQueue = dispatch_queue_create("data_queue", NULL);
    
    
    
    one_second_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                              0, 0, self.synchronizingQueue );
    
    __block NSNumber *count = [NSNumber numberWithUnsignedInteger:0];
    if (one_second_timer)
    {
        dispatch_source_set_timer(one_second_timer, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC/100);
        dispatch_source_set_event_handler(one_second_timer, ^{
            
            
            count = [NSNumber numberWithUnsignedInteger:[count unsignedIntegerValue]+1 ];
            
            self.accelerometerXNotification = count;
            
       });
        dispatch_resume(one_second_timer);
    }


 
    
//    three_second_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
//                                                                0, 0, dataQueue);
//    if (three_second_timer)
//    {
//        dispatch_source_set_timer(three_second_timer, DISPATCH_TIME_NOW, 3ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC/10);
//        dispatch_source_set_event_handler(three_second_timer, ^{
//            
//            NSArray *plotData = [self.accelerationPlotX copy];
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 
//                 for (NSNumber *n in plotData)
//                 {
//                     NSLog(@"Plot value: %i",[n unsignedIntegerValue]);
//                 }
//                 NSLog(@"============");
//                 
//             });
//                            
//                            
//            
//        });
//        
//         dispatch_resume(three_second_timer);
//
//    }
   
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_source_cancel(self.sampleClock);
    self.sampleClock = nil;
    
    dispatch_source_cancel(one_second_timer);
    one_second_timer = nil;
    
    
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
