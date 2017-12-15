//
//  LCManager.h
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/9.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVConstants.h"

@interface LCManager : NSObject

// 查询一个用户是否订阅了主播
+ (BOOL)ifUser:(NSString*)followerId followUp:(NSString *)upId;
// 用户新关注主播
+ (BOOL)addUser:(NSString *)followerId followUp:(NSString *)upId;
// 用户取消关注主播
+ (BOOL)cancelUser:(NSString *)followerId followUp:(NSString *)upId;
// 获取用户的订阅数量
+ (NSInteger)getUserSubscribeCount:(NSString *)userId;
// 获取用户订阅的所有主播id
+ (NSArray<NSString*>*)getUserSubscribeIds: (NSString *)userId;
// 获取用户粉丝的数量
+ (NSInteger)getUserFansCount:(NSString *)userId;
// 获取用户所有粉丝的id
+ (NSArray<NSString*>*)getUserFansIds: (NSString *)userId;

// 获取一个用户的总资产，若用户不存在则返回-1
+ (NSInteger)getUserBalanceById:(NSString *)userId;
// 初始化一个用户的总资产
+ (BOOL)initUser:(NSString *)userId Balance: (NSInteger) number;
// 减少一个用户的总资产
+ (void)decreaseUser:(NSString *)userId Balance:(NSInteger)number result:(AVBooleanResultBlock)resultBlock;
// 增加一个用户的总资产
+ (void)increaseUser:(NSString *)userId Balance:(NSInteger)number result:(AVBooleanResultBlock)resultBlock;

// 用户是否在LeanCloud主播表里
+ (BOOL)ifUpTableContainsUser: (NSString *)userId;
// 添加主播信息
+ (BOOL)addUp: (NSString *)userId withRoomCover:(NSString *)coverUrl
     nickname:(NSString *)nickname userPhoto:(NSString*)photoUrl roomName:(NSString*)roomName;
// 删除主播
+ (BOOL)deleteUp: (NSString *)upId;

// 礼物赠送
+ (void)sendGiftWithNum:(NSString *)senderId to:(NSString *)receiverId gift1: (NSInteger)num1 gift2: (NSInteger) num2
                  gift3: (NSInteger) num3 gift4: (NSInteger) num4 gift5: (NSInteger) num5 gift6: (NSInteger)num6;
// 礼物信息拉取
// 返回格式为 giftName: xxxx,  giftNumber: xxxx, senderId: xxxx 的JSON数组
+ (NSArray *)getGiftMessageArray: (NSString *)userId;
// 删除所有礼物消息
+ (BOOL)deleteAllGiftMessage: (NSString *)userId;

@end
