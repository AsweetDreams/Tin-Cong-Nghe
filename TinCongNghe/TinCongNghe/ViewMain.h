//
//  ViewController.h
//  TinCongNghe
//
//  Created by Khai on 23/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kViewmain [ViewMain sharedInstance]

@interface ViewMain : UIViewController

+ (instancetype) sharedInstance;
@end

