//
//  NewViewController.h
//  TinCongNghe
//
//  Created by Khai on 30/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tbvNew;
@property (nonatomic, strong) NSString *url;

@end
