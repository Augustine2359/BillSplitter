//
//  Item.h
//  BillSplitterCoreData
//
//  Created by Augustine on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contribution;

@interface Item : NSManagedObject
{
  NSSet *contributions;
}

@property (nonatomic, retain) NSNumber * basePrice;
@property (nonatomic, retain) NSNumber * finalPrice;
@property (nonatomic, retain) NSNumber * tag;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *contributions;

- (NSNumber *)calculateContributions;
- (NSNumber *)unpaidPortion;
- (void)reduceContributions:(CGFloat)oldFinalPrice;

@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addContributionObject:(Contribution *)value;
- (void)removeContributionObject:(Contribution *)value;
- (void)addContribution:(NSSet *)values;
- (void)removeContribution:(NSSet *)values;

@end
