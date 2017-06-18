//
//  TXTReaderParse.h
//  MyFileManage
//
//  Created by 掌上先机 on 2017/6/15.
//  Copyright © 2017年 wangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "TXTReaderConfigue.h"


@interface TXTReaderParse : NSObject

+(NSDictionary *)parserAttribute:(TXTReaderConfigue *)config;


+(CTFrameRef)parserContent:(NSString *)content  andBouds:(CGRect)bounds;

@end
