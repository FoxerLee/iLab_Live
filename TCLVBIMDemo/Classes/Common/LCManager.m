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

+ (NSInteger)getUserSubscribeCount:(NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"subscription"];

    [query whereKey:@"follower" equalTo:userId];

    NSArray *result = [query findObjects];

    return result.count;
}

+ (NSArray<NSString*>*)getUserSubscribeIds: (NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"subscription"];

    [query whereKey:@"follower" equalTo:userId];

    NSArray *result = [query findObjects];

    NSMutableArray *ids = [NSMutableArray array];
    for (AVObject *object in result) {
        [ids addObject:object[@"up"]];
    }

    return ids;
}

+ (NSInteger)getUserFansCount:(NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"subscription"];

    [query whereKey:@"up" equalTo:userId];

    NSArray *result = [query findObjects];

    return result.count;
}

+ (NSArray<NSString*>*)getUserFansIds: (NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"subscription"];

    [query whereKey:@"up" equalTo:userId];

    NSArray *result = [query findObjects];

    NSMutableArray *ids = [NSMutableArray array];
    for (AVObject *object in result) {
        [ids addObject:object[@"follower"]];
    }

    return ids;
}

+ (NSDictionary *)getUpInfo: (NSString *)upId {
    NSDictionary *upInfo;
    AVQuery *query = [AVQuery queryWithClassName:@"up_info"];

    [query whereKey:@"up_id" equalTo:upId];

    NSArray *result = [query findObjects];
    if (result.count == 0) {
        upInfo = nil;
    } else {
        AVObject *object = result[0];
        upInfo = @{
                @"room_cover": object[@"room_cover"],
                @"up_name": object[@"up_name"],
                @"up_photo": object[@"up_photo"],
                @"room_name": object[@"room_name"]
        };
    }
    return upInfo;
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

+ (BOOL)initUser:(NSString *)userId Balance: (NSInteger) number {
    AVObject *row = [AVObject objectWithClassName:@"user_balance"];

    [row setObject:userId forKey:@"id"];
    [row setObject:@(number) forKey:@"balance"];

    return [row save];
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

#pragma mark - 礼物赠送与信息拉取

+ (void)sendGiftWithNum:(NSString *)senderId to:(NSString *)receiverId gift1: (NSInteger)num1 gift2: (NSInteger) num2
                  gift3: (NSInteger) num3 gift4: (NSInteger) num4 gift5: (NSInteger) num5 gift6: (NSInteger)num6 {
    AVObject *row = [AVObject objectWithClassName:@"gift_relation"];

    [row setObject:senderId forKey:@"sender_id"];
    [row setObject:receiverId forKey:@"receiver_id"];
    [row setObject:@(num1) forKey:@"gift_1"];
    [row setObject:@(num2) forKey:@"gift_2"];
    [row setObject:@(num3) forKey:@"gift_3"];
    [row setObject:@(num4) forKey:@"gift_4"];
    [row setObject:@(num5) forKey:@"gift_5"];
    [row setObject:@(num6) forKey:@"gift_6"];

    [row save];
}

+ (NSArray *)getGiftMessageArray: (NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"gift_relation"];

    [query whereKey:@"receiver_id" equalTo:userId];

    NSArray *result = [query findObjects];

    NSMutableArray *giftMessageArray = [NSMutableArray array];
    for (AVObject *object in result) {
        NSString *giftName;
        NSInteger giftNum = 0;
        if ([object[@"gift_1"] intValue] > 0) {
            giftName = @"棒棒糖";
            giftNum = [object[@"gift_1"] intValue];
        } else if ([object[@"gift_2"] intValue] > 0) {
            giftName = @"生日蛋糕";
            giftNum = [object[@"gift_2"] intValue];
        } else if ([object[@"gift_3"] intValue] > 0) {
            giftName = @"钻戒";
            giftNum = [object[@"gift_3"] intValue];
        } else if ([object[@"gift_4"] intValue] > 0) {
            giftName = @"跑车";
            giftNum = [object[@"gift_4"] intValue];
        } else if ([object[@"gift_5"] intValue] > 0) {
            giftName = @"豪华游艇";
            giftNum = [object[@"gift_5"] intValue];
        } else if ([object[@"gift_6"] intValue] > 0) {
            giftName = @"火箭";
            giftNum = [object[@"gift_6"] intValue];
        }
        NSString *senderId = object[@"sender_id"];
        NSDate *date = object.updatedAt;
        NSDictionary *giftMessage = @{
                @"giftName": giftName,
                @"giftNumber": @(giftNum),
                @"senderId": senderId,
                @"dateTime": date
        };
        [giftMessageArray addObject:giftMessage];
    }
    return giftMessageArray;
}

+ (BOOL)deleteAllGiftMessage: (NSString *)userId {
    AVQuery *query = [AVQuery queryWithClassName:@"gift_relation"];

    [query whereKey:@"receiver_id" equalTo:userId];

    NSArray *result = [query findObjects];

    return [AVObject deleteAll:result];
}

@end
