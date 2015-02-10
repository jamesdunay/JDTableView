//
//  UISelectionCollectionView.m
//  JDTableView
//
//  Created by James Dunay on 1/31/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#include <math.h>

#import "JDSelectionView.h"
#import "SelectionViewFlowLayout.h"

static CGFloat const titleDisplayThreshold = 50.f;

@interface JDSelectionView()
@property(nonatomic, strong)UILabel* titleLabel;
@end

@implementation JDSelectionView

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, titleDisplayThreshold)];
        self.titleLabel.text = @"SELECTED";
        self.titleLabel.alpha = 0.f;
        
        [self addSubview:self.titleLabel];
    }
    return self;
}


-(void)setFrame:(CGRect)frame{
    CGRect newFrame = frame;
    if (frame.size.height < 50.f) newFrame = CGRectMake(0, 0, frame.size.width, 50.f);
    else if (frame.size.height > self.maxHeight) newFrame = CGRectMake(0, 0, frame.size.width, self.maxHeight );
    
    [super setFrame:newFrame];
    if (frame.size.height <= titleDisplayThreshold) self.titleLabel.alpha = 1.f;
    else self.titleLabel.alpha = 0.f;

    self.titleLabel.frame = CGRectMake(0, self.contentOffset.y, newFrame.size.width, newFrame.size.height);
}


-(CGFloat)getPercentageClosed{
    
    CGFloat currentAvailableHeight = self.frame.size.height - titleDisplayThreshold;
    CGFloat maximumAvailableHeight = self.maxHeight - titleDisplayThreshold;
    CGFloat currentHeightPercentage = currentAvailableHeight/maximumAvailableHeight;
    
    if (isinf(currentHeightPercentage)) currentHeightPercentage = 0;
    
//    NSLog(@"Current Height : %f", currentAvailableHeight);
//    NSLog(@"Maximum Av. Height : %f", maximumAvailableHeight);
//    NSLog(@"Height Percentage : %f", currentHeightPercentage);
//    NSLog(@"---------------------");

    return currentHeightPercentage;
}


-(CGFloat)getCenterHeight{
    return self.center.y - self.frame.origin.y;
}


-(CGFloat)getHeight{
    return self.frame.size.height;
}

@end








