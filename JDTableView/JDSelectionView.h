//
//  UISelectionCollectionView.h
//  JDTableView
//
//  Created by James Dunay on 1/31/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDSelectionView : UICollectionView

@property(nonatomic)CGFloat maxHeight;

-(CGFloat)getPercentageClosed;
-(CGFloat)getCenterHeight;
-(CGFloat)getHeight;

@end
