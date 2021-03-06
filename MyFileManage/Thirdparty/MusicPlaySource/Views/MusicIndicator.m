//
//  MusicIndicator.m
//  Ting
//
//  Created by Aufree on 11/18/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "MusicIndicator.h"

@implementation MusicIndicator

+ (instancetype)sharedInstance {
    static MusicIndicator *_sharedMusicIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMusicIndicator = [[MusicIndicator alloc] initWithFrame:CGRectMake(kScreenWidth - 50, 0, 50, 44)];
    });
    
    return _sharedMusicIndicator;
}

@end
