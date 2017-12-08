//
//  TCSubscribeViewController.h
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Complete)();

@interface TCSubscribeViewController: UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *dataTable;

@property (strong, nonatomic) NSMutableArray *subscriptionArry;

@property (copy, nonatomic) Complete complete;

@end
