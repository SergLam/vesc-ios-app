//
//  SecondViewController.m
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "SettingsViewController.h"
#import "VSCUIHelper.h"
#import "VSCBluetoothHelper.h"

@interface SettingsViewController () <VSCBluetoothHelper>
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [VSCBluetoothHelper sharedInstance].delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self updateState];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - State management

-(void)updateState {
    
    VSCBluetoothHelper *bluetoothHelper = [VSCBluetoothHelper sharedInstance];
    
    if (bluetoothHelper.status == VSCBluetoothStatusDisconnected) {
        self.textLabel.text = @"Bluetooth disconnected";
    } else if (bluetoothHelper.status == VSCBluetoothStatusError) {
        self.textLabel.text = @"Bluetooth not available";
    } else if (bluetoothHelper.status == VSCBluetoothStatusConnected || bluetoothHelper.status == VSCBluetoothStatusReady) {
        self.textLabel.text = @"Bluetooth connected";
    } else if (bluetoothHelper.status == VSCBluetoothStatusScanning) {
        self.textLabel.text = @"Scanning for bluetooth devices...";
    }
    
    
}

#pragma mark - Bluetooth Helper Delegates

-(void)onBluetoothStatusChanged:(VSCBluetoothStatus)status {
    [self updateState];
}



@end
