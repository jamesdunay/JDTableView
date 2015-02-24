//
//  MasterSelectionView.h
//  JDTableView
//
//  Created by James Dunay on 2/3/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewItem.h"



@protocol SelectionViewDelegate <NSObject>
-(void)selectionsSwipedClosed;
-(void)selectionsSwipedOpen:(CGFloat)maximumSelectionViewHeight;
-(void)adjustScrollViewOffsetTo:(CGFloat)offset;
-(void)getNewContentInsetsAndAdjustOffset;
-(void)moveMaskToPosition:(CGFloat)yPos;
@end

@interface MasterSelectionView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) CGFloat selectedCellHeight;
@property (nonatomic) CGRect fullFrame;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) NSLayoutConstraint* backgroundTopConstraint;
@property (nonatomic, strong) id <SelectionViewDelegate> selectionViewDelegate;

@property (nonatomic) BOOL viewIsLockedUp;

-(void)adjustSelectedCellHeightWithOffset:(CGFloat)offsetChange andScrollView:(UIScrollView*)scrollView;
-(void)addItem:(CollectionViewItem*)item;
-(void)removeItem:(CollectionViewItem *)item;

@end
