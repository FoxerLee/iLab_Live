//
//  TCSubscribeViewController.h
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCSubscribeViewControllerDelegate <NSObject>

- (NSMutableArray *)getLiveList;

@end


@interface TCSubscribeViewController: UIViewController<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, weak) id<TCSubscribeViewControllerDelegate> delegate;

@end
