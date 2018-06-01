//
//  ChildViewController.m
//  Example
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import "ChildViewController.h"

@interface ChildViewController ()

@end

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 65)];
    testLabel.text = self.title;
    testLabel.center = self.view.center;
    [self.view addSubview:testLabel];
}

- (NSString *)title {
    return @"Portfolio";
}

@end
