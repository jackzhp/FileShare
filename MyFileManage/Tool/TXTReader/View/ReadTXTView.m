//
//  ReadTXTView.m
//  MyFileManage
//
//  Created by 掌上先机 on 2017/6/14.
//  Copyright © 2017年 wangchao. All rights reserved.
//

#import "ReadTXTView.h"
#import "TXTReaderParse.h"
#import "ReadTXTMagnifierView.h"


@interface ReadTXTView()
{

    NSRange _selectRange;
    NSArray *_pathArray;
    
    CGRect _leftRect;
    CGRect _rightRect;
    
    BOOL _direction;
    
    BOOL _selectState;


}

@property(nonatomic,strong)ReadTXTMagnifierView *magnifierView;

@end

@implementation ReadTXTView



-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        
        self.backgroundColor = [UIColor whiteColor];
        
        
        [self addGestureRecognizer:({
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            
            longPress;
        
        })];
        
        [self addGestureRecognizer:({
        
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
            
            pan;
        
        })];
        

        
        
        
    }

    return self;

}

-(void)pan:(UIPanGestureRecognizer *)pan{


    CGPoint point = [pan locationInView:self];

    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        [self showMagnifierView];
        self.magnifierView.touchPoint = point;
        if (CGRectContainsPoint(_rightRect, point)||CGRectContainsPoint(_leftRect, point)) {
            if (CGRectContainsPoint(_leftRect, point)) {
                _direction = NO;   //从左侧滑动
            }
            else{
                _direction=  YES;    //从右侧滑动
            }
            _selectState = YES;
        }
        if (_selectState) {
            //            NSArray *path = [LSYReadParser parserRectsWithPoint:point range:&_selectRange frameRef:_frameRef paths:_pathArray];
            NSArray *path = [TXTReaderParse parserRectsWithPoint:point range:&_selectRange frameRef:_frameRef paths:_pathArray direction:_direction];
            _pathArray = path;
            [self setNeedsDisplay];
        }
        
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self hidenMagnifierView];
        
        _selectState = NO;
    }



    


}

-(void)longPress:(UILongPressGestureRecognizer *)gester{


    [self hidenMagnifierView];
    
    CGPoint point = [gester locationInView:self];
    
    if (gester.state  == UIGestureRecognizerStateBegan || gester.state == UIGestureRecognizerStateChanged) {
        
        [self showMagnifierView];
        
        _magnifierView.touchPoint = point;
        

        CGRect rect = [TXTReaderParse parserRectWithPoint:point range:&_selectRange frameRef:_frameRef];
        
        if (!CGRectEqualToRect(rect, CGRectZero)) {
            _pathArray = @[NSStringFromCGRect(rect)];
            [self setNeedsDisplay];
        }
        
        
    }
    if (gester.state == UIGestureRecognizerStateEnded) {
        
        [self hidenMagnifierView];
    }
    

    

}

-(void)drawRect:(CGRect)rect{


    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    
    CGRect left = CGRectZero;
    CGRect right = CGRectZero;
    

    [self drawSelectedPath:_pathArray andLeft:&left andRight:&right];
    

    
    CTFrameDraw(_frameRef, ctx);
    
    [self drawDotWithLeft:left right:right];
    
   // []
    
}
-(void)drawDotWithLeft:(CGRect)Left right:(CGRect)right
{
    if (CGRectEqualToRect(CGRectZero, Left) || (CGRectEqualToRect(CGRectZero, right))){
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef _path = CGPathCreateMutable();
    [[UIColor orangeColor] setFill];
    CGPathAddRect(_path, NULL, CGRectMake(CGRectGetMinX(Left)-2, CGRectGetMinY(Left),2, CGRectGetHeight(Left)));
    CGPathAddRect(_path, NULL, CGRectMake(CGRectGetMaxX(right), CGRectGetMinY(right),2, CGRectGetHeight(right)));
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);
    CGPathRelease(_path);
    CGFloat dotSize = 15;
    
    _leftRect = CGRectMake(CGRectGetMinX(Left)-dotSize/2-10, ViewSize(self).height-(CGRectGetMaxY(Left)-dotSize/2-10)-(dotSize+20), dotSize+20, dotSize+20);
    _rightRect = CGRectMake(CGRectGetMaxX(right)-dotSize/2-10,ViewSize(self).height- (CGRectGetMinY(right)-dotSize/2-10)-(dotSize+20), dotSize+20, dotSize+20);
    CGContextDrawImage(ctx,CGRectMake(CGRectGetMinX(Left)-dotSize/2, CGRectGetMaxY(Left)-dotSize/2, dotSize, dotSize),[UIImage imageNamed:@"r_drag-dot"].CGImage);
    CGContextDrawImage(ctx,CGRectMake(CGRectGetMaxX(right)-dotSize/2, CGRectGetMinY(right)-dotSize/2, dotSize, dotSize),[UIImage imageNamed:@"r_drag-dot"].CGImage);
}


#pragma mark  Draw Selected Path
-(void)drawSelectedPath:(NSArray *)array andLeft:(CGRect *)left andRight:(CGRect *)right{
    if (!array.count) {
        
        return;
    }
    
    CGMutablePathRef _path = CGPathCreateMutable();
    [[UIColor redColor]setFill];
    for (int i = 0; i < [array count]; i++) {
        CGRect rect = CGRectFromString([array objectAtIndex:i]);
        CGPathAddRect(_path, NULL, rect);
        
        if (i == 0) {
            *left = rect;
        }
        if (i == [array count]-1) {
            *right = rect;
        }

        
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);
    CGPathRelease(_path);
    
}



-(void)showMagnifierView{
    
    
    if (!_magnifierView) {
        
        _magnifierView = [[ReadTXTMagnifierView alloc] init];
        
        _magnifierView.readView = self;
        
        [self addSubview:_magnifierView];
        
    }
    
}
-(void)hidenMagnifierView{
    
    if (_magnifierView) {
        
        [_magnifierView removeFromSuperview];
        
        _magnifierView = nil;
    }
    
    
}

-(void)cancelSelected{
    if (_pathArray) {
        
        _pathArray = nil;
    }
    
    [self setNeedsDisplay];
    


}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{


    [self cancelSelected];

}

@end
