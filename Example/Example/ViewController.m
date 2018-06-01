//
//  ViewController.m
//  Example
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import "ViewController.h"
#import "ChildViewController.h"

@interface ViewController ()<PTStripDataSource>

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = self;
    }
    return self;
}

- (NSArray<UIViewController *> *)pagerTabStripViewControllersFor:(PTStripViewController *)controller {
    return @[
             [[ChildViewController alloc] init]
             ];
}

@end
