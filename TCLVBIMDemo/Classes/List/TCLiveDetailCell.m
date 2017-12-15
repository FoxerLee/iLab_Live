//
//  TCLiveDetailCell.m
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCLiveDetailCell.h"
#import "UIImageView+WebCache.h"

@interface TCLiveDetailCell()

@property (nonatomic, strong) UIImageView *frontCover;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *hostNameLabel;

@property (nonatomic, strong) UILabel *viewNumLabel;

@end

@implementation TCLiveDetailCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    float width = [UIScreen mainScreen].bounds.size.width;
    float picWidth = (width - 30)/2;
    float fontSize = 12;
    _frontCover = [[UIImageView alloc] init];
    _frontCover.frame = CGRectMake(20, 20, picWidth, picWidth * 9/16);
    _frontCover.layer.cornerRadius = 5;
    _frontCover.layer.masksToBounds = YES;
    [_frontCover setImage:[UIImage imageNamed:@"bg.jpg"]];
    [self addSubview:_frontCover];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"直播标题";
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_frontCover.frame) + 10, 20, picWidth-20, 20);
    _titleLabel.font = [UIFont systemFontOfSize:15];
//    _titleLabel.backgroundColor = [UIColor redColor];
    [self addSubview:_titleLabel];

    UILabel *hostTipLabel = [[UILabel alloc] init];
    hostTipLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + 25, 40, 15);
    hostTipLabel.text = @"主播:";
    hostTipLabel.textColor = UIColorFromRGB(0x666666);
//    hostTipLabel.backgroundColor = [UIColor redColor];
    hostTipLabel.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:hostTipLabel];

    _hostNameLabel = [[UILabel alloc] init];
    _hostNameLabel.frame = CGRectMake(CGRectGetMaxX(hostTipLabel.frame), hostTipLabel.frame.origin.y
            , _titleLabel.frame.size.width-hostTipLabel.frame.size.width, 15);
    _hostNameLabel.text = @"主播名";
    _hostNameLabel.textColor = UIColorFromRGB(0x666666);
    _hostNameLabel.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:_hostNameLabel];

    UILabel *viewTipLabel = [[UILabel alloc] init];
    viewTipLabel.frame = CGRectMake(_titleLabel.frame.origin.x, hostTipLabel.frame.origin.y + 20, 40, 15);
    viewTipLabel.text = @"观看:";
    viewTipLabel.textColor = UIColorFromRGB(0x666666);
//    viewTipLabel.backgroundColor = [UIColor redColor];
    viewTipLabel.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:viewTipLabel];

    _viewNumLabel = [[UILabel alloc] init];
    _viewNumLabel.frame = CGRectMake(CGRectGetMaxX(viewTipLabel.frame), viewTipLabel.frame.origin.y
            , _titleLabel.frame.size.width-viewTipLabel.frame.size.width, 15);
    _viewNumLabel.text = @"0";
    _viewNumLabel.textColor = UIColorFromRGB(0x666666);
    _viewNumLabel.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:_viewNumLabel];

    UILabel *typeTipLabel = [[UILabel alloc] init];
    typeTipLabel.frame = CGRectMake(_titleLabel.frame.origin.x, viewTipLabel.frame.origin.y + 20, 40, 15);
    typeTipLabel.text = @"分类:";
    typeTipLabel.textColor = UIColorFromRGB(0x666666);
    typeTipLabel.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:typeTipLabel];

    _typeLabel = [[UILabel alloc] init];
    _typeLabel.frame = CGRectMake(CGRectGetMaxX(typeTipLabel.frame), typeTipLabel.frame.origin.y
            , _titleLabel.frame.size.width - typeTipLabel.frame.size.width, 15);
    _typeLabel.text = @"分类";
    _typeLabel.textColor = UIColorFromRGB(0x666666);
    _typeLabel.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:_typeLabel];


    self.height = CGRectGetMaxY(_frontCover.frame) + 20;
}

- (void)setModel:(TCLiveInfo *)model {
    if (_model != model) {
        _model = model;
    }
    [_frontCover sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:model.userinfo.frontcover]]
                   placeholderImage:[UIImage imageNamed:@"bg.jpg"]];
    _titleLabel.text = model.title;
    _hostNameLabel.text = model.userinfo.nickname;
    _viewNumLabel.text = [NSString stringWithFormat:@"%d",  model.viewercount];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
