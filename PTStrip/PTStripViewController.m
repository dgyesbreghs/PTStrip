//
//  DGPagerTabStripViewController.m
//  PagerTab
//
//  Created by Dylan Gyesbreghs on 14/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import "PTStripViewController.h"

@interface PTStripViewController()

#pragma mark - Public Properties
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger preCurrentIndex;
@property (nonatomic, assign) BOOL isViewRotating;
@property (nonatomic, assign) BOOL isViewAppearing;
@property (nonatomic, strong) UIScrollView *containerView;
@property (nonatomic, strong) NSArray<PTStripChildViewController *> *viewControllers;

#pragma mark - Private Properties
@property (nonatomic, strong) NSArray<PTStripChildViewController *> *pagerTabStripChildViewControllersForScrolling;
@property (nonatomic, assign) NSInteger lastPageNumber;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) NSInteger pageBeforeRotate;
@property (nonatomic, assign) CGSize lastSize;

@end

@implementation PTStripViewController

#pragma mark - Memory Management

- (instancetype)init
{
    if (self = [super init]) {
        [self setupProperties];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperties];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setupProperties];
    }
    return self;
}

- (void)setupProperties {
    // Setup Public Properties
    _currentIndex = 0;
    _preCurrentIndex = 0;
    _viewControllers = [NSMutableArray arrayWithCapacity:4];
    
    // Setup Private Properties
    _pagerTabStripChildViewControllersForScrolling = [NSMutableArray arrayWithCapacity:4];
    _lastPageNumber = 0;
    _lastContentOffset = 0;
    _pageBeforeRotate = 0;
    _lastSize = CGSizeMake(0, 0);
    _isViewRotating = NO;
    _isViewAppearing = NO;
}

#pragma mark - View LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContainerView];
    [self reloadViewControllers];
    [self setupChildViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isViewAppearing = YES;
    [self performSelectorOnChildViewControllers:@selector(beginAppearanceTransition:animated:) withObject:@(YES) withObject:@(animated)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppearing = NO;
    [self performSelectorOnChildViewControllers:@selector(endAppearanceTransition) withObject:nil withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self performSelectorOnChildViewControllers:@selector(beginAppearanceTransition:animated:) withObject:@(NO) withObject:@(animated)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self performSelectorOnChildViewControllers:@selector(endAppearanceTransition) withObject:nil withObject:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

#pragma mark - Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.isViewRotating = YES;
    self.pageBeforeRotate = self.currentIndex;
    __weak typeof(self) welf = self;
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        welf.isViewRotating = NO;
        welf.currentIndex = welf.pageBeforeRotate;
        welf.preCurrentIndex = welf.currentIndex;
        [welf updateIfNeeded];
    }];
}

#pragma mark - Setup Methods

- (void)setupContainerView {
    if (self.containerView.superview == nil) {
        [self.view addSubview:self.containerView];
    }
    
    self.containerView.bounces = YES;
    self.containerView.alwaysBounceVertical = NO;
    self.containerView.alwaysBounceHorizontal = YES;
    self.containerView.scrollsToTop = NO;
    self.containerView.delegate = self;
    self.containerView.showsVerticalScrollIndicator = NO;
    self.containerView.showsHorizontalScrollIndicator = NO;
    self.containerView.pagingEnabled = YES;
}

- (void)setupChildViewController {
    UIViewController *childViewController = [_viewControllers objectAtIndex:self.currentIndex];
    [self addChildViewController:childViewController];
    childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.containerView addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}

#pragma mark - Getters

- (UIScrollView *)containerView {
    if (!_containerView) {
        _containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

- (CGFloat)pageWidth {
    return CGRectGetWidth(self.containerView.bounds);
}

- (CGFloat)scrollPercentage {
    if (self.swipeDirection != PagerTabStripSwipeDirectionRight) {
        CGFloat module = fmod(self.containerView.contentOffset.x, self.pageWidth);
        return module == 0.0 ? 1.0 : module / self.pageWidth;
    }
    return 1 - fmod(self.containerView.contentOffset.x >= 0 ? self.containerView.contentOffset.x : self.pageWidth + self.containerView.contentOffset.x, self.pageWidth) / self.pageWidth;
}

- (PTStripSwipeDirection)swipeDirection {
    if (self.containerView.contentOffset.x > self.lastContentOffset) {
        return PagerTabStripSwipeDirectionLeft;
    } else if (self.containerView.contentOffset.x < self.lastContentOffset) {
        return PagerTabStripSwipeDirectionRight;
    }
    return PagerTabStripSwipeDirectionNone;
}

#pragma mark - Public Methods

- (void)moveToControllerAtIndex:(NSInteger)index {
    [self moveToControllerAtIndex:index animated:YES];
}

- (void)moveToControllerAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (animated && (labs(self.currentIndex - index) > 1)) {
        NSMutableArray<UIViewController *> *viewControllers = [self.viewControllers mutableCopy];
        
        UIViewController *currentChildViewController = self.viewControllers[index];
        
        NSInteger fromIndex = self.currentIndex < index ? index - 1 : index + 1;
        UIViewController *fromChildViewController = self.viewControllers[fromIndex];
        
        [viewControllers insertObject:fromChildViewController atIndex:self.currentIndex];
        [viewControllers insertObject:currentChildViewController atIndex:fromIndex];
        
        self.pagerTabStripChildViewControllersForScrolling = [viewControllers copy];
        
        CGPoint contentOffset = CGPointMake([self pageOffsetForChildAtIndex:fromIndex], 0);
        [self.containerView setContentOffset:contentOffset animated:NO];
    }
    UIView *view = (self.navigationController.view?: self.view);
    view.userInteractionEnabled = !animated;
    CGPoint contentOffset = CGPointMake([self pageOffsetForChildAtIndex:index], 0);
    [self.containerView setContentOffset:contentOffset animated:animated];
}

- (void)updateIfNeeded {
    if (self.isViewLoaded && !CGSizeEqualToSize(self.lastSize, self.containerView.bounds.size)) {
        [self updateContent];
    }
}

- (BOOL)canMoveToIndex:(NSInteger)index {
    return (self.currentIndex != index && self.viewControllers.count > index);
}

- (CGFloat)pageOffsetForChildAtIndex:(NSInteger)index {
    return index * self.pageWidth;
}

- (CGFloat)offsetForChildAtIndex:(NSInteger)index {
    return (index * self.pageWidth) + ((self.pageWidth - CGRectGetWidth(self.view.bounds)) * 0.5);
}

- (CGFloat)offsetForChildViewController:(PTStripChildViewController *)viewController {
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        return 0;
    }
    return [self offsetForChildAtIndex:index];
}

- (NSInteger)pageForContentOffset:(CGFloat)contentOffset {
    NSInteger virtualPage = [self virtualPageForContentOffset:contentOffset];
    return [self pageForVirtualPage:virtualPage];
}

- (NSInteger)virtualPageForContentOffset:(CGFloat)contentOffset {
    return ((contentOffset + 1.5 * self.pageWidth) / self.pageWidth) - 1;
}

- (NSInteger)pageForVirtualPage:(NSInteger)virtualPage {
    if (virtualPage <= 0) {
        return 0;
    }
    if (virtualPage > self.viewControllers.count - 1) {
        return self.viewControllers.count - 1;
    }
    return virtualPage;
}

- (void)updateContent {
    if (self.lastSize.width != CGRectGetWidth(self.containerView.bounds)) {
        self.lastSize = self.containerView.bounds.size;
        self.containerView.contentOffset = CGPointMake([self pageOffsetForChildAtIndex:self.currentIndex], 0);
    }
    self.lastSize = self.containerView.bounds.size;
    
    NSArray<PTStripChildViewController *> *viewControllers = self.pagerTabStripChildViewControllersForScrolling ?: self.viewControllers;
    self.containerView.contentSize = CGSizeMake(CGRectGetWidth(self.containerView.bounds) * viewControllers.count, self.containerView.contentSize.height);
    
    for (PTStripChildViewController *childViewController in viewControllers) {
        NSInteger index = [viewControllers indexOfObject:childViewController];
        CGFloat pageOffsetForChild = [self pageOffsetForChildAtIndex:index];
        if (fabs(self.containerView.contentOffset.x - pageOffsetForChild) < CGRectGetWidth((self.containerView.bounds))) {
            if (childViewController.parentViewController != nil) {
                childViewController.view.frame = CGRectMake([self offsetForChildAtIndex:index], 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.containerView.bounds));
                childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            } else {
                [childViewController beginAppearanceTransition:YES animated:NO];
                [self addChildViewController:childViewController];
                childViewController.view.frame = CGRectMake([self offsetForChildAtIndex:index], 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.containerView.bounds));
                childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.containerView addSubview:childViewController.view];
                [childViewController didMoveToParentViewController:self];
                [childViewController endAppearanceTransition];
            }
        } else {
            if (childViewController.parentViewController != nil) {
                [childViewController beginAppearanceTransition:NO animated:NO];
                [childViewController willMoveToParentViewController:nil];
                [childViewController.view removeFromSuperview];
                [childViewController removeFromParentViewController];
                [childViewController endAppearanceTransition];
            }
        }
    }
 
    NSInteger oldCurrentIndex = self.currentIndex;
    NSInteger virtualPage = [self virtualPageForContentOffset:self.containerView.contentOffset.x];
    NSInteger newCurrentIndex = [self pageForVirtualPage:virtualPage];
    self.currentIndex = newCurrentIndex;
    self.preCurrentIndex = self.currentIndex;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagerTabStrip:fromIndex:toIndex:)]) {
        [self.delegate pagerTabStrip:self fromIndex:MIN(oldCurrentIndex, viewControllers.count - 1) toIndex:newCurrentIndex];
    }
}

- (void)reloadPagerTabStripView {
    if (!self.isViewLoaded) { return; }
    
    for (PTStripChildViewController *viewController in self.viewControllers) {
        if (viewController.parentViewController) {
            [viewController beginAppearanceTransition:NO animated:NO];
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
            [viewController endAppearanceTransition];
        }
    }
    [self reloadViewControllers];
    self.containerView.contentSize = CGSizeMake(CGRectGetWidth(self.containerView.bounds) * self.viewControllers.count, CGRectGetHeight(self.containerView.bounds));
    if (self.currentIndex >= self.viewControllers.count) {
        self.currentIndex = self.viewControllers.count - 1;
    }
    self.preCurrentIndex = self.currentIndex;
    self.containerView.contentOffset = CGPointMake([self pageOffsetForChildAtIndex:self.currentIndex], 0);
    [self updateContent];
}

#pragma mark - Private Methods

- (void)reloadViewControllers {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pagerTabStripViewControllersFor:)]) {
        self.viewControllers = [NSMutableArray arrayWithArray:[self.dataSource pagerTabStripViewControllersFor:self]];
        NSAssert(self.viewControllers.count > 0, @"pagerTabStripViewControllersFor: should provide at least one child viewcontroller");
    }
}

- (void)performSelectorOnChildViewControllers:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 {
    for (PTStripChildViewController *viewController in self.viewControllers) {
        if ([viewController respondsToSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (object1 && object2) {
                [viewController performSelector:aSelector withObject:object1 withObject:object2];
            } else {
                [viewController performSelector:aSelector];
            }
#pragma clang diagnostic pop
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.containerView == scrollView) {
        [self updateContent];
        self.lastContentOffset = scrollView.contentOffset.x;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.containerView == scrollView) {
        self.lastPageNumber = [self pageForContentOffset:scrollView.contentOffset.x];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.containerView == scrollView) {
        self.pagerTabStripChildViewControllersForScrolling = nil;
        UIView *view = self.navigationController.view ? : self.view;
        view.userInteractionEnabled = YES;
        [self updateContent];
    }
}

@end
