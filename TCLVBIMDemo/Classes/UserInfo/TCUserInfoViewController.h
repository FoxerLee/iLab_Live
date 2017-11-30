//
//  TCUserInfoController.h
//  TCLVBIMDemo
//
//  Created by jemilyzhou on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/*
 * TCUserInfoController 类说明 : 该类显示用户点击下方右边第一个按钮“我”后显示的界面
 * 界面上包括一个tableview和一个button
 *
 * tableview上显示5行元素:
 * 第一个cell显示 : 头像,昵称,ID信息,此cell不响应点击消息
 * 第二个cell分为两个cell,左cell显示 : 我的关注,点击后显示我的关注列表
 *                      右cell显示 : 我的粉丝,点击后显示我的粉丝列表
 * 第三个cell显示 : 账户余额,此cell不响应点击消息
 * 第四个cell显示 : 观看记录,点击后按时间顺序显示观看记录
 * 第五个cell显示 : 编辑个人信息（设置）,点击后进去编辑个人信息页面
 * 第六个cell显示 : 关于小直播,点击后显示版本号信息（可以不要
 *
 * button是退出登陆按钮,点击后退出登陆并且返回到登录页面
 */

@interface TCUserInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *dataTable;

@property (strong, nonatomic) NSMutableArray *userInfoUISetArry;

@end
