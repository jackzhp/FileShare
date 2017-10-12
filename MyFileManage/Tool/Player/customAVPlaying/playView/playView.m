//
//  playView.m
//  learningAVPlaying
//
//  Created by 掌上先机 on 16/10/31.
//  Copyright © 2016年 wangchao. All rights reserved.
//

#import "playView.h"

#import "progressView.h"
#import "playView+playControl.h"
#import "playView+showHMSecond.h"
#import "playView+slidePlayControl.h"
#import "cacheVideoConnect.h"
#import "Masonry.h"
#import "MBProgressHUD.h"

@interface playView()<progressViewDelegate>

@property(nonatomic,strong)AVPlayerItem *playItem;
@property (nonatomic,strong) AVURLAsset *videoURLAsset;
@property(nonatomic,strong)MBProgressHUD *hud;
@property(nonatomic,strong,nonnull)NSString * urlString;
@property(nonatomic,assign)double currentCacheTime;
@property(nonatomic,assign)double currentPlayTime;

@property(nonatomic,strong)cacheVideoConnect *cacheConnnect;

@end

@implementation playView


+(Class)layerClass{

    return [AVPlayerLayer class];
    
}

-(instancetype)initWithFrameAndUrl:(CGRect)frame url:(NSString *)urlString
{

    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor blackColor];
        _urlString = urlString;
        [self setUp];
        //初始化控制手势
        [self initControlGester];
        //添加进度条控制
        [self addSlidePlayControl];
        
    }

    return self;
    

}



-(AVPlayer *)myPlayer{


    if (_myPlayer == nil) {
        
        _myPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playItem];
        
    }

    return _myPlayer;
    
}

-(void)setUp{


    
    if ([_urlString hasPrefix:@"http"] || [_urlString hasPrefix:@"https"]) {
    
        _cacheConnnect = [[cacheVideoConnect alloc] init];
        
        NSURL *url = [NSURL URLWithString:_urlString];
        //替换成系统不能识别的 url，才能让 resourceLoader的代理方法运行.
        
        NSURL *playUrl = [self getSchemeVideoURL:url];
        _videoURLAsset = [AVURLAsset assetWithURL:playUrl];
        //设置resourceLoader的代理
        [_videoURLAsset.resourceLoader setDelegate:_cacheConnnect queue:dispatch_get_main_queue()];
        _playItem = [AVPlayerItem playerItemWithAsset:self.videoURLAsset];

    }else{
        
        NSURL *sourceMovieURL = [NSURL fileURLWithPath:_urlString];
        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
        _playItem = [[AVPlayerItem alloc] initWithAsset:movieAsset];
        
    }
    _hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    _playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.backgroundColor = [UIColor clearColor];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_playerLayer];
    _playProgress = [[progressView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
    _playProgress.delegate = self;
    [self addSubview:_playProgress];
    
    [_playProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.height.mas_equalTo(40);
        make.bottom.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.left.equalTo(self).with.offset(0);
    }];
    
    [self addProgressObserver];
    [self addPlayStatus];
    

}
#pragma mark------添加播放状态


-(void)addPlayStatus{
    
    [self.myPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.myPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
     [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
}



#pragma mark-------监听播放的进度

- (void)addProgressObserver{
    
    AVPlayerItem *playerItem = self.myPlayer.currentItem;
    //这里设置每秒执行一次
    __weak __typeof(self) weakself = self;
   [_myPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(playerItem.currentTime);
        float total = CMTimeGetSeconds([playerItem duration]);
       weakself.currentPlayTime = current;
       NSString * currentHMSString = [weakself showHMAndSecondString:current];
       NSString * totalHMSString = [weakself showHMAndSecondString:total];
       weakself.playProgress.currentTimeLable.text = currentHMSString;
       weakself.playProgress.totalTimeLable.text = totalHMSString;
       NSString *progressString = [NSString stringWithFormat:@"%.6f",current/total];
       weakself.playProgress.progressValue = progressString;
   
    }];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{

    AVPlayerItem * itme = (AVPlayerItem *)object;
    __weak playView * weakSelf = self;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        if ([itme status] == AVPlayerStatusReadyToPlay) {
            
            [_hud hide:YES];
            float total = CMTimeGetSeconds([itme duration]);
            NSString * totalString = [weakSelf showHMAndSecondString:total];
            weakSelf.playProgress.totalTimeLable.text = totalString;
            weakSelf.playProgress.playButton.enabled = true;
            
        }else{
            
            [_hud hide:YES];
        
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        _currentCacheTime = timeInterval;
        CMTime duration = _playItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        weakSelf.playProgress.cacheProgressValue = [NSString stringWithFormat:@"%.6f",timeInterval/totalDuration];
        if (_currentCacheTime - _currentPlayTime > 1 && _myPlayer.rate == 0 ) {
            [weakSelf play];
            [weakSelf.hud hide:YES];
        }
    }
    
    if ([keyPath isEqualToString:@"frame"]) {
        
        _playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}
- (NSTimeInterval)availableDuration {
    
    NSArray *loadedTimeRanges = [[self.myPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark-------moveDidPlayEnd

-(void)moveDidPlayEnd:(NSNotification *)noti{

    [self moveToTime:0];
    //从零开始
    [self pause];
    self.playProgress.currentTimeLable.text = @"00:00";

}



#pragma mark-------playProgressDelegate


-(void)playOrPause:(playStaus)status{

    switch (status) {
        case PLAY:
            [self play];
            break;
        case PAUSE:
            [self pause];
            break;
        default:
            break;
    }
}

#pragma mark-----播放

-(void)play{
   
    if (self.myPlayer.currentItem == nil) {

        [self.myPlayer replaceCurrentItemWithPlayerItem:self.playItem];
        
    }
    [self.playProgress.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    [self.myPlayer play];
}
// 替换系统无法识别的 URL
- (NSURL *)getSchemeVideoURL:(NSURL *)url
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}


#pragma mark-----暂停

-(void)pause{

    if (self.myPlayer.rate > 0) {

        [self.playProgress.playButton setTitle:@"播放" forState:UIControlStateNormal];

        [self.myPlayer pause];
    }
    
}
//status
-(void)dealloc{
    
    [self.myPlayer.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [self removeObserver:self forKeyPath:@"frame"];
    [self.myPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}





@end
