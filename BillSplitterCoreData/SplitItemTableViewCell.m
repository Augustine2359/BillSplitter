//
//  SplitItemTableViewCell.m
//  BillSplitterCoreData
//
//  Created by Augustine on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitItemTableViewCell.h"
#import "Item.h"
#import "DataModel.h"
#import "Person.h"

@implementation SplitItemTableViewCell

@synthesize expandToggleButton;
@synthesize nameLabel;
@synthesize contributionLabel;

@synthesize contribution;
@synthesize percentageTextField;
@synthesize percentageSlider;
@synthesize amountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contribution:(Contribution *)theContribution
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.clipsToBounds = YES;

      self.expandToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
      self.expandToggleButton.frame = CGRectMake(0, 0, self.frame.size.width, 40);
      self.expandToggleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      [self.contentView addSubview:self.expandToggleButton];

      self.contribution = theContribution;
      self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, 40)];
      [self.expandToggleButton addSubview:self.nameLabel];

      self.contributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, 40)];
      [self.expandToggleButton addSubview:self.contributionLabel];

      self.percentageSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, 40, self.contentView.frame.size.width - 60, 40)];
      self.percentageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      self.percentageSlider.minimumValue = 0;
      self.percentageSlider.maximumValue = 100;
      [self.contentView addSubview:self.percentageSlider];

      self.percentageTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, 60, 40)];
      self.percentageTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
      [self.contentView addSubview:self.percentageTextField];
    }
    return self;
}

- (void)updateContributions
{
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  self.contributionLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:self.contribution.amount]];
  self.percentageSlider.value = [self.contribution.amount floatValue] / [self.contribution.item.finalPrice floatValue] * 100;
  self.percentageTextField.text = [NSString stringWithFormat:@"%.1f%%", self.percentageSlider.value];
}

@end
