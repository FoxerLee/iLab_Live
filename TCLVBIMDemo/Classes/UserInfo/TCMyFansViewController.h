//
//  TCMyFans.h
//  TCLVBIMDemo
//
//  Created by chenyulei on 2017/11/29.
//  Copyright © 2017年 tencent. All rights reserved.
//

#ifndef TCMyFans_h
#define TCMyFans_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


/*
 * TCMyFansViewController 类说明 : 该类显示用户点击我的粉丝后显示页面
 * 页面上只有一个tableview控件
 */

@interface TCMyFansViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView      *tableView;

@property (strong, nonatomic) NSMutableArray   *userInfoArry;

@end

#endif /* TCMyFans_h */
