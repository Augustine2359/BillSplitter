//
//  DataArrays.h
//  BillSplitter
//
//  Created by Augustine on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, strong) NSMutableArray *peopleArray;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic) BOOL isGstIncluded;
@property (nonatomic) BOOL isServiceTaxIncluded;

+ (DataModel *)sharedInstance;
- (void)refreshFinalPrices;

@end
