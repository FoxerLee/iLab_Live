//
//  TCLiveGiftModel.h
//  TCGiftPickerView
//
//  Created by Yichao Wu on 2017/11/24.
//  Copyright © 2017 Yichao Wu. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface TCLiveGiftModel : NSObject

@property (nonatomic, strong) NSString *giftName;
@property (nonatomic, strong) NSString *giftPic;
@property (nonatomic) NSInteger         goldCount;

- (TCLiveGiftModel *)initWithName: (NSString *)name andPic:(NSString *)giftPic andGoldCount:(NSInteger)count;

+ (TCLiveGiftModel *)initWithName: (NSString *)name andPic:(NSString *)giftPic andGoldCount:(NSInteger)count;

@end
