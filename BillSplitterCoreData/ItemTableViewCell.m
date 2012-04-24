//
//  ItemTableViewCell.m
//  BillSplitter
//
//  Created by Augustine on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "DataModel.h"

#define UNSETTLED_ITEM_BACKGROUND_COLOR [UIColor redColor]
#define UNSETTLED_ITEM_TEXT_COLOR [UIColor redColor]
#define SETTLED_ITEM_BACKGROUND_COLOR [UIColor greenColor]
#define SETTLED_ITEM_TEXT_COLOR [UIColor blackColor]

@interface ItemTableViewCell()

@property (nonatomic, strong) UILabel *itemQuantityLabel;
@property (nonatomic, strong) UILabel *itemNameLabel;
@property (nonatomic, strong) UILabel *itemPriceLabel;

@end

@implementation ItemTableViewCell

@synthesize item;
@synthesize itemQuantityLabel;
@synthesize itemNameLabel;
@synthesize itemPriceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self)
  {
    self.textLabel.textAlignment = UITextAlignmentCenter;
    
    self.itemQuantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, self.frame.size.height)];
    self.itemQuantityLabel.backgroundColor = [UIColor redColor];
    self.itemQuantityLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.itemQuantityLabel];

    self.itemPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 0, 80, self.frame.size.height)];
    self.itemPriceLabel.backgroundColor = [UIColor blueColor];
    self.itemPriceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:self.itemPriceLabel];
    
    self.itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.itemQuantityLabel.frame), 0, CGRectGetMinX(self.itemPriceLabel.frame) - CGRectGetMaxX(self.itemQuantityLabel.frame), self.frame.size.height)];
    self.itemNameLabel.backgroundColor = [UIColor greenColor];
    self.itemNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:self.itemNameLabel];
  }
  return self;
}

- (void)updateWithItem:(Item *)theItem {
  self.item = theItem;
  
  if (theItem == nil)
  {
    self.itemQuantityLabel.hidden = YES;
    self.itemPriceLabel.hidden = YES;
    self.itemNameLabel.hidden = YES;
    self.textLabel.hidden = NO;
    self.textLabel.text = @"Tap here to add a new item";
  }
  else 
  {
    self.textLabel.hidden = YES;
    self.itemQuantityLabel.hidden = NO;
    self.itemPriceLabel.hidden = NO;
    self.itemNameLabel.hidden = NO;
    self.itemNameLabel.text = theItem.name;
    
    self.itemQuantityLabel.text = [NSString stringWithFormat:@"%@X", theItem.quantity];
    
    NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
    self.itemPriceLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:theItem.finalPrice]];
    if (theItem.finalPrice == nil)
      self.itemPriceLabel.text = nil;

    NSNumber *totalContributions = [item calculateContributions];
    if ([totalContributions floatValue] < [item.finalPrice floatValue])
      self.itemPriceLabel.textColor = UNSETTLED_ITEM_TEXT_COLOR;
    else
      self.itemPriceLabel.textColor = SETTLED_ITEM_TEXT_COLOR;

  }
  
}

@end