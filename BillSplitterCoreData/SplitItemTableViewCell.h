//
//  SplitItemTableViewCell.h
//  BillSplitterCoreData
//
//  Created by Augustine on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contribution.h"

@interface SplitItemTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *expandToggleButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contributionLabel;

@property (nonatomic, strong) Contribution *contribution;
@property (nonatomic, strong) UISlider *percentageSlider;
@property (nonatomic, strong) UITextField *percentageTextField;
@property (nonatomic, strong) UILabel *amountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contribution:(Contribution *)theContribution;
- (void)updateContributions;

@end