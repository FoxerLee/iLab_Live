//
//  TCSubscribeModel.m
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCSubscribeModel.h"

@implementation TCSubscribeModel


-(id) initWithDict:(NSDictionary *)dict{
    if (self == [super init]) {
        self.subHeadImageUrl = dict[@"imgUrl"];
        self.subTitle = dict[@"title"];
        self.subName = dict[@"name"];
        self.subTimes = [dict[@"times"] integerValue];
        self.subClass = dict[@"class"];
    }
    return self;
}

+(id) subWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}


@end
