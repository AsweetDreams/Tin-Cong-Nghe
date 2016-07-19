//
//  LinesOfInfor.m
//  TinCongNghe
//
//  Created by Khai on 10/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "LinesOfInfor.h"

@implementation LinesOfInfor

-(instancetype)initWithText:(NSMutableAttributedString *)textOfCell andArrLink:(NSArray *)arrLink andArrLocaLink:(NSArray *)locaLink{
    if (self = [super init]) {
        self.textOfCell = textOfCell;
        self.arrLink = arrLink;
        self.locaGetLink = locaLink;
    }
    return self;
}

@end
