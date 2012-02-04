//
//  ItemTableViewCell.m
//  BillSplitter
//
//  Created by Augustine on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemTableViewCell.h"

@implementation ItemTableViewCell

@synthesize item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier item:(Item *)theItem
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.item = theItem;
  }
  return self;
}

@end
