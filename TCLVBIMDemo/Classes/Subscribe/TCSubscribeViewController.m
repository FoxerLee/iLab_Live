//
//  TCSubscribeViewController.m
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCSubscribeViewController.h"
#import "TCSubscribeTableViewCell.h"
#import "TCSubscribeModel.h"
#import "TCUserInfoModel.h"
#import "TCLiveListModel.h"
#import "TCPlayViewController.h"
#import "TCPlayViewController_LinkMic.h"
#import "LCManager.h"


@interface TCSubscribeViewController (){
    NSMutableArray   *_upInfoList;
    NSArray          *upIds;
    UIView *_nullDataView;
    NSMutableArray *_liveList;
}

@property(nonatomic,retain) TCPlayViewController *playVC;

@property (nonatomic, strong) UITableView *tableView;

@end



@implementation TCSubscribeViewController {
    BOOL             _hasEnterplayVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"订阅";

    [self initData];
    [self initUI];
    [self initNullView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];

    [self.navigationController setNavigationBarHidden:NO];

    if ([self.delegate respondsToSelector:@selector(getLiveList)]) {
        _liveList = [self.delegate getLiveList];
    }

    _nullDataView.hidden = _upInfoList.count != 0;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_upInfoList removeAllObjects];
        [self getUpInfos];
        dispatch_async(dispatch_get_main_queue(), ^{
            _nullDataView.hidden = _upInfoList.count != 0;
            [_tableView reloadData];
        });
    });

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _playVC = nil;
    _hasEnterplayVC = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initData {
    _upInfoList = [NSMutableArray array];
    _liveList = [NSMutableArray array];
}

- (void)getUpInfos {
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    upIds = [LCManager getUserSubscribeIds:profile.identifier];

    for (NSString *id in upIds) {
        NSDictionary *dict = [LCManager getUpInfo:id];
        if (dict != nil) {
            NSString *upName = dict[@"up_name"];
            NSString *totalTitle = dict[@"room_name"];
            NSString *roomCover = dict[@"room_cover"];

            NSArray *separateArray = [totalTitle componentsSeparatedByString:@";;;"];
            NSString *typeName = @"";
            NSString *trueTitle = @"";
            if (separateArray.count > 2) {
                trueTitle = separateArray[0];
                for (int i = 0; i < separateArray.count - 1; i++) {
                    trueTitle = [NSString stringWithFormat:@"%@;;;%@", trueTitle, separateArray[i]];
                }
                typeName = separateArray[separateArray.count-1];
            } else if (separateArray.count == 1) {
                trueTitle = separateArray[0];
                typeName = @"游戏";
            } else {
                trueTitle = separateArray[0];
                typeName = separateArray[1];
            }

            TCSubscribeModel *model = [TCSubscribeModel initWithLiveTitle:trueTitle upName:upName upId:id
                                                                 liveType:typeName liveCover:roomCover liveViews:nil];

            [_upInfoList addObject:model];
        }
    }

}

- (void)initUI {
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 30);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;

    [self.view addSubview:_tableView];
}

- (void)initNullView {
    CGFloat nullViewWidth   = 90;
    CGFloat nullViewHeight  = 115;
    CGFloat imageViewWidth  = 68;
    CGFloat imageViewHeight = 74;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((nullViewWidth - imageViewWidth)/2, 0, imageViewWidth, imageViewHeight)];
    imageView.image = [UIImage imageNamed:@"null_image"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + 5, nullViewWidth, 22)];
    label.text = @"暂无直播哦";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x777777);
    _nullDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - nullViewWidth)/2, (self.view.height - nullViewHeight)/2, nullViewWidth, nullViewHeight)];
    [_nullDataView addSubview:imageView];
    [_nullDataView addSubview:label];
    _nullDataView.hidden = YES;
    [self.view addSubview:_nullDataView];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCSubscribeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TCSubscribeTableViewCell"];
    if (cell == nil){
        cell = [[TCSubscribeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCSubscribeTableViewCell"];
    }

    if (_upInfoList.count != 0) {
        cell.model = _upInfoList[(NSUInteger) indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _upInfoList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveInfo *liveInfo;
    for (TCLiveInfo *live in _liveList) {
        TCSubscribeModel *model = _upInfoList[(NSUInteger) indexPath.row];
        if ([live.userid isEqualToString:model.upId]) {
            liveInfo = live;
            break;
        }
    }
    if (liveInfo != nil) {
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat padding = 15;
    CGFloat cellHeight = (screenWidth - 2*padding)/2 * 9/16 + padding;
    return cellHeight;
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
