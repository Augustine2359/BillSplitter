//
//  SplitItemTableViewCell.m
//  BillSplitterCoreData
//
//  Created by Augustine on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitItemTableViewCell.h"
#import "Item.h"

#import "Person.h"
@implementation SplitItemTableViewCell

@synthesize contribution;
@synthesize percentageLabel;
@synthesize percentageSlider;
@synthesize amountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contribution:(Contribution *)theContribution
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.contribution = theContribution;
      self.percentageSlider = [[UISlider alloc] initWithFrame:self.contentView.frame];
      self.percentageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      self.percentageSlider.minimumValue = 0;
      self.percentageSlider.maximumValue = 100;
      [self updateContributions];
      [self.contentView addSubview:self.percentageSlider];
    }
    return self;
}

- (void)updateContributions
{
  self.percentageSlider.value = [self.contribution.amount floatValue] / [self.contribution.item.finalPrice floatValue] * 100;
}

@end
