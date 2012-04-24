//
//  ItemTableViewCell.h
//  BillSplitter
//
//  Created by Augustine on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ItemTableViewCell : UITableViewCell

@property (nonatomic, strong) Item *item;

- (void)updateWithItem:(Item *)item;

@end
