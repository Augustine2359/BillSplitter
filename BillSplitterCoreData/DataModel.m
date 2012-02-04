//
//  DataArrays.m
//  BillSplitter
//
//  Created by Augustine on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataModel.h"
#import "Item.h"

@implementation DataModel

//@synthesize fetchedResultsController;
@synthesize context;
@synthesize model;
@synthesize coordinator;

@synthesize itemsArray;
@synthesize peopleArray;
@synthesize currencyFormatter;
@synthesize isGstIncluded;
@synthesize isServiceTaxIncluded;

+ (DataModel *)sharedInstance
{
  static DataModel *myInstance = nil;
  
  if (nil == myInstance)
  {
    myInstance = [[[self class] alloc] init];
//    myInstance.fetchedResultsController = [[NSFetchedResultsController alloc] init];
//    myInstance.context = [[NSManagedObjectContext alloc] init];
    
    myInstance.itemsArray = [NSMutableArray array];
    myInstance.peopleArray = [NSMutableArray array];
    myInstance.currencyFormatter = [[NSNumberFormatter alloc] init];
    myInstance.currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    myInstance.isGstIncluded = NO;
    myInstance.isServiceTaxIncluded = NO;
  }
  
  return myInstance;
}

- (void)refreshFinalPrices
{
  for (Item *item in itemsArray)
  {
    CGFloat finalPrice = [item.basePrice floatValue];
    if (self.isGstIncluded)
      finalPrice *= 1.07;
    if (self.isServiceTaxIncluded)
      finalPrice *= 1.10;
    item.finalPrice = [NSNumber numberWithFloat:finalPrice];
  }
}

@end
