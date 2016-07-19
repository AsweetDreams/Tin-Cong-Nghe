//
//  ReadingViewController.h
//  TinCongNghe
//
//  Created by Khai on 01/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@interface ReadingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UITableView *tbvMainContent;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *imagehead;
@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
-(void)loadBeforeWithArr:(NSMutableArray *)listArticle andOfNumber:(NSInteger )Number;
@end
