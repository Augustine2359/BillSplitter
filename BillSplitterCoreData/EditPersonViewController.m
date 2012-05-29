//
//  EditPersonViewController.m
//  BillSplitter
//
//  Created by Augustine on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditPersonViewController.h"
#import "SplitterTextField.h"
#import "Contribution.h"
#import "Item.h"

@interface EditPersonViewController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SplitterTextField *nameTextField;
@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) NSArray *contributions;
@property (nonatomic, strong) UITableView *contributionsTableView;

@end

@implementation EditPersonViewController

@synthesize nameTextField;
@synthesize person;
@synthesize contributions;
@synthesize contributionsTableView;

- (id)initWithPerson:(Person *)thePerson
{
  self = [super init];
  if (self)
  {
    self.title = @"Edit person";
    self.person = thePerson;
    self.contributions = [self.person.contributions allObjects];

    self.nameTextField = [[SplitterTextField alloc] init];
    self.nameTextField.text = self.person.name;
    self.nameTextField.delegate = self;

    self.contributionsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.contributionsTableView.dataSource = self;
    self.contributionsTableView.delegate = self;
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

  [self.view addSubview:self.contributionsTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  CGRect rect = CGRectZero;
  CGRect rect2;

  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
  {
    rect.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height/2);
    rect2 = CGRectOffset(rect, 0, self.view.frame.size.height/2);
  }
  else
  {
    rect.size = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height);
    rect2 = CGRectOffset(rect, self.view.frame.size.width/2, 0);
  }
  self.nameTextField.frame = rect;
  self.contributionsTableView.frame = rect2;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  CGRect rect = CGRectZero;
  CGRect rect2;

  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
  {
    rect.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height/2);
    rect2 = CGRectOffset(rect, 0, self.view.frame.size.height/2);
  }
  else
  {
    rect.size = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height);
    rect2 = CGRectOffset(rect, self.view.frame.size.width/2, 0);
  }
  self.nameTextField.frame = rect;
  self.contributionsTableView.frame = rect2;
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

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *MyIdentifier = @"MyIdentifier";

  UITableViewCell *cell = [self.contributionsTableView dequeueReusableCellWithIdentifier:MyIdentifier];

  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  Contribution *contribution = [self.contributions objectAtIndex:indexPath.row];
  cell.textLabel.text = contribution.item.name;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", contribution.amount];

  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.contributions count];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
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
