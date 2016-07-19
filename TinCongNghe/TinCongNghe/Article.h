//
//  Article.h
//  TinCongNghe
//
//  Created by Khai on 29/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic ,strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *mainUrl;
@property (nonatomic, strong) NSString *timePost;
@property (nonatomic, strong) UIImageView *imageview;

-(instancetype)initWithImageUrl:(NSString *)imageUrl andTitle:(NSString *)title andMainUrl:(NSString *)mainUrl andTimePost:(NSString *)timeSkip;

@end
