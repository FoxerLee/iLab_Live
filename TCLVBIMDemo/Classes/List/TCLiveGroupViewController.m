//
//  TCLiveGroupViewController.m
//  TCLVBIMDemo
//
//  Created by Yichao Wu on 2017/12/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCLiveGroupViewController.h"
#import "TCLiveDetailCell.h"
#import "NSString+Common.h"
#import "TCPlayViewController.h"
#import "TCPlayViewController_LinkMic.h"

@interface TCLiveGroupViewController ()<UITableViewDataSource, UITableViewDelegate> {
    UIView *_nullDataView;
}

@property(nonatomic,retain) TCPlayViewController *playVC;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *lives;

@end

@implementation TCLiveGroupViewController {
    BOOL             _hasEnterplayVC;

}

- (id)initWithGroupInfo: (TCLiveGroupInfo *)groupInfo {
    self = [super init];
    if (self) {
        self.groupInfo = groupInfo;
    }
    TCLiveInfo *live = groupInfo.liveList[0];
    if ([live.playurl equalsString:@"nolive"]) {
        _lives = [NSMutableArray array];
    } else {
        _lives = groupInfo.liveList;
    }
    NSLog(@"%d", _lives.count);
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _playVC = nil;
    _hasEnterplayVC = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.groupInfo.groupName;
    self.view.backgroundColor = [UIColor whiteColor];

    [self initNullView];
    [self initUI];

    if (_lives.count == 0) {
        _nullDataView.hidden = NO;
        [self.view bringSubviewToFront:_nullDataView];
    }
}

- (void)initUI {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    _tableView = [[UITableView alloc] init];
    CGRect tableViewFrame = CGRectMake(0,
            navHeight,
            width,
            height - navHeight - tabBarHeight);
    _tableView.frame = tableViewFrame;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)initNullView {
    CGFloat nullViewWidth   = 90;
    CGFloat nullViewHeight  = 115;
    CGFloat imageViewWidth  = 68;
    CGFloat imageViewHeight = 74;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((nullViewWidth - imageViewWidth)/2, 0, imageViewWidth, imageViewHeight)];
    imageView.image = [UIImage imageNamed:@"null_image"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + 5, nullViewWidth, 22)];
    label.text = @"暂无内容哦";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x777777);
    _nullDataView = [[UIView alloc] initWithFrame:CGRectMake((width - nullViewWidth)/2, (self.view.height - nullViewHeight)/2, nullViewWidth, nullViewHeight)];
    [_nullDataView addSubview:imageView];
    [_nullDataView addSubview:label];
    _nullDataView.hidden = YES;
    [self.view addSubview:_nullDataView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - UITableView datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCLiveDetailCell"];
    if (cell == nil) {
        cell = [[TCLiveDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCLiveDetailCell"];
    }
//    NSMutableArray *lives = self.groupInfo.liveList;

    cell.model = _lives[(NSUInteger) indexPath.row];
    cell.typeLabel.text = self.title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.groupInfo.liveList.count;
    return self.lives.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 137.03;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveInfo *liveInfo = _lives[indexPath.row];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playError:) name:kTCLivePlayError object:nil];
    // MARK: 打开播放界面
    if (_playVC == nil) {
        _playVC = [[TCPlayViewController_LinkMic alloc] initWithPlayInfo:liveInfo videoIsReady:^{
            if (!_hasEnterplayVC) {
                [[TCBaseAppDelegate sharedAppDelegate] pushViewController:_playVC animated:YES];
                _hasEnterplayVC = YES;
            }
        }];
    }

    [self performSelector:@selector(enterPlayVC:) withObject:_playVC afterDelay:0.5];
}


- (void)playError:(NSNotification *)noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCLivePlayError object:nil];
}

-(void)enterPlayVC:(NSObject *)obj{
    if (!_hasEnterplayVC) {
        [[TCBaseAppDelegate sharedAppDelegate] pushViewController:_playVC animated:YES];
        _hasEnterplayVC = YES;
    }
}


@end
