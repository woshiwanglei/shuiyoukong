//
//  MyCentreTableViewCell.m
//  Free
//
//  Created by yangcong on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyCentreTableViewCell.h"

@implementation MyCentreTableViewCell

- (void)awakeFromNib
{
    UIView *cellview = [[UIView alloc] initWithFrame:self.bounds];
    
    cellview.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    
    self.selectedBackgroundView = cellview;
    
    [FontSizemodle setfontSizeLableSize:_leftName];
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _leftName.text = _centreModel.cellName;
    
    _cellImages.image=[UIImage imageNamed:_centreModel.cellImages];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
