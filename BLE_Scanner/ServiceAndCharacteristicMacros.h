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

#define DEVICE_INFORMATION_SERVICE @"180A"

#define HEART_RATE_MEASUREMENT_SERVICE @"180D"

#define BATTERY_SERVICE @"180F"

#define TI_KEYFOB_ACCELEROMETER_SERVICE @"FFA0"

#define TI_KEYFOB_KEYPRESSED_SERVICE @"FFE0"

// Characteristics
#define BATTERY_LEVEL_CHARACTERISTIC              @"2A19"
#define MODEL_NUMBER_STRING_CHARACTERISTIC        @"2A24"
#define MANUFACTURER_NAME_STRING_CHARACTERISTIC   @"2A29"
#define HEART_RATE_MEASUREMENT_CHARACTERISTIC     @"2A37"
#define BODY_SENSOR_LOCATION_CHARACTERISTIC       @"2A38"

#define TI_ENABLE_ACCELEROMETER   @"FFA1"
#define TI_ACCELEROMETER_X_VALUE  @"FFA3"
#define TI_ACCELEROMETER_Y_VALUE  @"FFA4"
#define TI_ACCELEROMETER_Z_VALUE  @"FFA5"

#define TI_KEY_PRESSED_STATE_CHARACTERISTIC @"FFE1"


// Accelerometer Calibration Coefficients
#define  X_CALIBRATION_SCALE 55.0
#define  X_CALIBRATION_OFFSET 0.1

#define  Y_CALIBRATION_SCALE 55.0
#define  Y_CALIBRATION_OFFSET 0.1

#define  Z_CALIBRATION_SCALE 55.0
#define  Z_CALIBRATION_OFFSET 0.1

#endif

