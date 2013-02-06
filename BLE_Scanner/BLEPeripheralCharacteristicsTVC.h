//
//  BLEPeripheralCharacteristicsTVC.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/5/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLECentralManagerDelegate.h"

@interface BLEPeripheralCharacteristicsTVC : UITableViewController <CBPeripheralDelegate>

// Model for the view controller
@property (nonatomic, strong)NSArray *characteristics;



@end
