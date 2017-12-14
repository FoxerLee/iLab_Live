//
//  TCLiveGiftGlanceView.m
//  TCGiftPickerView
//
//  Created by Yichao Wu on 2017/11/24.
//  Copyright © 2017 Yichao Wu. All rights reserved.
//

#import "TCLiveGiftGlanceView.h"

@implementation TCLiveGiftGlanceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (frame.size.height >= frame.size.width * 4/5) {
            [self initUI];
        }
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.1f];

    _giftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gift_racket"]];
    _giftImg.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_giftImg];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.text = @"火箭";
    [self addSubview:_nameLabel];

    _goldCountLabel = [[UILabel alloc] init];
    _goldCountLabel.textAlignment = NSTextAlignmentRight;
    _goldCountLabel.font = [UIFont systemFontOfSize:12];
    _goldCountLabel.textColor = [UIColor whiteColor];
    _goldCountLabel.text = @"66666";
    [self addSubview:_goldCountLabel];

    _goldImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gift_gold_img"]];
    _goldImg.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_goldImg];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    float width = self.bounds.size.width;
//    float height = self.bounds.size.height;
    float margin = 5;
    float goldPicWidth = 10;

    float giftPicWidth = width / 2;
    _giftImg.center = CGPointMake(width/2, margin + giftPicWidth/2);
    _giftImg.bounds = CGRectMake(0, 0, width - 20, giftPicWidth - 5);

    CGSize labelSize = [self labelAutoCalculateRectWith:_goldCountLabel.text FontSize:12 MaxSize:CGSizeMake(100, 15)];

    float totalWidth = labelSize.width + 4 + goldPicWidth;

//    NSLog(@"%f ", totalWidth);

    _goldCountLabel.frame = CGRectMake(width/2 - totalWidth/2, CGRectGetMaxY(_giftImg.frame) + margin, labelSize.width, 10);


    _goldImg.frame = CGRectMake(CGRectGetMaxX(_goldCountLabel.frame)+4, _goldCountLabel.frame.origin.y, goldPicWidth, goldPicWidth);

    _nameLabel.center = CGPointMake(width/2, CGRectGetMaxY(_goldImg.frame) + margin + 5);
    _nameLabel.bounds = CGRectMake(0, 0, 100, 10);


}

- (void)setModel:(TCLiveGiftModel *)model {
    [_giftImg setImage:[UIImage imageNamed:model.giftPic]];
    _goldCountLabel.text = [NSString stringWithFormat:@"%d", model.goldCount];
    _nameLabel.text = model.giftName;
    [self layoutSubviews];
}

- (CGSize)labelAutoCalculateRectWith:(NSString *)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};

    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;

    return labelSize;
}

@end

