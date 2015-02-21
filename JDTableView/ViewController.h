//
//  ViewController.h
//  JDTableView
//
//  Created by james.dunay on 12/23/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDCollectionViewCell.h"
#import "MasterSelectionView.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, SelectionViewDelegate>
@end