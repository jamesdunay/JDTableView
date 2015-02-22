//
//  MasterSelectionView.m
//  JDTableView
//
//  Created by James Dunay on 2/3/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import "MasterSelectionView.h"
#import "JDSelectionView.h"
#import "SelectionViewFlowLayout.h"
#import "JDCollectionViewCell.h"
#import "JDSelectionViewFooter.h"
#import "JDTitleView.h"


@interface MasterSelectionView()

@property(nonatomic, strong)JDTitleView* titleView;
@property(nonatomic, strong)JDSelectionView* selectionView;
@property(nonatomic, strong)JDSelectionViewFooter* swipeDismissView;


@property(nonatomic, strong)NSMutableArray* selections;

@property(nonatomic) BOOL defaultConstraintsSet;
@property(nonatomic) BOOL canSaveCurrentOffsetPoint;

@property (nonatomic) CGFloat yOffsetStartingPoint;
@property(nonatomic) CGPoint savedScrollViewPoint;
@property(nonatomic) NSInteger maxItemsCanBeDisplayed;

@property(nonatomic) CGFloat lastPanOffset;

@property(nonatomic)BOOL viewHasBeenSwipedOpen;

@end

static CGFloat const selectedViewDelayExpandingTheshold = 200.f;
//  ^^  Used to delay pull down on selection view
static CGFloat const selectionViewBottomInset = 10;
static CGFloat const titleDisplayThreshold = 41.f;
static CGFloat const maximumCellHeight = 41.f;

@implementation MasterSelectionView

-(id)init{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, 64, 320, 10);
        
        self.selections = [[NSMutableArray alloc] init];

        self.backgroundImageView = [[UIImageView alloc] init];
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundImageView.contentMode = UIViewContentModeTop;
        self.backgroundImageView.clipsToBounds = YES;
        [self addSubview:self.backgroundImageView];
        
        SelectionViewFlowLayout* selectionFlow = [[SelectionViewFlowLayout alloc] init];
        selectionFlow.minimumInteritemSpacing = 0;
        selectionFlow.minimumLineSpacing = 0;
        self.selectionView = [[JDSelectionView alloc] initWithFrame:CGRectZero collectionViewLayout:selectionFlow];
        [self.selectionView registerClass:[JDCollectionViewCell class] forCellWithReuseIdentifier:@"selectedCell"];
        self.selectionView.dataSource = self;
        self.selectionView.delegate = self;
        self.selectionView.tag = 2;
        self.selectionView.translatesAutoresizingMaskIntoConstraints = NO;
        self.selectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.selectionView];
        
        self.titleView = [[JDTitleView alloc] init];
        self.titleView.titleLabel.text = @"SELECTED";
        [self.titleView setTextColor:[UIColor whiteColor]];
        self.titleView.alpha = 0.f;
        self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.titleView];
        
        self.swipeDismissView = [[JDSelectionViewFooter alloc] init];
        self.swipeDismissView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.swipeDismissView];
        
        
        UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToClose)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
//
//        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragFrame:)];
//        [self.swipeDismissView addGestureRecognizer:pan];
        
        UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToOpen)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        
        [self.swipeDismissView addGestureRecognizer:swipeUp];
        [self.swipeDismissView addGestureRecognizer:swipeDown];
    }
    return self;
}

-(void)setFullFrame:(CGRect)fullFrame{
    _fullFrame = fullFrame;
    self.maxItemsCanBeDisplayed = (fullFrame.size.height/2)/maximumCellHeight;
}

//-(void)dragFrame:(UIPanGestureRecognizer*)pan{
//    CGPoint translate = [pan translationInView:self];
//    CGFloat newOffset = translate.y - self.lastPanOffset;
//    
////    self.frame = UIEdgeInsetsInsetRect(self.frame, UIEdgeInsetsMake(0, 0, -newOffset, 0));
//    [self.selectionViewDelegate adjustScrollViewOffsetTo:-newOffset];
//    
//    self.lastPanOffset = translate.y;
//    
//    if(pan.state == UIGestureRecognizerStateEnded){
//        self.lastPanOffset = 0.f;
//    }
//}

-(void)swipedToClose{
    [self.selectionViewDelegate selectionsSwipedClosed];
    self.viewIsLockedUp = YES;
}

-(void)swipedToOpen{
    self.viewHasBeenSwipedOpen = YES;
    [self.selectionViewDelegate selectionsSwipedOpen:self.getMaxHeighForSelectionView];
    self.viewIsLockedUp = NO;
}

-(void)layoutSubviews{
    
    if (!self.defaultConstraintsSet) {
        [self addConstraints:[self defaultConstraints]];
        self.defaultConstraintsSet = YES;
    }
    [super layoutSubviews];
}


-(void)setViewIsLockedUp:(BOOL)viewIsLockedUp{
    _viewIsLockedUp = viewIsLockedUp;
    [self.swipeDismissView viewIsLocked:viewIsLockedUp];
}

-(NSArray*)defaultConstraints{
    NSMutableArray* constraints =[NSMutableArray new];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_backgroundImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_backgroundImageView)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_backgroundImageView)
                                      ]];
    
    self.backgroundTopConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.f
                                                                 constant:-64.f
                                    ];
    [constraints addObject:self.backgroundTopConstraint];
    
    
    NSDictionary* metrics = @{@"bottomInset" : @(selectionViewBottomInset)};
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectionView]-bottomInset-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:NSDictionaryOfVariableBindings(_selectionView)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectionView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_selectionView)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_titleView)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_titleView)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_swipeDismissView(==25)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_swipeDismissView)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_swipeDismissView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_swipeDismissView)
                                      ]];
    
    return [constraints copy];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selections.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* reuseID;
    UIColor* backgroundColor;
    CollectionViewItem* item;

    reuseID = @"selectedCell";
    backgroundColor = [UIColor clearColor];
    item = _selections[indexPath.row];
    
    JDCollectionViewCell* cell = (JDCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    cell.backgroundColor = backgroundColor;

//    cell.kJDCellDelegate = self;
//    ^^ unselect cell
    
    [cell shouldShowImages:NO];
    cell.indexPath = indexPath;
    [cell setInfoWithItem:item];
    
    [cell shouldHideTitleBar:(indexPath.row == self.selections.count - 1)];
        
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.frame.size.width, self.selectedCellHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    

//  Need selected cell actions

    
    /*
    JDCollectionViewCell* tappedCell = (JDCollectionViewCell*)[_selectionView cellForItemAtIndexPath:indexPath];
    NSIndexPath* indexInCollectionView = [NSIndexPath indexPathForItem:tappedCell.item.index inSection:0];
    JDCollectionViewCell* collectionViewCell = (JDCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexInCollectionView];
    
    [self.selections removeObjectAtIndex:indexPath.row];
    
    [self animateCollectionsForNewSelection];
    [_selectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    [(CollectionViewItem*)_items[indexInCollectionView.row] setIsSelected:NO];
    [collectionViewCell toggleSelected];
     */
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.selectedCellHeight == maximumCellHeight) {
        self.savedScrollViewPoint = scrollView.contentOffset;
//        ^^ Could leave this for the animation when the scrollview appears
    }
}


-(void)adjustSelectedCellHeightWithOffset:(CGFloat)offsetChange andScrollView:(UIScrollView *)scrollView{
    
    if (self.selections.count) {
        if (offsetChange > 0.f) {
            self.yOffsetStartingPoint = scrollView.contentOffset.y;
//            ^^ Mark Offset threshold
        }
                
        //  ^^ Offset > 0 == Shrinking
        if (([self canShrinkSelectionViewWithCurrentOffset:scrollView.contentOffset] && offsetChange > 0.f) || ([self canExpandSelectionViewWithCurrentOffset:scrollView.contentOffset] && offsetChange < 0.f)) {
            CGFloat offsetDivision = offsetChange/self.numberOfVisibleCells;
            self.selectedCellHeight -= offsetDivision;
            
            self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height - offsetChange);

            if (self.selectedCellHeight > maximumCellHeight && scrollView.contentOffset.y > 0.f){
                self.selectedCellHeight = maximumCellHeight;
                self.frame = [self getMaxSizeFrame];
                self.viewHasBeenSwipedOpen = NO;
            }

            if (self.frame.size.height < titleDisplayThreshold) {
                self.selectedCellHeight = titleDisplayThreshold/self.numberOfVisibleCells;
                self.frame = [self getMinSizeFrame];
            }
            
            [self.selectionView reloadData];
            scrollView.scrollIndicatorInsets = [self getInsetForSelectionFrame];
        }
        [self adjustAlphas];
    }
}

-(void)adjustAlphas{
    self.titleView.alpha = self.selectionView.frame.size.height <= titleDisplayThreshold;
    self.selectionView.alpha = !self.titleView.alpha;
}

-(BOOL)canShrinkSelectionViewWithCurrentOffset:(CGPoint)collectionOffset{
    BOOL hasReachedMinimiumSize = self.frame.size.height <= maximumCellHeight;
    return !hasReachedMinimiumSize && collectionOffset.y >= 0.f;
}

-(BOOL)canExpandSelectionViewWithCurrentOffset:(CGPoint)collectionOffset{
    //    ^^  Used to direct the control states for expanding the selection view
    
    BOOL hasHitThreshold = self.yOffsetStartingPoint - collectionOffset.y > selectedViewDelayExpandingTheshold;
    BOOL thresholdShouldBeApplied = self.selectionView.frame.size.height <= maximumCellHeight;
    BOOL thresholdShouldBeCanceled = (collectionOffset.y <= (self.fullFrame.size.height/2 - titleDisplayThreshold)) || self.viewHasBeenSwipedOpen;
    BOOL isSmallerThanMaxHeight = self.frame.size.height <= self.getMaxHeighForSelectionView;
    
    
//    NEED to cancel threshold for self.viewIsLockedUp
    
    
//    Maybe the bounce can only be allowed if the scrollview is not at max height
//    BOOL collectionViewIsPastTopOfContent = collectionOffset.y <= 0;
//    ^^ Allows for selectionview to spring with collection at top of content
    
//    || (!collectionViewIsPastTopOfContent && thresholdShouldBeCanceled
//    BOOL hasReachedMaxSize = self.selectionView.frame.size.height >= self.getCurrentSelectionViewMaxHeight;

    return (self.selectedCellHeight < maximumCellHeight &&
            collectionOffset.y >= 0.0f &&
            !self.viewIsLockedUp &&
            isSmallerThanMaxHeight &&
            ((hasHitThreshold || !thresholdShouldBeApplied) || thresholdShouldBeCanceled));
}



#pragma Mark Custom View Logic

-(void)adjustCounter{
    self.titleView.counterLabel.text = [NSString stringWithFormat:@"%ld", self.selections.count];
}


#pragma Mark Add Items ----------------

-(void)addItem:(CollectionViewItem *)item{
    
    _selectedCellHeight = maximumCellHeight;
    [self.selections addObject:item];
    NSIndexPath* newSelectionIndex = [NSIndexPath indexPathForItem:(_selections.count - 1) inSection:0];
    [_selectionView insertItemsAtIndexPaths:@[newSelectionIndex]];
    
    [self.selectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
//    ^^ used to re-draw titlebar
    [self animateCollectionToMaxSize];
    [self adjustCounter];
}

-(void)removeItem:(CollectionViewItem *)item{
    
    __block NSIndexPath *indexPathToRemove;
    [_selections enumerateObjectsUsingBlock:^(CollectionViewItem* tempItem, NSUInteger idx, BOOL *stop) {
        if ([tempItem isEqual:item]) {
            indexPathToRemove = [NSIndexPath indexPathForItem:idx inSection:0];
        }
    }];
    
    [_selections removeObjectAtIndex:indexPathToRemove.row];
    [_selectionView deleteItemsAtIndexPaths:@[indexPathToRemove]];
    
    [self animateCollectionToMaxSize];
    [self adjustCounter];
}

-(void)animateCollectionToMaxSize{
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = [self getMaxSizeFrame];
                         [self layoutIfNeeded];
                     }completion:nil];
    [self adjustAlphas];
}


-(CGRect)getMinSizeFrame{
    return CGRectMake(0, self.frame.origin.y, self.fullFrame.size.width, titleDisplayThreshold);
}

-(CGRect)getMaxSizeFrame{
    return CGRectMake(0, self.frame.origin.y, self.fullFrame.size.width, self.getMaxHeighForSelectionView);
}

-(CGFloat)getMaxHeighForSelectionView{
    CGFloat height = self.selections.count * maximumCellHeight;
    if (height > self.fullFrame.size.height/2) height = self.maxItemsCanBeDisplayed * maximumCellHeight;
    return height + selectionViewBottomInset;
}

-(UIEdgeInsets)getInsetForSelectionFrame{
    return UIEdgeInsetsMake(self.frame.size.height, 0, 0, 0);
}

-(NSInteger)numberOfVisibleCells{
    return self.selections.count > self.maxItemsCanBeDisplayed ? self.maxItemsCanBeDisplayed : self.selections.count;
}



@end