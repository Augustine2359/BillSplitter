//
//  Contribution.h
//  BillSplitterCoreData
//
//  Created by Augustine on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Person;

@interface Contribution : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) Person *person;

@end
