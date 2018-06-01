//
//  HomeViewController.m
//  Example
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewController.h"

@interface HomeViewController ()

@property (nonatomic, weak) IBOutlet UIView *testView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ViewController *viewController = [[ViewController alloc] init];
    [self addChildViewController:viewController];
    [self.testView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
