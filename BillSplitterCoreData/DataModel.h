//
//  DataArrays.h
//  BillSplitter
//
//  Created by Augustine on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic) NSNumber *discount;
@property (nonatomic) BOOL isGstIncluded;
@property (nonatomic) BOOL isServiceTaxIncluded;

+ (DataModel *)sharedInstance;
- (void)updateFinalPrices;

@end
