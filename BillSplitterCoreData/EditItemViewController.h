//
//  EditItemViewController.h
//  BillSplitter
//
//  Created by Augustine on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface EditItemViewController : UIViewController <UITextFieldDelegate>

- (id)initWithItem:(Item *)item;

@end
