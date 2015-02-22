//
//  JDSelectionViewFooter.m
//  JDTableView
//
//  Created by James Dunay on 2/21/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import "JDSelectionViewFooter.h"

@interface JDSelectionViewFooter()

@property(nonatomic, strong) UIImageView* arrowIndicator;
@property(nonatomic, strong) UIView* divider;

@property(nonatomic) BOOL initialConstraintsSet;

@end

@implementation JDSelectionViewFooter

-(id)init{
    self = [super init];
    if (self) {
        self.arrowIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WhiteArrow"]];
        self.arrowIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.arrowIndicator.contentMode = UIViewContentModeBottom;
        [self addSubview:self.arrowIndicator];
        
        self.divider = [[UIView alloc] init];
        self.divider.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.divider];
        [self createDividerSubviews];
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


-(void)viewIsLocked:(BOOL)locked{
    if (locked) self.divider.alpha = 1.f;
    else self.divider.alpha = .3;
}

-(NSMutableArray*)defaultConstraints{
    NSMutableArray* constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_arrowIndicator]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_arrowIndicator)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_arrowIndicator]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_arrowIndicator)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_divider]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_divider)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_divider]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_divider)
                                      ]];
    
    
    return constraints;
}

-(void)createDividerSubviews{
    UIView* leftBar = [[UIView alloc] init];
    leftBar.translatesAutoresizingMaskIntoConstraints = NO;
    leftBar.backgroundColor = [UIColor whiteColor];
    [self.divider addSubview:leftBar];
    
    UIView* rightBar = [[UIView alloc] init];
    rightBar.translatesAutoresizingMaskIntoConstraints = NO;
    rightBar.backgroundColor = [UIColor whiteColor];
    [self.divider addSubview:rightBar];
    
    [self.divider addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[leftBar]-15-[rightBar(==leftBar)]-20-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(leftBar, rightBar)
                                  ]];
    
    NSDictionary* metrics = @{@"height" : @(.5f)};
    
    [self.divider addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[leftBar(==height)]-2-|"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:NSDictionaryOfVariableBindings(leftBar)
                                  ]];
    
    [self.divider addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[rightBar(==height)]-2-|"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:NSDictionaryOfVariableBindings(rightBar)
                                  ]];
    
    
}

@end
