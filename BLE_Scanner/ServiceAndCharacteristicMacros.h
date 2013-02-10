//
//  ServiceAndCharacteristicMacros.h
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/7/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#ifndef BLE_Scanner_ServiceAndCharacteristicMacros_h
#define BLE_Scanner_ServiceAndCharacteristicMacros_h

//Services
#define IMMEDIATE_ALERT_SERVICE @"1802"

#define Tx_POWER_SERVICE @"1804"

#define HEART_RATE_MEASUREMENT_SERVICE @"180D"

#define BATTERY_SERVICE @"180F"

#define TI_KEYFOB_ACCELEROMETER_SERVICE @"FFA0"

#define TI_KEYFOB_KEYPRESSED_SERVICE @"FFE0"

// Characteristics
#define BATTERY_LEVEL_CHARACTERISTIC @"2A19"

#define TI_ENABLE_ACCELEROMETER   @"FFA1"
#define TI_ACCELEROMETER_X_VALUE  @"FFA3"
#define TI_ACCELEROMETER_Y_VALUE  @"FFA4"
#define TI_ACCELEROMETER_Z_VALUE  @"FFA5"

#define TI_KEY_PRESSED_STATE_CHARACTERISTIC @"FFE1"

#endif
