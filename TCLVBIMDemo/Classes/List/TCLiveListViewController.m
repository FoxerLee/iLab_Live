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


@interface TCLiveListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,
        UITableViewDataSource, UITableViewDelegate, TCLiveGroupCellDelegate>

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
    [_searchView addSubview:_searchInput];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTintColor:RGB(240, 240, 240)];
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
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
//    tapGestureRecognizer.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tapGestureRecognizer];
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

    //self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,tabView.bottom, SCREEN_WIDTH, self.view.height - tabView.height - statuBarHeight) //style:UITableViewStylePlain];


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
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.isLoading = YES;
        [_liveListMgr queryVideoList:_videoType getType:GetType_Down];
    }];

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
    return _liveGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCLiveGroupCell"];
    if (cell == nil) {
        cell = [[TCLiveGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCLiveGroupCell"];
    }
    TCLiveGroupInfo *group = _liveGroups[indexPath.row];
    NSLog(@"row: %d", indexPath.row);
    NSLog(@"group name: %@", group.groupName);
    cell.group = group;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;           // 为直播预览图点击事件设置代理
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLiveGroupCell *cell = _cells[indexPath.row];
    cell.group = _liveGroups[indexPath.row];

    return cell.height;
}


#pragma mark - TCLiveGroupCell delegate
- (void)onTapLiveView:(TCLiveInfo *)liveInfo {
    NSLog(@"tap test %@", liveInfo.userinfo.nickname);
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

    NSLog(@"%d", self.lives.count);
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

    if (self.lives.count != 0) {
        for (TCLiveInfo *live in self.lives) {
            // TODO: 编写分组逻辑

            [eduLives addObject:live];
        }
    }

    if (gameLives.count != 0) {
        TCLiveGroupInfo *groupGameLives = [TCLiveGroupInfo initWithName:@"游戏达人" andType:LiveTypeGame
                                                              andDetail:nil andLiveList:gameLives];
        [liveGroups addObject:groupGameLives];
    }
    if (girlsLives.count != 0) {
        TCLiveGroupInfo *groupGirlsLives = [TCLiveGroupInfo initWithName:@"美妆" andType:LiveTypeGirls
                                                               andDetail:nil andLiveList:girlsLives];
        [liveGroups addObject:groupGirlsLives];
    }
    if (outdoorLives.count != 0) {
        TCLiveGroupInfo *groupOutdoorLives = [TCLiveGroupInfo initWithName:@"户外" andType:LiveTypeOutdoor
                                                                 andDetail:nil andLiveList:outdoorLives];
        [liveGroups addObject:groupOutdoorLives];
    }
    if (musicLives.count != 0) {
        TCLiveGroupInfo *groupMusicLives = [TCLiveGroupInfo initWithName:@"音乐" andType:LiveTypeMusic
                                                               andDetail:nil andLiveList:musicLives];
        [liveGroups addObject:groupMusicLives];
    }
    if (sportsLives.count != 0) {
        TCLiveGroupInfo *groupSportsLives = [TCLiveGroupInfo initWithName:@"体育" andType:LiveTypeSport
                                                                andDetail:nil andLiveList:sportsLives];
        [liveGroups addObject:groupSportsLives];
    }
    if (eduLives.count != 0) {
        TCLiveGroupInfo *groupEduLives = [TCLiveGroupInfo initWithName:@"教育" andType:LiveTypeEdu
                                                             andDetail:nil andLiveList:eduLives];
        [liveGroups addObject:groupEduLives];
    }
    if (foodLives.count != 0) {
        TCLiveGroupInfo *groupFoodLives = [TCLiveGroupInfo initWithName:@"美食" andType:LiveTypeFood
                                                              andDetail:nil andLiveList:foodLives];
        [liveGroups addObject:groupFoodLives];
    }
    if (acgLives.count != 0) {
        TCLiveGroupInfo *groupACGLives = [TCLiveGroupInfo initWithName:@"二次元" andType:LiveTypeACG
                                                             andDetail:nil andLiveList:acgLives];
        [liveGroups addObject:groupACGLives];
    }

    self.liveGroups = liveGroups;

    _cells = [[NSMutableArray alloc] init];
    for (int i = 0; i < _liveGroups.count; ++i) {
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
