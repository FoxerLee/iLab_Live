//
//  TCSubscribeTableViewCell.h
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCSubscribeFrame;
@interface TCSubscribeTableViewCell : UITableViewCell

//@property(nonatomic,strong) UIImageView *view;
//@property(nonatomic,strong) UILabel* title;
@property(nonatomic,strong) UILabel* name;
@property(nonatomic,strong) UILabel* watch;
@property(nonatomic,strong) UILabel* sclass;

@property(nonatomic,strong) TCSubscribeFrame* subFrame;

 +(NSString *)getID;
@end
