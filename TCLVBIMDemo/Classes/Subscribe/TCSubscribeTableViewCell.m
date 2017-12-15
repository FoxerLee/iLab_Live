//
//  TCSubscribeTableViewCell.m
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCSubscribeTableViewCell.h"
#import "TCSubscribeModel.h"
#import "UIImageView+WebCache.h"


@implementation TCSubscribeTableViewCell{
    UIImageView*    _liveCoverView;
    UILabel*        _titleLabel;
    UILabel*        _upNameLabel;
    UILabel*        _liveViewsLabel;
    UILabel*        _liveTypeLabel;
    
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initUI];
    }
    
    return self;
    
}

- (void)initUI {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat padding = 15;
    CGFloat titleFontSize = 16;
    CGFloat contentFontSize = 13;
    // 直播封面
    _liveCoverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.jpg"]];
    _liveCoverView.frame = CGRectMake(padding, padding, (screenWidth-padding*2)/2, (screenWidth-padding*2)/2 * 9/16);
    _liveCoverView.layer.cornerRadius = 3;
//    _liveCoverView.contentMode = UIViewContentModeScaleAspectFit;
    _liveCoverView.layer.masksToBounds = YES;
    [self addSubview:_liveCoverView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_liveCoverView.frame) + 5, _liveCoverView.frame.origin.y, (screenWidth -padding*2)/2-5 , 30);
//    _titleLabel.backgroundColor = [UIColor grayColor];
    _titleLabel.font = [UIFont systemFontOfSize:titleFontSize];
    _titleLabel.text = @"测试";
    [self addSubview:_titleLabel];

    CGFloat tipWidth = 40;
    CGFloat tipHeight = 20;

    // 主播名
    UILabel *liveTipLabel = [[UILabel alloc] init];
    liveTipLabel.frame = CGRectMake(_titleLabel.frame.origin.x, CGRectGetMaxY(_titleLabel.frame) + 5, tipWidth, tipHeight);
    liveTipLabel.textColor = [UIColor grayColor];
    liveTipLabel.font = [UIFont systemFontOfSize:contentFontSize];
    liveTipLabel.text = @"主播:";
    [self addSubview:liveTipLabel];

    CGFloat contentWidth = (screenWidth - padding*2)/2 - 5 - tipWidth;

    _upNameLabel = [[UILabel alloc] init];
    _upNameLabel.frame = CGRectMake(CGRectGetMaxX(liveTipLabel.frame), liveTipLabel.frame.origin.y, contentWidth, tipHeight);
    _upNameLabel.font = [UIFont systemFontOfSize:contentFontSize];
    _upNameLabel.textColor = [UIColor grayColor];
    _upNameLabel.text = @"iLab";
    [self addSubview:_upNameLabel];

    // 直播类别
    UILabel *liveTypeTip = [[UILabel alloc] init];
    liveTypeTip.frame = CGRectMake(_titleLabel.frame.origin.x, CGRectGetMaxY(liveTipLabel.frame) + 5, tipWidth, tipHeight);
    liveTypeTip.textColor = [UIColor grayColor];
    liveTypeTip.font = [UIFont systemFontOfSize:contentFontSize];
    liveTypeTip.text = @"分类:";
    [self addSubview:liveTypeTip];

    _liveTypeLabel = [[UILabel alloc] init];
    _liveTypeLabel.frame = CGRectMake(CGRectGetMaxX(liveTypeTip.frame), liveTypeTip.frame.origin.y, contentWidth, tipHeight);
    _liveTypeLabel.font = [UIFont systemFontOfSize:contentFontSize];
    _liveTypeLabel.textColor = [UIColor grayColor];
    _liveTypeLabel.text = @"游戏";
    [self addSubview:_liveTypeLabel];

}

- (void)setModel:(TCSubscribeModel *)model {
    [_liveCoverView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:model.liveCover]]
                      placeholderImage:[UIImage imageNamed:@"bg.jpg"]];
    _titleLabel.text = model.liveTitle;
    _upNameLabel.text = model.upName;
    _liveTypeLabel.text = model.liveType;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
