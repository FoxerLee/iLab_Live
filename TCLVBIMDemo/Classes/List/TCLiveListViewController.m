//
//  TCLiveListViewController.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLiveListViewController.h"
#import "TCLiveListCell.h"
#import "TCLiveListModel.h"
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking.h>
#import "HUDHelper.h"
#import <MJExtension/MJExtension.h>
#import <BlocksKit/BlocksKit.h>
#import "TCLiveListModel.h"
#import "TCPlayViewController_LinkMic.h"
#import "UIColor+MLPFlatColors.h"
#import "TCLiveGroupCell.h"
#import "TCLiveGroupViewController.h"
#import "NSString+Common.h"
#import "LCManager.h"
#import "TCUserInfoModel.h"
#import "TCSubscribeViewController.h"


@interface TCLiveListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,
        UITableViewDataSource, UITableViewDelegate, TCLiveGroupCellDelegate, UITextFieldDelegate>

@property TCLiveListMgr *liveListMgr;

@property(nonatomic, strong) NSMutableArray *lives;
//@property(nonatomic, strong) UICollectionView *tableView;
@property (nonatomic, strong) UITableView *tableView;
@property BOOL isLoading;

// 新增属性
@property (nonatomic, strong) NSMutableArray *liveGroups;       //储存各个直播的分组情况
@property (nonatomic, strong) NSMutableArray *cells;            //tableView的cell缓存
@end

@implementation TCLiveListViewController
{
    BOOL             _hasEnterplayVC;
    UIView           *_nullDataView;
    VideoType        _videoType;

    //新UI控件
    UIView           *_searchView;          //整个上部搜索区
    UITextField      *_searchInput;         //搜索栏
    CGFloat          searchViewHeight;      //搜索View的高度
    CGFloat          statusBarHeight;       //状态栏高度

    // 旧UI控件
    UIButton         *_liveVideoBtn;
    UIButton         *_clickVieoBtn;
    UIButton         *_ugcVideoBtn;
    UIView           *_scrollView;
    CGFloat          scrollViewWidth;
    CGFloat          scrollViewHeight;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        
        _lives = [NSMutableArray array];
        _liveListMgr = [TCLiveListMgr sharedMgr];
        self.navigationItem.title = @"最新直播";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xF6F2F4);

    [self initNullView];
    
//    [self initMainUIOld];
//    [self setup:VideoType_VOD_SevenDay];

//    [self initBasicBalance];
    [self initMainUI];
    [self setupGestures];
    [self setup: VideoType_LIVE_Online];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = YES;
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor whiteColor];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataAvailable:) name:kTCLiveListNewDataAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataUpdated:) name:kTCLiveListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(svrError:) name:kTCLiveListSvrError object:nil];
    _playVC = nil;
    _hasEnterplayVC = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCLiveListNewDataAvailable object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kTCLiveListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCLiveListSvrError object:nil];
}

- (void)initBasicBalance {
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    NSInteger goldCount = [LCManager getUserBalanceById:profile.identifier];
    if (goldCount < 0) {
        [LCManager initUser:profile.identifier Balance:kInitBalance];
    }
}

- (NSMutableArray *)getLiveList {
    return self.lives;
}

/**
 * 初始化直播列表主界面(修改版)
 */
- (void)initMainUI {
    statusBarHeight = 20;
    searchViewHeight = 50;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 初始化搜索View
    CGRect searchViewFrame = CGRectMake(0, statusBarHeight, screenWidth, searchViewHeight);
    _searchView = [[UIView alloc] initWithFrame:searchViewFrame];
    _searchView.backgroundColor = RGB(98, 213, 201);
    [self.view addSubview:_searchView];

    UIImage *searchImage = [UIImage imageNamed:@"main_search_bar"];
    UIImageView *searchBar = [[UIImageView alloc] initWithImage:searchImage];
    searchBar.frame = CGRectMake(10, 3, 310, 44);
    [_searchView addSubview:searchBar];

    _searchInput = [[UITextField alloc] init];
    _searchInput.placeholder = kLiveSearchPlaceHolder;
    _searchInput.frame = CGRectMake(55, 5, 260, 40);
    _searchInput.enablesReturnKeyAutomatically = YES;
    _searchInput.returnKeyType = UIReturnKeySearch;
//    _searchInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchInput.delegate = self;
    [_searchView addSubview:_searchInput];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTintColor:RGB(250, 250, 250)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(CGRectGetMaxX(searchBar.frame), 5, 50, 40);
    [cancelBtn addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:cancelBtn];

    CGRect tableViewFrame = CGRectMake(0,
            CGRectGetMaxY(_searchView.frame),
            screenWidth,
            screenHeight-CGRectGetMaxY(_searchView.frame) - self.tabBarController.tabBar.frame.size.height);
    _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style: UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_footer.hidden = YES;
    [self.view addSubview:_tableView];

    self.automaticallyAdjustsScrollViewInsets = YES;
}

/**
 * 设置交互手势
 */
- (void)setupGestures {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_searchInput.text.length == 0) {
        return NO;
    } else {
        [_searchInput resignFirstResponder];
        [self enterSearchView];
        return YES;
    }

}

/**
 *   Enter search view controller
 */
- (void)enterSearchView {
    NSString *keyWord = _searchInput.text;
    NSMutableArray *searchLives = [NSMutableArray array];

    for (TCLiveInfo *live in _lives) {
        if ([live.title containsString:keyWord] || [live.userinfo.nickname containsString:keyWord]) {
            [searchLives addObject:live];
        }
    }

    if (searchLives.count == 0) {
        TCLiveUserInfo *fakeUser = [[TCLiveUserInfo alloc] init];
        fakeUser.nickname = @"无主播";
        TCLiveInfo *fakeLive = [[TCLiveInfo alloc] init];
        fakeLive.userinfo = fakeUser;
        fakeLive.title = @"暂无直播";
        fakeLive.playurl = @"nolive";
        [searchLives addObject:[fakeLive copy]];
        [searchLives addObject:[fakeLive copy]];
    }

    TCLiveGroupInfo *group = [TCLiveGroupInfo initWithName:@"搜索结果" andType:LiveTypeGame andDetail:nil andLiveList:searchLives];

    TCLiveGroupViewController *groupVC = [[TCLiveGroupViewController alloc] initWithGroupInfo:group];
    [self.navigationController pushViewController:groupVC animated:YES];
}


/**
 * 初始化直播列表主界面(demo版)
 */
- (void)initMainUIOld {
    CGFloat btnSpace         = 40;
    CGFloat btnWidth         = 38;
    CGFloat btnHeight        = 24;
    CGFloat statuBarHeight   = 20;
    scrollViewWidth  = 70;
    scrollViewHeight = 3;
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0,statuBarHeight,SCREEN_WIDTH, 44)];
    tabView.backgroundColor = [UIColor whiteColor];

    _liveVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_liveVideoBtn setFrame:CGRectMake((SCREEN_WIDTH - btnWidth*3 - btnSpace*2)/2, 11, btnWidth, btnHeight)];
    [_liveVideoBtn setTitle:@"直播" forState:UIControlStateNormal];
    _liveVideoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_liveVideoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
    [_liveVideoBtn addTarget:self action:@selector(videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _liveVideoBtn.tag = 0;

    _clickVieoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_clickVieoBtn setFrame:CGRectMake(_liveVideoBtn.right + btnSpace, 11, btnWidth, btnHeight)];
    [_clickVieoBtn setTitle:@"回放" forState:UIControlStateNormal];
    _clickVieoBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_clickVieoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_clickVieoBtn addTarget:self action:@selector(videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _clickVieoBtn.tag = 1;

    _ugcVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_ugcVideoBtn setFrame:CGRectMake(_clickVieoBtn.right + btnSpace, 11, btnWidth + 20, btnHeight)];
    [_ugcVideoBtn setTitle:@"小视频" forState:UIControlStateNormal];
    _ugcVideoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_ugcVideoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
    [_ugcVideoBtn addTarget:self action:@selector(videoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _ugcVideoBtn.tag = 2;

    _scrollView = [[UIView alloc] initWithFrame:CGRectMake(_clickVieoBtn.left - (scrollViewWidth - _clickVieoBtn.width)/2, _clickVieoBtn.bottom + 5, scrollViewWidth, scrollViewHeight)];
    _scrollView.backgroundColor = UIColorFromRGB(0xFF0ACBAB);

    UIView *boomView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.bottom, SCREEN_WIDTH, 1)];
    boomView.backgroundColor = UIColorFromRGB(0xD8D8D8);

    [tabView addSubview:_liveVideoBtn];
    [tabView addSubview:_clickVieoBtn];
    [tabView addSubview:_ugcVideoBtn];
    [tabView addSubview:_scrollView];
    [tabView addSubview:boomView];

    [self.view addSubview:tabView];

//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,tabView.bottom, SCREEN_WIDTH, self.view.height - tabView.height - statuBarHeight)//style:UITableViewStylePlain];


//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
//    self.tableView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,tabView.bottom, SCREEN_WIDTH, self.view.height - tabView.height - statuBarHeight) collectionViewLayout:layout];
//    [self.tableView registerClass:[TCLiveListCell class] forCellWithReuseIdentifier:@"TCLiveListCell"];
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
//    [self.view addSubview:self.tableView];
//
//    self.automaticallyAdjustsScrollViewInsets = YES;
}

/**
 * 设置无在线直播时显示的UIView
 */
- (void)initNullView {
    CGFloat nullViewWidth   = 90;
    CGFloat nullViewHeight  = 115;
    CGFloat imageViewWidth  = 68;
    CGFloat imageViewHeight = 74;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((nullViewWidth - imageViewWidth)/2, 0, imageViewWidth, imageViewHeight)];
    imageView.image = [UIImage imageNamed:@"null_image"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + 5, nullViewWidth, 22)];
    label.text = @"暂无内容哦";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x777777);
    _nullDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - nullViewWidth)/2, (self.view.height - nullViewHeight)/2, nullViewWidth, nullViewHeight)];
    [_nullDataView addSubview:imageView];
    [_nullDataView addSubview:label];
    _nullDataView.hidden = YES;
    [self.view addSubview:_nullDataView];
}

- (void)hideKeyboard {
    _searchInput.text = @"";
    [_searchInput resignFirstResponder];
}

- (void)setup:(VideoType)type
{
    _videoType = type;
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.isLoading = YES;
        self.lives = [NSMutableArray array];
        [_liveListMgr queryVideoList:_videoType getType:GetType_Up];
    }];
    
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        self.isLoading = YES;
//        [_liveListMgr queryVideoList:_videoType getType:GetType_Down];
//    }];

    // 先加载缓存的数据，然后再开始网络请求，以防用户打开是看到空数据
    [self.liveListMgr loadLivesFromArchive];
    [self doFetchList];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header beginRefreshing];
    });
    
    [(MJRefreshHeader *)self.tableView.mj_header endRefreshingWithCompletionBlock:^{
        self.isLoading = NO;
    }];
    [(MJRefreshFooter *)self.tableView.mj_footer endRefreshingWithCompletionBlock:^{
        self.isLoading = NO;
    }];
}

-(void)videoBtnClick:(UIButton *)button
{
    UIButton *btn = button;
    switch (btn.tag) {
        case 0:
        {
            //if (!self.isLoading) {
                [_liveVideoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_clickVieoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
                [_ugcVideoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
                _liveVideoBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                _clickVieoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                _ugcVideoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                [UIView animateWithDuration:0.5 animations:^{
                    _scrollView.frame = CGRectMake(_liveVideoBtn.left - (scrollViewWidth - _liveVideoBtn.width)/2, _liveVideoBtn.bottom + 5, scrollViewWidth, scrollViewHeight);
                }];
                
                [self setup:VideoType_LIVE_Online];
            //}
        }
            break;
        case 1:
        {
            //if (!self.isLoading) {
                [_liveVideoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
                [_clickVieoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_ugcVideoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
                _liveVideoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                _clickVieoBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                _ugcVideoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                [UIView animateWithDuration:0.5 animations:^{
                    _scrollView.frame = CGRectMake(_clickVieoBtn.left - (scrollViewWidth - _clickVieoBtn.width)/2, _clickVieoBtn.bottom + 5, scrollViewWidth, scrollViewHeight);
                }];
                
                [self setup:VideoType_VOD_SevenDay];
            //}
        }
            break;
        case 2:
        {
            //if (!self.isLoading) {
                [_liveVideoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
                [_clickVieoBtn setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
                [_ugcVideoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                _liveVideoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                _clickVieoBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                _ugcVideoBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                [UIView animateWithDuration:0.5 animations:^{
                    _scrollView.frame = CGRectMake(_ugcVideoBtn.left - (scrollViewWidth - _ugcVideoBtn.width)/2, _ugcVideoBtn.bottom + 5, scrollViewWidth, scrollViewHeight);
                }];
                
                [self setup:VideoType_UGC_SevenDay];
            //}
            
        }
            break;
        default:
            break;
    }
}


#pragma mark - UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _liveGroups.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveGroupCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TCLiveGroupCell2"];
        if (cell == nil) {
            cell = [[TCLiveGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCLiveGroupCell2"];
        }
        [cell initFromType:TCLiveGroupCellTypeHeader];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TCLiveGroupCell"];
        if (cell == nil) {
            cell = [[TCLiveGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCLiveGroupCell"];
        }
        [cell initFromType:TCLiveGroupCellTypeDefault];
        TCLiveGroupInfo *group = _liveGroups[indexPath.row - 1];
        NSLog(@"row: %d", indexPath.row);
        NSLog(@"group name: %@", group.groupName);
        cell.group = group;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;           // 为直播预览图点击事件设置代理
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveGroupCell *cell = _cells[indexPath.row];
    if (indexPath.row == 0) {
        [cell initFromType:TCLiveGroupCellTypeHeader];
    } else {
        [cell initFromType:TCLiveGroupCellTypeDefault];
        cell.group = _liveGroups[indexPath.row - 1];
    }
    return cell.height;
}


#pragma mark - TCLiveGroupCell delegate
- (void)onTapLiveView:(TCLiveInfo *)liveInfo {
    NSLog(@"tap test %@", liveInfo.userinfo.nickname);
    // liveView 持有的live不是用来填充的fakeLive，则打开播放控制器
    if (![liveInfo.playurl isEqualToString:@"nolive"]) {
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

- (void)onClickEnterBtn:(LiveType)groupType {
    TCLiveGroupInfo *group;
    switch (groupType) {
        case LiveTypeGame: {
            NSLog(@"game");
            group = self.liveGroups[0];
        }
        break;
        case LiveTypeGirls: {
            NSLog(@"girls");
            group = self.liveGroups[1];
        }
        break;
        case LiveTypeOutdoor: {
            NSLog(@"outdoor");
            group = self.liveGroups[2];
        }
        break;
        case LiveTypeMusic:
            NSLog(@"music");
            group = self.liveGroups[3];
            break;
        case LiveTypeSport:
            NSLog(@"sport");
            group = self.liveGroups[4];
            break;
        case LiveTypeEdu:
            NSLog(@"edu");
            group = self.liveGroups[5];
            break;
        case LiveTypeFood:
            NSLog(@"food");
            group = self.liveGroups[6];
            break;
        case LiveTypeACG:
            NSLog(@"acg");
            group = self.liveGroups[7];
            break;
        default:{
        }
    }
    TCLiveGroupViewController *groupVC = [[TCLiveGroupViewController alloc] initWithGroupInfo:group];
    [self.navigationController pushViewController:groupVC animated:YES];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%d", indexPath.row);
//}


#pragma mark - UICollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (VideoType_UGC_SevenDay == _videoType) {
        return (self.lives.count + 1) / 2;
    }
    return self.lives.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (VideoType_UGC_SevenDay == _videoType) {
        if (self.lives.count % 2 != 0 && section == (self.lives.count + 1) / 2 - 1) {
            return 1;
        } else {
            return 2;
        }
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveListCell *cell = (TCLiveListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TCLiveListCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TCLiveListCell alloc] initWithFrame:CGRectZero videoType:_videoType];
    }
    
    NSInteger index = 0;
    if (VideoType_UGC_SevenDay == _videoType) {
        index = indexPath.section * 2 + indexPath.row;
    }
    else {
        index = indexPath.section;
    }

    if (self.lives.count > index) {
        TCLiveInfo *live = self.lives[index];
        cell.type = (VideoType_UGC_SevenDay == _videoType ? 1 : 0);
        cell.model = live;
    }
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (VideoType_UGC_SevenDay == _videoType) {
        // 图片的宽高比为9:16
        CGFloat width = (self.view.width - 3) / 2;
        CGFloat height = 16 * width / 9 + 50;
        return CGSizeMake(width, height);
    }
    return CGSizeMake(self.view.width, 340);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (VideoType_UGC_SevenDay == _videoType) {
        return UIEdgeInsetsMake(0, 0, 3, 0);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (VideoType_UGC_SevenDay == _videoType) {
        return 3;
    }
    return 0;
}

#pragma mark - UICollectionView delegate

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 此处一定要用cell的数据，live中的对象可能已经清空了
    TCLiveListCell *cell = (TCLiveListCell *)[collectionView cellForItemAtIndexPath:indexPath];
    TCLiveInfo *info = cell.model;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playError:) name:kTCLivePlayError object:nil];
    // MARK: 打开播放界面
    if (_playVC == nil) {
        _playVC = [[TCPlayViewController_LinkMic alloc] initWithPlayInfo:info videoIsReady:^{
            if (!_hasEnterplayVC) {
                [[TCBaseAppDelegate sharedAppDelegate] pushViewController:_playVC animated:YES];
                _hasEnterplayVC = YES;
            }
        }];
    }

    [self performSelector:@selector(enterPlayVC:) withObject:_playVC afterDelay:0.5];
}

-(void)enterPlayVC:(NSObject *)obj{
    if (!_hasEnterplayVC) {
        [[TCBaseAppDelegate sharedAppDelegate] pushViewController:_playVC animated:YES];
        _hasEnterplayVC = YES;
        
        if (self.listener) {
            [self.listener onEnterPlayViewController];
        }
    }
}

#pragma mark - Net fetch
/**
 * 拉取直播列表。TCLiveListMgr在启动是，会将所有数据下载下来。在未全部下载完前，通过loadLives借口，
 * 能取到部分数据。通过finish接口，判断是否已取到最后的数据
 *
 */
- (void)doFetchList {
    NSRange range = NSMakeRange(_lives.count, 20);
    BOOL finish;
    NSArray *result = [_liveListMgr readLives:range finish:&finish];
    if (result.count) {
        result = [self mergeResult:result];
        [self.lives addObjectsFromArray:result];
    } else {
        if (!finish) {
            return; // 等待新数据的通知过来
        }
        //[[HUDHelper sharedInstance] tipMessage:@"没有啦"];
    }

    NSLog(@"Total live count: %d", self.lives.count);
    //对self.lives 进行分组
    [self groupingLives];

    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    _nullDataView.hidden = self.lives.count != 0;
}

/**
 *  将取到的数据于已存在的数据进行合并。
 *
 *  @param result 新拉取到的数据
 *
 *  @return 新数据去除已存在记录后，剩余的数据
 */
- (NSArray *)mergeResult:(NSArray *)result {
   
    // 每个直播的播放地址不同，通过其进行去重处理
    NSArray *existArray = [self.lives bk_map:^id(TCLiveInfo *obj) {
        return obj.playurl;
    }];
    NSArray *newArray = [result bk_reject:^BOOL(TCLiveInfo *obj) {
        return [existArray containsObject:obj.playurl];
    }];
    
    return newArray;
}

- (void)groupingLives {
    NSMutableArray *liveGroups = [NSMutableArray array];

    NSMutableArray *gameLives       = [NSMutableArray array];
    NSMutableArray *girlsLives      = [NSMutableArray array];
    NSMutableArray *outdoorLives    = [NSMutableArray array];
    NSMutableArray *musicLives      = [NSMutableArray array];
    NSMutableArray *sportsLives     = [NSMutableArray array];
    NSMutableArray *eduLives        = [NSMutableArray array];
    NSMutableArray *foodLives       = [NSMutableArray array];
    NSMutableArray *acgLives        = [NSMutableArray array];

    TCLiveUserInfo *fakeUser = [[TCLiveUserInfo alloc] init];
    fakeUser.nickname = @"无主播";
    TCLiveInfo *fakeLive = [[TCLiveInfo alloc] init];
    fakeLive.userinfo = fakeUser;
    fakeLive.title = @"暂无直播";
    fakeLive.playurl = @"nolive";

    if (self.lives.count != 0) {
        for (TCLiveInfo *live in self.lives) {
            NSArray *separateArray = [live.title componentsSeparatedByString:@";;;"];
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

            live.title = trueTitle;

            if ([typeName equalsString:@"游戏"]) {
                [gameLives addObject:live];
            } else if ([typeName equalsString:@"美妆"]) {
                [girlsLives addObject:live];
            } else if ([typeName equalsString:@"户外"]) {
                [outdoorLives addObject:live];
            } else if ([typeName equalsString:@"音乐"]) {
                [musicLives addObject:live];
            } else if ([typeName equalsString:@"体育"]) {
                [sportsLives addObject:live];
            } else if ([typeName equalsString:@"教育"]) {
                [eduLives addObject:live];
            } else if ([typeName equalsString:@"美食"]) {
                [foodLives addObject:live];
            } else if ([typeName equalsString:@"二次元"]) {
                [acgLives addObject:live];
            } else {
                [gameLives addObject:live];
            }
        }
    }

    if (gameLives.count != 0) {
        TCLiveGroupInfo *groupGameLives = [TCLiveGroupInfo initWithName:@"游戏达人" andType:LiveTypeGame
                                                              andDetail:nil andLiveList:gameLives];
        [liveGroups addObject:groupGameLives];
    } else {
        [gameLives addObject:[fakeLive copy]];
        [gameLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupGameLives = [TCLiveGroupInfo initWithName:@"游戏达人" andType:LiveTypeGame
                                                              andDetail:nil andLiveList:gameLives];
        [liveGroups addObject:groupGameLives];
    }

    if (girlsLives.count != 0) {
        TCLiveGroupInfo *groupGirlsLives = [TCLiveGroupInfo initWithName:@"美妆" andType:LiveTypeGirls
                                                               andDetail:nil andLiveList:girlsLives];
        [liveGroups addObject:groupGirlsLives];
    } else {
        [girlsLives addObject:[fakeLive copy]];
        [girlsLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupGirlsLives = [TCLiveGroupInfo initWithName:@"美妆" andType:LiveTypeGirls
                                                               andDetail:nil andLiveList:girlsLives];
        [liveGroups addObject:groupGirlsLives];
    }

    if (outdoorLives.count != 0) {
        TCLiveGroupInfo *groupOutdoorLives = [TCLiveGroupInfo initWithName:@"户外" andType:LiveTypeOutdoor
                                                                 andDetail:nil andLiveList:outdoorLives];
        [liveGroups addObject:groupOutdoorLives];
    } else {
        [outdoorLives addObject:[fakeLive copy]];
        [outdoorLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupOutdoorLives = [TCLiveGroupInfo initWithName:@"户外" andType:LiveTypeOutdoor
                                                                 andDetail:nil andLiveList:outdoorLives];
        [liveGroups addObject:groupOutdoorLives];
    }

    if (musicLives.count != 0) {
        TCLiveGroupInfo *groupMusicLives = [TCLiveGroupInfo initWithName:@"音乐" andType:LiveTypeMusic
                                                               andDetail:nil andLiveList:musicLives];
        [liveGroups addObject:groupMusicLives];
    } else {
        [musicLives addObject:[fakeLive copy]];
        [musicLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupMusicLives = [TCLiveGroupInfo initWithName:@"音乐" andType:LiveTypeMusic
                                                               andDetail:nil andLiveList:musicLives];
        [liveGroups addObject:groupMusicLives];
    }

    if (sportsLives.count != 0) {
        TCLiveGroupInfo *groupSportsLives = [TCLiveGroupInfo initWithName:@"体育" andType:LiveTypeSport
                                                                andDetail:nil andLiveList:sportsLives];
        [liveGroups addObject:groupSportsLives];
    } else {
        [sportsLives addObject:[fakeLive copy]];
        [sportsLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupSportsLives = [TCLiveGroupInfo initWithName:@"体育" andType:LiveTypeSport
                                                                andDetail:nil andLiveList:sportsLives];
        [liveGroups addObject:groupSportsLives];
    }

    if (eduLives.count != 0) {
        TCLiveGroupInfo *groupEduLives = [TCLiveGroupInfo initWithName:@"教育" andType:LiveTypeEdu
                                                             andDetail:nil andLiveList:eduLives];
        [liveGroups addObject:groupEduLives];
    } else {
        [eduLives addObject:[fakeLive copy]];
        [eduLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupEduLives = [TCLiveGroupInfo initWithName:@"教育" andType:LiveTypeEdu
                                                             andDetail:nil andLiveList:eduLives];
        [liveGroups addObject:groupEduLives];
    }

    if (foodLives.count != 0) {
        TCLiveGroupInfo *groupFoodLives = [TCLiveGroupInfo initWithName:@"美食" andType:LiveTypeFood
                                                              andDetail:nil andLiveList:foodLives];
        [liveGroups addObject:groupFoodLives];
    } else {
        [foodLives addObject:[fakeLive copy]];
        [foodLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupFoodLives = [TCLiveGroupInfo initWithName:@"美食" andType:LiveTypeFood
                                                              andDetail:nil andLiveList:foodLives];
        [liveGroups addObject:groupFoodLives];
    }

    if (acgLives.count != 0) {
        TCLiveGroupInfo *groupACGLives = [TCLiveGroupInfo initWithName:@"二次元" andType:LiveTypeACG
                                                             andDetail:nil andLiveList:acgLives];
        [liveGroups addObject:groupACGLives];
    } else {
        [acgLives addObject:[fakeLive copy]];
        [acgLives addObject:[fakeLive copy]];
        TCLiveGroupInfo *groupACGLives = [TCLiveGroupInfo initWithName:@"二次元" andType:LiveTypeACG
                                                             andDetail:nil andLiveList:acgLives];
        [liveGroups addObject:groupACGLives];
    }

    self.liveGroups = liveGroups;

    _cells = [[NSMutableArray alloc] init];
    // modify
    for (int i = 0; i < _liveGroups.count + 1; ++i) {
        TCLiveGroupCell *cell = [[TCLiveGroupCell alloc] init];
        [_cells addObject:cell];
    }
}

/**
 *  TCLiveListMgr有新数据过来
 *
 *  @param noti
 */
- (void)newDataAvailable:(NSNotification *)noti {
    [self doFetchList];
}

/**
 *  TCLiveListMgr数据有更新
 *
 *  @param noti
 */
- (void)listDataUpdated:(NSNotification *)noti {
    NSDictionary* dict = noti.userInfo;
    NSString* userId = nil;
    NSString* fileId = nil;
    int type = 0;
    if (dict[@"userid"])
        userId = dict[@"userid"];
    if (dict[@"type"])
        type = [dict[@"type"] intValue];
    if (dict[@"fileid"])
        fileId = dict[@"fileid"];
    
    TCLiveInfo* info = [_liveListMgr readLive:type userId:userId fileId:fileId];
    if (nil == info)
        return;
    
    for (TCLiveInfo* item in self.lives)
    {
        if ([info.userid isEqualToString:item.userid])
        {
            item.viewercount = info.viewercount;
            item.likecount = info.likecount;
            break;
        }
    }
    
    [self.tableView reloadData];
}


/**
 *  TCLiveListMgr内部出错
 *
 *  @param noti
 */
- (void)svrError:(NSNotification *)noti {
    NSError *e = noti.object;
    if ([e isKindOfClass:[NSError class]]) {
        if ([e localizedFailureReason]) {
            [HUDHelper alert:[e localizedFailureReason]];
        }
        else if ([e localizedDescription]) {
            [HUDHelper alert:[e localizedDescription]];
        }
    }
    
    // 如果还在加载，停止加载动画
    if (self.isLoading) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.isLoading = NO;
    }
}

/**
 *  TCPlayViewController出错，加入房间失败
 *
 */
- (void)playError:(NSNotification *)noti {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView.mj_header beginRefreshing];
        //加房间失败后，刷新列表，不需要刷新动画
        self.lives = [NSMutableArray array];
        self.isLoading = YES;
        [_liveListMgr queryVideoList:VideoType_LIVE_Online getType:GetType_Up];
    });
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCLivePlayError object:nil];
}

@end
