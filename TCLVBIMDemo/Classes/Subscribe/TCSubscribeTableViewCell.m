//
//  TCSubscribeTableViewCell.m
//  TCLVBIMDemo
//
//  Created by Ricardo on 2017/11/19.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "TCSubscribeTableViewCell.h"
#import "TCSubscribeFrame.h"
#import "TCSubscribeModel.h"

#define lblWidth 50
#define lblHeight 10

#define Border 13
#define FONTSIZE 13
#define LARGE_FONTSIZE 15
#define IMG_WIDTH 180
#define LIST_TO_TOP 58

@implementation TCSubscribeTableViewCell{
    UIImageView* subView;
    UILabel* subTitle;
    UILabel* subName;
    UILabel* subWatch;
    UILabel* subClass;
    
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setData];
        [self setBaseItem];
        [self setSubFrame:_subFrame];
        
    }
    
    return self;
    
}

-(void)setSubFrame:(TCSubscribeFrame *)subframe{
    _subFrame = subframe;
    
    [self settingSubData];
    [self settingSubFrame];
    
}

-(void)settingSubData{
    TCSubscribeModel* sub = _subFrame.subscription;
    
    subView = [[UIImageView alloc]init];
    subView.image = [UIImage imageNamed:@"subView.png"];
    [self.contentView addSubview:subView];
    
    subTitle.text = sub.subTitle;
    subTitle.font = [UIFont systemFontOfSize:LARGE_FONTSIZE];
    
    subName.text = sub.subName;
    subName.font = [UIFont systemFontOfSize:FONTSIZE];
    subName.textColor = [UIColor colorWithRed:125/255.f green:125/255.f blue:125/255.f alpha:1.0];
    
    subWatch.text = [NSString stringWithFormat:@"%ld",(long)sub.subTimes];
    subWatch.font = [UIFont systemFontOfSize:FONTSIZE];
    subWatch.textColor = [UIColor colorWithRed:125/255.f green:125/255.f blue:125/255.f alpha:1.0];
    
    subClass.text = sub.subClass;
    subClass.font = [UIFont systemFontOfSize:FONTSIZE];
    subClass.textColor = [UIColor colorWithRed:125/255.f green:125/255.f blue:125/255.f alpha:1.0];
}

-(void)settingSubFrame{
    subView.frame = _subFrame.viewFrame;
    subTitle.frame = _subFrame.titleFrame;
    subName.frame = _subFrame.nameFrame;
    subWatch.frame = _subFrame.timeFrame;
    subClass.frame = _subFrame.classFrame;
}

-(void)setData{
    subTitle = [[UILabel alloc]init];
    [self.contentView addSubview:subTitle];
    
    subName = [[UILabel alloc]init];
    [self.contentView addSubview:subName];
    
    subWatch = [[UILabel alloc]init];
    [self.contentView addSubview:subWatch];
    
    subClass = [[UILabel alloc]init];
    [self.contentView addSubview:subClass];
    
}


-(void)setBaseItem{
    CGFloat nameX = IMG_WIDTH + 2.3*Border;
    CGFloat nameY = LIST_TO_TOP;
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, lblWidth, lblHeight)];
    _name.font = [UIFont systemFontOfSize:FONTSIZE];
    _name.textColor = [UIColor colorWithRed:125/255.f green:125/255.f blue:125/255.f alpha:1.0];
    
    [self.contentView addSubview:_name];
    _name.text = @"主播：";
    
    
    CGFloat watchX = nameX;
    CGFloat wathcY = CGRectGetMaxY(_name.frame) + Border;
    _watch = [[UILabel alloc] initWithFrame:CGRectMake(watchX, wathcY, lblWidth, lblHeight)];
    [self.contentView addSubview:_watch];
    _watch.font = [UIFont systemFontOfSize:FONTSIZE];
    _watch.textColor = [UIColor colorWithRed:125/255.f green:125/255.f blue:125/255.f alpha:1.0];
    _watch.text = @"观看：";
    
    CGFloat classX = watchX;
    CGFloat classY = CGRectGetMaxY(_watch.frame) + Border;
    _sclass = [[UILabel alloc] initWithFrame:CGRectMake(classX, classY, lblWidth, lblHeight)];
    [self.contentView addSubview:_sclass];
    _sclass.font = [UIFont systemFontOfSize:FONTSIZE];
    _sclass.textColor = [UIColor colorWithRed:125/255.f green:125/255.f blue:125/255.f alpha:1.0];
    _sclass.text = @"分类：";
}

+(NSString *)getID{
    return @"cell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
