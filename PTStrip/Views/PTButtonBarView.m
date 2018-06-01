//
//  PTButtonBarView.m
//  PagerTab
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import "PTButtonBarView.h"

@interface PTButtonBarView()

@property (nonatomic, assign) CGFloat selectedBarHeight;

@end

@implementation PTButtonBarView

#pragma mark - Memory Management

- (instancetype)init {
    if (self = [super init]) {
        [self setupProperties];
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperties];
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self setupProperties];
        [self setupView];
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSelectedBarYPosition];
}

#pragma mark - Setup Methods

- (void)setupProperties {
    // Private Properties
    _selectedBarHeight = 4.0;
    
    // Public Properties
    _selectedIndex = 0;
    _selectedBarAlignment = ButtonBarViewSelectedBarAlignmentCenter;
    _selectedBarVerticalAlignment = ButtonBarViewSelectedBarVerticalAlignmentBottom;
}

- (void)setupView {
    [self addSubview:self.selectedBar];
}

#pragma mark - Getters

- (UIView *)selectedBar {
    if (!_selectedBar) {
        _selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - self.selectedBarHeight, 0, self.selectedBarHeight)];
        _selectedBar.layer.zPosition = 9999;
    }
    return _selectedBar;
}

#pragma mark - Setters

- (void)setSelectedBarHeight:(CGFloat)selectedBarHeight {
    _selectedBarHeight = selectedBarHeight;
    [self updateSelectedBarYPosition];
}

#pragma mark - Public Methods

- (void)moveToIndex:(NSInteger)toIndex animated:(BOOL)animated swipeDirection:(PTSwipeDirection)swipeDirection pagerScroll:(PTButtonBarViewPagerScroll)pagerScroll {
    self.selectedIndex = toIndex;
    [self updateSelectedBarPositionAnimated:animated swipeDirection:swipeDirection pagerScroll:pagerScroll];
}

- (void)moveFromIndex:(NSInteger)fromindex ToIndex:(NSInteger)toIndex animated:(BOOL)animated progressPercentage:(CGFloat)progressPercentage pagerScroll:(PTButtonBarViewPagerScroll)pagerScroll {
    self.selectedIndex = progressPercentage > 0.5 ? toIndex : fromindex;
    
    CGRect toFrame;
    CGRect fromFrame = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:fromindex inSection:0]].frame;
    NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:0];
    
    if (toIndex < 0 || toIndex > numberOfItems - 1) {
        UICollectionViewLayoutAttributes *cellAttributes;
        if (toIndex < 0) {
            cellAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        } else {
            cellAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:0]];
        }
        toFrame = CGRectOffset(cellAttributes.frame, cellAttributes.frame.size.width, 0);
    } else {
        toFrame = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]].frame;
    }
    
    CGRect targetFrame = fromFrame;
    targetFrame.size.height = self.selectedBar.frame.size.height;
    targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * progressPercentage;
    targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage;
    
    self.selectedBar.frame = CGRectMake(targetFrame.origin.x, self.selectedBar.frame.origin.y, targetFrame.size.width, self.selectedBar.frame.size.height);

    CGFloat targetContentOffset = 0.0;
    if (self.contentSize.width > self.frame.size.width) {
        CGFloat toContentOffset = [self contentOffsetForCellWithFrame:toFrame andIndex:toIndex];
        CGFloat fromContentOffset = [self contentOffsetForCellWithFrame:fromFrame andIndex:fromindex];
        
        targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage);
    }
    
    [self setContentOffset:CGPointMake(targetContentOffset, 0) animated:NO];
}

- (void)updateSelectedBarPositionAnimated:(BOOL)animated swipeDirection:(PTSwipeDirection)swipeDirection pagerScroll:(PTButtonBarViewPagerScroll)pagerScroll {
    CGRect selectedBarFrame = self.selectedBar.frame;

    NSIndexPath *selectedCellIndexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
    UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:selectedCellIndexPath];
    CGRect selectedCellFrame = layoutAttributes.frame;

    [self updateContentOffsetAnimated:animated withPagerScroll:pagerScroll toFrame:selectedCellFrame toIndex:selectedCellIndexPath.row];
    
    selectedBarFrame.size.width = selectedCellFrame.size.width;
    selectedBarFrame.origin.x = selectedCellFrame.origin.x;

    if (animated) {
        __weak typeof(self) welf = self;
        [UIView animateWithDuration:0.3 animations:^{
            welf.selectedBar.frame = selectedBarFrame;
        }];
    } else {
        self.selectedBar.frame = selectedBarFrame;
    }
}

#pragma mark - Private Methods

- (void)updateContentOffsetAnimated:(BOOL)animated withPagerScroll:(PTButtonBarViewPagerScroll)pagerScroll toFrame:(CGRect)toFrame toIndex:(NSInteger)toIndex {
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (CGFloat)contentOffsetForCellWithFrame:(CGRect)frame andIndex:(NSInteger)index {
    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout *)self.collectionViewLayout sectionInset];
    CGFloat alignmentOffset = 0.0;
    
    switch (self.selectedBarAlignment) {
        case ButtonBarViewSelectedBarAlignmentLeft:
            alignmentOffset = sectionInset.left;
            break;
        case ButtonBarViewSelectedBarAlignmentRight:
            alignmentOffset = self.frame.size.width - sectionInset.right - frame.size.width;
            break;
        case ButtonBarViewSelectedBarAlignmentCenter:
            alignmentOffset = (self.frame.size.width - frame.size.width) * 0.5;
            break;
        case ButtonBarViewSelectedBarAlignmentProgressive: {
            CGFloat cellHalfWidth = frame.size.width * 0.5;
            CGFloat leftAlignmentOffset = sectionInset.left + cellHalfWidth;
            CGFloat rightAlignmentOffset = self.frame.size.width - sectionInset.right - cellHalfWidth;
            NSInteger numerOfItems = [self.dataSource collectionView:self numberOfItemsInSection:0];
            NSInteger progress = index / (numerOfItems - 1);
            alignmentOffset = leftAlignmentOffset + (rightAlignmentOffset - leftAlignmentOffset) * progress - cellHalfWidth;
            break;
        }
    }
    
    CGFloat contentOffset = frame.origin.x - alignmentOffset;
    contentOffset = MAX(0, contentOffset);
    contentOffset = MIN(self.contentSize.width - frame.size.width, contentOffset);
    return contentOffset;
}

- (void)updateSelectedBarYPosition {
    CGRect selectedBarFrame = self.selectedBar.frame;
    
    switch (self.selectedBarVerticalAlignment) {
        case ButtonBarViewSelectedBarVerticalAlignmentTop:
            selectedBarFrame.origin.y = 0;
            break;
        case ButtonBarViewSelectedBarVerticalAlignmentMiddle:
            selectedBarFrame.origin.y = ((self.frame.size.height - self.selectedBarHeight) / 2);
            break;
        case ButtonBarViewSelectedBarVerticalAlignmentBottom:
            selectedBarFrame.origin.y = (self.frame.size.height - self.selectedBarHeight);
            break;
    }
    
    selectedBarFrame.size.height = self.selectedBarHeight;
    self.selectedBar.frame = selectedBarFrame;
}

@end
