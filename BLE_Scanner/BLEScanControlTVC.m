//
//  BLEScanControlTVC.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 1/28/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEScanControlTVC.h"

@interface BLEScanControlTVC ()

@property (nonatomic, readonly) NSArray  *scanOptions;
@property (weak, nonatomic) IBOutlet UITableViewCell *scanForAllServices;
@property (weak, nonatomic) IBOutlet UITableViewCell *scanForSelectedServices;

@property (nonatomic) BOOL userSelectedServices;

@end

@implementation BLEScanControlTVC


-(void) awakeFromNib
{
    [super awakeFromNib];
    self.userSelectedServices = NO;
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
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    // ensure the disclosure indicator is presented unless returning from service list segue
    if (self.userSelectedServices)
    {
        // clear the userSelected service flag but leave the indicator to be a checkmark
        self.userSelectedServices = NO;
        
    }
    else // show the disclosure indicator
    {
        self.scanForSelectedServices.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"Preparing to segue to ServiceList from SvanControl");
    BLEServiceListTVC *serviceListTVC;
    
    if ([segue.identifier isEqualToString:@"ShowServices"])
    {
        
        if ([segue.destinationViewController isKindOfClass:[BLEServiceListTVC class]])
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
    NSLog(@"Configure Scan Control Row Selected");
    
    // identify which row was selected
    if (indexPath.row == 0)
    {
        NSLog(@"User selected scan for all services.");
        // add checkmark
        self.scanForAllServices.accessoryType= UITableViewCellAccessoryCheckmark;
        [self.delegate scanForAllServices:self];
    }
    else if (indexPath.row == 1)
    {
        NSLog(@"User selected scan for specific services.");
        // ensure the scan for all services row is unchecked
        self.scanForAllServices.accessoryType= UITableViewCellAccessoryNone;
        
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

-(void) scanForServices: (NSArray *)services : (id)sender
{
    // change the accessory view to a checkmark
    self.scanForSelectedServices.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // indicate that the check mark was set due to user selection so that in viewWillAppear it is not overwritten
    self.userSelectedServices = YES;
    
}

@end
