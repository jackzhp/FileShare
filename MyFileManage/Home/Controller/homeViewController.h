//
//  homeViewController.h
//  MyFileManage
//
//  Created by 掌上先机 on 2017/5/24.
//  Copyright © 2017年 wangchao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fileModel.h"

@interface homeViewController : UIViewController

@property(nonatomic,assign)BOOL isPushSelf;
@property(nonatomic,strong)fileModel *model;

@end
