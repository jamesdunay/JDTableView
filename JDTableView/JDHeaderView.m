//
//  JDHeaderView.m
//  JDTableView
//
//  Created by James Dunay on 2/6/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import "JDHeaderView.h"

@interface JDHeaderView()

@property(nonatomic)BOOL initialConstraintsSet;
@property(nonatomic, strong)UIView* metrics;
@property(nonatomic, strong)UIView* line;
@property(nonatomic, strong)UIImageView* cameraIcon;

@end

@implementation JDHeaderView

-(id)init{
    self = [super init];
    if(self){
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.f];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        self.metrics = [[UIView alloc] init];
        self.metrics.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.metrics];
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:8.f];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.alpha = .4f;
        self.dateLabel.textColor = [UIColor whiteColor];
        [self.metrics addSubview:self.dateLabel];
        
        self.numberOfPhotosLabel = [[UILabel alloc] init];
        self.numberOfPhotosLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.numberOfPhotosLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:12.f];
        self.numberOfPhotosLabel.textAlignment = NSTextAlignmentRight;
        self.numberOfPhotosLabel.textColor = [UIColor whiteColor];
        [self.metrics addSubview:self.numberOfPhotosLabel];
        
        self.cameraIcon = [[UIImageView alloc] init];
        self.cameraIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.cameraIcon.image = [UIImage imageNamed:@"camera.png"];
        self.cameraIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.metrics addSubview:self.cameraIcon];
        
        self.line = [[UIView alloc] init];
        self.line.translatesAutoresizingMaskIntoConstraints = NO;
        self.line.backgroundColor = [UIColor whiteColor];
        self.line.alpha = .25f;
        [self addSubview:self.line];
        
    }
    
    return self;
}

-(void)layoutSubviews{
    if(!self.initialConstraintsSet){
        [self addConstraints:self.defaultConstraints];
        [self.metrics addConstraints:self.metricConstraints];
        self.initialConstraintsSet = YES;
    }
    
    [super layoutSubviews];
}

-(NSArray*)defaultConstraints{
    NSMutableArray* constraints = [NSMutableArray new];
    
    NSDictionary* metrics = @{@"line" : @.5f};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_titleLabel(==28)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_titleLabel)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_metrics]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_metrics)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel(==170)][_metrics]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_metrics, _titleLabel)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_line]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_line)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_line(==line)]|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:NSDictionaryOfVariableBindings(_line)
                                      ]];
    return constraints;
}

-(NSArray*)metricConstraints{
    NSMutableArray* constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_numberOfPhotosLabel(==_dateLabel)]-2-[_dateLabel]-6-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_dateLabel, _numberOfPhotosLabel)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dateLabel]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_dateLabel)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_numberOfPhotosLabel]-3-[_cameraIcon]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_numberOfPhotosLabel, _cameraIcon)
                                      ]];
    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.cameraIcon
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.numberOfPhotosLabel
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.f
                                                         constant:-1.f
                            ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.cameraIcon
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.numberOfPhotosLabel
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.f
                                                         constant:-1.f
                            ]];
    
    return constraints;
}

@end
