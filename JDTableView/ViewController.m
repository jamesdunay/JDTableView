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
static CGFloat const maximumCellHeight = 170.f;
static CGFloat const baseTopInset = 64.f;


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

@property (nonatomic, strong) UIImageView* backgroundView;

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
    
    _speedThreshold = baseThreshold;
    _selectedCellHeight = 50.f;

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 2;
    
    self.collectionView = [[JDCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flow];
    [self.collectionView registerClass:[JDCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.tag = 1;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    
    UICollectionViewFlowLayout *flowTwo = [[UICollectionViewFlowLayout alloc] init];
    flowTwo.minimumInteritemSpacing = 0;
    flowTwo.minimumLineSpacing = 2;
    
    self.springyFlowLayout = [[THSpringyFlowLayout alloc] init];
    self.springyFlowLayout.minimumInteritemSpacing = 0;
    self.springyFlowLayout.minimumLineSpacing = 2;
    
    self.imageCollectionView = [[JDCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowTwo];
    [self.imageCollectionView registerClass:[JDCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.imageCollectionView.dataSource = self;
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.tag = 3;
    self.self.imageCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.imageCollectionView];

    
    self.masterSelectionView = [[MasterSelectionView alloc] init];
    self.masterSelectionView.fullFrame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    self.masterSelectionView.selectionViewDelegate = self;
    [self.view addSubview:self.masterSelectionView];
    
    _fastDisplayView = [[JDFastDisplayView alloc] initWithFrame:self.view.frame];
    _fastDisplayView.alpha = 0;
    _fastDisplayView.userInteractionEnabled = NO;
    _fastDisplayView.backgroundColor = [UIColor colorWithWhite:0.f alpha:.8f];
//    [self.view addSubview:_fastDisplayView];
    
    UIImage* backgroundImage = [UIImage imageNamed:@"largebackground.png"];
    
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, backgroundImage.size.height)];
    self.backgroundView.image = backgroundImage;
//    background.alpha = .65f;
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    
}


-(void)selectionsSwipedClosed{
    CGPoint newContentOffset = CGPointMake(0, self.collectionView.contentOffset.y + (self.masterSelectionView.frame.size.height - 38.f));
//    ^^ using -38 here to make sure that the offset will close the view just past its MINIMUM threshold. This ensures that the 'selected' view will display.
    [self.imageCollectionView setContentOffset:newContentOffset animated:YES];
}

-(void)selectionsSwipedOpen:(CGFloat)maximumSelectionViewHeight{
    CGPoint newContentOffset = CGPointMake(0, self.collectionView.contentOffset.y - maximumSelectionViewHeight + 40.f);
    [self.imageCollectionView setContentOffset:newContentOffset animated:YES];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_items count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* reuseID = @"cell";

    JDCollectionViewCell* cell = (JDCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];;
    cell.indexPath = indexPath;
    [cell shouldShowImages:collectionView.tag == 3];
    [cell setInfoWithItem:self.items[indexPath.row]];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return [self getNewCollectionViewInset];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.frame.size.width, maximumCellHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
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

    
    [self.imageCollectionView performBatchUpdates:^{
        [self.imageCollectionView reloadData];
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
    self.collectionView.contentOffset = scrollView.contentOffset;
    
    CGFloat newYPos = scrollView.contentOffset.y/scrollView.contentSize.height * (self.backgroundView.frame.size.height - self.view.frame.size.height);
    self.backgroundView.frame = CGRectMake(0, -newYPos , self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    
    
//   self.backgroundView.frame = CGRectMake(scrollView.contentOffset.y, 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
//    ^^ THIS IS REAL COOL, could be some sort of section switching, like maybe backgrounds for something like seasons? Notice the Y offset in the X
    
    
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
    return UIEdgeInsetsMake(self.masterSelectionView.frame.size.height + baseTopInset, 0, 0, 0);
}

-(CGFloat)getCurrentSelectionViewMaxHeight{
    CGFloat height = _selections.count * maximumCellHeight;
    if (height > self.view.frame.size.height/2) height = self.view.frame.size.height/2;
    return height;
}


#pragma Mark Custom Delegate Methods


#pragma Mark Helper Methodss

-(JDCollectionViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath{
    return (JDCollectionViewCell*)[_collectionView cellForItemAtIndexPath:indexPath];
}



@end