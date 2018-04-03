//
//  OpenImagesPageViewController.m
//  MyFileManage
//
//  Created by Viterbi on 2018/4/3.
//  Copyright © 2018年 wangchao. All rights reserved.
//

#import "OpenImagesPageViewController.h"
#import "OpenImageViewController.h"
#import "FolderFileManager.h"
#import "fileModel.h"

@interface OpenImagesPageViewController ()
<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *picModelArray;

@end

@implementation OpenImagesPageViewController

-(NSArray *)picModelArray{
    if (!_picModelArray) {
        NSString *path = [[FolderFileManager shareInstance] getUploadPath];
        _picModelArray = [[FolderFileManager shareInstance] getAllPicModelInDic:path];
    }
    return _picModelArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置UIPageViewController的配置项
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(0)};

    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:options];
    // 设置UIPageViewController代理和数据源
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    

    
    NSArray *viewControllers = [NSArray arrayWithObject:[self viewControllerAtIndex:0]];
    
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:NO
                                 completion:nil];
    
    _pageViewController.view.frame = self.view.bounds;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
}

#pragma mark 返回上一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(OpenImageViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
    
}

#pragma mark 返回下一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(OpenImageViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.picModelArray count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
    
}

-(OpenImageViewController *)viewControllerAtIndex:(NSInteger )index{
    
    if (self.picModelArray.count == 0 || self.picModelArray.count <= index) {
        return nil;
    }
    fileModel *model = [self.picModelArray objectAtIndex:index];
    OpenImageViewController *vc = [[OpenImageViewController alloc] init];
    vc.model = model;
    return vc;
}
- (NSUInteger)indexOfViewController:(OpenImageViewController *)viewController {
    return [self.picModelArray indexOfObject:viewController.model];
}



@end
