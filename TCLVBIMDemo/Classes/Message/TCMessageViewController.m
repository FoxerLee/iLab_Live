//
//  TCMessageViewController.m
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/15.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCMessageViewController.h"
#import "TCMessageCell.h"
#import "LCManager.h"
#import "TCUserInfoModel.h"

@interface TCMessageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *msgArray;

@end

@implementation TCMessageViewController {
    NSMutableArray *_nicknameArray;
    UIView *_nullDataView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initUI];
    [self initNullView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _nullDataView.hidden = _msgArray.count != 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            _nullDataView.hidden = _msgArray.count != 0;
            [_tableView reloadData];
        });
    });
}

- (void)initData {
    _msgArray = [NSMutableArray array];
    _nicknameArray = [NSMutableArray array];
}

- (void)getData {
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    _msgArray = [[LCManager getGiftMessageArray:profile.identifier] mutableCopy];
    for (NSDictionary *dict in _msgArray) {
        NSLog(@"giftName: %@, giftNumber: %d, senderid: %@", dict[@"giftName"], [dict[@"giftNumber"] intValue], dict[@"senderId"]);
    }
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];

    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 30);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"全部删除" style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(onClickDeleteAll)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)initNullView {
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat nullViewWidth   = 90;
    CGFloat nullViewHeight  = 115;
    CGFloat imageViewWidth  = 68;
    CGFloat imageViewHeight = 74;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((nullViewWidth - imageViewWidth)/2, 0, imageViewWidth, imageViewHeight)];
    imageView.image = [UIImage imageNamed:@"null_image"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + 5, nullViewWidth, 22)];
    label.text = @"暂无消息";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x777777);
    _nullDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - nullViewWidth)/2, (self.view.height - nullViewHeight)/2, nullViewWidth, nullViewHeight)];
    [_nullDataView addSubview:imageView];
    [_nullDataView addSubview:label];
    _nullDataView.hidden = YES;
    [self.view addSubview:_nullDataView];
}

- (void)onClickDeleteAll {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"确定删除所有消息？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self deleteAllMsg];
                                                              NSLog(@"delete all");
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];

    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteAllMsg {
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    if (_msgArray.count == 0) {
        return;
    } else {
        [LCManager deleteAllGiftMessage:profile.identifier];
        [_msgArray removeAllObjects];
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCMessageCell"];
    if (cell == nil) {
        cell = [[TCMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCMessageCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *giftMsg = _msgArray[indexPath.row];
    NSDate *date = giftMsg[@"dateTime"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm";
    NSString *dateTime = [formatter stringFromDate:date];
    cell.dateTime = dateTime;
    cell.message = [NSString stringWithFormat:@"%@送给你%d个%@", giftMsg[@"senderId"], [giftMsg[@"giftNumber"] intValue], giftMsg[@"giftName"]];
    return cell;
}


@end
