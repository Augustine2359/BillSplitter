//
//  SplitItemHeaderView.m
//  BillSplitterCoreData
//
//  Created by Augustine on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitItemHeaderView.h"

@implementation SplitItemHeaderView

@synthesize button;
@synthesize nameLabel;
@synthesize contributionLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.button = [UIButton buttonWithType:UIButtonTypeCustom];
      self.button.frame = self.frame;
      self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, 40)];
      self.contributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, 40)];
      
      [self.button addSubview:self.nameLabel];
      [self.button addSubview:self.contributionLabel];
      [self addSubview:self.button];
    }
    return self;
}

@end
