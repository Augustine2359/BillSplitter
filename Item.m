//
//  Item.m
//  BillSplitterCoreData
//
//  Created by Augustine on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "Contribution.h"

@implementation Item

@dynamic quantity;
@dynamic basePrice;
@dynamic finalPrice;
@dynamic tag;
@dynamic name;
@dynamic contributions;

- (NSSet *)contributions
{
  return contributions;
}

- (void)setContributions:(NSSet *)theContributions
{
  contributions = theContributions;
}

- (NSNumber *)calculateContributions
{
  CGFloat amount = 0;
  for (Contribution *contribution in self.contributions)
    amount += [contribution.amount floatValue];
  
  return [NSNumber numberWithFloat:amount];
}

- (NSNumber *)unpaidPortion
{
  CGFloat unpaidPortion = [self.finalPrice floatValue] - [[self calculateContributions] floatValue];
  return [NSNumber numberWithFloat:unpaidPortion];
}

- (void)reduceContributions:(CGFloat)oldFinalPrice
{
  if ([[self calculateContributions] floatValue] > [self.finalPrice floatValue])
    for (Contribution *contribution in self.contributions)
    {
      if ([contribution.amount isEqualToNumber:[NSNumber numberWithFloat:0]])
        continue;
      CGFloat amount = [contribution.amount floatValue]/oldFinalPrice*[self.finalPrice floatValue];
      contribution.amount = [NSNumber numberWithFloat:amount];
    }
}

- (void)addContributionObject:(Contribution *)value
{
  self.contributions = [self.contributions setByAddingObject:value];
}

- (void)removeContributionObject:(Contribution *)value
{
  NSMutableSet *set = [self.contributions mutableCopy];
  [set removeObject:value];
  self.contributions = [set copy];
}

- (void)addContributions:(NSSet *)objects
{
  self.contributions = [self.contributions setByAddingObjectsFromSet:objects];
}

- (void)removeContributions:(NSSet *)objects
{
  NSMutableSet *set = [self.contributions mutableCopy];
  for (id object in objects)
    [set removeObject:object];
  self.contributions = [set copy];
}

@end
