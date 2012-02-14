//
//  SplitItemHeaderView.h
//  BillSplitterCoreData
//
//  Created by Augustine on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitItemHeaderView : UIView

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contributionLabel;

- (void)updateContributionLabel:(NSNumber *)amount;

@end