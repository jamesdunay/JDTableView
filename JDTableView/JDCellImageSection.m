//
//  JDCellImageSection.m
//  JDTableView
//
//  Created by James Dunay on 2/6/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import "JDCellImageSection.h"
#import <QuartzCore/QuartzCore.h>

@interface JDCellImageSection()

@property(nonatomic, strong)UIView *mainImageContainer;
@property(nonatomic, strong)UIView *secondaryView;
@property(nonatomic)BOOL initialConstraintsSet;

@property(nonatomic, strong)UIView* secondaryTopContainer;
@property(nonatomic, strong)UIView* secondaryBottomContainer;

@property(nonatomic, strong)NSDictionary* viewDictionary;

@end


@implementation JDCellImageSection

-(id)init{
    self = [super init];
    if(self){
        self.mainImageContainer = [[UIView alloc] init];
        self.mainImageContainer.backgroundColor = [UIColor clearColor];
        self.mainImageContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.mainImageContainer];
        
        self.secondaryView = [[UIView alloc] init];
        self.secondaryView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.secondaryView];
        
        self.secondaryTopContainer = [[UIView alloc] init];
        self.secondaryTopContainer.backgroundColor = [UIColor clearColor];
        self.secondaryTopContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.secondaryView addSubview:self.secondaryTopContainer];
        
        self.secondaryBottomContainer = [[UIView alloc] init];
        self.secondaryBottomContainer.backgroundColor = [UIColor clearColor];
        self.secondaryBottomContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.secondaryView addSubview:self.secondaryBottomContainer];
    }
    
    return self;
}

-(void)layoutSubviews{
    
    if(!self.initialConstraintsSet){
        [self addConstraints:self.defaultConstraints];

        self.initialConstraintsSet = YES;
    }
    
    [self.secondaryView layoutSubviews];
    [super layoutSubviews];
    
    [self setupShadowsForView:self.mainImageContainer];
    [self setupShadowsForView:self.secondaryTopContainer];
    if (self.hasTwoSecondaryImages) {
        self.secondaryBottomContainer.hidden = NO;
        [self setupShadowsForView:self.secondaryBottomContainer];
    }else{
        self.secondaryBottomContainer.hidden = YES;
    }
}


-(void)setupShadowsForView:(UIView*)view{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(0, 4, 0, 4))];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 8.0f);
    view.layer.shadowRadius = 16.f;
    view.layer.shadowOpacity = 0.4f;
    view.layer.shadowPath = shadowPath.CGPath;
}

-(void)setImages:(NSArray*)images{
    _images = images;
    [self.secondaryView removeConstraints:self.secondaryView.constraints];
    [self.secondaryView addConstraints:[self secondImageConstraintsWithMoreThanOneImage:(images.count > 2)]];
    
    [self addImage:images[0] toView:self.mainImageContainer];
    [self addImage:images[1] toView:self.secondaryTopContainer];
    if ((images.count > 2)) {
        [self addImage:images[2] toView:self.secondaryBottomContainer];
    }
}

-(void)addImage:(UIImage*)image toView:(UIView*)view{
    if (!view.subviews.count) {
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.layer.cornerRadius = 3.f;
        imageView.clipsToBounds = YES;
        imageView.layer.shouldRasterize = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:imageView];
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(imageView)
                                                  ]];
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(imageView)
                              ]];
        
    }
    
    ((UIImageView*)view.subviews[0]).image = image;
}

-(NSArray*)defaultConstraints{
    NSMutableArray* constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainImageContainer]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_mainImageContainer)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_secondaryView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_secondaryView)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainImageContainer]-6-[_secondaryView(==80)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_mainImageContainer, _secondaryView)
                                      ]];
    
    return constraints;
}


     -(NSArray*)secondImageConstraintsWithMoreThanOneImage:(BOOL)hasMoreThanOneImage{
    NSMutableArray* constraints = [NSMutableArray new];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_secondaryBottomContainer]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_secondaryBottomContainer)
                                      ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_secondaryTopContainer]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_secondaryTopContainer)
                                      ]];
    if (!hasMoreThanOneImage) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_secondaryTopContainer][_secondaryBottomContainer(==0)]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_secondaryTopContainer, _secondaryBottomContainer)
                                       ]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_secondaryTopContainer]-6-[_secondaryBottomContainer(==_secondaryTopContainer)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_secondaryTopContainer, _secondaryBottomContainer)
                                      ]];
    }
    
    return constraints;
}


-(BOOL)hasTwoSecondaryImages{
    return self.images.count > 2;
}

@end
