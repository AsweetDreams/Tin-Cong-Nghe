//
//  Detect3GorWifiViewController.m
//  TinCongNghe
//
//  Created by Khai on 11/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "Detect3GorWifiViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "Reachability.h"

@interface Detect3GorWifiViewController ()

@end

@implementation Detect3GorWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:k3gstate] == nil) {
        [defaults setInteger:1 forKey:kdataMb];
        [defaults setInteger:0 forKey:kAllstate];
        [defaults setInteger:0 forKey:kWifistate];
        [defaults setInteger:0 forKey:k3gstate];
    }
    // Do any additional setup after loading the view.
    self.switchAll.on = [[defaults objectForKey:kAllstate]integerValue];
    self.switchWifi.on = [[defaults objectForKey:kWifistate]integerValue];
    self.switch3G.on = [[defaults objectForKey:k3gstate]integerValue];
    NSLog(@"%i - %i - %i",self.switchAll.on, self.switchWifi.on,self.switch3G.on);
    NSInteger integer = [[defaults objectForKey:kdataMb]integerValue];
    switch (integer) {
        case 0:
        case 1:
            self.btn100Mb.selected = YES;
            break;
        case 3:
            self.btn200Mb.selected = YES;
            break;
        case 5:
            self.btn300Mb.selected = YES;
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)switchAll:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.switchAll.on) {
        self.switchAll.on = 1;
        self.switchWifi.on = 1;
        [defaults setInteger:self.switchAll.on forKey:kAllstate];
        [defaults setInteger:self.switchWifi.on forKey:kWifistate];
    }else{
        self.switchAll.on = 0;
        self.switchWifi.on = 0;
        self.switch3G.on = 0;
        [defaults setInteger:self.switchAll.on forKey:kAllstate];
        [defaults setInteger:self.switchWifi.on forKey:kWifistate];
        [defaults setInteger:self.switch3G.on forKey:k3gstate];
    }
}
- (IBAction)switchWifi:(id)sender {
    if (self.switchWifi.on) {
        self.switchAll.on = 1;
    }else{
        self.switchWifi.on = 0;
        if (!self.switch3G.on) {
            self.switchAll.on = 0;
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.switchAll.on forKey:kAllstate];
    [defaults setInteger:self.switchWifi.on forKey:kWifistate];
}
- (IBAction)switch3G:(id)sender {
    if (self.switch3G.on) {
        self.switchAll.on = 1;
    }else{
        self.switch3G.on = 0;
        if (!self.switchWifi.on) {
            self.switchAll.on = 0;
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.switch3G.on forKey:kAllstate];
    [defaults setInteger:self.switchAll.on forKey:k3gstate];
}
- (IBAction)btn100Mb:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!self.btn100Mb.selected) {
        self.btn100Mb.selected = true;
        self.btn200Mb.selected = false;
        self.btn300Mb.selected = false;
        [defaults setInteger:1 forKey:kdataMb];
    }
}
- (IBAction)btn200Mb:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!self.btn200Mb.selected) {
        self.btn200Mb.selected = true;
        self.btn100Mb.selected = false;
        self.btn300Mb.selected = false;
        [defaults setInteger:3 forKey:kdataMb];
    }
}
- (IBAction)btn300Mb:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!self.btn300Mb.selected) {
        self.btn300Mb.selected = true;
        self.btn100Mb.selected = false;
        self.btn200Mb.selected = false;
        [defaults setInteger:5 forKey:kdataMb];
    }
}

- (IBAction)dismissTab:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
