//
//  TCSubscribeFrame.m
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//
#define lblWidth 40
#define LARGE_LBLWIDTH 80
#define lblHeight 10
#define Border 13
#define FONTSIZE 12
#define IMG_WIDTH 180
#define IMG_HEIGHT 110

#define LIST_TO_TOP 52

#define SEPERATOR 7

#import "TCSubscribeFrame.h"
#import "TCSubscribeModel.h"


@implementation TCSubscribeFrame

-(void) setSubscription:(TCSubscribeModel*) subs{
    _subscription = subs;
    
    CGFloat viewX = 2*Border;
    CGFloat viewY = 2*Border;
    _viewFrame = CGRectMake(viewX, viewY, IMG_WIDTH, IMG_HEIGHT);
    
    CGFloat titleX = CGRectGetMaxX(_viewFrame) + 1.5*Border;
    CGFloat titleY = 2.5*Border;
    _titleFrame = CGRectMake(titleX, titleY, LARGE_LBLWIDTH, lblHeight);
    
    CGFloat nameX = CGRectGetMaxX(_viewFrame) + lblWidth;
    CGFloat nameY = LIST_TO_TOP;
    
    CGSize namesize = [self getLabelHeighDynamic:subs.subName];
    _nameFrame = CGRectMake(nameX, nameY, namesize.width, namesize.height);
    
    CGFloat timeX = nameX;
    CGFloat timeY = CGRectGetMaxY(_nameFrame) + SEPERATOR;
    _timeFrame = CGRectMake(timeX, timeY, lblWidth, lblHeight);
    
    CGFloat classX = timeX;
    CGFloat classY = CGRectGetMaxY(_timeFrame) + Border;
    _classFrame = CGRectMake(classX, classY, lblWidth, lblHeight);
    
    
    
    _cellHeight = CGRectGetMaxY(_viewFrame) + Border;
}

#pragma 根据文字长度动态确定label的高度
-(CGSize)getLabelHeighDynamic:(NSString *)word
{
    UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    CGSize size = [word sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil]];
    return size;
}

@end
