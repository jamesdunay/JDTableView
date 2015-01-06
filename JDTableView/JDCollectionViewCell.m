//
//  JDCollectionViewCell.m
//  JDTableView
//
//  Created by james.dunay on 12/25/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDCollectionViewCell.h"

@interface JDCollectionViewCell()

@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) UIView* accessoryView;

@end

@implementation JDCollectionViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 320, 50)];
        _baseTransform = self.layer.transform;
        
        CATransform3D transform = CATransform3DMakeScale(2, 2, 1);
        transform = CATransform3DTranslate(transform, 50, 0, 0);
        _magnifiedTransform = transform;
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = _titleLabel.frame;
        
        _accessoryView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _accessoryView.center = CGPointMake(300, self.contentView.center.y);
        _accessoryView.backgroundColor = [UIColor whiteColor];
        _accessoryView.hidden = YES;
    }
    
    return self;
}

-(void)setItem:(CollectionViewItem *)item{
    _item = item;
    _accessoryView.hidden = !_item.isSelected;
}

-(void)tapped:(id)sender{
    [self.kJDCellDelegate touchingCell:self];
}

-(void)layoutSubviews{
    [super layoutSubviews];

    [_button addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchDown];
//    [self addSubview:_button];
    
    _titleLabel.textColor = [UIColor whiteColor];

    [self addSubview:_titleLabel];
    [self addSubview:_accessoryView];
}

-(void)toggleSelected{
    _item.isSelected = _item.isSelected ? NO : YES;
    _accessoryView.hidden = !_item.isSelected;
}


@end
