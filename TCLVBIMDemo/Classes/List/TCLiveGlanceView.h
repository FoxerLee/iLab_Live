//
//  TCLiveGlanceView.h
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/11/20.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLiveListModel.h"

@interface TCLiveGlanceView : UIView

@property (nonatomic, strong) UIImageView   *coverPic;         //用UIImageView替换
@property (nonatomic, strong) UIImageView   *headPic;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *titleLabel;

@end
