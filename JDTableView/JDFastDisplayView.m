//
//  JDFastDisplayView.m
//  JDTableView
//
//  Created by james.dunay on 12/26/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDFastDisplayView.h"

@interface JDFastDisplayView()
@property (nonatomic, strong)UILabel* displayLabel;
@end

@implementation JDFastDisplayView

-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        _displayLabel = [[UILabel alloc] init];
        _displayLabel.textColor = [UIColor whiteColor];
        _displayLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30.f];
        _displayLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_displayLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self addConstraints:[self defaultConstraints]];
}

#pragma mark Constraints ---
- (NSArray *)defaultConstraints {
    NSMutableArray* constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_displayLabel]|"
                                                                             options:0
                                                                             metrics:0
                                                                               views:NSDictionaryOfVariableBindings(_displayLabel)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_displayLabel]|"
                                                                             options:0
                                                                             metrics:0
                                                                               views:NSDictionaryOfVariableBindings(_displayLabel)
                                      ]];
    
    return [constraints copy];
}

-(void)setDisplayLabelText:(NSString*)text{
    _displayLabel.text = text;
}



@end
