//
//  SplitterTextField.m
//  BillSplitter
//
//  Created by Augustine on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitterTextField.h"

@implementation SplitterTextField

- (id)init
{
  self = [super init];
  if (self)
  {
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.frame = CGRectMake(0, 0, self.superview.bounds.size.width, 30);
    doneButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    self.inputAccessoryView = doneButton;
  }

  return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  UIMenuController *menuController = [UIMenuController sharedMenuController];
  if (menuController)
    [UIMenuController sharedMenuController].menuVisible = NO;
  return NO;
}

@end
