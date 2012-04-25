//
//  EditPersonViewController.m
//  BillSplitter
//
//  Created by Augustine on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditPersonViewController.h"
#import "SplitterTextField.h"

@interface EditPersonViewController()

@property (nonatomic, strong) SplitterTextField *nameTextField;
@property (nonatomic, strong) Person *person;

@end

@implementation EditPersonViewController

@synthesize nameTextField;
@synthesize person;

- (id)initWithPerson:(Person *)thePerson
{
  self = [super init];
  if (self)
  {
    self.title = @"Edit person";
    self.person = thePerson;
    self.nameTextField = [[SplitterTextField alloc] init];
    self.nameTextField.text = self.person.name;
    self.nameTextField.delegate = self;
  }
  return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  //  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(popViewControllerAnimated:)];
  
  self.nameTextField.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 100);
  self.nameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
  self.nameTextField.backgroundColor = [UIColor redColor];
  [self.view addSubview:self.nameTextField];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

#pragma mark - Action methods

- (IBAction)save:(UIBarButtonItem *)barButton;
{
  if ([self.nameTextField isFirstResponder])
  {
    self.person.name = self.nameTextField.text;
    [self.nameTextField resignFirstResponder];
  }

  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
}

@end
