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
#define GENERIC_ACCESS_PROFILE @"1800"

#define IMMEDIATE_ALERT_SERVICE @"1802"

#define Tx_POWER_SERVICE @"1804"

#define DEVICE_INFORMATION_SERVICE @"180A"

#define HEART_RATE_MEASUREMENT_SERVICE @"180D"

#define BATTERY_SERVICE @"180F"

#define TI_KEYFOB_ACCELEROMETER_SERVICE @"FFA0"

#define TI_KEYFOB_KEYPRESSED_SERVICE @"FFE0"

// Characteristics
#define DEVICE_NAME_CHARACTERISTIC                @"2A00"
#define APPEARANCE_CHARACTERISTIC                 @"2A01"
#define PERIPHERAL_PRIVACY_FLAG_CHARACTERISTIC    @"2A02"
#define ALERT_LEVEL_CHARACTERISTIC                @"2A06"
#define TRANSMIT_POWER_LEVEL_CHARACTERISTIC       @"2A07"
#define BATTERY_LEVEL_CHARACTERISTIC              @"2A19"
#define MODEL_NUMBER_STRING_CHARACTERISTIC        @"2A24"
#define SERIAL_NUMBER_STRING_CHARACTERISTIC       @"2A25"
#define FIRMWARE_REVISION_STRING_CHARACTERISTIC   @"2A26"
#define HARDWARE_REVISION_STRING_CHARACTERISTIC   @"2A27"
#define SOFTWARE_REVISION_STRING_CHARACTERISTIC   @"2A28"
#define MANUFACTURER_NAME_STRING_CHARACTERISTIC   @"2A29"
#define HEART_RATE_MEASUREMENT_CHARACTERISTIC     @"2A37"
#define BODY_SENSOR_LOCATION_CHARACTERISTIC       @"2A38"

#define TI_ENABLE_ACCELEROMETER   @"FFA1"
#define TI_ACCELEROMETER_RANGE    @"FFA2"
#define TI_ACCELEROMETER_X_VALUE  @"FFA3"
#define TI_ACCELEROMETER_Y_VALUE  @"FFA4"
#define TI_ACCELEROMETER_Z_VALUE  @"FFA5"

// TI triaxial accelerometer characteristic is not supported by key fob
// It packs all three accelerometer values in a single characteristic
#define TI_TRIAXIAL_ACCELEROMETER_VALUES    @"FFAA"

#define TI_KEY_PRESSED_STATE_CHARACTERISTIC @"FFE1"


// Accelerometer Calibration Coefficients
#define  X_CALIBRATION_SCALE 55.0
#define  X_CALIBRATION_OFFSET 0.0

#define  Y_CALIBRATION_SCALE 55.0
#define  Y_CALIBRATION_OFFSET 0.0

#define  Z_CALIBRATION_SCALE 55.0
#define  Z_CALIBRATION_OFFSET 0.0

#define HIGH_ALERT_VALUE 2
#define LOW_ALERT_VALUE  1
#define NO_ALERT_VALUE   0


#define BLUETOOTH_DEVELOPER_PORTAL_REGISTERED_SERVICES @"http://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx?SortField=AssignedNumber&SortDir=Asc"
#endif

