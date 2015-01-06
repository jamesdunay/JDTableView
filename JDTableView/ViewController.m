//
//  ViewController.m
//  JDTableView
//
//  Created by james.dunay on 12/23/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "ViewController.h"
#import "JDCollectionView.h"
#import "THSpringyFlowLayout.h"
#import "JDFastDisplayView.h"
#import "CollectionViewItem.h"


static CGFloat const baseThreshold = 55.f;
static CGFloat const activeThreshold = 6.f;
static CGFloat const cellHeight = 50.f;


@interface ViewController ()

@property (nonatomic, strong) JDCollectionView* collectionView;
@property (nonatomic, strong) JDCollectionViewCell* centerCell;
@property (nonatomic, strong) JDCollectionView* selectionView;
@property (nonatomic, strong) JDFastDisplayView* fastDisplayView;
@property (nonatomic, strong) THSpringyFlowLayout* springyFlowLayout;

@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableArray* selections;

@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic) BOOL isScrollingFast;
@property (nonatomic) CGFloat speedThreshold;

@property (nonatomic, strong) NSIndexPath* activeIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSArray* tempNames = @[@"James", @"Donna", @"Loran", @"Mike", @"Ernesto", @"Lydia", @"Jordan", @"Thomas", @"Matthew", @"Kennan", @"Johnny", @"Robert", @"Katianne", @"Donna", @"Whitney", @"Michelle", @"Carson", @"Christina", @"Kristy", @"Bert", @"Adam", @"Ashley", @"Riley", @"Alice", @"Sue"];
    
    _items = [[NSMutableArray alloc] init];
    _selections = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i++) {
        [tempNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CollectionViewItem* item = [[CollectionViewItem alloc] init];
            item.index = idx;
            item.name = obj;
            [_items addObject:item];
        }];
    }
    
    _speedThreshold = baseThreshold;
    
     _springyFlowLayout = [[THSpringyFlowLayout alloc] init];
    _collectionView = [[JDCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:_springyFlowLayout];
    [_collectionView registerClass:[JDCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tag = 1;
    [self.view addSubview:_collectionView];
    
    UICollectionViewFlowLayout* flow = [[UICollectionViewFlowLayout alloc] init];
    _selectionView = [[JDCollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 0) collectionViewLayout:flow];
    [_selectionView registerClass:[JDCollectionViewCell class] forCellWithReuseIdentifier:@"selectedCell"];
    _selectionView.dataSource = self;
    _selectionView.delegate = self;
    _selectionView.tag = 2;
    [self.view addSubview:_selectionView];
    
    _fastDisplayView = [[JDFastDisplayView alloc] initWithFrame:self.view.frame];
    _fastDisplayView.alpha = 0;
    _fastDisplayView.userInteractionEnabled = NO;
    [self.view addSubview:_fastDisplayView];
    
//    _collectionView.delaysContentTouches = NO;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == 1)     return [_items count];
    else return [_selections count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* reuseID;
    NSString* title;
    UIColor* backgroundColor;
    CollectionViewItem* item;
    
    if (collectionView.tag ==1) {
        reuseID = @"cell";
        title = (NSString*)((CollectionViewItem*)_items[indexPath.row]).name;
        backgroundColor = [UIColor clearColor];
        item = _items[indexPath.row];
    }else if (collectionView.tag == 2) {
        reuseID = @"selectedCell";
        title = (NSString*)((CollectionViewItem*)_selections[indexPath.row]).name;
        backgroundColor = [UIColor darkGrayColor];
        item = _selections[indexPath.row];
    }

    JDCollectionViewCell* cell = (JDCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    cell.backgroundColor = backgroundColor;
    cell.kJDCellDelegate = self;
    cell.titleLabel.text = title;
    cell.item = item;

    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

//    if ([indexPath isEqual:_activeIndex]) {
//        return CGSizeMake(self.view.frame.size.width, 20);
//    }else{
        return CGSizeMake(self.view.frame.size.width, cellHeight);
//    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.tag ==1 ) {
        JDCollectionViewCell* cell = (JDCollectionViewCell*)[_collectionView cellForItemAtIndexPath:indexPath];
        CollectionViewItem* item = (CollectionViewItem*)_items[indexPath.row];
        
        if (!item.isSelected) {
            [_selections addObject:(CollectionViewItem*)_items[indexPath.row]];
    //        [_items removeObjectAtIndex:indexPath.row];
            [self animateCollectionsForNewSelectionOnComplete:^{
                NSIndexPath* newSelectionIndex = [NSIndexPath indexPathForItem:(_selections.count-1) inSection:0];
                [_selectionView insertItemsAtIndexPaths:@[newSelectionIndex]];
    //            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }];
        }else{
            __block NSIndexPath *indexPathToRemove;
            [_selections enumerateObjectsUsingBlock:^(CollectionViewItem* tempItem, NSUInteger idx, BOOL *stop) {
                if ([tempItem isEqual:item]) {
                    indexPathToRemove = [NSIndexPath indexPathForItem:idx inSection:0];
                }
            }];
            
            [_selections removeObjectAtIndex:indexPathToRemove.row];
            
            [self animateCollectionsForNewSelectionOnComplete:^{
                [_selectionView deleteItemsAtIndexPaths:@[indexPathToRemove]];
            }];
        }
        
        [cell toggleSelected];
        
    } else if (collectionView.tag == 2){

        JDCollectionViewCell* tappedCell = (JDCollectionViewCell*)[_selectionView cellForItemAtIndexPath:indexPath];
        NSIndexPath* indexInCollectionView = [NSIndexPath indexPathForItem:tappedCell.item.index inSection:0];
        JDCollectionViewCell* collectionViewCell = (JDCollectionViewCell*)[_collectionView cellForItemAtIndexPath:indexInCollectionView];
        
        [_selections removeObjectAtIndex:indexPath.row];
        
        [self animateCollectionsForNewSelectionOnComplete:^{
            [_selectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
    
        
        [collectionViewCell toggleSelected];
    }


//    _springyFlowLayout.activeIndex = indexPath;
//    _activeIndex = indexPath;
//    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
//    [_collectionView performBatchUpdates:^{
//    } completion:^(BOOL finished) {
//    }];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    [self setIsScrollingFast:NO];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    NSLog(@"withVelocity");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self setIsScrollingFast:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint currentOffset = scrollView.contentOffset;
    CGFloat distance = currentOffset.y - _lastOffset.y;
    CGFloat scrollSpeed = fabsf(distance);
    if (scrollSpeed > _speedThreshold) {
        [self setIsScrollingFast:YES];
    } else {
        [self setIsScrollingFast:NO];
    }
    
    _lastOffset = currentOffset;
}


-(void)setIsScrollingFast:(BOOL)isScrollingFast{
    _isScrollingFast = isScrollingFast;
    
    if (isScrollingFast) {

        if (_fastDisplayView.hidden) {
            _speedThreshold = activeThreshold;
            _fastDisplayView.hidden = NO;
            [UIView animateWithDuration:.2f
                                  delay:.0f
                                options: UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 _fastDisplayView.alpha = 1.f;
                                 _collectionView.alpha = .2f;
                             } completion:nil];
        }
        
        NSIndexPath* centerCellIndexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(0, _collectionView.contentOffset.y + self.view.center.y)];
        if (centerCellIndexPath) {
            [_fastDisplayView setDisplayLabelText:(NSString*)((CollectionViewItem*)_items[centerCellIndexPath.row]).name];//[NSString stringWithFormat:@"%ld", centerCellIndexPath.row]];
        }
        
    }else{
        if (!_fastDisplayView.hidden) {
            [UIView animateWithDuration:.2f
                                  delay:.0f
                                options: UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 _fastDisplayView.alpha = 0.f;
                                 _collectionView.alpha = 1.f;
                             } completion:^(BOOL finished) {
                                 _fastDisplayView.hidden = YES;
                             }];
            _speedThreshold = baseThreshold;
        }
    }
}

-(void)toggleCellVisibility:(JDCollectionViewCell*)cell{
    
    if (![_centerCell isEqual:cell]) {
        _centerCell.alpha = 0.1f;

        _centerCell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
        _centerCell = cell;
    }
    
    _centerCell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.f];
    _centerCell.alpha = 1.f;

}

#pragma Mark View Adjustments

// Not really 'OnComplete'
-(void)animateCollectionsForNewSelectionOnComplete:(void(^)())complete{
    
    void (^animation)(void) = ^{
        _collectionView.frame = [self getNewCollectionViewFrame];
        _selectionView.frame = [self getNewSelectionViewFrame];
    };
    
    complete();
    
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:animation
                     completion:^(BOOL finished) {

                     }];
}


-(CGRect)getNewCollectionViewFrame{
    CGFloat yPos = _selections.count * (cellHeight + 10);
    return CGRectMake(0, yPos, 320, self.view.frame.size.height - yPos);
}

-(CGRect)getNewSelectionViewFrame{
    CGFloat height = _selections.count * (cellHeight + 10);
    return CGRectMake(0, 0, 320, height);
}


#pragma Mark Custom Delegate Methods

-(void)touchingCell:(id)cell{
        
//    [_collectionView performBatchUpdates:^{
//        
//    } completion:^(BOOL finished) {
//        
//    }];
    
//    JDCollectionViewCell* targetedCell = (JDCollectionViewCell*)cell;
//    targetedCell.isActive = YES;
    
//    targetedCell.titleLabel.alpha = .1;
}


#pragma Mark Helper Methodss

-(JDCollectionViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath{
    return (JDCollectionViewCell*)[_collectionView cellForItemAtIndexPath:indexPath];
}



@end