//
//  TCSubscribeModel.h
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSubscribeModel : NSObject

@property (nonatomic, strong) NSString *upId;          //主播id
@property(nonatomic,retain)NSString *liveTitle;        //订阅直播名
@property(nonatomic,retain)NSString *upName;           //订阅主播名
@property(nonatomic,retain)NSString *liveType;         //订阅分类
@property(nonatomic,retain)NSString *liveCover;        //封面url
@property(nonatomic,assign)NSInteger liveViews;        //观看人次

- (TCSubscribeModel *)initWithLiveTitle: (NSString *)title upName:(NSString *)upName upId:(NSString *)upId
                               liveType:(NSString *)type liveCover:(NSString *)cover liveViews:(NSInteger)views;
+ (TCSubscribeModel *)initWithLiveTitle: (NSString *)title upName:(NSString *)upName upId:(NSString *)upId
                               liveType:(NSString *)type liveCover:(NSString *)cover liveViews:(NSInteger)views;

@end
