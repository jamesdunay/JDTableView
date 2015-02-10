//
//  JDCollectionViewCell.h
//  JDTableView
//
//  Created by james.dunay on 12/25/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewItem.h"

@protocol JDCollectionViewCellDelegate <NSObject>
-(void)touchingCell:(id)cell;
@end


@interface JDCollectionViewCell : UICollectionViewCell

//@property (nonatomic) CATransform3D baseTransform;
//@property (nonatomic) CATransform3D magnifiedTransform;
@property (nonatomic) id <JDCollectionViewCellDelegate> kJDCellDelegate;
//@property (nonatomic, copy) void (^onTouch)(NSIndexPath *);
@property (nonatomic, strong) CollectionViewItem* item;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) BOOL isActive;
//@property (nonatomic) BOOL isSelected;


-(void)shouldShowImages:(BOOL)showImages;
-(void)toggleSelected;

@end
