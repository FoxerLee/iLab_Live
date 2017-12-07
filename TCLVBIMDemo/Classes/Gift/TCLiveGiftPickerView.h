//
//  TCLiveGiftPickerView.h
//  TCGiftPickerView
//
//  Created by Yichao Wu on 2017/11/25.
//  Copyright © 2017 Yichao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCLiveGiftPickerViewDelegate<NSObject>

- (void)onClickSend: (NSString *)giftName andCount:(NSInteger)number;

@end

@interface TCLiveGiftPickerView : UIView

@property (nonatomic, strong)UIScrollView * giftScrollView;

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong) UITextField  *giftNumberInput;

@property (nonatomic, copy)NSMutableArray *giftModelList;

@property (nonatomic, assign)NSInteger goldCount;

@property (nonatomic, assign)NSInteger pickedIndex;

@property (weak, nonatomic) id<TCLiveGiftPickerViewDelegate> delegate;

@end
