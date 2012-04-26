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
#import "SplitterTextField.h"

@implementation SplitItemTableViewCell

@synthesize expandToggleButton;
@synthesize nameLabel;
@synthesize contributionTextField;

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

      self.contributionTextField = [[SplitterTextField alloc] init];
      self.contributionTextField.frame = CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, 40);
      self.contributionTextField.keyboardType = UIKeyboardTypeDecimalPad;
      self.contributionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
      [self.expandToggleButton addSubview:self.contributionTextField];
      
      self.percentageSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, 40, self.contentView.frame.size.width - 60, 40)];
      self.percentageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      self.percentageSlider.minimumValue = 0;
      self.percentageSlider.maximumValue = 100;
      [self.contentView addSubview:self.percentageSlider];

      self.percentageTextField = [[SplitterTextField alloc] init];
      self.percentageTextField.frame = CGRectMake(0, 40, 60, 40);
      self.percentageTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
      self.percentageTextField.keyboardType = UIKeyboardTypeDecimalPad;
      self.percentageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
      [self.contentView addSubview:self.percentageTextField];
    }
    return self;
}

- (void)updateContributions
{
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  self.contributionTextField.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:self.contribution.amount]];
  self.percentageSlider.value = [self.contribution.amount floatValue] / [self.contribution.item.finalPrice floatValue] * 100;
  self.percentageTextField.text = [NSString stringWithFormat:@"%.1f%%", self.percentageSlider.value];
}

@end
