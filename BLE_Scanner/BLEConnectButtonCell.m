//
//  BLEConnectButtonCell.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/1/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEConnectButtonCell.h"

@interface BLEConnectButtonCell()


@end

@implementation BLEConnectButtonCell


static NSMutableDictionary *titleDictionary;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

-(void)awakeFromNib
{
    if (titleDictionary == nil)
    {
        titleDictionary = [NSMutableDictionary dictionary];

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+(NSString *)getButtonTitle : (NSIndexPath *)index
{
    NSString *title = [titleDictionary objectForKey:index];
    
    if (title == nil)
    {
        // if values have not been set in the dictionary return default title
        title = @"Connect";  
    }
    return title;
}

+(void) setButtonTitle : (NSString *)title AtIndex:(NSIndexPath *)index
{
    [titleDictionary setObject:title forKey:index];
    
}

// Show disclosure button on table cell if the state of the cell is connected.
// State is connected if the button label shows Disconnect (user can then Disconnect the connected peripheral.
+(BOOL)showDisclosureButton : (NSIndexPath *)index
{
    NSString *title = [titleDictionary objectForKey:index];
    
    if (title && ([title localizedCompare:@"Disconnect"] == NSOrderedSame))
        return YES;
    else
        return NO;
}


@end
