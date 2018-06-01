//
//  PTButtonBarView.h
//  PagerTab
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSwipeDirection.h"

typedef NS_ENUM(NSUInteger, PTButtonBarViewPagerScroll) {
    ButtonBarViewPagerScrollNo,
    ButtonBarViewPagerScrollYes,
    ButtonBarViewPagerScrollScrollOnlyIfOutOfScreen
};

typedef NS_ENUM(NSUInteger, PTButtonBarViewSelectedBarAlignment) {
    ButtonBarViewSelectedBarAlignmentLeft,
    ButtonBarViewSelectedBarAlignmentCenter,
    ButtonBarViewSelectedBarAlignmentRight,
    ButtonBarViewSelectedBarAlignmentProgressive
};

typedef NS_ENUM(NSUInteger, PTButtonBarViewSelectedBarVerticalAlignment) {
    ButtonBarViewSelectedBarVerticalAlignmentTop,
    ButtonBarViewSelectedBarVerticalAlignmentMiddle,
    ButtonBarViewSelectedBarVerticalAlignmentBottom
};

@interface PTButtonBarView : UICollectionView

@property (nonatomic, strong) UIView *selectedBar;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) PTButtonBarViewSelectedBarAlignment selectedBarAlignment;
@property (nonatomic, assign) PTButtonBarViewSelectedBarVerticalAlignment selectedBarVerticalAlignment;

- (void)moveToIndex:(NSInteger)toIndex animated:(BOOL)animated swipeDirection:(PTSwipeDirection)swipeDirection pagerScroll:(PTButtonBarViewPagerScroll)pagerScroll;
- (void)moveFromIndex:(NSInteger)fromindex ToIndex:(NSInteger)toIndex animated:(BOOL)animated progressPercentage:(CGFloat)progressPercentage pagerScroll:(PTButtonBarViewPagerScroll)pagerScroll;
- (void)updateSelectedBarPositionAnimated:(BOOL)animated swipeDirection:(PTSwipeDirection)swipeDirection pagerScroll:(PTButtonBarViewPagerScroll)pagerScroll;

@end
