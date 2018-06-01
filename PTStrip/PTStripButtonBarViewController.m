//
//  PTButtonBarStripViewController.m
//  PagerTab
//
//  Created by Dylan Gyesbreghs on 15/05/2018.
//  Copyright © 2018 Dylan Gyesbreghs. All rights reserved.
//

#import "PTStripButtonBarViewController.h"

#import "PTButtonBarView.h"
#import "PTButtonBarViewCell.h"

@interface PTStripButtonBarViewController() <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PTStripDelegate>

@property (nonatomic, assign) BOOL shouldUpdateButtonBarView;
@property (nonatomic, assign) BOOL collectionViewDidLoad;

@property (nonatomic, strong) PTButtonBarView *buttonBarView;
@property (nonatomic, strong) NSArray<NSNumber *>* cachedCellWidths;

@end

@implementation PTStripButtonBarViewController

#pragma mark - Memory Management

- (instancetype)init {
    if (self = [super init]) {
        [self setupProperties];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperties];
    }
    return self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setupProperties];
    }
    return self;
}

- (void)setupProperties {
    self.delegate = self;
    
    _shouldUpdateButtonBarView = YES;
    _collectionViewDidLoad = NO;
}

#pragma mark - View Life Cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtonBarView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.buttonBarView layoutIfNeeded];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isViewAppearing || self.isViewRotating) {
        self.cachedCellWidths = [self calculateWidths];
        [self.buttonBarView.collectionViewLayout invalidateLayout];
        [self.buttonBarView moveToIndex:self.currentIndex animated:NO swipeDirection:PagerTabSwipeDirectionNone pagerScroll:ButtonBarViewPagerScrollScrollOnlyIfOutOfScreen];
        [self.buttonBarView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - Setup Methods

- (void)setupButtonBarView {
    self.buttonBarView.delegate = self;
    self.buttonBarView.dataSource = self;
    
    self.buttonBarView.scrollsToTop = NO;
    self.buttonBarView.showsHorizontalScrollIndicator = NO;
    UINib *buttonBarViewNib = [UINib nibWithNibName:[PTButtonBarViewCell reuseIdentifier] bundle:[NSBundle bundleForClass:[PTButtonBarViewCell class]]];
    [self.buttonBarView registerNib:buttonBarViewNib forCellWithReuseIdentifier:[PTButtonBarViewCell reuseIdentifier]];
}

#pragma mark - Getters

- (PTButtonBarView *)buttonBarView {
    if (!_buttonBarView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat height = 44;
        _buttonBarView = [[PTButtonBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height) collectionViewLayout:flowLayout];
        _buttonBarView.backgroundColor = [UIColor orangeColor];
        _buttonBarView.selectedBar.backgroundColor = [UIColor blackColor];
        _buttonBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CGRect newContainerViewFrame = self.containerView.frame;
        newContainerViewFrame.origin.y = height;
        newContainerViewFrame.size.height = CGRectGetHeight(self.containerView.frame) - (height -self.containerView.frame.origin.y);
        self.containerView.frame = newContainerViewFrame;
        
        [self.view addSubview:self.buttonBarView];
    }
    return _buttonBarView;
}

- (NSArray<NSNumber *> *)cachedCellWidths {
    if (!_cachedCellWidths) {
        _cachedCellWidths = [NSArray arrayWithArray:[self calculateWidths]];
    }
    return _cachedCellWidths;
}

#pragma mark - Public Methods

- (void)reloadPagerTabStripView {
    [super reloadPagerTabStripView];
    if (self.isViewLoaded) {
        [self.buttonBarView reloadData];
        self.cachedCellWidths = [self calculateWidths];
        [self.buttonBarView moveToIndex:self.currentIndex animated:NO swipeDirection:PagerTabSwipeDirectionNone pagerScroll:ButtonBarViewPagerScrollYes];
    }
}

- (CGFloat)calculateStretchedCellWidthsWithMinimumCellWidths:(NSArray<NSNumber *> *)minimumCellWidths suggestedStretchedCellWidth:(CGFloat)suggestedStretchedCellWidth previousNumberOfLargeCells:(NSInteger)previousNumberOfLargeCells {
    NSInteger numberOfLargeCells = 0;
    CGFloat totalWidthOfLargeCells = 0;
    
    for (NSNumber *minimumCellWidthValue in minimumCellWidths) {
        if ([minimumCellWidthValue doubleValue] > suggestedStretchedCellWidth) {
            totalWidthOfLargeCells += [minimumCellWidthValue doubleValue];
            numberOfLargeCells++;
        }
    }
    
    if (numberOfLargeCells <= previousNumberOfLargeCells) { return suggestedStretchedCellWidth; }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.buttonBarView.collectionViewLayout;
    CGFloat collectionViewAvailiableWidth = CGRectGetWidth(self.buttonBarView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    NSInteger numberOfCells = minimumCellWidths.count;
    CGFloat cellSpacingTotal = (numberOfCells - 1) * flowLayout.minimumLineSpacing;
    
    NSInteger numberOfSmallCells = numberOfCells - numberOfLargeCells;
    NSInteger newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / numberOfSmallCells;
    
    return [self calculateStretchedCellWidthsWithMinimumCellWidths:minimumCellWidths suggestedStretchedCellWidth:newSuggestedStretchedCellWidth previousNumberOfLargeCells:numberOfLargeCells];
}

#pragma mark - PagerTabStripDelegate

- (void)pagerTabStrip:(PTStripViewController *)controller fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (self.shouldUpdateButtonBarView) {
        PTSwipeDirection direction = toIndex < fromIndex ? PagerTabSwipeDirectionRight : PagerTabSwipeDirectionLeft;
        [self.buttonBarView moveToIndex:toIndex animated:YES swipeDirection:direction pagerScroll:ButtonBarViewPagerScrollYes];
    }
}

#pragma mark - Private Methods

- (NSArray<NSNumber *> *)calculateWidths {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.buttonBarView.collectionViewLayout;
    NSInteger numberOfCells = self.viewControllers.count;
    
    NSMutableArray<NSNumber *>* widths = [NSMutableArray arrayWithCapacity:numberOfCells];
    CGFloat collectionViewContentWidth = 0;
    
    for (PTStripChildViewController *viewController in self.viewControllers) {
        CGFloat width = [self minimumCellWidthsForTitle:viewController.title];
        [widths addObject:@(width)];
        collectionViewContentWidth += width;
    }
    
    CGFloat cellSpacingTotal = numberOfCells - 1 * flowLayout.minimumLineSpacing;
    collectionViewContentWidth += cellSpacingTotal;
    
    CGFloat collectionViewAvailableVisibleWidth = self.buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    
    if (collectionViewAvailableVisibleWidth < collectionViewContentWidth) {
        return [widths copy];
    } else {
        CGFloat stretchedCellWidthIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / numberOfCells;
        CGFloat generalMinimumCellWidth = [self calculateStretchedCellWidthsWithMinimumCellWidths:widths suggestedStretchedCellWidth:stretchedCellWidthIfAllEqual previousNumberOfLargeCells:0];
        NSMutableArray<NSNumber *>* stretchedCellWidths = [NSMutableArray arrayWithCapacity:numberOfCells];
        
        for (NSNumber *minimumCellWidthValue in widths) {
            CGFloat cellWidth = ([minimumCellWidthValue doubleValue] > generalMinimumCellWidth) ? [minimumCellWidthValue doubleValue] : generalMinimumCellWidth;
            [stretchedCellWidths addObject:@(cellWidth)];
        }
        
        return [stretchedCellWidths copy];
    }
}

- (NSArray<PTButtonBarViewCell *> *)cellForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths reloadIfNotVisible:(BOOL)reload {
    NSMutableArray<PTButtonBarViewCell *> *cells = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PTButtonBarViewCell *cell = (PTButtonBarViewCell *)[self.buttonBarView cellForItemAtIndexPath:indexPath];
        [cells addObject:cell];
    }
    
    if (reload) {
        [self.buttonBarView reloadItemsAtIndexPaths:indexPaths];
    }
    
    return [cells copy];
}

- (CGFloat)minimumCellWidthsForTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = title;
    CGSize labelSize = label.intrinsicContentSize;
    return (labelSize.width + 8) * 2;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PTButtonBarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PTButtonBarViewCell reuseIdentifier] forIndexPath:indexPath];
    self.collectionViewDidLoad = YES;
    PTStripChildViewController *childViewController = [self.viewControllers objectAtIndex:indexPath.row];
    [cell setupWithTitle:childViewController.title];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *widthValue = [self.cachedCellWidths objectAtIndex:indexPath.row];
    return CGSizeMake([widthValue doubleValue], CGRectGetHeight(collectionView.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.currentIndex) {
        return;
    }
    
    [self.buttonBarView moveToIndex:indexPath.item animated:YES swipeDirection:PagerTabSwipeDirectionNone pagerScroll:ButtonBarViewPagerScrollYes];
    self.shouldUpdateButtonBarView = YES;
    [self moveToControllerAtIndex:indexPath.item];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [super scrollViewDidEndScrollingAnimation:scrollView];
    
    if (self.containerView == scrollView) {
        _shouldUpdateButtonBarView = YES;
    }
}

@end
