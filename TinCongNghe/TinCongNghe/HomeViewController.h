//
//  HomeViewController.h
//  TinCongNghe
//
//  Created by Khai on 24/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *clvContent;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *page;

@end
