//
//  TCMyFollowViewController.h
//  TCLVBIMDemo
//
//  Created by chenyulei on 2017/11/29.
//  Copyright © 2017年 tencent. All rights reserved.
//

#ifndef TCMyFollowViewController_h
#define TCMyFollowViewController_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


/*
 * TCMyFollowViewController 类说明 : 该类显示用户点击我的关注后显示页面
 * 页面上只有一个tableview控件
 */

@interface TCMyFollowViewController: UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *dataTable;

@property (strong, nonatomic) NSMutableArray *subscriptionArry;

@end

#endif /* TCMyFollowViewController_h */
