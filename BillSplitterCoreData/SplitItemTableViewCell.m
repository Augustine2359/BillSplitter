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
@synthesize percentageTextField;
@synthesize percentageSlider;
@synthesize amountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contribution:(Contribution *)theContribution
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.contribution = theContribution;
      self.percentageSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, 0, self.contentView.frame.size.width - 60, self.contentView.frame.size.height)];
      self.percentageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
      self.percentageSlider.minimumValue = 0;
      self.percentageSlider.maximumValue = 100;
      [self.contentView addSubview:self.percentageSlider];

      self.percentageTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 60, self.contentView.frame.size.height)];
      self.percentageTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
      [self.contentView addSubview:self.percentageTextField];

      [self updateContributions];
    }
    return self;
}

- (void)updateContributions
{
  self.percentageSlider.value = [self.contribution.amount floatValue] / [self.contribution.item.finalPrice floatValue] * 100;
  self.percentageTextField.text = [NSString stringWithFormat:@"%.1f%%", self.percentageSlider.value];
}

@end
