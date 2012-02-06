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

@synthesize context;
@synthesize model;
@synthesize coordinator;

@synthesize currencyFormatter;
@synthesize isGstIncluded;
@synthesize isServiceTaxIncluded;

+ (DataModel *)sharedInstance
{
  static DataModel *myInstance = nil;
  
  if (nil == myInstance)
  {
    myInstance = [[[self class] alloc] init];
//    myInstance.context = [[NSManagedObjectContext alloc] init];
    
    myInstance.currencyFormatter = [[NSNumberFormatter alloc] init];
    myInstance.currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    myInstance.isGstIncluded = NO;
    myInstance.isServiceTaxIncluded = NO;
  }
  
  return myInstance;
}

- (void)refreshFinalPrices
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"basePrice" ascending:NO];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  fetchRequest.sortDescriptors = sortDescriptors;
  NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                             managedObjectContext:self.context
                                                                                               sectionNameKeyPath:nil
                                                                                                        cacheName:nil];
  NSError *error;
  [fetchedResultsController performFetch:&error];

  for (Item *item in fetchedResultsController.fetchedObjects)
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
