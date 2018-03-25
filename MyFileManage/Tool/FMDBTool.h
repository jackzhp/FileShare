//
//  FMDBTool.h
//  MyFileManage
//
//  Created by Viterbi on 2018/3/23.
//  Copyright © 2018年 wangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fileModel.h"

typedef void(^selectedComplete)(NSArray *data);

@interface FMDBTool : NSObject

+(instancetype)shareInstance;

//添加收藏
-(BOOL)addCollectionModel:(fileModel *)model;

//查找收藏数组
-(void)selectedCollectionModel:(selectedComplete)complete;

//删除收藏
-(BOOL)deleteCollectionModel:(fileModel *)model;


@end
