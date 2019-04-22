//
//  AppDelegate.m
//  AOPDemo
//
//  Created by 飞鱼 on 2019/4/15.
//  Copyright © 2019 xxx. All rights reserved.
//  https://github.com/cimain/AopTestDemo

#import "AppDelegate.h"
#import "AspectManager.h"
#import <UMMobClick/MobClick.h>
#import "MoLocationManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self loadForDDLog];

    UMConfigInstance.appKey = @"58169d3af5ade43b83003053";
    [MobClick startWithConfigure:UMConfigInstance];
    [MobClick setCrashReportEnabled:YES];
    [MobClick isJailbroken];
    [MobClick isPirated];
    [MobClick setAppVersion:@"XcodeAppVersion"];
    [MoLocationManager getMoLocationWithSuccess:^(double lat, double lng) {
        [MobClick setLatitude:lat longitude:lng];
        [MoLocationManager stop];
    } Failure:^(NSError *error) {
        [MoLocationManager stop];
    }];

#ifdef DEBUG
    [MobClick setLogEnabled:YES];
    [MobClick setEncryptEnabled:YES];
    [MobClick setLogSendInterval:300];
#endif

    [AspectManager trackAspectHooks];

    return YES;
}

- (void)loadForDDLog{

    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    //    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs

    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];// 启用颜色区分
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagDebug];// 可以修改你想要的颜色

    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];

    DDLogInfo(@"LogFilePath: %@", fileLogger.currentLogFileInfo.filePath);

    DDLogError(@"错误信息"); // 红色
    DDLogWarn(@"警告%@",@"asd"); // 橙色
    DDLogInfo(@"提示信息:%@",@"嘎嘎"); // 默认是黑色
    DDLogVerbose(@"详细信息error:%d",1016); // 默认是黑色
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
