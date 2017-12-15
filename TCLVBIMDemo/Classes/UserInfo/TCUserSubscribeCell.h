//
//  TCUserSubscribeCell.h
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/15.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIMUserProfile;

@protocol TCUserSubscribeCellDelegate <NSObject>

- (void)onClickCancelSubscribe: (NSString *)upId;
@end

typedef NS_ENUM(NSInteger, TCUserSubscribeCellType) {
    TCUserSubscribeCellTypeDefault,
    TCUserSubscribeCellTypeFans
};

@interface TCUserSubscribeCell : UITableViewCell

@property (nonatomic, strong)TIMUserProfile *model;

@property (assign)CGFloat height;

@property (nonatomic, assign)TCUserSubscribeCellType cellType;

@property (nonatomic, weak) id<TCUserSubscribeCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier andType:(TCUserSubscribeCellType)type;

@end
