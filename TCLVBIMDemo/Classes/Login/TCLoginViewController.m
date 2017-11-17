//
//  TCLoginViewController.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLoginViewController.h"
#import "TCLoginModel.h"
#import "ImSDK/TIMComm.h"
#import "TLSSDK/TLSHelper.h"
#import "TCUtil.h"
#import "TCLoginParam.h"
#import "TCRegisterViewController.h"
#import "UIView+CustomAutoLayout.h"
#import "HUDHelper.h"
#import "TLSSDK/TLSHelper.h"
#import "TLSSDK/TLSErrInfo.h"
#import "TCRegisterViewController.h"
#import "TCLoginModel.h"
#import "TCLoginModel.h"
#import "TCUserInfoModel.h"


@interface TCLoginViewController () <TLSRefreshTicketListener, TCTLSLoginListener>
{
    TCLoginParam *_loginParam;

    UITextField    *_accountTextField;  // 用户名/手机号
    UITextField    *_pwdTextField;      // 密码/验证码
    UIButton       *_loginBtn;          // 登录
    UIButton       *_regBtn;            // 注册
    
    UIView         *_lineView1;
    UIView         *_lineView2;
    
    BOOL           _isSMSLoginType;     // YES 表示手机号登录，NO 表示用户名登录
}
@end

@implementation TCLoginViewController

- (void)dealloc {
    if (_loginParam) {
        // 持久化param
        [_loginParam saveToLocal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 先判断是否自动登录
    BOOL isAutoLogin = [TCLoginModel isAutoLogin];
    if (isAutoLogin) {
        _loginParam = [TCLoginParam loadFromLocal];
    }
    else {
        _loginParam = [[TCLoginParam alloc] init];
    }
    
    // 登录前需要先初始化IMSDK
    [[TCLoginModel sharedInstance] initIMSDK];

    if (isAutoLogin && [_loginParam isValid]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self autoLogin];
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pullLoginUI];
        });
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - login

- (void)autoLogin {
    if ([_loginParam isExpired]) {
        // 刷新票据
        [[TLSHelper getInstance] TLSRefreshTicket:_loginParam.identifier andTLSRefreshTicketListener:self];
    }
    else {
        [self loginIMSDK];
    }
}

- (void)pullLoginUI {
    [self setupUI];
}

- (void)loginWith:(TLSUserInfo *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (userInfo) {
            _loginParam.identifier = userInfo.identifier;
            _loginParam.userSig = [[TLSHelper getInstance] getTLSUserSig:userInfo.identifier];
            _loginParam.tokenTime = (NSInteger) [[NSDate date] timeIntervalSince1970];
            
            [self loginIMSDK];
        }
    });
}

- (void)loginIMSDK {
    __weak TCLoginViewController *weakSelf = self;
    
    [[TCLoginModel sharedInstance] login:_loginParam succ:^{
        // 持久化param
        [_loginParam saveToLocal];
        // 进入主界面
        [[AppDelegate sharedAppDelegate] enterMainUI];
        
    } fail:^(int code, NSString *msg) {
        [weakSelf pullLoginUI];
    }];
}

#pragma mark - delegate<TCTLSLoginListener>

- (void)TLSUILoginOK:(TLSUserInfo *)userinfo {
    [self loginWith:userinfo];
}

#pragma mark - 刷新票据代理

- (void)OnRefreshTicketSuccess:(TLSUserInfo *)userInfo {
    NSLog(@"OnRefreshTicketSuccess");
    [self loginWith:userInfo];
}

- (void)OnRefreshTicketFail:(TLSErrInfo *)errInfo {
    NSLog(@"OnRefreshTicketFail");
    _loginParam.tokenTime = 0;
    [self pullLoginUI];
}

- (void)OnRefreshTicketTimeout:(TLSErrInfo *)errInfo {
    NSLog(@"OnRefreshTicketTimeout");
    [self OnRefreshTicketFail:errInfo];
}

// --------------------------------------------

- (void)setupUI {
    [super viewDidLoad];

    _isSMSLoginType = NO;
    [self initUI];
    [self initState];
    
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickScreen)];
    [self.view addGestureRecognizer:tag];
}

- (void)initUI {
    UIImage *image = [UIImage imageNamed:@"loginBG.jpg"];
    self.view.layer.contents = (id)image.CGImage;
 
    _accountTextField = [[UITextField alloc] init];
    _accountTextField.font = [UIFont systemFontOfSize:14];
    _accountTextField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _accountTextField.returnKeyType = UIReturnKeyDone;
    _accountTextField.delegate = self;

    _pwdTextField = [[UITextField alloc] init];
    _pwdTextField.font = [UIFont systemFontOfSize:14];
    _pwdTextField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _pwdTextField.returnKeyType = UIReturnKeyDone;
    _pwdTextField.delegate = self;
    
    _lineView1 = [[UIView alloc] init];
    [_lineView1 setBackgroundColor:[UIColor whiteColor]];
    
    _lineView2 = [[UIView alloc] init];
    [_lineView2 setBackgroundColor:[UIColor whiteColor]];
    
    _loginBtn = [[UIButton alloc] init];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateSelected];
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    _regBtn = [[UIButton alloc] init];
    _regBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_regBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_regBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_regBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_regBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateSelected];
    [_regBtn addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    
    

    
    
    [self.view addSubview:_accountTextField];
    [self.view addSubview:_lineView1];
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_lineView2];
    [self.view addSubview:_loginBtn];
    [self.view addSubview:_regBtn];
    
    
    [self relayout];
}

- (void)relayout {
    CGFloat screen_width = self.view.bounds.size.width;
    
    [_accountTextField sizeWith:CGSizeMake(screen_width - 50, 33)];
    [_accountTextField alignParentTopWithMargin:180];
    [_accountTextField alignParentLeftWithMargin:25];
    
    [_lineView1 sizeWith:CGSizeMake(screen_width - 44, 1)];
    [_lineView1 layoutBelow:_accountTextField margin:6];
    [_lineView1 alignParentLeftWithMargin:22];
    
    if (_isSMSLoginType) {
        [_pwdTextField sizeWith:CGSizeMake(200, 33)];
    } else {
        [_pwdTextField sizeWith:CGSizeMake(screen_width - 50, 33)];
    }
    [_pwdTextField layoutBelow:_lineView1 margin: 10];
    [_pwdTextField layoutBelow:_lineView1 margin:6];
    [_pwdTextField alignParentLeftWithMargin:25];
    
    [_lineView2 sizeWith:CGSizeMake(screen_width - 44, 1)];
    [_lineView2 layoutBelow:_pwdTextField margin:6];
    [_lineView2 alignParentLeftWithMargin:22];
    
    [_loginBtn sizeWith:CGSizeMake(screen_width - 44, 35)];
    [_loginBtn layoutBelow:_lineView2 margin:36];
    [_loginBtn alignParentLeftWithMargin:22];
    
    [_regBtn sizeWith:CGSizeMake(screen_width - 44, 35)];
    [_regBtn layoutBelow:_loginBtn margin:18];
    [_regBtn alignParentLeftWithMargin:22];


    [_accountTextField setPlaceholder:@"输入用户名"];
    [_accountTextField setText:@""];
    _accountTextField.keyboardType = UIKeyboardTypeDefault;
    [_pwdTextField setPlaceholder:@"输入密码"];
    [_pwdTextField setText:@""];

    _pwdTextField.secureTextEntry = YES;
    
    _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
    _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];

}

- (void)clickScreen {
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}

- (void)reg:(UIButton *)button {
    TCRegisterViewController *regViewController = [[TCRegisterViewController alloc] init];
    regViewController.loginListener = self;
    [self.navigationController pushViewController:regViewController animated:YES];
}

- (void)switchLoginWay:(UIButton *)button {
    _isSMSLoginType = !_isSMSLoginType;
    [self clickScreen];
    [self relayout];
}

- (void)login:(UIButton *)button {
    NSString *userName = _accountTextField.text;
    if (userName == nil || [userName length] == 0) {
        [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能为空" cancel:@"确定"];
        return;
    }
    NSString *pwd = _pwdTextField.text;
    if (pwd == nil || [pwd length] == 0) {
        [HUDHelper alertTitle:@"密码错误" message:@"密码不能为空" cancel:@"确定"];
        return;
    }
    
    // 用户名密码登录
    __weak typeof(self) weakSelf = self;
    [[HUDHelper sharedInstance] syncLoading];
    int ret = [[TCTLSPlatform sharedInstance] pwdLogin:userName andPassword:pwd succ:^(TLSUserInfo *userInfo) {
        [[HUDHelper sharedInstance] syncStopLoading];
        id listener = weakSelf;
        [listener TLSUILoginOK:userInfo];
        
    } fail:^(TLSErrInfo *errInfo) {
        [[HUDHelper sharedInstance] syncStopLoading];
        [HUDHelper alertTitle:errInfo.sErrorTitle message:errInfo.sErrorMsg cancel:@"确定"];
        NSLog(@"%s %d %@", __func__, errInfo.dwErrorCode, errInfo.sExtraMsg);
    }];
    if (ret != 0) {
        [[HUDHelper sharedInstance] syncStopLoading];
        [HUDHelper alertTitle:@"内部错误" message:[NSString stringWithFormat:@"%d", ret] cancel:@"确定"];
    }
}

- (void)initState {
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
