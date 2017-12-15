//
//  TCUserSubscribeCell.m
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/15.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <ImSDK/ImSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TCUserSubscribeCell.h"

@interface TCUserSubscribeCell() {
    UIImageView *_headPic;
    UILabel *_nicknameLabel;
    UIButton *_subscribeBtn;
}

@end

@implementation TCUserSubscribeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier andType:(TCUserSubscribeCellType)type {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        switch (type) {
            case TCUserSubscribeCellTypeDefault:
                [self initUI];
            case TCUserSubscribeCellTypeFans:
                [self initUI];
                _subscribeBtn.hidden = YES;
        }

    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    _headPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_user"]];
    _headPic.frame = CGRectMake(10, 10, 40, 40);
    _headPic.layer.masksToBounds = YES;
    _headPic.layer.cornerRadius = _headPic.frame.size.height / 2;
    [self addSubview:_headPic];

    _nicknameLabel = [[UILabel alloc] init];
    _nicknameLabel.frame = CGRectMake(60, 20, 200, 20);
//    _nicknameLabel.backgroundColor = RGB(160, 210, 240);
    _nicknameLabel.text = @"default";
    _nicknameLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:_nicknameLabel];

    _subscribeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _subscribeBtn.center = CGPointMake(screenWidth - 45, _headPic.center.y);
    _subscribeBtn.bounds = CGRectMake(0, 0, 60, 20);
    [_subscribeBtn setTitle:@"已订阅" forState:UIControlStateNormal];
    _subscribeBtn.backgroundColor = RGB(160, 210, 240);
    [_subscribeBtn setTintColor:[UIColor whiteColor]];
    _subscribeBtn.layer.cornerRadius = 10;
    [_subscribeBtn addTarget:self action:@selector(onClickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_subscribeBtn];

    _height = CGRectGetMaxY(_nicknameLabel.frame) + 10;
}

- (void)onClickCancelBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(onClickCancelSubscribe:)]) {
        [self.delegate onClickCancelSubscribe:self.model.identifier];
    }
}

- (void)setModel:(TIMUserProfile *)model {
    _model = [[TIMUserProfile alloc] init];
    _model.nickname = model.nickname;
    _model.identifier = model.identifier;
    _model.faceURL = model.faceURL;
    if ([model.nickname isEqualToString:@""]) {
        _nicknameLabel.text = model.identifier;
    } else {
        _nicknameLabel.text = model.nickname;
    }

    [_headPic sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:model.faceURL]] placeholderImage:[UIImage imageNamed:@"default_user"]];
}

- (void)setCellType:(TCUserSubscribeCellType)cellType {
    if (cellType == TCUserSubscribeCellTypeFans) {
        _subscribeBtn.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

