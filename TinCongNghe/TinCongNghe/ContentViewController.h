//
//  InformViewController.h
//  TinCongNghe
//
//  Created by Khai on 23/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *clvContent;
@property (nonatomic,assign) NSString *url;
@property (nonatomic,assign) NSString *page;
@end
