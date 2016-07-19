//
//  LinesOfInfor.h
//  TinCongNghe
//
//  Created by Khai on 10/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinesOfInfor : NSObject

@property (nonatomic, strong) NSMutableAttributedString *textOfCell;
@property (nonatomic, strong) NSArray *arrLink;
@property (nonatomic, strong) NSArray *locaGetLink;
-(instancetype)initWithText:(NSMutableAttributedString *)textOfCell andArrLink:(NSArray *)arrLink andArrLocaLink:(NSArray *)locaLink;
@end
