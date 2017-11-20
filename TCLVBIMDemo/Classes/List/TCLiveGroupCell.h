//
// Created by Yichao Wu on 2017/11/18.
// Copyright (c) 2017 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLiveGlanceView.h"

@class TCLiveGroupInfo;

@protocol TCLiveGroupCellDelegate <NSObject>

- (void)onTapLiveView: (TCLiveInfo *)liveInfo;

@end

/**
 * 首页直播列表组Cell类
 */
@interface TCLiveGroupCell : UITableViewCell

@property (nonatomic, strong) TCLiveGroupInfo *group;

@property (assign, atomic) CGFloat height;

@property (weak, nonatomic) id delegate;

@end