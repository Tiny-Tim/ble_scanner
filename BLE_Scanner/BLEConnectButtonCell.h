//
//  BLEConnectButtonCell.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/1/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>

// Custom button cell for discovered device table which holds a button
@interface BLEConnectButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *connectDisconnectButton;

+(NSString *)getButtonTitle : (NSNumber *)key;

+(void) setButtonTitle : (NSString *)title AtKey:(NSNumber *)key;



@end
