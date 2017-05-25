//
//  openImageViewController.m
//  MyFileManage
//
//  Created by 掌上先机 on 2017/5/25.
//  Copyright © 2017年 wangchao. All rights reserved.
//

#import "openImageViewController.h"

@interface openImageViewController ()<UIScrollViewDelegate>


@property(nonatomic,strong)UIScrollView *bgScrollView;

@property(nonatomic,strong)UIImageView *localImgV;

@property(nonatomic)BOOL zoomOut_In;

@end

@implementation openImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _model.fileName;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_bgScrollView];
    
   

    UIImage *fileImage = [UIImage imageWithContentsOfFile:_model.fullPath];
    
    UIImageView *imgV = [[UIImageView alloc] initWithImage:fileImage];
    _localImgV = imgV;
    UITapGestureRecognizer* tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];//给imageview添加tap手势
    tap.numberOfTapsRequired = 2;//双击图片执行tapGesAction
    imgV.userInteractionEnabled=YES;
    [imgV addGestureRecognizer:tap];
    
     _zoomOut_In = YES;//控制点击图片放大或缩小
    
    
    _bgScrollView.maximumZoomScale=2.0;//最大倍率（默认倍率）
    _bgScrollView.minimumZoomScale=0.1;//最小倍率（默认倍率）
    _bgScrollView.decelerationRate=1.0;//减速倍率（默认倍率）
    
    if (fileImage) {
        
        _bgScrollView.delegate = self;
    }
    
    
    [_bgScrollView addSubview:imgV];
    
    _bgScrollView.contentSize = CGSizeMake(imgV.width, imgV.height);
    
    


}
-(void)tapGesAction:(UIGestureRecognizer*)gestureRecognizer//手势执行事件
{
    float newscale=0.0;
    if (_zoomOut_In) {
        newscale = 2*1.5;
        _zoomOut_In = NO;
    }else
    {
        newscale = 1.0;
        _zoomOut_In = YES;
    }
    
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    NSLog(@"zoomRect:%@",NSStringFromCGRect(zoomRect));
    [_bgScrollView zoomToRect:zoomRect animated:YES];//重新定义其cgrect的x和y值
    
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    zoomRect.size.height = [_bgScrollView frame].size.height / scale;
    zoomRect.size.width  = [_bgScrollView frame].size.width  / scale;
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _localImgV;
}

-(void)dealloc{

    NSLog(@"dealloc");
}


@end
