//
//  CollectionViewItem.h
//  JDTableView
//
//  Created by james.dunay on 1/5/15.
//  Copyright (c) 2015 James.Dunay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionViewItem : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSObject *name;
@property (nonatomic) BOOL isSelected;

@end