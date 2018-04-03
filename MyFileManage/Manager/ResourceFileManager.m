//
//  ResourceFileManager.m
//  MyFileManage
//
//  Created by Viterbi on 2018/1/18.
//  Copyright © 2018年 wangchao. All rights reserved.
//

#import "ResourceFileManager.h"
#import "FolderFileManager.h"

static ResourceFileManager *manager = nil;

@implementation ResourceFileManager

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ResourceFileManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
        self.musicEntities = [MusicEntity arrayOfEntitiesFromArray:[self getAllUploadMusicDic]].mutableCopy;
        //PDF data
        self.documentStore = [[PDFDocumentStore alloc] init];
    }
    return self;
}

/**
 构造 音乐列表字典
 
 @return array
 */
- (NSArray *) getAllUploadMusicDic
{
    NSArray *fileModelArray =  [[[[self getAllFilesName] firstleap_filter:^BOOL(NSString *obj) {
        return [obj hasSuffix:@"mp3"];
    }] firstleap_map:^NSDictionary * ( NSString *fileString) {
        
        NSString *fileName = [fileString stringByDeletingPathExtension];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",FileUploadSavePath,fileString];
        NSDictionary *musicDic = @{@"name":fileName,
                                   @"fileName":fileName,
                                   @"fullPath":fullPath
                                   };
        return musicDic;
    }] copy];
    
    return fileModelArray;
}

/**
 获取所有file model
 
 @return array
 */
- (NSArray *) getAllUploadAllFileModels
{
    NSArray *fileModelArray = [[[self getAllFilesName] firstleap_filter:^BOOL(NSString *files) {
        return ![files isEqualToString:@".DS_Store"] && ![files isEqualToString:RecycleFolderName];
    }] firstleap_map:^fileModel *(NSString *files) {
        return [[fileModel alloc] initWithFilePath:[NSString stringWithFormat:@"%@/%@",FileUploadSavePath,files]];
    }];
    
    NSArray *systemFolder = [fileModelArray firstleap_filter:^BOOL(fileModel *model) {
        return model.isSystemFolder;
    }];
    NSArray *notSystemFolder = [fileModelArray firstleap_filter:^BOOL(fileModel *model) {
        return !model.isSystemFolder;
    }];
    
   notSystemFolder = [notSystemFolder sortedArrayUsingComparator:^NSComparisonResult(fileModel * obj1, fileModel * obj2) {
       if (obj1.isFolder < obj2.isFolder) {
           return NSOrderedDescending;
       }
       return NSOrderedAscending;
    }];
    
    NSMutableArray *sortArry = [NSMutableArray arrayWithCapacity:0];
    [sortArry addObjectsFromArray:systemFolder];
    [sortArry addObjectsFromArray:notSystemFolder];
    return [sortArry copy];
}

- (NSArray *)getAllBeHiddenFolderFileModels{
    NSString *hiddenPath = [[FolderFileManager shareInstance] getBeHiddenFolderPath];
    return [[FolderFileManager shareInstance] getAllFileModelInDic:hiddenPath];
}

-(NSArray *) getAllRecycelFolderFileModels{
    NSString *recyclePath = [[FolderFileManager shareInstance] getCycleFolderPath];
    return [[FolderFileManager shareInstance] getAllFileModelInDic:recyclePath];
}
/**
 获取 MyFileManageUpload 文件夹下的所有文件名字
 
 @return 文件数组
 */
-(NSArray *)getAllFilesName{
    
    NSString *uploadDirPath = [[FolderFileManager shareInstance] getDocumentPath];
    uploadDirPath = [NSString stringWithFormat:@"%@/MyFileManageUpload",uploadDirPath];
    NSMutableArray *files = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:uploadDirPath error:nil] mutableCopy];
    if (![[DataBaseTool shareInstance] getShowHiddenFolderHidden]) {
        if ([files containsObject:HiddenFolderName]) {
            [files removeObject:HiddenFolderName];
        }
    }
    return [files copy];
}

-(NSArray *)getAllHomePageFolder{
  
  NSMutableArray *foldeArray = [[NSMutableArray alloc] initWithCapacity:0];
  NSArray *foldeiWithoutHome = [[self getAllUploadAllFileModels] firstleap_filter:^BOOL(fileModel *model) {
    return model.isFolder == YES;
  }];
  fileModel *model = [[fileModel alloc] initWithFilePath:[[FolderFileManager shareInstance] getUploadPath]];
  model.fileName = @"首页";
  [foldeArray addObject:model];
  [foldeArray addObjectsFromArray:foldeiWithoutHome];
  
  return foldeArray.copy;
}

@end
