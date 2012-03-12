//
//  SplitItemViewController.h
//  BillSplitter
//
//  Created by Augustine on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "Person.h"

@interface SplitItemViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

- (id)initWithItem:(Item *)theItem andPeople:(NSArray *)people;

@end
