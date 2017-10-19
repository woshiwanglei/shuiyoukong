//
//  NewsGuideViewController.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "NewsGuideViewController.h"
#import "FreeAddressBook.h"
#import "Utils.h"

@interface NewsGuideViewController ()

@property (weak, nonatomic) IBOutlet UIButton *guideBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation NewsGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView
{
    _guideBtn.layer.borderColor = [[UIColor clearColor] CGColor];
    _guideBtn.layer.masksToBounds = YES;
    _guideBtn.layer.cornerRadius = 5;
    _guideBtn.backgroundColor  = FREE_BACKGOURND_COLOR;
    _textView.scrollEnabled = NO;
    _textView.userInteractionEnabled = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    //初始化右边上角
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(passUpload:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)guiteBtn:(id)sender {
    _guideBtn.userInteractionEnabled = NO;
    [self performSegueWithIdentifier:@"registerSuccessd" sender:self];
}

- (void)passUpload:(id)sender
{
    [self performSegueWithIdentifier:@"pass" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
