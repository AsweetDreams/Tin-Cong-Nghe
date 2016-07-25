//
//  UIImageView+BlurView.m
//  TinCongNghe
//
//  Created by Khai on 25/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "UIImageView+BlurView.h"

@implementation UIImageView(BlurView)

+(void)makeBlurEffectWithImageView:(UIImageView *)imageview{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y, imageview.frame.size.width, imageview.frame.size.height);
    [imageview addSubview:blurEffectView];
}

@end
