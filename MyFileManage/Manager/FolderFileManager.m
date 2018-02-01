//
//  FolderFileManager.m
//  MyFileManage
//
//  Created by Viterbi on 2018/1/18.
//  Copyright © 2018年 wangchao. All rights reserved.
//

#import "FolderFileManager.h"
#import "NSFileManager+GreatReaderAdditions.h"

static FolderFileManager *manage = nil;

@implementation FolderFileManager

+(instancetype)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[FolderFileManager alloc] init];
    });
    return manage;
}

- (instancetype)init
{
    self = [super init];
    if (self) {}
    return self;
}

-(NSString *)getCachePath{
    return [NSFileManager grt_cachePath];
}

-(NSString *)getDocumentPath{
    return [NSFileManager grt_documentsPath];
}

-(NSString *)getUploadPath{
    return [NSFileManager grt_cacheUploadPath];
}

-(void)deleteFileInPath:(NSString *)path{
    NSFileManager *manage = [NSFileManager defaultManager];
    [manage removeItemAtPath:path error:nil];
}

-(void)createTextWithPath:(NSString *)path{
    NSFileManager *manag = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (![manag fileExistsAtPath:path isDirectory:&isDir]) {
        [manag createFileAtPath:path contents:nil attributes:nil];
    }
}

-(void )createDirWithPath:(NSString *)path{
    NSFileManager *manage = [NSFileManager defaultManager];
    if (![manage fileExistsAtPath:path]) {
        [manage createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
-(void)createIsBeHiddenFolder{
    NSString *hiddenPath = [[self getUploadPath] stringByAppendingPathComponent:HiddenFolderName];
    [self createDirWithPath:hiddenPath];
}

-(NSArray *)getAllFileModelInDic:(NSString *)dir{
    
    NSArray *fileModelArray = [[[self getAllFilesName:dir] firstleap_filter:^BOOL(NSString *files) {
        return ![files isEqualToString:@".DS_Store"];
    }] firstleap_map:^fileModel *(NSString *files) {
        return [[fileModel alloc] initWithFilePath:[NSString stringWithFormat:@"%@/%@",dir,files]];
    }];
    return fileModelArray;
}
-(NSArray *)getAllFilesName:(NSString *)dir{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    return files;
}


@end
