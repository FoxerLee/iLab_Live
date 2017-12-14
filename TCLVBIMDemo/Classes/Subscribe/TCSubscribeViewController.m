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
#import "TCSubscribeFrame.h"
#import "TCUserInfoModel.h"


@interface TCSubscribeViewController (){
    NSMutableArray *_subFrames;
    NSMutableArray* upIDs;
    UIView *_nullDataView;
}
@end



@implementation TCSubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     _subFrames = [NSMutableArray array];
    
    //用于存储被订阅者id
     upIDs = [NSMutableArray array];
    
    _subscriptionArry = [NSMutableArray array];
    
    [self initData];

    _dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 340, 600) style:UITableViewStylePlain];
    
    
    _dataTable.delegate = self;
    _dataTable.dataSource = self;
    
    _dataTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_dataTable];

    [self initNullView];
    
    //从leancloud端获取数据
    //[self getUpInfoFromNetwork];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
    [self getUpInfoFromNetwork];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    
    [_subFrames removeAllObjects];
    [upIDs removeAllObjects];
    [_subscriptionArry removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    label.text = @"暂无直播哦";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x777777);
    _nullDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - nullViewWidth)/2, (self.view.height - nullViewHeight)/2, nullViewWidth, nullViewHeight)];
    [_nullDataView addSubview:imageView];
    [_nullDataView addSubview:label];
    _nullDataView.hidden = YES;
    [self.view addSubview:_nullDataView];
}

- (void)getUpInfoFromNetwork{
    //获取当前登录账户信息
    TCUserInfoData *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    NSString* followID = profile.identifier;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    //请求1 获取被订阅者ID
    NSBlockOperation *a = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self getUpIDs:followID :upIDs :semaphore];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }];
    
    //请求二 根据被订阅者ID查询被订阅信息
    NSBlockOperation *b = [NSBlockOperation blockOperationWithBlock:^{
        if (upIDs.count) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [self getUpInfos:upIDs :_subscriptionArry :sema];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        
    }];
    
    //请求三更新UI
    NSBlockOperation *c = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initData];
            [self.dataTable reloadData];
            _nullDataView.hidden = _subscriptionArry.count != 0;
        });
    }];
    
    //添加依赖与添加到队列中
    [b addDependency:a];
    [c addDependency:b];
    [queue addOperation:a];
    [queue addOperation:b];
    [queue addOperation:c];
}


//获取被订阅者的ID
- (void)getUpIDs: (NSString *)followerID: (NSMutableArray*  ) upIDs :(dispatch_semaphore_t ) semaphore {
    
    AVQuery *query = [AVQuery queryWithClassName:@"subscription"];
    
    
    [query whereKey:@"follower" equalTo:followerID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        for(AVObject *avObject in objects){
            
            NSString* upID = avObject[@"up"];
            
            [upIDs addObject:upID];
            
        }
        
        dispatch_semaphore_signal(semaphore);
        
    }];
    
}

//获取被订阅信息
- (void)getUpInfos: (NSMutableArray *)upIDs :(NSMutableArray *)up_infos:(dispatch_semaphore_t ) semaphore  {
    AVQuery *query = [AVQuery queryWithClassName: @"up_info"];
    dispatch_semaphore_signal(semaphore);
    
    for(NSString* upID in upIDs){
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        @synchronized(self){
            [query whereKey:@"up_id" equalTo:upID];
            //获取query不为空的话
            if (query.countObjects) {
                [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error){
                    NSString* upName = object[@"up_name"];
                    NSString* photoURL = object[@"up_photo"];
                    NSString* upRoomName = object[@"room_name"];
                    NSString* className = NULL;
                    
                    NSArray *tempArr = [upRoomName componentsSeparatedByString:@";;;"];

                    if (tempArr.count) {
                        upRoomName = tempArr[0];
                        className = tempArr[1];
                    }
                    
                    NSDictionary* upInfo = @{@"name": upName,
                            @"imgUrl": photoURL,
                            @"title": upRoomName,
                            @"class": className};
                    [up_infos addObject:upInfo];
                    dispatch_semaphore_signal(semaphore);
                }];
                
            }
            else{
                dispatch_semaphore_signal(semaphore);
            }
        }
        
        
    }
    
    
}


- (void)initData{
    
    for(NSDictionary *dict in _subscriptionArry){
        TCSubscribeFrame *sFrame = [[TCSubscribeFrame alloc]init];
        sFrame.subscription = [TCSubscribeModel subWithDict:dict];
        [_subFrames addObject:sFrame];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TCSubscribeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[TCSubscribeTableViewCell getID]];
    
    
    if (cell == nil){
        cell = [[TCSubscribeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[TCSubscribeTableViewCell getID]];
    }
    
    
    cell.subFrame = _subFrames[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _subFrames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [_subFrames[indexPath.row] cellHeight];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
