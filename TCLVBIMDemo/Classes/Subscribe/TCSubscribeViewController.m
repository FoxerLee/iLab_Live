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

@interface TCSubscribeViewController (){
    NSMutableArray *_subFrames;
}

@end

@implementation TCSubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    _subFrames = [NSMutableArray array];
    
    _subscriptionArry = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil]];
    
    [self initData];
    
    
    _dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 600) style:UITableViewStylePlain];
    
    
    _dataTable.delegate = self;
    _dataTable.dataSource = self;
    
    _dataTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_dataTable];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
