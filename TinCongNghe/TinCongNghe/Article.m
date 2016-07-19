//
//  Article.m
//  TinCongNghe
//
//  Created by Khai on 29/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "Article.h"

@implementation Article

-(instancetype)initWithImageUrl:(NSString *)imageUrl andTitle:(NSString *)title andMainUrl:(NSString *)mainUrl andTimePost:(NSString *)timeSkip{
    if (self == [super init]) {
        self.imageUrl = imageUrl;
        self.title = title;
        self.mainUrl = mainUrl;
        self.timePost = timeSkip;
    }
    return self;
}

@end
