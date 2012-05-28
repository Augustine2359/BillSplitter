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

  self.nameTextField.backgroundColor = [UIColor redColor];
  [self.view addSubview:self.nameTextField];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  CGRect rect = CGRectZero;
  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    rect.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height/2);
  else
    rect.size = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height);
  self.nameTextField.frame = rect;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  CGRect rect = CGRectZero;
  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    rect.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height/2);
  else
    rect.size = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height);
  self.nameTextField.frame = rect;
}

#pragma mark - Action methods

- (IBAction)done:(UIBarButtonItem *)barButton;
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
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self done:nil];
}

@end
