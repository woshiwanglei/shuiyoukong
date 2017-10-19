//
//  MyCentreTableViewCell.h
//  Free
//
//  Created by yangcong on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCentreModel.h"
#import "FontSizemodle.h"
@interface MyCentreTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftName;

@property (weak, nonatomic) IBOutlet UIImageView *cellImages;

@property (strong, nonatomic) MyCentreModel *centreModel;

@end
