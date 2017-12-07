//
//  TCLiveGroupViewController.h
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLiveListModel.h"

@interface TCLiveGroupViewController : UIViewController

@property (nonatomic, strong)TCLiveGroupInfo  *groupInfo;

- (id)initWithGroupInfo: (TCLiveGroupInfo *)groupInfo;

@end
