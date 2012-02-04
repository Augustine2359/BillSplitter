//
//  SplitterTextField.m
//  BillSplitter
//
//  Created by Augustine on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitterTextField.h"

@implementation SplitterTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  UIMenuController *menuController = [UIMenuController sharedMenuController];
  if (menuController)
    [UIMenuController sharedMenuController].menuVisible = NO;
  return NO;
}

@end
