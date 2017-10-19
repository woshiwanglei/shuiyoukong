//
//  InviteUIview.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/5/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "InviteUIview.h"

@implementation InviteUIview

- (IBAction)sert:(UIButton *)sender {
    
    MFMessageComposeViewController *message;
    
    if ([MFMessageComposeViewController canSendText]) {
        message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        message.recipients = @[_phonenumber];
        [message setBody:[NSString stringWithFormat:@"%@%@",UM_SHARE_DESCRIBE, UM_SHARE_URL]];
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_NEED_DELETE_NOTIFICATION];
        [_inviteController presentViewController:message animated:YES completion:^{
            [_backgroudView removeFromSuperview];
        }];
    }
    else
    {
        NSLog(@"设别不支持");
    }

}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    if(result==MessageComposeResultSent)
    {
        NSLog(@"发短信成功");
    }
    else if(result==MessageComposeResultCancelled)
    {
        NSLog(@"发短信取消");
    }
    else if(result==MessageComposeResultFailed)
    {
        NSLog(@"发短信失败");
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
}

@end
