//
//  TCLiveGlanceView.m
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/11/20.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCLiveGlanceView.h"

@implementation TCLiveGlanceView

/**
 * 初始化TCLiveGlanceView
 * @param frame height = width*0.5 + 50
 * @return
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _coverPic = [[UIImageView alloc] init];
    [_coverPic setImage:[UIImage imageNamed:@"bg_nolive@2x.png"]];
    _coverPic.layer.masksToBounds = YES;
    [self addSubview:_coverPic];

//    _headPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_user"]];
    _headPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_user.jpeg"]];
    _headPic.layer.masksToBounds = YES;
    _headPic.layer.borderWidth = 1;
    _headPic.layer.borderColor = [UIColor whiteColor].CGColor;  //头像外圈颜色
    [self addSubview:_headPic];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"主播名";
    [_nameLabel setFont:[UIFont systemFontOfSize:13]];
    _nameLabel.textColor = [UIColor grayColor];
    [self addSubview:_nameLabel];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"直播标题";
    [_titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self addSubview:_titleLabel];

    // 将头像移到最上层
    [self bringSubviewToFront:_headPic];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    _coverPic.frame = CGRectMake(0, 0, width, width * 9/16);
    _coverPic.layer.cornerRadius = 5;

    CGFloat headPicWidth = 40;
    _headPic.frame = CGRectMake(5, width*9/16 - headPicWidth/2, headPicWidth, headPicWidth);
    _headPic.layer.cornerRadius = _headPic.frame.size.width*0.5f;

    CGFloat nameLabelMarginX = CGRectGetMaxX(_headPic.frame) + 5;
    CGFloat nameLabelHeight = headPicWidth / 2;
    _nameLabel.frame = CGRectMake(nameLabelMarginX, CGRectGetMaxY(_coverPic.frame), width-nameLabelMarginX-5, nameLabelHeight);

    _titleLabel.frame = CGRectMake(5, CGRectGetMaxY(_headPic.frame), width-10, height- CGRectGetMaxY(_headPic.frame));
}


@end
