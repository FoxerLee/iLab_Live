//
//  TCShowMyFollowViewController.m
//  TCLVBIMDemo
//
//  Created by chenyulei on 2017/11/29.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCMyFollowViewController.h"
#import "TCUserInfoCell.h"
#import "TCUserSubscribeCell.h"
#import "LCManager.h"


@interface TCMyFollowViewController ()<TCUserSubscribeCellDelegate>{
    NSMutableArray* upIDs;
}
@end



@implementation TCMyFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"我的订阅";

    [self initData];

    _dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-30) style:UITableViewStylePlain];

    _dataTable.delegate = self;
    _dataTable.dataSource = self;

    _dataTable.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:_dataTable];
}

- (void)initData {
    upIDs = [NSMutableArray array];
    _subscriptionArry = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    [self.navigationController setNavigationBarHidden:NO];
    [self getUpIds];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getUpIds {
    [upIDs removeAllObjects];
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    upIDs = [[LCManager getUserSubscribeIds:profile.identifier] mutableCopy];
    [[TIMFriendshipManager sharedInstance] GetFriendsProfile:upIDs succ:^(NSArray *friends) {
        [_subscriptionArry removeAllObjects];
        for (TIMUserProfile *user in friends) {
            NSLog(@"user: %@", user.identifier);
            [_subscriptionArry addObject:user];
        }
        [_dataTable reloadData];
    } fail:^(int code, NSString *msg) {
        NSLog(@"get users failed");
        [_dataTable reloadData];
    }];
}

- (void)onClickCancelSubscribe:(NSString *)upId {
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    NSLog(@"click btn: %@", upId);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"确定取消订阅吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [LCManager cancelUser:profile.identifier followUp:upId];
                                                              [self getUpIds];
                                                              NSLog(@"action = %@", action);
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             NSLog(@"action = %@", action);
                                                         }];

    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    cell.delegate = self;
    cell.model = _subscriptionArry[(NSUInteger) indexPath.row];
    NSLog(@"model user id: %@", cell.model.identifier);
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _subscriptionArry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}


@end

