//
//  JDTitleView.h
//  JDTableView
//
//  Created by James Dunay on 2/22/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDTitleView : UIView

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* counterLabel;

-(void)setTextColor:(UIColor*)color;

@end
