//
//  JDCollectionViewCell.m
//  JDTableView
//
//  Created by james.dunay on 12/25/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDCollectionViewCell.h"
#import "JDHeaderView.h"
#import "JDCellImageSection.h"

@interface JDCollectionViewCell()

@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) UIView* accessoryView;


@property (nonatomic, strong) JDHeaderView* headerView;
@property (nonatomic, strong) JDCellImageSection* imageSectionView;

@property (nonatomic)BOOL initialConstraintsSet;

@end

@implementation JDCollectionViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _accessoryView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _accessoryView.center = CGPointMake(300, self.contentView.center.y);
        _accessoryView.backgroundColor = [UIColor whiteColor];
        _accessoryView.hidden = YES;
        
        self.headerView = [[JDHeaderView alloc] init];
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.headerView];
        
        self.imageSectionView = [[JDCellImageSection alloc] init];
        self.imageSectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
        [self addSubview:self.imageSectionView];
    }
    return self;
}

-(void)setItem:(CollectionViewItem *)item{
    _item = item;
    
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:item.title attributes:@{NSKernAttributeName : @(1.f)}];
    
    self.headerView.titleLabel.attributedText = attributedString;
    self.headerView.numberOfPhotosLabel.text = [item.numberOfPhotos stringValue];
    self.headerView.dateLabel.text = item.date;
    [self.imageSectionView setImages:item.photos];
    
//    _accessoryView.hidden = !_item.isSelected;
}

-(void)shouldShowImages:(BOOL)showImages{
    if (showImages) {
        self.headerView.hidden = YES;
        self.imageSectionView.hidden = NO;
    }else{
        self.imageSectionView.hidden = YES;
        self.headerView.hidden = NO;
    }
}

-(void)tapped:(id)sender{
    [self.kJDCellDelegate touchingCell:self];
}

-(void)layoutSubviews{
    if (!self.initialConstraintsSet) {
        [self addConstraints:[self defaultConstraints]];
    
        self.initialConstraintsSet = YES;
    }
    
    [super layoutSubviews];
    [_button addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchDown];
    //    [self addSubview:_button];
    //    [self addSubview:_accessoryView];
}

-(NSArray*)defaultConstraints{
    NSMutableArray* constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-19-[_headerView]-19-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_headerView)
                                      ]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[_imageSectionView]-12-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_imageSectionView)
                                      ]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView(==41)]-[_imageSectionView]-16-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_headerView, _imageSectionView)
                                      ]];
    
    return constraints;
}

-(void)toggleSelected{
    _item.isSelected = _item.isSelected ? NO : YES;
    _accessoryView.hidden = !_item.isSelected;
}

@end
