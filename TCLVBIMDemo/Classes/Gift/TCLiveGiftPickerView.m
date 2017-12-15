//
//  TCLiveGiftPickerView.m
//  TCGiftPickerView
//
//  Created by Yichao Wu on 2017/11/25.
//  Copyright © 2017 Yichao Wu. All rights reserved.
//

#import "TCLiveGiftPickerView.h"
#import "TCLiveGiftGlanceView.h"

@interface TCLiveGiftPickerView() {
    UIPageControl *_pageControl;
    CGFloat _bottomHeight;
    CGFloat _fontSize;
    UILabel *_goldCountLabel;
    UIImageView *_bottomDiamond;
    UILabel *_remainLabel;
    NSMutableArray *_giftViewList;
}

@end

//float pickerViewBottomHeight = 50;
//_pickerViewHeight = width/3 * 4/5 * 2 + pickerViewBottomHeight;

@implementation TCLiveGiftPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _pickedIndex = 0;
    _giftViewList = [NSMutableArray array];
    _giftModelList = [NSMutableArray array];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    _bottomHeight = self.frame.size.height - screenWidth/3 * 4/5 * 2;

    self.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.1];

    if ( self.frame.size.width == screenWidth) {

        // 礼物View初始化
        _giftScrollView = [[UIScrollView alloc] init];
        _giftScrollView.frame = CGRectMake(0, 0, screenWidth, screenWidth/3 * 4/5 * 2);
        _giftScrollView.pagingEnabled = YES;
        _giftScrollView.scrollEnabled = YES;
        _giftScrollView.bounces = NO;
        _giftScrollView.showsHorizontalScrollIndicator = NO;
        _giftScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_giftScrollView];


        // 底部View初始化
        _fontSize = 16;
        UIView *pickerViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-_bottomHeight, screenWidth, _bottomHeight)];
        _bottomView = pickerViewBottom;
        pickerViewBottom.backgroundColor = RGBA(100, 175, 165, 0.8);
        [self addSubview:pickerViewBottom];

        _remainLabel = [[UILabel alloc] init];
        _remainLabel.text = @"余额";
        _remainLabel.font = [UIFont systemFontOfSize:_fontSize];
        _remainLabel.textColor = [UIColor whiteColor];
        CGSize remainLabelSize = [self labelAutoCalculateRectWith:@"余额" FontSize:_fontSize MaxSize:CGSizeMake(60, 30)];
        _remainLabel.frame = CGRectMake(20, 10, remainLabelSize.width, 30);
        [pickerViewBottom addSubview:_remainLabel];

        _goldCountLabel = [[UILabel alloc] init];
        _goldCountLabel.text = @"600000";
        _goldCountLabel.font = [UIFont systemFontOfSize:_fontSize];
        _goldCountLabel.textColor = [UIColor whiteColor];
        CGSize goldCountLabelSize = [self labelAutoCalculateRectWith:@"600000" FontSize:_fontSize MaxSize:CGSizeMake(100, 30)];
        _goldCountLabel.frame = CGRectMake(CGRectGetMaxX(_remainLabel.frame) + 5, 10, goldCountLabelSize.width, 30);
        [pickerViewBottom addSubview:_goldCountLabel];

        _bottomDiamond = [[UIImageView alloc] init];
        [_bottomDiamond setImage:[UIImage imageNamed:@"gift_gold_img"]];
        _bottomDiamond.contentMode = UIViewContentModeScaleAspectFit;
        _bottomDiamond.center = CGPointMake(CGRectGetMaxX(_goldCountLabel.frame) + 5 + 10, 25);
        _bottomDiamond.bounds = CGRectMake(0, 0, 20, 20);
        [pickerViewBottom addSubview:_bottomDiamond];

        UIButton *btnSendGift = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnSendGift.backgroundColor = RGBA(115, 165, 165, 1.0);
        [btnSendGift setTintColor:[UIColor whiteColor]];
        [btnSendGift setTitle:@"赠送" forState:UIControlStateNormal];
        btnSendGift.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
        btnSendGift.center = CGPointMake(screenWidth - 20 - 25, 25);
        btnSendGift.bounds = CGRectMake(0, 0, 50, 30);
        btnSendGift.layer.cornerRadius = 15;
        [btnSendGift addTarget:self action:@selector(clickSend) forControlEvents:UIControlEventTouchUpInside];
        [pickerViewBottom addSubview:btnSendGift];

        UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnAdd.backgroundColor = RGBA(115, 165, 165, 1.0);
        [btnAdd setTintColor:[UIColor whiteColor]];
        [btnAdd setTitle:@"+" forState:UIControlStateNormal];
        btnAdd.titleLabel.font = [UIFont systemFontOfSize:20];
        btnAdd.center = CGPointMake(btnSendGift.center.x - 25 - 15, 25);
        btnAdd.bounds = CGRectMake(0, 0, 30, 30);
        btnAdd.layer.cornerRadius = 15;
        [btnAdd addTarget:self action:@selector(clickAdd) forControlEvents:UIControlEventTouchUpInside];
        [pickerViewBottom addSubview:btnAdd];

        _giftNumberInput = [[UITextField alloc] init];
        _giftNumberInput.backgroundColor = [UIColor whiteColor];
        _giftNumberInput.keyboardType = UIKeyboardTypeNumberPad;
        _giftNumberInput.textAlignment = NSTextAlignmentCenter;
        _giftNumberInput.center = CGPointMake(btnAdd.center.x - 15 - 20, 25);
        _giftNumberInput.bounds = CGRectMake(0, 0, 40, 30);
        _giftNumberInput.layer.cornerRadius = 5;
        _giftNumberInput.text = @"0";
        [pickerViewBottom addSubview:_giftNumberInput];

        UIButton *btnSub = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnSub.backgroundColor = RGBA(115, 165, 165, 1.0);
        [btnSub setTintColor:[UIColor whiteColor]];
        [btnSub setTitle:@"-" forState:UIControlStateNormal];
        btnSub.titleLabel.font = [UIFont systemFontOfSize:20];
        btnSub.center = CGPointMake(_giftNumberInput.center.x - 20 - 15, 25);
        btnSub.bounds = CGRectMake(0, 0, 30, 30);
        btnSub.layer.cornerRadius = 15;
        [btnSub addTarget:self action:@selector(clickSub) forControlEvents:UIControlEventTouchUpInside];
        [pickerViewBottom addSubview:btnSub];



    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)clickAdd {
    NSInteger current = [_giftNumberInput.text intValue];
    if (current < 99) {
        current += 1;
    }

    _giftNumberInput.text = [NSString stringWithFormat:@"%d", current];
}

- (void)clickSub {
    NSInteger current = [_giftNumberInput.text intValue];
    if (current > 0) {
        current -= 1;
    }
    _giftNumberInput.text = [NSString stringWithFormat:@"%d", current];
}

- (void)clickSend {
    NSInteger current = [_giftNumberInput.text intValue];
    NSLog(@"index: %d", self.pickedIndex);
    if (current != 0 && _pickedIndex < _giftModelList.count) {
        TCLiveGiftModel *gift = _giftModelList[(NSUInteger) _pickedIndex];
        if ([self.delegate respondsToSelector:@selector(onClickSend:andCount:)]) {
            [self.delegate onClickSend:gift.giftName andCount:current];
        }
    }
}

- (void)setGiftModelList:(NSMutableArray *)giftModelList {
    _giftModelList = giftModelList;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSUInteger giftTypeCount = giftModelList.count;
    if (giftTypeCount <= 6) {
        _giftScrollView.contentSize = CGSizeMake(screenWidth, 0);
        UIView *giftPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth/3 * 4/5 * 2)];
        [_giftScrollView addSubview:giftPageView];
        for (NSUInteger i=0; i<giftTypeCount; i++) {
            TCLiveGiftModel *gift = giftModelList[i];
            TCLiveGiftGlanceView *giftView = [[TCLiveGiftGlanceView alloc] init];
            giftView.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGiftView:)];
            tap.numberOfTapsRequired = 1;
            [giftView addGestureRecognizer:tap];
            [_giftViewList addObject:giftView];
//            if (i == _pickedIndex) {
//                giftView.layer.borderWidth =1;
//                giftView.layer.borderColor = RGB(125, 190, 170).CGColor;
//            }
            if (i < 3) {
                giftView.frame = CGRectMake(screenWidth/3 * i, 0, screenWidth/3, screenWidth/3 * 4/5);
                giftView.model =gift;
                [giftPageView addSubview:giftView];
            } else {
                giftView.frame = CGRectMake(screenWidth/3 * (i-3), screenWidth/3 * 4/5, screenWidth/3, screenWidth/3 * 4/5);
                giftView.model = gift;
                [giftPageView addSubview:giftView];
            }
        }
    }
}

- (void)setGoldCount:(NSInteger)goldCount {
    NSString *count = [NSString stringWithFormat:@"%d", goldCount];
    CGSize goldCountLabelSize = [self labelAutoCalculateRectWith:count FontSize:_fontSize MaxSize:CGSizeMake(100, 30)];
    _goldCountLabel.frame = CGRectMake(CGRectGetMaxX(_remainLabel.frame) + 5, 10, goldCountLabelSize.width, 30);
    _goldCountLabel.text = count;

    _bottomDiamond.center = CGPointMake(CGRectGetMaxX(_goldCountLabel.frame) + 5 + 10, 25);
    _bottomDiamond.bounds = CGRectMake(0, 0, 20, 20);
}

- (void)setPickedIndex:(NSInteger)pickedIndex {
    TCLiveGiftGlanceView *view = _giftViewList[(NSUInteger) pickedIndex];
    _pickedIndex = pickedIndex;
    for (int i = 0; i < _giftViewList.count; ++i) {
        TCLiveGiftGlanceView *tmp = _giftViewList[(NSUInteger) i];
        tmp.layer.borderWidth = 0;
    }
    view.layer.borderWidth = 1;
    view.layer.borderColor = RGB(125, 190, 170).CGColor;
}

- (void)tapGiftView: (UITapGestureRecognizer *)tap {
    self.pickedIndex = tap.view.tag;
}

/**
 * 计算自适应UILabel大小
 * @param text 要显示的字符串
 * @param fontSize 字号
 * @param maxSize UILabel 的最大尺寸
 * @return  自适应的UILabel的尺寸
 */
- (CGSize)labelAutoCalculateRectWith:(NSString *)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};

    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;

    return labelSize;
}

@end
