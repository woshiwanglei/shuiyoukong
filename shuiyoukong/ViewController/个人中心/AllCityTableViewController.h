//
//  AllCityTableViewController.h
//  Free
//
//  Created by yangcong on 15/5/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllCityTableViewController : UITableViewController<UISearchBarDelegate,UISearchDisplayDelegate>
@property(nonatomic, assign) BOOL isSearch;//是否是search状态
@property(nonatomic, assign) BOOL isColor;//是否是选中状态
@end
