//
//  BLEScanControlTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEScanControlTVC.h"

#define ALL_SERVICE_INDEX 0
#define SELECT_SERVICE_INDEX 1

@interface BLEScanControlTVC ()

@property (nonatomic, readonly) NSArray  *scanOptions;
@property (weak, nonatomic) IBOutlet UITableViewCell *scanForAllServices;
@property (weak, nonatomic) IBOutlet UITableViewCell *scanForSelectedServices;

@property (nonatomic, strong) NSArray* servicesToScan;

// 0 index is scanForAllServices, 1st index is scan for selected services
@property (nonatomic, strong) NSMutableArray *checkMarkState;
@end

@implementation BLEScanControlTVC

@synthesize checkMarkState = _checkMarkState;
@synthesize servicesToScan = _servicesToScan;

-(NSMutableArray *)checkMarkState
{
    if (_checkMarkState == nil)
    {
        _checkMarkState = [NSMutableArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO], nil];
    }
    
    return _checkMarkState;
}



-(void) awakeFromNib
{
    [super awakeFromNib];
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
     self.scanForSelectedServices.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     self.scanForAllServices.accessoryType = UITableViewCellAccessoryNone;
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingToParentViewController])
    {
        // invoke the method which specifies the scan method
         BOOL checkState = [[self.checkMarkState objectAtIndex:(ALL_SERVICE_INDEX)]boolValue];
         if (checkState)
         {
             [self.delegate scanForServices:nil sender:self];
         }
        else
        {
            [self.delegate scanForServices:self.servicesToScan sender:self];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DLog(@"Preparing to segue to ServiceList from ScanControl");
    BLEDeviceListTVC *serviceListTVC;
    
    if ([segue.identifier isEqualToString:@"ShowServices"])
    {
        
        if ([segue.destinationViewController isKindOfClass:[BLEDeviceListTVC class]])
        {
            serviceListTVC= segue.destinationViewController;
            serviceListTVC.delegate = self;
            
        }
    }
}



#pragma mark - Table view delegate

// Allow the user to choose to either scan for all services or scan for specifically identified
// services. The choice is mutually exclusive.
// Initial default selection is scan for all services.
// Remember state of selection using user defaults (for both scan selection choice and services).
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Configure Scan Control Row Selected");
    
    // identify which row was selected
    if (indexPath.row == 0)
    {
        DLog(@"User selected scan for all services.");
        
        BOOL checkState = [[self.checkMarkState objectAtIndex:(ALL_SERVICE_INDEX)]boolValue];
        if (checkState)
        {
            // turn off check
            self.scanForAllServices.accessoryType= UITableViewCellAccessoryNone;
            [self.checkMarkState replaceObjectAtIndex:(ALL_SERVICE_INDEX) withObject:[NSNumber numberWithBool:NO] ];

        }
        else
        {
           // add checkmark for all
           self.scanForAllServices.accessoryType= UITableViewCellAccessoryCheckmark;
           [self.checkMarkState replaceObjectAtIndex:(ALL_SERVICE_INDEX) withObject:[NSNumber numberWithBool:YES]  ];
            
            // turn off selected
            self.scanForSelectedServices.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [self.checkMarkState replaceObjectAtIndex:(SELECT_SERVICE_INDEX) withObject:[NSNumber numberWithBool:NO]  ];
            
           
        }
    }
    else if (indexPath.row == 1)
    {
        DLog(@"User selected scan for specific services.");
        
        BOOL checkState = [[self.checkMarkState objectAtIndex:(SELECT_SERVICE_INDEX)]boolValue];
        if (checkState)
        {
            // turn off check
            self.scanForSelectedServices.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
            [self.checkMarkState replaceObjectAtIndex:(SELECT_SERVICE_INDEX) withObject:[NSNumber numberWithBool:NO]  ];
            
        }
        else
        {
            // add checkmark for select
            self.scanForSelectedServices.accessoryType= UITableViewCellAccessoryCheckmark;
            [self.checkMarkState replaceObjectAtIndex:(SELECT_SERVICE_INDEX) withObject:[NSNumber numberWithBool:YES]  ];
            
            // turn off all
            self.scanForAllServices.accessoryType = UITableViewCellAccessoryNone;
            [self.checkMarkState replaceObjectAtIndex:(ALL_SERVICE_INDEX) withObject:[NSNumber numberWithBool:NO] ];
            
            //segue to services list
            [self performSegueWithIdentifier:@"ShowServices" sender:self];
            
        }

                
        // Choosing this row indicates the user wants to scan for specific services
        // As a reminder of which services will be scanned, segue to the service list
        // when returning from the segue using view will appear, apply the check button.
        
        // The service list controller invokes a BLEScanControlDelegate protocol method to provide the list of services to scan for.
        
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     ; *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark - BLEServiceListDelegate Protocol

-(void) scanForServices: (NSArray *)services sender:(id)sender
{
    // change the accessory view to a checkmark
    self.scanForSelectedServices.accessoryType = UITableViewCellAccessoryCheckmark;
    [self.checkMarkState replaceObjectAtIndex:(SELECT_SERVICE_INDEX) withObject:[NSNumber numberWithBool:YES] ];
    
    self.scanForAllServices.accessoryType= UITableViewCellAccessoryNone;
    [self.checkMarkState replaceObjectAtIndex:(ALL_SERVICE_INDEX) withObject:[NSNumber numberWithBool:NO] ];
    
    // save the selected services
    self.servicesToScan = [services copy];
   
}

@end
