//
//  Contribution.m
//  BillSplitterCoreData
//
//  Created by Augustine on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Contribution.h"
#import "Item.h"
#import "Person.h"

@implementation Contribution

@dynamic amount;
@dynamic item;
@dynamic person;

- (void)deleteFromContext:(NSManagedObjectContext *)context
{
  [self.item removeContributionObject:self];
  [self.person removeContributionObject:self];
  [context deleteObject:self];
}
- (void)addToRelatedObjects
{
  [self.person addContributionObject:self];
  [self.item addContributionObject:self];
}

@end
