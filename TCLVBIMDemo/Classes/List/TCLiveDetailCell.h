//
//  TCLiveDetailCell.h
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLiveListModel.h"

@interface TCLiveDetailCell : UITableViewCell

@property (nonatomic, strong) TCLiveInfo *model;

@property (nonatomic, strong) UILabel *typeLabel;

@property (assign, atomic) CGFloat height;

@end
