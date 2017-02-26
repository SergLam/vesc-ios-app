//
//  FirstViewController.m
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "StatsViewController.h"
#import "VSCBluetoothHelper.h"
#import "VSCVescHelper.h"
#import "VSCStatsHelper.h"


@interface StatsViewController ()<VSCBluetoothHelper>

@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *ampsLabel;
@property (weak, nonatomic) IBOutlet UILabel *voltsLabel;
@property (weak, nonatomic) IBOutlet UILabel *celciusLabel;
@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.voltsLabel.textColor = [UIColor whiteColor];
    self.ampsLabel.textColor = [UIColor whiteColor];
    self.celciusLabel.textColor = [UIColor whiteColor];
    self.speedLabel.textColor = [UIColor whiteColor];
    self.batteryLabel.textColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view, typically from a nib.
    [VSCBluetoothHelper sharedInstance].delegate = self;
    if ([VSCBluetoothHelper sharedInstance].status == VSCBluetoothStatusReady) {
        [self fetchVescData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bluetooth Helper Delegates

-(void)onBluetoothStatusChanged:(VSCBluetoothStatus)status {
    if (status == VSCBluetoothStatusReady) {
        [self fetchVescData];
    }
}

-(void)onReceivedNewVescData:(NSData *)data {
    
    struct bldcMeasure newData;
    [data getBytes:&newData length:sizeof(newData)];
    
    NSLog(@"VESC COMMUNICATION OK");
    NSLog(@"INPUT VOLTAGE: %@", [NSString stringWithFormat:@"%0.1f volts", newData.inpVoltage]);
    self.voltsLabel.text = [NSString stringWithFormat:@"%0.1f V", newData.inpVoltage];
    self.ampsLabel.text = [NSString stringWithFormat:@"%0.1f A", newData.avgMotorCurrent];
    self.celciusLabel.text = [NSString stringWithFormat:@"%0.1f °C", newData.temp_pcb];
    self.speedLabel.text = [NSString stringWithFormat:@"%d km/u", [VSCStatsHelper calculateSpeed:newData.rpm]];
    
    [self performSelector:@selector(fetchVescData) withObject:nil afterDelay:.5];
}

#pragma mark - VESC Data

-(void)fetchVescData {
    
    VSCBluetoothHelper *bluetoothHelper = [VSCBluetoothHelper sharedInstance];
    
    NSLog(@"Fetching new data");
    
    NSData *dataToSend = [[VSCVescHelper sharedInstance] dataForGetValues:COMM_GET_VALUES val:0];
    if (dataToSend && bluetoothHelper.txCharacteristic) [bluetoothHelper.vescPeripheral writeValue:dataToSend forCharacteristic:bluetoothHelper.txCharacteristic type:CBCharacteristicWriteWithResponse];
}

@end
