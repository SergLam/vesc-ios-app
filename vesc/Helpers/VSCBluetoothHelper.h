//
//  VSCBluetoothHelper.h
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;
@import QuartzCore;

#define UART_SERVICE_UUID @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define RX_CHARACTERISTIC_UUID @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define TX_CHARACTERISTIC_UUID @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define DEVICE_INFO_UUID @"180A"
#define HARDWARE_REVISION_UUID @"2A27"

typedef NS_ENUM(NSInteger, VSCBluetoothStatus) {
    VSCBluetoothStatusDisconnected,
    VSCBluetoothStatusConnected,
    VSCBluetoothStatusError,
    VSCBluetoothStatusReady
};

@protocol VSCBluetoothHelper;

@interface VSCBluetoothHelper : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

+ (VSCBluetoothHelper *) sharedInstance;

@property (nonatomic) VSCBluetoothStatus status;
@property (nonatomic, assign) id <VSCBluetoothHelper> delegate;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *vescPeripheral;

@property (nonatomic, strong) CBCharacteristic *txCharacteristic;
@property (nonatomic, strong) CBCharacteristic *rxCharacteristic;
@end


@protocol VSCBluetoothHelper <NSObject>
@optional
-(void)onBluetoothStatusChanged:(VSCBluetoothStatus)status;
-(void)onReceivedNewVescData:(NSData *)data;
@end
