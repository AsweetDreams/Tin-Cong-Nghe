//
//  MenuViewController.h
//  TinCongNghe
//
//  Created by Khai on 01/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuTbv;

@end
