//
//  TCSubscribeModel.h
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSubscribeModel : NSObject

@property(nonatomic,retain)NSString *subTitle;        //订阅名
@property(nonatomic,retain)NSString *subName;         //订阅主播名
@property(nonatomic,retain)NSString *subClass;        //订阅分类
@property(nonatomic,retain)NSString *subHeadImageUrl; //订阅头像url
@property(nonatomic,assign)NSInteger subTimes;        //观看人次

-(id) initWithDict:(NSDictionary *)dict;
+(id) subWithDict:(NSDictionary *)dict;

@end
