//
//  CrowdPersonModel.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CrowdPersonModel.h"
#import "FreeSQLite.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
@implementation CrowdPersonModel

- (void)initWithDic:(NSDictionary*)dictionary
{
    _imageUrl = dictionary[@"headImg"];
    _crowdId = [dictionary[@"accountId"] intValue];
    NSString *accountId = [NSString stringWithFormat:@"%@", dictionary[@"accountId"]];
    
    _name = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:accountId];
    
    if (_name == nil) {
        _name = dictionary[@"name"];
    }
}
//- (void)showImage:(NSString *)img_url
//{
//    [_imageUrl sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
//     {
//         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
//     }];
//}
@end
