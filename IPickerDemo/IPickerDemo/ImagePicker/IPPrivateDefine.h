//
//  IPPrivateDefine.h
//  AHBusiness
//
//  Created by Wangjianlong on 2016/11/2.
//  Copyright © 2016年 Autohome. All rights reserved.
//

#ifndef IPPrivateDefine_h
#define IPPrivateDefine_h

#if DEBUG
#define IPLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define IPLog(format, ...)
#endif

static inline BOOL iOS7Later()
{
    return [UIDevice currentDevice].systemVersion.floatValue >= 7.0f;
}

static inline BOOL iOS8Later()
{
    return [UIDevice currentDevice].systemVersion.floatValue >= 8.0f;
}

static inline BOOL iOS9Later()
{
    return [UIDevice currentDevice].systemVersion.floatValue >= 9.0f;
}

static inline CGFloat STATUS_BAR_HEIGHT()
{
    return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
}

#define headerHeight 44

#endif /* Header_h */
