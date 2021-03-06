//
//  DataArrays.m
//  BillSplitter
//
//  Created by Augustine on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataModel.h"
#import "Item.h"
#import "Contribution.h"

@interface DataModel()

- (void)updateContributionsForTax:(CGFloat)ratio;

@end

@implementation DataModel

@synthesize context;
@synthesize model;
@synthesize coordinator;

@synthesize currencyFormatter;
@synthesize discount;
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
    myInstance.discount = [NSNumber numberWithFloat:0];
    myInstance.isGstIncluded = NO;
    myInstance.isServiceTaxIncluded = NO;
  }
  
  return myInstance;
}

- (void)updateFinalPrices
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

  CGFloat oldFinalPrice;
  CGFloat finalPrice;
  CGFloat undiscountedPortion = 100.0 - [self.discount floatValue];

  for (Item *item in fetchedResultsController.fetchedObjects)
  {
    oldFinalPrice = [item.finalPrice floatValue];
    finalPrice = [item.basePrice floatValue];
    if (self.isGstIncluded)
      finalPrice *= 1.07;
    if (self.isServiceTaxIncluded)
      finalPrice *= 1.10;
    finalPrice *= undiscountedPortion / 100.0;
    item.finalPrice = [NSNumber numberWithFloat:finalPrice];
  }
  if (finalPrice != oldFinalPrice)
    [self updateContributionsForTax:finalPrice/oldFinalPrice];
}

- (void)updateContributionsForTax:(CGFloat)ratio
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Contribution"];
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"amount" ascending:NO];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  fetchRequest.sortDescriptors = sortDescriptors;
  NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                             managedObjectContext:self.context
                                                                                               sectionNameKeyPath:nil
                                                                                                        cacheName:nil];
  NSError *error;
  [fetchedResultsController performFetch:&error];

  for (Contribution *contribution in fetchedResultsController.fetchedObjects)
  {
    CGFloat amount = [contribution.amount floatValue];
    amount *= ratio;
    contribution.amount = [NSNumber numberWithFloat:amount];
  }
}

@end
