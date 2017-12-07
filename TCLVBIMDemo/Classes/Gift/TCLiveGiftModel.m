//
//  TCLiveGiftModel.m
//  TCGiftPickerView
//
//  Created by Yichao Wu on 2017/11/24.
//  Copyright © 2017 Yichao Wu. All rights reserved.
//

#import "TCLiveGiftModel.h"

@implementation TCLiveGiftModel

- (TCLiveGiftModel *)initWithName:(NSString *)name andPic:(NSString *)giftPic andGoldCount:(NSInteger)count {
    self = [super init];
    if (self) {
        self.giftName = name;
        self.giftPic = giftPic;
        self.goldCount = count;
    }
    return self;
}

+ (TCLiveGiftModel *)initWithName:(NSString *)name andPic:(NSString *)giftPic andGoldCount:(NSInteger)count {
    return [[TCLiveGiftModel alloc] initWithName:name andPic:giftPic andGoldCount:count];
}

@end
