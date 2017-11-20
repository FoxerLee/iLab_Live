//
//  TCSubscribeFrame.h
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TCSubscribeModel;
@interface TCSubscribeFrame : NSObject

@property (nonatomic, assign, readonly) CGRect viewFrame;
@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect nameFrame;
@property (nonatomic, assign, readonly) CGRect timeFrame;
@property (nonatomic, assign, readonly) CGRect classFrame;

@property(nonatomic, assign, readonly) CGFloat cellHeight;

@property (nonatomic, strong) TCSubscribeModel* subscription;

@end
