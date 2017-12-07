//
//  TCLiveGiftGlanceView.h
//  TCGiftPickerView
//
//  Created by Yichao Wu on 2017/11/24.
//  Copyright © 2017 Yichao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLiveGiftModel.h"

@interface TCLiveGiftGlanceView : UIView

@property (nonatomic, strong)TCLiveGiftModel *model;
@property (nonatomic, strong)UIImageView *giftImg;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *goldCountLabel;
@property (nonatomic, strong)UIImageView *goldImg;

@end
