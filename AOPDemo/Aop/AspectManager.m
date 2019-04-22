//
//  AspectManager.m
//  AOPDemo
//
//  Created by 飞鱼 on 2019/4/15.
//  Copyright © 2019 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AspectManager.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import <Aspects/Aspects.h>

#import "AspectHeader.h"

#import <UMMobClick/MobClick.h>

@implementation AspectManager

+(void)trackAspectHooks{

    [AspectManager trackViewAppear];
    [AspectManager trackAppLife];
    [AspectManager trackButtonEvent];
}

#pragma mark -- 监控统计用户进入此界面的时长，频率等信息
+ (void)trackViewAppear{
    /// 页面将要出现
    [UIViewController aspect_hookSelector:@selector(viewWillAppear:)
                              withOptions:AspectPositionBefore
                               usingBlock:^(id<AspectInfo> info){
                                   if ([info.instance isKindOfClass:[UINavigationController class]]) {
                                       return;
                                   }

                                   //用户统计代码写在此处
                                   DDLogDebug(@"[打点统计]:%@ viewWillAppear",NSStringFromClass([info.instance class]));
                                   NSString *className = NSStringFromClass([info.instance class]);
                                   DDLogDebug(@"className-->%@",className);
                                   [MobClick beginLogPageView:className];//(className为页面名称

                               }
                                    error:NULL];

    /// 页面将要消失
    [UIViewController aspect_hookSelector:@selector(viewWillDisappear:)
                              withOptions:AspectPositionBefore
                               usingBlock:^(id<AspectInfo> info){
                                   if ([info.instance isKindOfClass:[UINavigationController class]]) {
                                       return;
                                   }
                                   //用户统计代码写在此处
                                   DDLogDebug(@"[打点统计]:%@ viewWillDisappear",NSStringFromClass([info.instance class]));
                                   NSString *className = NSStringFromClass([info.instance class]);
                                   DDLogDebug(@"className-->%@",className);
                                   [MobClick endLogPageView:className];

                               }
                                    error:NULL];

    //other hooks ... goes here


}

/// MARK: 监控应用生命周期
+ (void)trackAppLife {
    /// 应用进入前台
    [AppDelegate aspect_hookSelector:@selector(applicationWillEnterForeground:)
                         withOptions:AspectPositionBefore
                          usingBlock:^(id<AspectInfo> info){

                              //用户统计代码写在此处
                              DDLogDebug(@"[打点统计]:%@ applicationWillEnterForeground",NSStringFromClass([info.instance class]));
                              [MobClick event:@"applicationWillEnterForeground"];
                          }
                               error:NULL];
    /// 应用进入后台
    [AppDelegate aspect_hookSelector:@selector(applicationDidEnterBackground:)
                         withOptions:AspectPositionBefore
                          usingBlock:^(id<AspectInfo> info){

                              //用户统计代码写在此处
                              DDLogDebug(@"[打点统计]:%@ applicationDidEnterBackground",NSStringFromClass([info.instance class]));
                              [MobClick event:@"applicationDidEnterBackground"];
                          }
                               error:NULL];
}


#pragma mark --- 监控button的点击事件
+ (void)trackButtonEvent {

    __weak typeof(self) ws = self;

    //设置事件统计
    //放到异步线程去执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //读取配置文件，获取需要统计的事件列表
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EventList" ofType:@"plist"];
        NSDictionary *eventStatisticsDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        for (NSString *classNameString in eventStatisticsDict.allKeys) {
            //使用运行时创建类对象
            const char * className = [classNameString UTF8String];
            //从一个字串返回一个类
            Class newClass = objc_getClass(className);

            NSArray *pageEventList = [eventStatisticsDict objectForKey:classNameString];
            for (NSDictionary *eventDict in pageEventList) {
                //事件方法名称
                NSString *eventMethodName = eventDict[@"MethodName"];
                SEL seletor = NSSelectorFromString(eventMethodName);
                NSString *eventId = eventDict[@"EventId"];

                [ws trackEventWithClass:newClass selector:seletor eventID:eventId];
                [ws trackTableViewEventWithClass:newClass selector:seletor eventID:eventId];
                [ws trackParameterEventWithClass:newClass selector:seletor eventID:eventId];
            }
        }
    });
}



#pragma mark -- 1.监控button和tap点击事件(不带参数)
+ (void)trackEventWithClass:(Class)class selector:(SEL)selector eventID:(NSString*)eventID{

    [class aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {

        NSString *className = NSStringFromClass([aspectInfo.instance class]);
        NSLog(@"className--->%@",className);
        NSLog(@"event----->%@",eventID);
        [MobClick event:eventID];
//        if ([eventID isEqualToString:@"xxx"]) {
//            //            [EJServiceUserInfo isLogin]?[MobClick event:eventID]:[MobClick event:@"???"];
//        }else{
//            //            [MobClick event:eventID];
//        }
    } error:NULL];
}


#pragma mark -- 2.监控button和tap点击事件（带参数）
+ (void)trackParameterEventWithClass:(Class)class selector:(SEL)selector eventID:(NSString*)eventID{

    [class aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo,UIButton *button) {

        NSLog(@"button---->%@",button);
        NSString *className = NSStringFromClass([aspectInfo.instance class]);
        NSLog(@"className--->%@",className);
        NSLog(@"event----->%@",eventID);
        [MobClick event:eventID];
    } error:NULL];
}


#pragma mark -- 3.监控tableView的点击事件
+ (void)trackTableViewEventWithClass:(Class)class selector:(SEL)selector eventID:(NSString*)eventID{

    [class aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo,NSSet *touches, UIEvent *event) {

        NSString *className = NSStringFromClass([aspectInfo.instance class]);
        NSLog(@"className--->%@",className);
        NSLog(@"event----->%@",eventID);
        NSLog(@"section---->%@",[event valueForKeyPath:@"section"]);
        NSLog(@"row---->%@",[event valueForKeyPath:@"row"]);
        NSInteger section = [[event valueForKeyPath:@"section"]integerValue];
        NSInteger row = [[event valueForKeyPath:@"row"]integerValue];

        //统计事件
        if (section == 0 && row == 1) {
            //            [MobClick event:eventID];
        }
        [MobClick event:eventID];

    } error:NULL];
}

@end
