//
//  VSCBluetoothHelper.m
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "VSCBluetoothHelper.h"
#import "VSCVescHelper.h"

@interface VSCBluetoothHelper ()

@property (nonatomic, strong) NSArray *services;
@property (nonatomic) BOOL isConnected;

@end

@implementation VSCBluetoothHelper

+ (VSCBluetoothHelper *) sharedInstance {
    static VSCBluetoothHelper *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setup];
        
    });
    
    return sharedInstance;
}

-(void)setup {
    
    NSLog(@"=== VESC BLUETOOTH HELPER INIT");
    
    // Scan for all available CoreBluetooth LE devices
    self.services = @[[CBUUID UUIDWithString:UART_SERVICE_UUID], [CBUUID UUIDWithString:DEVICE_INFO_UUID]];
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
    
}


#pragma mark - CBCentralManagerDelegate

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.isConnected = peripheral.state == CBPeripheralStateConnected;
    NSString *statusString = self.isConnected ? @"CoreBluetooth BLE Connected" : @"CoreBluetooth BLE Not Connected";
    NSLog(@"%@", statusString);
    
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    if ([localName length] > 0) {
        NSLog(@"Found the VESC preipheral: %@", localName);
//        self.statusLabel.text = @"CoreBluetooth BLE Found";
        self.vescPeripheral = peripheral;
        
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
        
        [self.centralManager stopScan];
    }
    
}

//-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    
//    [self setStatus:VSCBluetoothStatusDisconnected];
//    
//    self.txCharacteristic = nil;
//    self.rxCharacteristic = nil;
//    self.vescPeripheral = nil;
//    [[VSCVescHelper sharedInstance] resetPacket];
//    
//    // Start scanning for it again
//    [self.centralManager scanForPeripheralsWithServices:self.services options:nil];
//    [self setStatus:VSCBluetoothStatusScanning];
//}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    // Determine the state of the peripheral
    if ([central state] == CBManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
        [self setStatus:VSCBluetoothStatusError];
    }
    else if ([central state] == CBManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self.centralManager scanForPeripheralsWithServices:self.services options:nil];
        NSLog(@"%@", self.services);
        [self setStatus:VSCBluetoothStatusScanning];
    }
    else if ([central state] == CBManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
        [self setStatus:VSCBluetoothStatusError];
    }
    else if ([central state] == CBManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
        [self setStatus:VSCBluetoothStatusError];
    }
    else if ([central state] == CBManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
        [self setStatus:VSCBluetoothStatusError];
    }
    
}

#pragma mark - CBPeripheralDelegate

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:UART_SERVICE_UUID]])  {
        
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:TX_CHARACTERISTIC_UUID]]) {
                NSLog(@"Found TX service");
                self.txCharacteristic = aChar;
                
                if (self.rxCharacteristic != nil){
                    [self onVescConnectionReady];
                }
                
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:RX_CHARACTERISTIC_UUID]]) {
                NSLog(@"Found RX service");
                self.rxCharacteristic = aChar;
                [self.vescPeripheral setNotifyValue:YES forCharacteristic:_rxCharacteristic];
                
                if (self.txCharacteristic != nil) {
                    [self onVescConnectionReady];
                }
                
            }
        }
        
        if (_txCharacteristic == nil && _rxCharacteristic == nil) {
            NSLog(@"RX and TX not discovered. Closing connection.");
            [self.centralManager cancelPeripheralConnection:self.vescPeripheral];
        }
        
    } else if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_INFO_UUID]]) {
        NSLog(@"Discovered Device Info");
        
        for (CBCharacteristic *aChar in service.characteristics)
        {
            NSLog(@"Found device service: %@", aChar.UUID);
            [self.vescPeripheral readValueForCharacteristic:aChar];
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        [self setStatus:VSCBluetoothStatusError];
        return;
    }
    
    VSCVescHelper *vescHelper = [VSCVescHelper sharedInstance];
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TX_CHARACTERISTIC_UUID]]) { // 1
        // TX
        NSLog(@"TX update value");
        
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:RX_CHARACTERISTIC_UUID]]) {
        // RX
        
        if ([vescHelper processIncomingBytes:characteristic.value] > 0) {
            struct bldcMeasure values = [vescHelper processReadPacket];
            
            NSData *myData = [NSData dataWithBytes:&values length:sizeof(values)];
            
            // Add this VESC data, with Date as an array
            [vescHelper.dataArray addObject:@[[NSDate date], myData]];
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onReceivedNewVescData:)]) {
                [self.delegate onReceivedNewVescData:myData];
            }
            
            if (values.fault_code == FAULT_CODE_NO_DATA) {
                NSLog(@"Error");
                [self setStatus:VSCBluetoothStatusError];
            }
        }
    }
    
}

- (void)onVescConnectionReady {
    [self setStatus:VSCBluetoothStatusReady];
}

#pragma mark - Setters

-(void)setStatus:(VSCBluetoothStatus)status {
    _status = status;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onBluetoothStatusChanged:)]) {
        [self.delegate onBluetoothStatusChanged:status];
    }
}


@end
