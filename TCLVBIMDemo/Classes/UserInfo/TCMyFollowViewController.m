//
//  TCShowMyFollowViewController.m
//  TCLVBIMDemo
//
//  Created by chenyulei on 2017/11/29.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCMyFollowViewController.h"
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

@implementation TCMyFollowViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *textColour = [UIColor colorWithRed:36/255.0 green:203/255.0 blue:173/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor    = textColour;
    self.navigationItem.title = @"我的关注";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor blackColor]}] ;
    
    self.view.backgroundColor = RGB(0xF3,0xF3,0xF3);
    
//    __weak typeof(self) ws = self;
//    TCUserInfoData  *_profile = [[TCUserInfoModel sharedInstance] getUserProfile ];
//    TCUserInfoCellItem *faceItem = [[TCUserInfoCellItem alloc] initWith:@"头像" value:nil type:TCUserInfo_EditFace action:^(TCUserInfoCellItem *menu, TCEditUserInfoTableViewCell *cell) {
//       nil; } ];
//
//    TCUserInfoCellItem *nickItem = [[TCUserInfoCellItem alloc] initWith:@"昵称" value:_profile.nickName type:TCUserInfo_EditNick action:^(TCUserInfoCellItem *menu, TCEditUserInfoTableViewCell *cell) {
//        nil; }];
//
//    TCUserInfoCellItem *genderItem = [[TCUserInfoCellItem alloc] initWith:@"性别" value:(TIM_GENDER_MALE==_profile.gender?@"男":@"女") type:TCUserInfo_EditGender action:^(TCUserInfoCellItem *menu, TCEditUserInfoTableViewCell *cell) {
//        [ws modifyUserInfoGender:menu cell:cell]; }];
//
//    _userInfoArry = [NSMutableArray arrayWithArray:@[faceItem, nickItem, genderItem]];
//
    NSInteger nHeighNavigationBar = self.navigationController.navigationBar.frame.size.height;
    NSInteger nStatusBarFrame     =[[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect tableViewFrame  = CGRectMake(0, nHeighNavigationBar+nStatusBarFrame+20, self.view.frame.size.width, 155);
    _tableView    = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate   = self;
    [_tableView setSeparatorColor:RGB(0xD8,0xD8,0xD8)];
    
    //设置tableView不能滚动
    [self.tableView setScrollEnabled:NO];
    
    //去掉多余的分割线
    [self setExtraCellLineHidden:self.tableView];
    [self.view addSubview:_tableView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    return;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
#pragma mark 绘制view
/**
 *  用于去掉界面上多余的横线
 *
 *  @param tableView 无意义
 */
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}
//获取需要绘制的cell数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userInfoArry.count;
}
//获取需要绘制的cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCUserInfoCellItem *item = _userInfoArry[indexPath.row];
    return [TCUserInfoCellItem heightOf:item];
}
//绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCEditUserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    //    TCUserInfoCellItem *item = _userInfoArry[indexPath.row];
    //    if (!cell)
    //    {
    //        cell = [[TCEditUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    //        [cell initUserinfoViewCellData:item];
    //    }
    //
    //    [cell drawRichCell:item delegate:self];
    return cell;
}


/**
 *  用户点击tableview上的cell后,找到对应的回到函数并执行
 *
 *  @param tableView 对应的tableview
 *  @param indexPath 对应的cell索引
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    TCUserInfoCellItem *item = _userInfoArry[indexPath.row];
    //    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    if (item.action)
    //    {
    //        item.action(item, cell);
    //    }
    //
    //    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
