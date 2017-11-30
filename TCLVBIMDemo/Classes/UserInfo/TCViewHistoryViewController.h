//
//  TCViewHistory.h
//  TCLVBIMDemo
//
//  Created by chenyulei on 2017/11/29.
//  Copyright © 2017年 tencent. All rights reserved.
//

#ifndef TCViewHistory_h
#define TCViewHistory_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


/*
 * TCViewHistoryViewController 类说明 : 该类显示用户点击观看历史后显示页面
 * 页面上只有一个tableview控件
 */

@interface TCViewHistoryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView      *tableView;

@property (strong, nonatomic) NSMutableArray   *userInfoArry;

@end


#endif /* TCViewHistory_h */
