//
//  BLEHeartRateDemoViewController.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/11/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEHeartRateDemoViewController.h"

@interface BLEHeartRateDemoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *heartBeatImage;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    [self.heartBeatImage startAnimating];
}



-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.heartBeatImage stopAnimating];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
