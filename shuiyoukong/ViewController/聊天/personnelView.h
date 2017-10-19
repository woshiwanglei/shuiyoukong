//
//  personnelView.h
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Crowdmodel.h"
@interface personnelView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (nonatomic,assign)int numberid;

@property (nonatomic,strong) Crowdmodel *cmodel;

@end
