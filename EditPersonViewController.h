//
//  EditPersonViewController.h
//  BillSplitter
//
//  Created by Augustine on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface EditPersonViewController : UIViewController <UITextFieldDelegate>

- (id)initWithPerson:(Person *)person;

@end
