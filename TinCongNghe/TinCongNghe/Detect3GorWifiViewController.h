//
//  Detect3GorWifiViewController.h
//  TinCongNghe
//
//  Created by Khai on 11/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <UIKit/UIKit.h>
#define knetwork [Detect3GorWifiViewController sharedInstance]

@interface Detect3GorWifiViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *switchAll;
@property (strong, nonatomic) IBOutlet UISwitch *switchWifi;
@property (strong, nonatomic) IBOutlet UISwitch *switch3G;
@property (strong, nonatomic) IBOutlet UIButton *btn100Mb;
@property (strong, nonatomic) IBOutlet UIButton *btn200Mb;
@property (strong, nonatomic) IBOutlet UIButton *btn300Mb;
@property (assign, nonatomic) NSInteger output;

+ (instancetype) sharedInstance;
-(BOOL)check;
-(instancetype)initwithState:(BOOL )state andValue:(int )interger;
@end
