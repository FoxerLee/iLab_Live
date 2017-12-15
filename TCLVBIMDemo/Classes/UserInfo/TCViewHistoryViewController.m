//
//  TCViewHistoryController.m
//  TCLVBIMDemo
//
//  Created by jemilyzhou on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCViewHistoryViewController.h"
#import "TCUserInfoCell.h"
#import "ImSDK/TIMFriendshipManager.h"
#import "TCUserInfoModel.h"
#import "TCLoginModel.h"
#import "TCUploadHelper.h"

#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UIActionSheet+BlocksKit.h"

#define OPEN_CAMERA  0
#define OPEN_PHOTO   1

@implementation TCViewHistoryViewController {
    UIView *_nullDataView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *textColour = [UIColor colorWithRed:36/255.0 green:203/255.0 blue:173/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor    = textColour;
    self.navigationItem.title = @"观看记录";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor blackColor]}] ;
    
    self.view.backgroundColor = RGB(0xF3,0xF3,0xF3);

    [self initNullView];

    _nullDataView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)initNullView {
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat nullViewWidth   = 90;
    CGFloat nullViewHeight  = 115;
    CGFloat imageViewWidth  = 68;
    CGFloat imageViewHeight = 74;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((nullViewWidth - imageViewWidth)/2, 0, imageViewWidth, imageViewHeight)];
    imageView.image = [UIImage imageNamed:@"null_image"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + 5, nullViewWidth, 22)];
    label.text = @"暂无记录";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x777777);
    _nullDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - nullViewWidth)/2, (self.view.height - nullViewHeight)/2, nullViewWidth, nullViewHeight)];
    [_nullDataView addSubview:imageView];
    [_nullDataView addSubview:label];
    _nullDataView.hidden = YES;
    [self.view addSubview:_nullDataView];
}

@end
