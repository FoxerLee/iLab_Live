//
// Created by Yichao Wu on 2017/11/18.
// Copyright (c) 2017 tencent. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "TCLiveGroupCell.h"


@interface TCLiveGroupCell() {
    UILabel                   *_groupTitleLabel;           //组别名称显示
    UIImageView               *_enterImg;                  //右上角小箭头
    UIButton                  *_enterBtn;                  //整个上部空白区的隐藏button
    TCLiveGlanceView          *_liveViewLeft;              //两个直播显示view
    TCLiveGlanceView          *_liveViewRight;
    TCLiveGroupInfo           *_tmpGroup;
}

@end

@implementation TCLiveGroupCell {

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _enterBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self addSubview:_enterBtn];

    _groupTitleLabel = [[UILabel alloc] init];
    _groupTitleLabel.textColor = [UIColor blackColor];
    _groupTitleLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:_groupTitleLabel];

    _enterImg = [[UIImageView alloc] init];
    [_enterImg setImage:[UIImage imageNamed:@"main_enter_img"]];
    [self addSubview:_enterImg];

    _liveViewLeft = [[TCLiveGlanceView alloc] init];
    [self addSubview:_liveViewLeft];
    _liveViewRight = [[TCLiveGlanceView alloc] init];
    [self addSubview:_liveViewRight];

}

- (void)setGroup:(TCLiveGroupInfo *)group {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageWidth = (screenWidth - 3*10)/2;

    _groupTitleLabel.frame = CGRectMake(10, 10, 200, 20);
    _groupTitleLabel.text = group.groupName;

    if (group.liveList.count >1) {

        TCLiveInfo *live1 = group.liveList[0];
        _liveViewLeft.frame = CGRectMake(10, CGRectGetMaxY(_groupTitleLabel.frame) + 10, imageWidth, imageWidth * 9/16 + 50);
        _liveViewLeft.nameLabel.text = live1.userinfo.nickname;
        _liveViewLeft.titleLabel.text = live1.title;
        [_liveViewLeft.coverPic sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:live1.userinfo.frontcover]]
                     placeholderImage:[UIImage imageNamed:@"bg.jpg"]];
        [_liveViewLeft.headPic sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:live1.userinfo.headpic]]
                                 placeholderImage:[UIImage imageNamed:@"face"]];
        TCLiveInfo *live2 = group.liveList[1];
        _liveViewRight.frame = CGRectMake(20+imageWidth, CGRectGetMaxY(_groupTitleLabel.frame) + 10, imageWidth, imageWidth * 9/16 + 50);
        _liveViewRight.nameLabel.text = live2.userinfo.nickname;
        _liveViewRight.titleLabel.text = live2.title;
        [_liveViewRight.coverPic sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:live2.userinfo.frontcover]]
                                  placeholderImage:[UIImage imageNamed:@"bg.jpg"]];
        [_liveViewRight.headPic sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:live2.userinfo.headpic]]
                                 placeholderImage:[UIImage imageNamed:@"face"]];
        [self addSubview:_liveViewRight];
    } else {
        TCLiveInfo *live1 = group.liveList[0];
        _liveViewLeft.frame = CGRectMake(10, CGRectGetMaxY(_groupTitleLabel.frame) + 10, imageWidth, imageWidth * 9/16 + 50);
        _liveViewLeft.nameLabel.text = live1.userinfo.nickname;
        _liveViewLeft.titleLabel.text = live1.title;
        [_liveViewLeft.coverPic sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:live1.userinfo.frontcover]]
                                  placeholderImage:[UIImage imageNamed:@"bg.jpg"]];
        [_liveViewLeft.headPic sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:live1.userinfo.headpic]]
                                 placeholderImage:[UIImage imageNamed:@"face"]];

        [_liveViewRight removeFromSuperview];
    }

//    _enterBtn.frame = CGRectMake(screenWidth - 10 - 50, 10, 50, 20);
    _enterBtn.frame = CGRectMake(10, 10, screenWidth-20, 20);

    _enterImg.frame = CGRectMake(screenWidth - 10 - 20, 10, 20, 20);

    _height = CGRectGetMaxY(_liveViewLeft.frame) + 5;

    _tmpGroup = group;

    [self addTapGestures];
}

- (void)addTapGestures {
    _liveViewLeft.tag = 0;
    _liveViewRight.tag = 1;
    UITapGestureRecognizer *tapLeft = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveViewTap:)];
    tapLeft.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapRight = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveViewTap:)];
    tapRight.numberOfTapsRequired = 1;
    _liveViewLeft.userInteractionEnabled = YES;
    _liveViewRight.userInteractionEnabled = YES;
    [_liveViewLeft addGestureRecognizer:tapLeft];
    [_liveViewRight addGestureRecognizer:tapRight];
}

- (void)liveViewTap: (UITapGestureRecognizer *)tap {
    switch (tap.view.tag) {
        case 0 : {
            if ([self.delegate respondsToSelector:@selector(onTapLiveView:)]) {
                [self.delegate onTapLiveView:_tmpGroup.liveList[0]];
            }
        }
        break;
        case 1: {
            if ([self.delegate respondsToSelector:@selector(onTapLiveView:)]) {
                [self.delegate onTapLiveView:_tmpGroup.liveList[1]];
            }
        }
        break;
        default: {
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


@end
