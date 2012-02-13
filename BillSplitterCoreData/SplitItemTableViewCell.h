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

@property (nonatomic, strong) Contribution *contribution;
@property (nonatomic, strong) UILabel *percentageLabel;
@property (nonatomic, strong) UISlider *percentageSlider;
@property (nonatomic, strong) UILabel *amountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contribution:(Contribution *)theContribution;

@end