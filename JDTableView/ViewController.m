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
#import "JDSelectionView.h"
#import "SelectionViewFlowLayout.h"

#import "MasterSelectionView.h"

static CGFloat const baseThreshold = 55.f;
static CGFloat const activeThreshold = 6.f;
static CGFloat const titleThreshold = 50.f;
static CGFloat const maximumCellHeight = 120.f;


//static CGFloat const minimumCellHeight = 0.f;
//static CGFloat const selectedViewDelayExpandingTheshold = 200.f;
//static CGFloat const selectionViewBounceAmount = 125.f;

@interface ViewController ()

@property (nonatomic, strong) JDCollectionView* collectionView;
@property (nonatomic, strong) JDCollectionView* imageCollectionView;

@property (nonatomic, strong) JDCollectionViewCell* centerCell;
//@property (nonatomic, strong) JDSelectionView* selectionView;
@property (nonatomic, strong) JDFastDisplayView* fastDisplayView;
@property (nonatomic, strong) THSpringyFlowLayout* springyFlowLayout;


@property(nonatomic, strong) MasterSelectionView *masterSelectionView;

@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableArray* selections;

@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic) BOOL isScrollingFast;
@property (nonatomic) CGFloat speedThreshold;

@property (nonatomic) CGFloat selectedCellHeight;

@property (nonatomic, strong) NSIndexPath* activeIndex;

@property (nonatomic) BOOL selectedViewCanContract;
@property (nonatomic) BOOL selectedViewCanExpand;
@property (nonatomic) CGFloat yOffsetStartingPoint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray* tempNames = @[@"James", @"Donna", @"Loran", @"Mike", @"Ernesto", @"Lydia", @"Jordan", @"Thomas", @"Matthew", @"Kenan", @"Johnny", @"Robert", @"Katianne", @"Donna", @"Whitney", @"Michelle", @"Carson", @"Christina", @"Kristy", @"Bert", @"Adam", @"Ashley", @"Riley", @"Alice", @"Sue"];

    UIImage* laThirdPhoto = [UIImage imageNamed:@"LA_1.png"];
    UIImage* laSecondPhoto = [UIImage imageNamed:@"LA_2.png"];
    UIImage* laMainPhoto = [UIImage imageNamed:@"LA_3.png"];
    
    UIImage* denverMainPhoto = [UIImage imageNamed:@"Denver_2.png"];
    UIImage* denverSecondPhoto = [UIImage imageNamed:@"Denver_1.png"];

    UIImage* costaMain = [UIImage imageNamed:@"Costa_2.png"];
    UIImage* costaSecond = [UIImage imageNamed:@"Costa_1.png"];

    
    NSDictionary* laDict = @{@"title" : @"LA THANKSGIVING",
                               @"date" : @"NOV 27, 2014",
                               @"numberOfPhotos" : @49,
                               @"photos" : @[laMainPhoto, laSecondPhoto, laThirdPhoto]
                               };
    
    NSDictionary* denverDict = @{@"title" : @"DENVER",
                             @"date" : @"AUG 17, 2014",
                             @"numberOfPhotos" : @171,
                             @"photos" : @[denverMainPhoto, denverSecondPhoto]
                             };
    
    NSDictionary* costaDict = @{@"title" : @"COSTA RICA",
                             @"date" : @"MAR 03, 2013",
                             @"numberOfPhotos" : @73,
                             @"photos" : @[costaMain, costaSecond]
                             };
    
    
    NSArray* infoDictionary = @[laDict, denverDict, costaDict];
    
    _items = [[NSMutableArray alloc] init];
    _selections = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i++) {
        for (NSDictionary* dict in infoDictionary) {
            CollectionViewItem* item = [[CollectionViewItem alloc] init];
            item.title = dict[@"title"];
            item.date = dict[@"date"];
            item.photos = dict[@"photos"];
            item.numberOfPhotos = dict[@"numberOfPhotos"];
            [self.items addObject:item];
        }
    }
    
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:self.view.frame];
    background.image = [UIImage imageNamed:@"background.png"];
    background.alpha = .65f;
    [self.view addSubview:background];
    
    
    
    _speedThreshold = baseThreshold;
    _selectedCellHeight = 50.f;

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 2;
    
     _springyFlowLayout = [[THSpringyFlowLayout alloc] init];
    _collectionView = [[JDCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flow];
    [_collectionView registerClass:[JDCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tag = 1;
    self.collectionView.backgroundColor = [UIColor clearColor];


    
    self.imageCollectionView = [[JDCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.springyFlowLayout];
    [self.imageCollectionView registerClass:[JDCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.imageCollectionView.dataSource = self;
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.tag = 3;
    self.self.imageCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.imageCollectionView];
    [self.view addSubview:_collectionView];
    
    self.masterSelectionView = [[MasterSelectionView alloc] init];
    self.masterSelectionView.fullFrame = self.view.frame;
    self.masterSelectionView.selectionViewDelegate = self;
    [self.view addSubview:self.masterSelectionView];
    
    _fastDisplayView = [[JDFastDisplayView alloc] initWithFrame:self.view.frame];
    _fastDisplayView.alpha = 0;
    _fastDisplayView.userInteractionEnabled = NO;
    _fastDisplayView.backgroundColor = [UIColor colorWithWhite:0.f alpha:.8f];
//    [self.view addSubview:_fastDisplayView];
}


-(void)selectionsSwipedClosed{
    CGPoint newContentOffset = CGPointMake(0, self.collectionView.contentOffset.y + (self.masterSelectionView.frame.size.height - 51.f));
    [self.collectionView setContentOffset:newContentOffset animated:YES];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == 1 || collectionView.tag == 3)     return [_items count];
    else return [_selections count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* reuseID = @"cell";

    JDCollectionViewCell* cell = (JDCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];;
    cell.kJDCellDelegate = self;
    cell.indexPath = indexPath;
    cell.item = self.items[indexPath.row];
    
    [cell shouldShowImages:collectionView.tag == 3];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (collectionView.tag == 1) {
        collectionView.scrollIndicatorInsets = [self getNewCollectionViewInset];
        return [self getNewCollectionViewInset];
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 1 || collectionView.tag == 3) {
        return CGSizeMake(self.view.frame.size.width, maximumCellHeight);
    }else {
        return CGSizeMake(self.view.frame.size.width, _selectedCellHeight);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _selectedCellHeight = 50.f;
    
    JDCollectionViewCell* cell = (JDCollectionViewCell*)[_collectionView cellForItemAtIndexPath:indexPath];
    CollectionViewItem* item = (CollectionViewItem*)_items[indexPath.row];
    
    if (!item.isSelected) {
        [cell toggleSelected];
        [self.masterSelectionView addItem:item];
    }else{
        [cell toggleSelected];
        [self.masterSelectionView removeItem:item];
    }

    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
    } completion:^(BOOL finished) {}];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    if(scrollView.contentOffset.y == 0.f){
//        self.selectedCellHeight = maximumCellHeight;
//        [self animateCollectionsForNewSelection];
//        ^^ This should animate, and possibly be in EndDragging:WithVelo:
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self setIsScrollingFast:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.imageCollectionView.contentOffset = scrollView.contentOffset;//CGPointMake(0, .y/2);
    
    if (scrollView.tag == 1) {
        CGPoint currentOffset = scrollView.contentOffset;
        CGFloat distance = currentOffset.y - _lastOffset.y;
        CGFloat scrollSpeed = fabsf(distance);
        if (scrollSpeed > _speedThreshold) {
            [self setIsScrollingFast:YES];
        } else {
            [self setIsScrollingFast:NO];
        }
        
        [self.masterSelectionView adjustSelectedCellHeightWithOffset:distance andScrollView:scrollView];
        
        _lastOffset = currentOffset;
    }
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
//                                 _fastDisplayView.alpha = 1.f;
//                                 _collectionView.alpha = .2f;
                             } completion:nil];
        }
        
        NSIndexPath* centerCellIndexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(0, _collectionView.contentOffset.y + self.view.center.y)];
        if (centerCellIndexPath) {
//            [_fastDisplayView setDisplayLabelText:(NSString*)((CollectionViewItem*)_items[centerCellIndexPath.row]).name];//[NSString stringWithFormat:@"%ld", centerCellIndexPath.row]];
        }
        
    }else{
        if (!_fastDisplayView.hidden) {
            [UIView animateWithDuration:.2f
                                  delay:.0f
                                options: UIViewAnimationOptionAllowUserInteraction
                             animations:^{
//                                 _fastDisplayView.alpha = 0.f;
//                                 _collectionView.alpha = 1.f;
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

        _centerCell = cell;
    }
    
    _centerCell.alpha = 1.f;

}

#pragma Mark SelectionView Controls


#pragma Mark View Adjustments





-(UIEdgeInsets)getNewCollectionViewInset{
    return UIEdgeInsetsMake(self.masterSelectionView.frame.size.height, 0, 0, 0);
}

-(CGRect)getNewSelectionViewFrame{
    return CGRectMake(0, 0, self.view.frame.size.width, [self getHeightOfSelectionView]);
}

-(CGFloat)getHeightOfSelectionView{
    CGFloat height = _selections.count * self.selectedCellHeight;
    
    if (height > self.view.frame.size.height/2) height = self.view.frame.size.height/2;
    if (height < titleThreshold) height = titleThreshold;
    
    return height;
}

-(CGFloat)getCurrentSelectionViewMaxHeight{
    CGFloat height = _selections.count * maximumCellHeight;
    if (height > self.view.frame.size.height/2) height = self.view.frame.size.height/2;
    return height;
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