//
//  TCMessageCell.m
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/15.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCMessageCell.h"

@interface TCMessageCell()

@property (nonatomic, strong) UILabel *msgLabel;

@end


@implementation TCMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    UIImageView *sysImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"system_msg"]];
    sysImage.frame = CGRectMake(15, 10, 50, 50);
    [self addSubview:sysImage];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame  = CGRectMake(CGRectGetMaxX(sysImage.frame) + 10, sysImage.frame.origin.y, 100, 25);
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = @"系统消息";
    [self addSubview:titleLabel];

    _msgLabel = [[UILabel alloc] init];
    _msgLabel.frame = CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame), 200, 30);
    _msgLabel.font = [UIFont systemFontOfSize:14];
    _msgLabel.textColor = [UIColor darkGrayColor];
    _msgLabel.text = @"fafafa送了你20个火箭";
    [self addSubview:_msgLabel];

}

- (void)setMessage:(NSString *)message {
    _msgLabel.text = message;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
