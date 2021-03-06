//
//  AppDelegate.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "AppDelegate.h"
#import "IPickerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
        UIApplicationShortcutItem *shortItem1 = [[UIApplicationShortcutItem alloc] initWithType:@"打开相册" localizedTitle:@"打开相册"];
        UIApplicationShortcutItem *shortItem2 = [[UIApplicationShortcutItem alloc] initWithType:@"打开视频" localizedTitle:@"打开视频"];
        
        NSArray *shortItems = [[NSArray alloc] initWithObjects:shortItem1,shortItem2, nil];
        
        [[UIApplication sharedApplication] setShortcutItems:shortItems];
    }
    
    
    return YES;
}
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler{
    IPickerViewController *IP;
    if ([shortcutItem.type isEqualToString:@"打开相册"]) {
        IP = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleImage];
        
    }else if ([shortcutItem.type isEqualToString:@"打开视频"]){
        IP = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleVideo];
    }else {
        
    }
    [self.window.rootViewController presentViewController:IP animated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
