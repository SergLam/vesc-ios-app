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
#import "VSCStatsView.h"

#import "VSCUIHelper.h"

@interface StatsViewController ()<VSCBluetoothHelper>

@property (weak, nonatomic) IBOutlet VSCStatsView *voltsView;
@property (weak, nonatomic) IBOutlet VSCStatsView *ampsView;
@property (weak, nonatomic) IBOutlet VSCStatsView *celcuisView;
@property (weak, nonatomic) IBOutlet VSCStatsView *speedView;
@property (weak, nonatomic) IBOutlet VSCStatsView *batteryPercentageView;


@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [VSCBluetoothHelper sharedInstance].delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    self.ampsView.hasSubLabel = YES;
    self.celcuisView.hasSubLabel = YES;
    self.speedView.hasSubLabel = YES;
    
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
        [self performSelector:@selector(fetchVescData) withObject:nil afterDelay:5];
    }
}

-(void)onReceivedNewVescData:(NSData *)data {
    
    struct bldcMeasure newData;
    [data getBytes:&newData length:sizeof(newData)];
    
    VSCStatsHelper *statsHelper = [VSCStatsHelper sharedInstance];
    statsHelper.amps = newData.avgInputCurrent;
    statsHelper.ampHours = newData.ampHours;
    statsHelper.celcius = newData.temp_pcb;
    statsHelper.speed = [VSCStatsHelper calculateSpeed:newData.rpm];
    
    self.voltsView.mainLabel.text = [NSString stringWithFormat:@"%0.1f V", newData.inpVoltage];
    
    self.ampsView.mainLabel.text = [NSString stringWithFormat:@"%0.1f A", statsHelper.amps];
    self.ampsView.subLabel.text = [NSString stringWithFormat:@"Max: %0.1f A", statsHelper.maxAmps];
    
    self.celcuisView.mainLabel.text = [NSString stringWithFormat:@"%0.1f °C", statsHelper.celcius];
    self.celcuisView.subLabel.text = [NSString stringWithFormat:@"Max: %0.1f °C", statsHelper.maxCelcius];
    
    self.speedView.mainLabel.text = [NSString stringWithFormat:@"%d km/u", statsHelper.speed];
    self.speedView.subLabel.text = [NSString stringWithFormat:@"Max: %d km/u", statsHelper.maxSpeed];
    
    
    self.batteryPercentageView.mainLabel.text = [NSString stringWithFormat:@"%d.1 %%", [VSCStatsHelper calculateBatteryStatusWithVoltage:newData.inpVoltage]];
    
    [self performSelector:@selector(fetchVescData) withObject:nil afterDelay:.75];
}

#pragma mark - VESC Data

-(void)fetchVescData {
    
    VSCBluetoothHelper *bluetoothHelper = [VSCBluetoothHelper sharedInstance];
    
    NSData *dataToSend = [[VSCVescHelper sharedInstance] dataForGetValues:COMM_GET_VALUES val:0];
    if (dataToSend && bluetoothHelper.txCharacteristic) {
        [bluetoothHelper.vescPeripheral writeValue:dataToSend forCharacteristic:bluetoothHelper.txCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

@end
