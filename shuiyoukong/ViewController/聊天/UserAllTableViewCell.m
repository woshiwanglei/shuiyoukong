//
//  UserAllTableViewCell.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "UserAllTableViewCell.h"

#import "CrowdPersonModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FreeSingleton.h"
#import "UserInfoViewController.h"
#import "ActivityTableViewController.h"
@implementation UserAllTableViewCell

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

  
}

-(void)setModel:(Crowdmodel *)model
{
    _model = model;
    
    for (int i = 0; i < model.groupInfoList.count; i ++)
    {
        _view = [[[NSBundle mainBundle] loadNibNamed:@"personnelView"
                                                             owner:self
                                                           options:nil] objectAtIndex:0];
        _view.userImage.layer.masksToBounds = YES;
        _view.userImage.layer.cornerRadius = 5.0;
        if ([UIScreen mainScreen].bounds.size.height < 600)
        {
            _view.frame = CGRectMake(0 + 80*(i%4),10 + 80*(i/4), 80, 80);
        }
        else if([UIScreen mainScreen].bounds.size.height < 700)
        {
            _view.frame = CGRectMake(30 + 80*(i%4), 10 + 80*(i/4), 80, 80);
        }
        else
        {
            _view.frame = CGRectMake(10 + 80*(i%5), 10 + 80*(i/5), 80, 80);
        }
        CrowdPersonModel *personModel = _model.groupInfoList[i];
        
        [_view.userImage sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:personModel.imageUrl sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
         {
            
         }];
        UITapGestureRecognizer *tapView=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
        [_view addGestureRecognizer:tapView];
        
        _view.numberid = personModel.crowdId;
        _view.userName.text = personModel.name;
        
        [self.superview addSubview:_view];
    }
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

-(void)tapChange:(UITapGestureRecognizer *)tap
{
    personnelView *tmpView = (personnelView *)tap.view;

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    vc.friend_id = [NSString stringWithFormat:@"%d",tmpView.numberid];
    vc.friend_name = tmpView.userName.text;
    vc.hidesBottomBarWhenPushed = YES;
    UIViewController *viewcontroller = [self viewController];
    [viewcontroller.navigationController pushViewController:vc animated:YES];

}
+ (float)cellHeight:(Crowdmodel *)model
{

    
    if([UIScreen mainScreen].bounds.size.height < 700)
    {
        return 20 + 80 * ((model.groupInfoList.count - 1)/4) + 80 ;
    }
    else
    {
        return 20 + 80 * ((model.groupInfoList.count - 1)/5) + 80 ;
    }

    
}
@end
