//
//  BLEConnectButtonCell.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/1/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLEConnectButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *connectDisconnectButton;

+(NSString *)getButtonTitle : (NSIndexPath *)index;

+(void) setButtonTitle : (NSString *)title AtIndex:(NSIndexPath *)index;


@end
