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

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static Detect3GorWifiViewController *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Detect3GorWifiViewController alloc]initwithState:YES andValue:100];
    });
    
    return sharedInstance;
}

-(instancetype)initwithState:(BOOL )state andValue:(int )interger{
    if (self == [super init]) {
        self.switchWifi = [[UISwitch alloc]init];
        self.switchAll = [[UISwitch alloc]init];
        self.switch3G = [[UISwitch alloc]init];
        self.btn100Mb = [[UIButton alloc]init];
        self.btn200Mb = [[UIButton alloc]init];
        self.btn300Mb = [[UIButton alloc]init];
        self.output = 1;
        self.switchAll.on = state;
        self.switchWifi.on = state;
        switch (interger) {
            case 100:
                self.btn100Mb.selected = YES;
                break;
            case 200:
                self.btn200Mb.selected = YES;
                break;
            case 300:
                self.btn300Mb.selected = YES;
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)check{
    if (self.switchAll.on) {
        return YES;
    }else{
        return NO;
    }
}

- (IBAction)switchAll:(id)sender {
    if (self.switchAll.on) {
        self.switchAll.on = 1;
        self.switchWifi.on = 1;
    }else{
        self.switchAll.on = 0;
        self.switchWifi.on = 0;
        self.switch3G.on = 0;
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
}
- (IBAction)btn100Mb:(id)sender {
    if (!self.btn100Mb.selected) {
        self.output = 1;
        self.btn100Mb.selected = true;
        self.btn200Mb.selected = false;
        self.btn300Mb.selected = false;
    }
}
- (IBAction)btn200Mb:(id)sender {
    if (!self.btn200Mb.selected) {
        self.output = 3;
        self.btn200Mb.selected = true;
        self.btn100Mb.selected = false;
        self.btn300Mb.selected = false;
    }
}
- (IBAction)btn300Mb:(id)sender {
    if (!self.btn300Mb.selected) {
        self.output = 5;
        self.btn300Mb.selected = true;
        self.btn100Mb.selected = false;
        self.btn200Mb.selected = false;
    }
}

- (IBAction)dismissTab:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
