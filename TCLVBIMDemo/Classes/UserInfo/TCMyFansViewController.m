//
//  TCShowMyFans.m
//  TCLVBIMDemo
//
//  Created by chenyulei on 2017/11/29.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCMyFansViewController.h"
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

#import "TCMyFansViewController.h"
#import "TCUserInfoCell.h"
#import "TCUserSubscribeCell.h"
#import "LCManager.h"


@interface TCMyFansViewController ()<TCUserSubscribeCellDelegate>{
    NSMutableArray* fansIds;
}
@end



@implementation TCMyFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"我的粉丝";

    [self initData];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-30) style:UITableViewStylePlain];

    _tableView.delegate = self;
    _tableView.dataSource = self;

    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:_tableView];
}

- (void)initData {
    fansIds = [NSMutableArray array];
    _userInfoArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    [self.navigationController setNavigationBarHidden:NO];
    [self getFansIds];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFansIds {
    [fansIds removeAllObjects];
    [_userInfoArray removeAllObjects];
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    fansIds = [[LCManager getUserFansIds:profile.identifier] mutableCopy];
    [[TIMFriendshipManager sharedInstance] GetFriendsProfile:fansIds succ:^(NSArray *friends) {
        for (TIMUserProfile *user in friends) {
            NSLog(@"user: %@", user.identifier);
            [_userInfoArray addObject:user];
        }
        [_tableView reloadData];
    } fail:^(int code, NSString *msg) {
        NSLog(@"get users failed");
    }];
}

- (void)onClickCancelSubscribe:(NSString *)upId {
//    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    NSLog(@"click btn: %@", upId);
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
//                                                                   message:@"确定取消订阅吗？"
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              [LCManager cancelUser:profile.identifier followUp:upId];
//                                                              [self getFansIds];
//                                                              NSLog(@"action = %@", action);
//                                                          }];
//    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {
//                                                             //响应事件
//                                                             NSLog(@"action = %@", action);
//                                                         }];
//
//    [alert addAction:defaultAction];
//    [alert addAction:cancelAction];
//    [self presentViewController:alert animated:YES completion:nil];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCUserSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCUserSubscribeCell"];
    if (cell == nil) {
        cell = [[TCUserSubscribeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCUserSubscribeCell"];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = _userInfoArray[(NSUInteger) indexPath.row];
    cell.cellType = TCUserSubscribeCellTypeFans;
    NSLog(@"model user id: %@", cell.model.identifier);
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userInfoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}


@end
