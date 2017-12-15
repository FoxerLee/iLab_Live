//
//  TCSubscribeModel.m
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCSubscribeModel.h"

@implementation TCSubscribeModel


- (TCSubscribeModel *)initWithLiveTitle: (NSString *)title upName:(NSString *)upName upId:(NSString *)upId
                               liveType:(NSString *)type liveCover:(NSString *)cover liveViews:(NSInteger)views {
    self = [super init];
    if (self) {
        self.upId = upId;
        self.liveTitle = title;
        self.upName = upName;
        self.liveType = type;
        self.liveCover = cover;
        self.liveViews = views;
    }
    return self;
}

+ (TCSubscribeModel *)initWithLiveTitle: (NSString *)title upName:(NSString *)upName upId:(NSString *)upId
                               liveType:(NSString *)type liveCover:(NSString *)cover liveViews:(NSInteger)views {
    TCSubscribeModel *model = [[TCSubscribeModel alloc] initWithLiveTitle:title upName:upName upId:upId
                                                                 liveType:type liveCover:cover liveViews:views];
    return model;
}


@end
