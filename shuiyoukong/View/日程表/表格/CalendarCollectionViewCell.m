//
//  CalendarCollectionViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CalendarCollectionViewCell.h"
#import "FreeSingleton.h"
#import "AppDelegate.h"
#import "FreeSQLite.h"
#import "SharePictureNoFriendsView.h"

@interface CalendarCollectionViewCell()
@property (nonatomic, strong)NSString *remark;
@property (nonatomic, strong)UIView *backView;
@end

@implementation CalendarCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _label_name.textColor = [UIColor colorWithRed:119/255.0 green:53/255.0 blue:25/255.0 alpha:1.0];
    self.layer.cornerRadius = 10.f;
    self.backgroundColor = [UIColor whiteColor];
    
    [self.btn_free setTitleColor:FREE_BACKGOURND_COLOR forState:UIControlStateNormal];
    _btn_free.userInteractionEnabled = NO;
    
}

- (void)setModel:(SubCalendarViewModel *)model
{
    _model = model;
    
//    _ifChange = model.isTurnOn;
    
    switch (model.typeNum) {
        case NOTHING:
        {
            _btn_free.hidden = NO;
            [_btn_free setImage:[UIImage imageNamed:@"gou"] forState:UIControlStateNormal];
        }
            break;
        case NEWFRIEND:
        {
            _btn_free.hidden = NO;
            [_btn_free setImage:[UIImage imageNamed:@"friend_icon"] forState:UIControlStateNormal];
        }
        default:
        {
            _btn_free.hidden = NO;
            [_btn_free setImage:[UIImage imageNamed:@"friend_icon"] forState:UIControlStateNormal];
        }
            break;
    }
    
    [self changeBackGroundColor:model];
    [self checkIsTimeLabel];
    
    if (model.isFristGrid == NO) {
        if([self isPostTime:[self changeString2Date:model.freeTime] freeStartTime:(model.timeTag + 1)* 6])
        {
            self.backgroundColor = [UIColor lightGrayColor];
            self.userInteractionEnabled = NO;
            self.btn_free.hidden = YES;
            self.layer.borderColor = [[UIColor clearColor] CGColor];
            self.layer.borderWidth = .8f;
        }
        else
        {
            self.userInteractionEnabled = YES;
        }
        
        UITapGestureRecognizer* tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchStatus:)];
        [self addGestureRecognizer:tapGes2];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
}

- (void)switchStatus:(UITapGestureRecognizer *)gesture
{
    
    NSArray *array = [AppDelegate getMainWindow].subviews;
    
    if ([array count] > 1) {
        UIView *view = array[1];
        if (view.tag == SETTINGVIEW) {
            return;
        }
    }
    NSArray * arrWeek = [NSArray arrayWithObjects:@"6",@"12",@"18", nil];
    
    if (_model.isTurnOn == NO) {
        NSString *strRemark = [[FreeSQLite sharedInstance] selectFreeSQLiteRemarkList:_model.freeTime freeTimeStart:[arrWeek objectAtIndex:_model.timeTag - 1]];
        if (strRemark) {
            _remark = strRemark;
            [self sendFreeDate];
        }
        else
        {
            [self writeMyCondition];
        }
        return;
    }
    
    [_btn_free setImage:[UIImage imageNamed:@"gou"] forState:UIControlStateNormal];
    NSMutableArray *data = [NSMutableArray array];
    
    [data addObject:_model.freeTime];
    
    [data addObject:[arrWeek objectAtIndex:_model.timeTag - 1]];
    [data addObject:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_GOTO_COUPLE_LIST object:data];//触发刷新通知
}


- (void)changeBackGroundColor:(SubCalendarViewModel *)model
{
    self.backgroundColor = [UIColor whiteColor];
    if (model.isTurnOn == YES) {
        self.layer.borderColor =  [[UIColor colorWithRed:32/255.0 green:186/255.0 blue:148/255.0 alpha:.7] CGColor];
        self.layer.borderWidth = .8f;
    }
    else
    {
        if (model.typeNum == FRIENDSHERE) {
            _btn_free.hidden = NO;
        }
        else
        {
            _btn_free.hidden = YES;
        }
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.layer.borderWidth = .8f;
    }
}

- (void)checkIsTimeLabel
{
    _label_name.hidden = YES;
    if (_model.isFristGrid == YES) {
        _label_name.hidden = NO;
    }
    
    _label_name.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    
    if (_model.timeTitle != nil) {
        if (_model.isToday == YES) {
            _label_name.textColor = [UIColor redColor];
        }
        _label_name.text = _model.timeTitle;
        return;
    }
    
    if (_model.timeTag < 1) {
        _label_name.hidden = YES;
        return;
    }
    
    NSArray * arrWeek = [NSArray arrayWithObjects:@"上午",@"下午",@"晚上", nil];
    _label_name.text = [arrWeek objectAtIndex:_model.timeTag - 1];
}

//弹出一句话
- (void)writeMyCondition
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_backView setBackgroundColor:[UIColor colorWithRed:(0/255.0)
                                                      green:(0/255.0)  blue:(0/255.0) alpha:.4]];
        _backView.tag = SETTINGVIEW;
    }
    
    if (![_backView superview])
    {
        [[AppDelegate getMainWindow] addSubview:_backView];
        
        SharePictureNoFriendsView* shareView =
        [[[NSBundle mainBundle] loadNibNamed:@"SharePictureNoFriendsView"
                                       owner:self
                                     options:nil] objectAtIndex:0];
        shareView.translatesAutoresizingMaskIntoConstraints = NO;
        shareView.text_input.placeholder = @"吃饭、电影、游戏，还是什么？";
        
        NSArray * arrayStartTime = [NSArray arrayWithObjects:@"上午",@"下午",@"晚上", nil];
        NSInteger index = _model.timeTag - 1;
        
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *inputDate = [dateformatter dateFromString:_model.freeTime];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unitFlags = NSWeekdayCalendarUnit;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:inputDate];
        NSInteger week = [comps weekday];
        NSArray * arrWeek = [NSArray arrayWithObjects:@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六", nil];
        
        shareView.myTextView.text = [NSString stringWithFormat:@"%@%@, 你想？", [arrWeek objectAtIndex:week - 1], [arrayStartTime objectAtIndex:index]];
        
        shareView.text_input.text = nil;
        [shareView.btn_cancel setTitle:@"还没想好" forState:UIControlStateNormal];
        [shareView.btn_commit setTitle:@"确定" forState:UIControlStateNormal];
        
        [shareView.btn_commit addTarget:self action:@selector(commitWrite:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareView.btn_cancel addTarget:self action:@selector(cancelWrite:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareView.text_input becomeFirstResponder];
        
        [_backView addSubview:shareView];
        
        NSDictionary *metrics = @{
                                  @"height" : @(([UIScreen mainScreen].bounds.size.height - 175)/2 - 100),
                                  @"width" : @([UIScreen mainScreen].bounds.size.width)
                                  };
        NSDictionary *views = NSDictionaryOfVariableBindings(shareView);
        
        [_backView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"H:|-30-[shareView]-30-|"
          options:0
          metrics:metrics
          views:views]];
        [_backView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:
                                         @"V:|-height-[shareView(175)]"
                                         options:0
                                         metrics:metrics
                                         views:views]];
    }
}

//取消
- (void)cancelWrite:(UIButton *)sender
{
    NSArray *array = [_backView subviews];
    for (UIView *view in array) {
        [view removeFromSuperview];
    }
    [_backView removeFromSuperview];
    [self sendFreeDate];
}

//发送
- (void)commitWrite:(UIButton *)sender
{
    SharePictureNoFriendsView* shareView = (SharePictureNoFriendsView *) sender.superview;
    _remark = shareView.text_input.text;
    NSArray *array = [_backView subviews];
    for (UIView *view in array) {
        [view removeFromSuperview];
    }
    [_backView removeFromSuperview];
    [self sendFreeDate];
}

//发送空闲时间
- (void)sendFreeDate
{
    if (_model.timeTag == 0 || _model.freeTime == nil) {
        return;
    }
    
    self.backgroundColor = [UIColor whiteColor];
    _model.isTurnOn = YES;
    self.layer.borderColor =  [[UIColor colorWithRed:32/255.0 green:186/255.0 blue:148/255.0 alpha:.7] CGColor];
    self.layer.borderWidth = .8f;
    _btn_free.hidden = NO;
    [_btn_free setImage:[UIImage imageNamed:@"gou"] forState:UIControlStateNormal];
    
    
    NSArray * arrWeek = [NSArray arrayWithObjects:@"6",@"12",@"18", nil];
    
    self.userInteractionEnabled = NO;
    
    __weak SubCalendarViewModel *model = _model;
    __weak CalendarCollectionViewCell *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger ret = [[FreeSingleton sharedInstance] addCalendarOnCompletion:_model.freeTime freeTimeStart:[arrWeek objectAtIndex:_model.timeTag - 1] City:[FreeSingleton sharedInstance].city remark:_remark position:nil block:^(NSUInteger retcode, id data) {
        [KVNProgress dismiss];
        if (retcode == RET_SERVER_SUCC) {
            
            if (model == nil) {
                return;
            }
            
            weakSelf.backgroundColor = [UIColor whiteColor];
            model.isTurnOn = YES;
            weakSelf.layer.borderColor =  [[UIColor colorWithRed:32/255.0 green:186/255.0 blue:148/255.0 alpha:.7] CGColor];
            weakSelf.layer.borderWidth = .8f;
            weakSelf.btn_free.hidden = NO;
            [weakSelf.btn_free setImage:[UIImage imageNamed:@"gou"] forState:UIControlStateNormal];
            [weakSelf sendChangeState:model];
            
            id array = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
            
            if (![array isKindOfClass:[NSNull class]] && array != nil && [array count]!= 0) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_COUPLE_FRIEND object:array userInfo:@{@"nowCoupleSucc":@"YES"}];
            }
        }
        else
        {
            model.typeNum = NOTHING;
//            _model.isTurnOn = NO;
//            [weakSelf changeBackGroundColor:model];
        }
        weakSelf.userInteractionEnabled = YES;
    }];
    
    if (ret != RET_OK)
    {
        [KVNProgress dismiss];
        weakSelf.userInteractionEnabled = YES;
        NSLog(@"sendFreeDate error is :%@", zcErrMsg(ret));
    }
    
}


- (NSDate *)changeString2Date:(NSString *)str
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *inputDate = [dateformatter dateFromString:str];
    return inputDate;
}


//时间是否过期
- (BOOL)isPostTime:(NSDate *)aDate freeStartTime:(NSInteger)freeStartTime
{
    if (aDate == nil) return NO;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:[NSDate date]];
    NSInteger dayNow = [components day];
    NSInteger hourNow = [components hour];
    NSInteger monthNow = [components month];
    NSInteger yearNow = [components year];
    
    components = [cal components:(NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:aDate];
    NSInteger dayDate = [components day];
    NSInteger monthDate = [components month];
    NSInteger yearDate = [components year];
    
    if(dayNow == dayDate && monthNow == monthDate && yearNow == yearDate && freeStartTime < hourNow)
        return YES;
    
    return NO;
}

//切换状态
- (void)sendChangeState:(SubCalendarViewModel *)model
{
    NSArray * arrayStartTime = [NSArray arrayWithObjects:@"6",@"12",@"18", nil];
    NSString *freeDate = model.freeTime;
    NSString *freeTimeStart = [arrayStartTime objectAtIndex:model.timeTag - 1];
    NSString *Id = [[FreeSingleton sharedInstance] getAccountId];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:freeDate, @"freeDate", freeTimeStart, @"freeTimeStart", Id, @"id",nil];
    
    NSString *strType;
    if (model.isTurnOn == YES) {
        strType = ADDMODEL;
    }
    else
    {
        strType = DELETEMODEL;
    }
    //通知状态变化
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_STATE_CHANGE object:strType userInfo:dic];
}


@end