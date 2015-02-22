//
//  JDTitleView.m
//  JDTableView
//
//  Created by James Dunay on 2/22/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import "JDTitleView.h"

@interface JDTitleView()

@property(nonatomic) BOOL initialConstraintsSet;

@end

@implementation JDTitleView

-(id)init{
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.f];
        [self addSubview:self.titleLabel];
        
        self.counterLabel = [[UILabel alloc] init];
        self.counterLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.counterLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.f];
        self.counterLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.counterLabel];
    }
    return self;
}

-(void)layoutSubviews{
    if (!self.initialConstraintsSet) {
        [self addConstraints:[self defaultConstraints]];
        self.initialConstraintsSet = YES;
    }
    
    [super layoutSubviews];
}

-(void)setTextColor:(UIColor *)color{
    self.titleLabel.textColor = color;
    self.counterLabel.textColor = color;
}

-(NSMutableArray*)defaultConstraints{
    NSMutableArray* constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_titleLabel][_counterLabel]-20-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_titleLabel, _counterLabel)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_titleLabel)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_counterLabel]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_counterLabel)
                                      ]];
    
    
    return constraints;
}

@end
