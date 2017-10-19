//
//  GameViewController.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "GameViewController.h"
#import "GamePlay.h"
#import "SelectFriendsModel.h"
#import "GameShareViewController.h"

@interface GameViewController ()

@property(nonatomic,strong)NSMutableArray *btns;
@property (nonatomic,assign) int timenumer;
@property(nonatomic,strong)NSMutableArray *datas;
@property(nonatomic,strong)NSTimer *stopTimer;
@property(nonatomic,strong)NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *timeout;
@property (weak, nonatomic) IBOutlet UILabel *markNumber;
@property (nonatomic,assign) int playct;
@property(nonatomic,strong)UIButton *startBnt;

@property(nonatomic,strong)NSMutableArray *todayarry;
@property(nonatomic,strong)NSMutableArray *tomorrowdayarry;
@property(nonatomic,strong)NSMutableArray *aftertodayarry;
@property(nonatomic,strong)NSMutableArray *rankarry;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    NSLog(@"%ld",(unsigned long)[_playsName count]);
    
}

- (void)dealloc
{
    [_stopTimer invalidate];
    _stopTimer = nil;
    [_timer invalidate];
    _timer = nil;
}

-(void)initView
{
    self.navigationItem.title = @"游戏";
    
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
    _timeout.text = @"20秒";
    _markNumber.text = @"0";
    float w = ([UIScreen mainScreen].bounds.size.width - 45 * 2 - 25 * 2)/3;;
    
    _btns = [NSMutableArray array];
    
    for (int i = 0; i < 9; i++) {
        
        UIButton *bnt = [[UIButton alloc] initWithFrame:CGRectMake(i%3*(25 + w) + 45,150+ i/3*(25 + w), w, w)];
        bnt.backgroundColor = [UIColor whiteColor];
        bnt.layer.masksToBounds = YES;
        bnt.layer.cornerRadius = 3.0;
        bnt.layer.borderWidth = 1.0;
        bnt.layer.borderColor =[[UIColor clearColor] CGColor];
        bnt.tag = 10000 + i;
        [bnt addTarget:self action:@selector(cilck:) forControlEvents:UIControlEventTouchUpInside];
        bnt.userInteractionEnabled = NO;
        [_btns addObject:bnt];
        
        [self.view addSubview:bnt];
        
        if (8 == i) {
            CGRect rect = bnt.frame;
            float y = rect.origin.y + w + 35;
            UIButton *startBnt = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 90, y, 80, 35)];
            [startBnt setImage:[UIImage imageNamed:@"kaishi"] forState:UIControlStateNormal];
            [startBnt addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:startBnt];
            _startBnt = startBnt;
            UIButton *stopBnt = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 + 10 , y, 80, 35)];
            [stopBnt setImage:[UIImage imageNamed:@"jieshu"] forState:UIControlStateNormal];
            [stopBnt addTarget:self action:@selector(stopbtn:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:stopBnt];
            
        }
        
    }
}
//停止运行
-(void)stopbtn:(UIButton *)sender
{
    [_stopTimer invalidate];
    [_timer invalidate];
    _timeout.text = @"20秒";
    for (int i = 0 ; i < _btns.count ; i++) {
        UIButton *bnt = (UIButton *)_btns[i];
        [bnt setTitle:@"" forState:UIControlStateNormal];
        [bnt setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        bnt.userInteractionEnabled = NO;
        bnt.layer.borderColor = [[UIColor clearColor] CGColor];
        bnt.backgroundColor =[UIColor whiteColor];
    }
    
    
}
//打击计数
-(void)cilck:(UIButton *)sender
{
    
    [sender setTitle:@"" forState:UIControlStateNormal];
    
    for (int i = 0; i < _datas.count; i++) {
        GamePlay *play = _datas[i];
        if (play.tag  == sender.tag) {
            play.count++;
            _playct++;
            _markNumber.text = [NSString stringWithFormat:@"%d",_playct];
            sender.layer.borderColor = [[UIColor clearColor] CGColor];
            [sender setImage:[UIImage imageNamed:@"baolie"] forState:UIControlStateNormal];
            sender.userInteractionEnabled = NO;
            sender.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        }
    }
    
}
//开始重玩运行
-(void)start:(UIButton *)sender
{
    //相当于for循环
    [_btns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *bnt = (UIButton*)obj;
        bnt.layer.borderColor = [[UIColor clearColor] CGColor];
        [bnt setTitle:@"" forState:UIControlStateNormal];
    }];
    
    _timenumer = 20;
    _timeout.text = @"20秒";
    _markNumber.text = @"0";
    [sender setImage:[UIImage imageNamed:@"chongwan"] forState:UIControlStateNormal];
    
    _datas = [NSMutableArray array];
    //添加model层
    for (int i = 0; i < [_playsName count]; i++) {
        
        NSString *name = ((SelectFriendsModel *)_playsName[i]).name;
        
        GamePlay *paly = [[GamePlay alloc] init];
        
        paly.name = name;
        paly.count = 0;
        paly.tag = i;
        [_datas addObject:paly];
    }
    if (_stopTimer) {
        [_stopTimer invalidate];
        _stopTimer = nil;
    }
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    //开启线程睡眠一秒执行重玩
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        
        sender.userInteractionEnabled = NO;
        [NSThread sleepForTimeInterval:1];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
            _stopTimer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(stop:) userInfo:@{@"bnt":sender} repeats:YES];
            _timer =  [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(playGame) userInfo:nil repeats:YES];
        });
    });
    
    
    for (int i = 0; i < _datas.count; i++)
    {
        
        GamePlay *play = _datas[i];
        
        play.count = 0;
        
        _playct = 0;
    }
    
}
//每隔0.5秒执行一次
- (void)playGame
{
    //重新刷新界面
    for (int i = 0 ; i < _btns.count ; i++)
    {
        UIButton *bnt = _btns[i];
        
        bnt.layer.borderColor =[[UIColor clearColor] CGColor];
        
        [bnt setTitle:@"" forState:UIControlStateNormal];
        
        [bnt setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        bnt.backgroundColor =[UIColor whiteColor];
        
        bnt.userInteractionEnabled = NO;
        
        bnt.tag = 10000 + i;
        
    }
    //随机数分布
    int appearCount = 0;
    if (_playsName.count == 1)
    {
        appearCount = 1;
    }
    else if(_playsName.count == 2)
    {
        appearCount =arc4random()%2+1;
    }
    else
    {
        
        appearCount = arc4random()%3+1;
        
    }
    int appearLoa = appearCount;
    
    NSMutableArray *appearPlays = [NSMutableArray array];
    //加入随机出现名字
    while (appearCount)
    {
        int count = arc4random()%_datas.count;
        GamePlay *play = _datas[count];
        if (0 == appearPlays.count) {
            [appearPlays addObject:play];
            appearCount--;
            
        }
        
        for (int i = 0; i < appearPlays.count;i++)
        {
            GamePlay *oldPlay = appearPlays[i];
            
            if (play.tag == oldPlay.tag)
            {
                break;
            }
            if (i == appearPlays.count - 1) {
                [appearPlays addObject:play];
                appearCount--;
                
                
            }
        }
    }
    
    
    NSMutableArray *appearLscation = [NSMutableArray array];
    //加入随机出现的位置
    while (appearLoa) {
        
        int count = arc4random()%9;
        if (0 == appearLscation.count) {
            [appearLscation addObject:[NSNumber numberWithInt:count]];
            
            appearLoa--;
        }
        
        for (int i = 0; i < appearLscation.count;i++)
        {
            
            NSNumber *oldNumer = appearLscation[i];
            
            if ([[NSNumber numberWithInt:count] isEqual:oldNumer])
            {
                break;
            }
            if (i == appearLscation.count - 1) {
                [appearLscation addObject:[NSNumber numberWithInt:count]];
                
                appearLoa--;
            }
        }
        
    }
    //循环显示在界面中
    for (int i = 0; i < appearLscation.count; i++)
    {
        
        NSNumber *location = appearLscation[i];
        
        int tag = [location intValue] + 10000;
        
        NSString *name = ((GamePlay*)appearPlays[i]).name;
        UIButton *bnt =  (UIButton*)[self.view viewWithTag:tag];
        
        bnt.layer.borderColor = [[UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1] CGColor];
        bnt.tag = ((GamePlay*)appearPlays[i]).tag;
        [bnt setTitle:name forState:UIControlStateNormal];
        [bnt setTitleColor:[UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1] forState:UIControlStateNormal];
        bnt.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [bnt setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        bnt.userInteractionEnabled = YES;
        bnt.backgroundColor =[UIColor whiteColor];
    }
    
}
//时间到停止运行
- (void)stop:(NSTimer*)timer
{
    
    UIButton *bnt = timer.userInfo[@"bnt"];
    
    _timenumer -- ;
    
    _timeout.text = [NSString stringWithFormat:@"%.2d秒",_timenumer];
    
    if (_timenumer == 0) {
        [_stopTimer invalidate];
        [_timer invalidate];
        [bnt setImage:[UIImage imageNamed:@"chongwan"] forState:UIControlStateNormal];
        
        for (int i = 0 ; i < _btns.count ; i++) {
            UIButton *bnt = (UIButton*)_btns[i];
            [bnt setTitle:@"" forState:UIControlStateNormal];
            [bnt setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            bnt.layer.borderColor = [[UIColor clearColor] CGColor];
            bnt.backgroundColor = [UIColor whiteColor];
            bnt.userInteractionEnabled = NO;
        }
        
        //排名次
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"count" ascending:NO];
        NSArray *sortArray = [_datas sortedArrayUsingDescriptors:@[sortDescriptor]];
    
        GameShareViewController *vc = [[GameShareViewController alloc] initWithNibName:@"GameShareViewController" bundle:nil];
        
        int i;
        for (i = 0; i < sortArray.count; i++) {
            GamePlay *play = sortArray[i];
            switch (i) {
                case 0:
                    vc.name1 = play.name;
                    break;
                case 1:
                    vc.name2 = play.name;
                    break;
                case 2:
                    vc.name3 = play.name;
                    break;
                default:
                    break;
            }
        }
        
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

#pragma mark -其他操作

-(void)changeLable:(UILabel *)lable
{
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:15.0];
    lable.textColor = [UIColor redColor];
    
}
-(void)changBtn:(UIButton*)sender
{
    
    sender.layer.masksToBounds = YES;
    sender.layer.cornerRadius = 3.0;
  
    sender.backgroundColor =[UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sender.titleLabel.font = [UIFont systemFontOfSize:14.0];
}
-(void)beginok:(UIButton *)btn
{
    
    [self start:_startBnt];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        
    }
    if (_stopTimer) {
        [_stopTimer invalidate];
        _stopTimer = nil;
    }
}


@end
