//
//  LCManager.m
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/9.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "LCManager.h"
#import <AVOSCloud/AVOSCloud.h>



@implementation LCManager


#pragma mark - About follower

+ (BOOL)ifUser:(NSString*)followerId followUp:(NSString *)upId {
    AVQuery *query = [AVQuery queryWithClassName:@"subscription"];
    
    [query whereKey:@"follower" equalTo:followerId];
    [query whereKey:@"up" equalTo:upId];
    
    NSArray *result = [query findObjects];
    return result.count == 1;
}

+ (BOOL)addUser:(NSString *)followerId followUp:(NSString *)upId {
    AVObject *row = [AVObject objectWithClassName:@"subscription"];
    
    [row setObject:followerId forKey:@"follower"];
    [row setObject:upId forKey:@"up"];
    
    return [row save];
}

+ (BOOL)cancelUser:(NSString *)followerId followUp:(NSString *)upId {
    AVQuery *query = [AVQuery queryWithClassName:@"subscription"];
    
    [query whereKey:@"follower" equalTo:followerId];
    [query whereKey:@"up" equalTo:upId];
    
    NSArray *result = [query findObjects];
    
    if (result.count == 1) {
        AVObject *row = result[0];
        return [row delete];
    } else {
        return NO;
    }
}


#pragma mark - About user balance

+ (NSInteger)getUserBalanceById:(NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"user_balance"];
    
    [query whereKey:@"id" equalTo:userId];
    
    NSArray *result = [query findObjects];
    
    if (result.count == 1) {
        AVObject *row = result[0];
        return [row[@"balance"] intValue];
    } else {
        return -1;
    }
}

+ (void)decreaseUser:(NSString *)userId Balance:(NSInteger)number result:(AVBooleanResultBlock)resultBlock {
    [self modifyUser:userId Plus:NO Balance:number result:^(BOOL succeeded, NSError *error) {
        resultBlock(succeeded, error);
    }];
}

+ (void)increaseUser:(NSString *)userId Balance:(NSInteger)number result:(AVBooleanResultBlock)resultBlock {
    [self modifyUser:userId Plus:YES Balance:number result:^(BOOL succeeded, NSError *error) {
        resultBlock(succeeded, error);
    }];
}

+ (void)modifyUser:(NSString *)userId Plus:(BOOL)ifPlus Balance: (NSInteger)number result:(AVBooleanResultBlock)resultBlock {
    AVQuery *queryUser = [AVQuery queryWithClassName:@"user_balance"];
    [queryUser whereKey:@"id" equalTo:userId];
    
    AVObject *user = [queryUser getFirstObject];
    NSInteger amount = ifPlus ? number : -number;
    
    [user incrementKey:@"balance" byAmount:@(amount)];
    
    AVQuery *query = [[AVQuery alloc] init];
    [query whereKey:@"balance" greaterThanOrEqualTo:@(-amount)];
    
    AVSaveOption *option = [[AVSaveOption alloc] init];
    option.query = query;
    option.fetchWhenSave = YES;
    
    [user saveInBackgroundWithOption:option block:^(BOOL succeeded, NSError * _Nullable error) {
        resultBlock(succeeded, error);
    }];
}

#pragma mark - 主播信息相关

+ (BOOL)ifUpTableContainsUser: (NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"up_info"];

    [query whereKey:@"up_id" equalTo:userId];

    NSArray *result = [query findObjects];

    return result.count == 1;
}

+ (BOOL)addUp: (NSString *)userId withRoomCover:(NSString *)coverUrl
     nickname:(NSString *)nickname userPhoto:(NSString*)photoUrl roomName:(NSString*)roomName{
    AVObject *row = [AVObject objectWithClassName:@"up_info"];

    [row setObject:userId forKey:@"up_id"];
    [row setObject:coverUrl forKey:@"room_cover"];
    [row setObject:nickname forKey:@"up_name"];
    [row setObject:photoUrl forKey:@"up_photo"];
    [row setObject:roomName forKey:@"room_name"];

    return [row save];
}

+ (BOOL)deleteUp: (NSString *)upId {
    AVQuery *query = [AVQuery queryWithClassName:@"up_info"];

    [query whereKey:@"up_id" equalTo:upId];

    NSArray *result = [query findObjects];

    if (result.count == 1) {
        AVObject *row = result[0];
        return [row delete];
    } else {
        return NO;
    }
}


@end
