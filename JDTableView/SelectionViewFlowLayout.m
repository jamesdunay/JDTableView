//
//  SelectionViewFlowLayout.m
//  JDTableView
//
//  Created by James Dunay on 2/1/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#include <math.h>

#import "SelectionViewFlowLayout.h"
#import "JDSelectionView.h"


@interface SelectionViewFlowLayout()

@property(nonatomic) CATransform3D baseTransform;

@end

@implementation SelectionViewFlowLayout


- (id)init {
    self = [super init];
    if (self){
        [self createBaseTransform];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self createBaseTransform];
    }
    return self;
}

-(void)createBaseTransform{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0f / -500.f;
    transform = CATransform3DTranslate(transform, 0, 0, 0);
    self.baseTransform = transform;
    
    
}

/*
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    CGFloat collectionViewCollapsedPercent = 1 - [(JDSelectionView*)(self.collectionView) getPercentageClosed];
    CGFloat centerPoint = [(JDSelectionView*)(self.collectionView) getCenterHeight];
    CGFloat fullFrameOfCollectionView = [(JDSelectionView*)(self.collectionView) getHeight];
    
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:self.collectionView.bounds];
//    NSLog(@"%ld  ------------------------------------------------------------------", attributesInRect.count);
    for (UICollectionViewLayoutAttributes *item in attributesInRect) {
        item.transform3D = self.baseTransform;

        NSInteger cellDistanceFromBottom = self.collectionView.frame.size.height - (item.frame.origin.y + item.frame.size.height);
        CGFloat cellPercentageFromBottom = cellDistanceFromBottom/self.collectionView.frame.size.height;
        
        NSInteger calculatedZDepth = (cellPercentageFromBottom * 300) * collectionViewCollapsedPercent;
//      ^^ Calculation for zdepth

        CGFloat cellDistanceFromCenter = item.center.y - centerPoint;
        CGFloat cellPercentageFromCenter = cellDistanceFromCenter/fullFrameOfCollectionView;
        CGFloat yAdjustmentDistance = cellPercentageFromCenter * (collectionViewCollapsedPercent * 70);
//      ^^ Calculation for yPos
        
//        NSLog(@"Cell distance from Center: %f", cellDistanceFromCenter);
//        NSLog(@"Cell percent from Center: %f", cellPercentageFromCenter);
//        NSLog(@"Y adjustment : %f", yAdjustmentDistance);
//        
//        NSLog(@"Cell Distance  %f", cellPercentageFromBottom);
//        NSLog(@"Cell Percent %f", cellPercentageFromBottom);
//        NSLog(@"ZDepth, %ld", calculatedZDepth);
    
//        calculatedZDepth = [self quadraticEaseOut:calculatedZDepth];
    
        item.transform3D = CATransform3DTranslate(item.transform3D, 0, 0, -calculatedZDepth);
        
        CGFloat alphaValue = 1 - (collectionViewCollapsedPercent * cellPercentageFromBottom);
        item.alpha = alphaValue;
    }
    
    return attributesInRect;
}
 */



-(CGFloat)quadraticEaseIn:(CGFloat)p{
    return p * p;
}

-(CGFloat)quadraticEaseOut:(CGFloat)p{
    return -(p * (p - 2));
}

-(CGFloat)quarticEaseIn:(CGFloat)p{
    return p * p * p * p;
}

@end







