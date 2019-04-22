//
//  ViewController.m
//  AOPDemo
//
//  Created by 飞鱼 on 2019/4/15.
//  Copyright © 2019 xxx. All rights reserved.
//  动态方法决议与消息转发: https://www.jianshu.com/p/1f68af299126

#import "ViewController.h"
#import "NextViewController.h"
#include <objc/runtime.h>

void dynamicMethodIMP(id self, SEL _cmd) {
//    NSLog(@" >> dynamicMethodIMP");
    DDLogError(@"%@ 方法 %@ 未实现。", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 在iOS开发中，可以直接调用方法的方式有两种：performSelector:withObject: 和 NSInvocation。
    [self performSelector:@selector(setText:) withObject:@"66666666"];
    // Do any additional setup after loading the view.
}

- (IBAction)go_nextAction:(UIButton *)sender {
    NextViewController *nextVC = [[NextViewController alloc]init];
    [self.navigationController pushViewController:nextVC animated:YES];
}

//[self performSelector:@selector(setText:) withObject:@"66666666"];
/* 优先级 1
- (void)setText:(NSString *)text {

}
*/

// /* 优先级 3
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [self.displayLabel methodSignatureForSelector:aSelector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    if ([self.displayLabel respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.displayLabel];
    }
}
// */

/* 优先级 2
+ (BOOL)resolveInstanceMethod:(SEL)name {
    DDLogInfo(@" >> Instance resolving %@", NSStringFromSelector(name));

    if (name == @selector(setText:)) {
        class_addMethod([self class], name, (IMP)dynamicMethodIMP, "v@:");
        return YES;
    }

    return [super resolveInstanceMethod:name];
}

+ (BOOL)resolveClassMethod:(SEL)name {
    DDLogInfo(@" >> Class resolving %@", NSStringFromSelector(name));
    return [super resolveClassMethod:name];
}
*/

@end
