//
//  PTStripViewController.h
//  PagerTab
//
//  Created by Dylan Gyesbreghs on 14/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTStripChild;

typedef UIViewController<PTStripChild> PTStripChildViewController;

typedef NS_ENUM(NSUInteger, PTStripSwipeDirection) {
    PagerTabStripSwipeDirectionLeft,
    PagerTabStripSwipeDirectionRight,
    PagerTabStripSwipeDirectionNone
};

@class PTStripViewController;

@protocol PTStripDelegate<NSObject>

- (void)pagerTabStrip:(PTStripViewController *)controller fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@protocol PTStripIsProgressiveDelegate<PTStripDelegate>

- (void)pagerTabStrip:(PTStripViewController *)controller fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage indexWasChanged:(BOOL)changed;

@end

@protocol PTStripDataSource<NSObject>

- (NSArray<UIViewController *> *)pagerTabStripViewControllersFor:(PTStripViewController *)controller;

@end

@interface PTStripViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, weak, nullable) id<PTStripDelegate> delegate;
@property (nonatomic, weak, nullable) id<PTStripDataSource> dataSource;

@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, assign, readonly) NSInteger preCurrentIndex;
@property (nonatomic, assign, readonly) BOOL isViewRotating;
@property (nonatomic, assign, readonly) BOOL isViewAppearing;
@property (nonatomic, strong, readonly) UIScrollView *containerView;
@property (nonatomic, strong, readonly) NSArray<PTStripChildViewController *> *viewControllers;

@property (nonatomic, assign, readonly) CGFloat pageWidth;
@property (nonatomic, assign, readonly) CGFloat scrollPercentage;
@property (nonatomic, assign, readonly) PTStripSwipeDirection swipeDirection;

- (void)moveToControllerAtIndex:(NSInteger)index;
- (void)moveToControllerAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)updateIfNeeded;
- (BOOL)canMoveToIndex:(NSInteger)index;
- (CGFloat)pageOffsetForChildAtIndex:(NSInteger)index;
- (CGFloat)offsetForChildAtIndex:(NSInteger)index;
- (CGFloat)offsetForChildViewController:(UIViewController *)viewController;
- (NSInteger)pageForContentOffset:(CGFloat)contentOffset;
- (NSInteger)virtualPageForContentOffset:(CGFloat)contentOffset;
- (NSInteger)pageForVirtualPage:(NSInteger)virtualPage;
- (void)updateContent;
- (void)reloadPagerTabStripView;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end
