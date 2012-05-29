//
//  EditItemViewController.m
//  BillSplitter
//
//  Created by Augustine on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditItemViewController.h"
#import "SplitterTextField.h"
#import "DataModel.h"
#import "Contribution.h"
#import "Person.h"

@interface EditItemViewController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SplitterTextField *quantityTextField;
@property (nonatomic, strong) SplitterTextField *nameTextField;
@property (nonatomic, strong) SplitterTextField *basePriceTextField;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) NSArray *contributions;
@property (nonatomic, strong) UITableView *contributorsTableView;

@end

@implementation EditItemViewController

@synthesize quantityTextField;
@synthesize nameTextField;
@synthesize basePriceTextField;
@synthesize item;
@synthesize contributions;
@synthesize contributorsTableView;

- (id)initWithItem:(Item *)theItem
{
  self = [super init];
  if (self)
  {
    self.title = @"Edit item";
    self.item = theItem;
    self.contributions = [item.contributions allObjects];
    
    self.quantityTextField = [[SplitterTextField alloc] init];
    self.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.quantityTextField.text = [NSString stringWithFormat:@"%@", self.item.quantity];
    self.quantityTextField.delegate = self;

    self.nameTextField = [[SplitterTextField alloc] init];
    self.nameTextField.text = self.item.name;
    self.nameTextField.delegate = self;

    self.basePriceTextField = [[SplitterTextField alloc] init];
    self.basePriceTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.basePriceTextField.text = [NSString stringWithFormat:@"$%@", self.item.basePrice];
    self.basePriceTextField.delegate = self;

    self.contributorsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.contributorsTableView.dataSource = self;
    self.contributorsTableView.delegate = self;
  }
  return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];

  self.quantityTextField.backgroundColor = [UIColor redColor];
  [self.view addSubview:self.quantityTextField];

  self.nameTextField.backgroundColor = [UIColor greenColor];
  [self.view addSubview:self.nameTextField];

  self.basePriceTextField.backgroundColor = [UIColor blueColor];
  [self.view addSubview:self.basePriceTextField];

  [self.view addSubview:self.contributorsTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
  {
    self.quantityTextField.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height/6);
    self.nameTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.quantityTextField.frame), self.view.frame.size.width, self.view.frame.size.height/6);
    self.basePriceTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.nameTextField.frame), self.view.frame.size.width, self.view.frame.size.height/6);
    self.contributorsTableView.frame = CGRectMake(0.0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
  }
  else
  {
    self.quantityTextField.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height/3);
    self.nameTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.quantityTextField.frame), self.view.frame.size.width/2, self.view.frame.size.height/3);
    self.basePriceTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.nameTextField.frame), self.view.frame.size.width/2, self.view.frame.size.height/3);
    self.contributorsTableView.frame = CGRectMake(self.view.frame.size.width/2, 0.0, self.view.frame.size.width/2, self.view.frame.size.height);
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
  {
    self.quantityTextField.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height/6);
    self.nameTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.quantityTextField.frame), self.view.frame.size.width, self.view.frame.size.height/6);
    self.basePriceTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.nameTextField.frame), self.view.frame.size.width, self.view.frame.size.height/6);
    self.contributorsTableView.frame = CGRectMake(0.0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
  }
  else
  {
    self.quantityTextField.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height/3);
    self.nameTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.quantityTextField.frame), self.view.frame.size.width/2, self.view.frame.size.height/3);
    self.basePriceTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.nameTextField.frame), self.view.frame.size.width/2, self.view.frame.size.height/3);
    self.contributorsTableView.frame = CGRectMake(self.view.frame.size.width/2, 0.0, self.view.frame.size.width/2, self.view.frame.size.height);
  }
}

- (void)viewWillDisappear:(BOOL)animated
{
  CGFloat finalPrice = [self.item.finalPrice floatValue];
  if (finalPrice < 0.01)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You cannot have an item that costs nothing" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    self.item.basePrice = [NSNumber numberWithFloat:1];
    CGFloat finalPrice = 1;
    if ([DataModel sharedInstance].isGstIncluded)
      finalPrice *= 1.07;
    if ([DataModel sharedInstance].isServiceTaxIncluded)
      finalPrice *= 1.10;
    finalPrice *= [self.item.quantity intValue];
    self.item.finalPrice = [NSNumber numberWithFloat:finalPrice];

    return;
  }
}

#pragma mark - Action methods

- (IBAction)done:(UIBarButtonItem *)barButton;
{
  self.item.name = self.nameTextField.text;
  CGFloat oldFinalPrice = [self.item.finalPrice floatValue];
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  self.item.basePrice = [numberFormatter numberFromString:[self.basePriceTextField.text substringFromIndex:1]];
  CGFloat finalPrice = [self.item.basePrice floatValue];
  if ([DataModel sharedInstance].isGstIncluded)
    finalPrice *= 1.07;
  if ([DataModel sharedInstance].isServiceTaxIncluded)
    finalPrice *= 1.10;

  NSUInteger quantity = [[numberFormatter numberFromString:[self.quantityTextField.text substringToIndex:[self.quantityTextField.text length]]] intValue];
  if (quantity < 1)
    quantity = 1;
  self.item.quantity = [NSNumber numberWithInt:quantity];
  finalPrice *= quantity;
  
  self.item.finalPrice = [NSNumber numberWithFloat:finalPrice];
  [self.item reduceContributions:oldFinalPrice];

  if ([self.quantityTextField isFirstResponder])
    [self.quantityTextField resignFirstResponder];
  else if ([self.nameTextField isFirstResponder])
    [self.nameTextField resignFirstResponder];
  else
    [self.basePriceTextField resignFirstResponder];

  if (finalPrice < 0.01)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You cannot have an item that costs nothing" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  self.navigationItem.rightBarButtonItem = nil;
  [self.contributorsTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *MyIdentifier = @"MyIdentifier";

  UITableViewCell *cell = [self.contributorsTableView dequeueReusableCellWithIdentifier:MyIdentifier];

  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  Contribution *contribution = [self.contributions objectAtIndex:indexPath.row];
  cell.textLabel.text = contribution.person.name;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  BOOL shouldChange = YES;
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter numberFromString:string];
  
  if ([textField isEqual:self.basePriceTextField])
  {
    if (range.location == 0) //trying to delete dollar sign
      shouldChange = NO;
    if (string.length > 1) //trying to paste text
      shouldChange = NO;
    
    NSCharacterSet *notAllowed = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] invertedSet];
    if ((string.length > 0) && ([notAllowed characterIsMember:[string characterAtIndex:0]])) //trying to insert invalid character
      shouldChange = NO;
    
    NSMutableString *replacementString = [self.basePriceTextField.text mutableCopy];
    [replacementString replaceCharactersInRange:range withString:string];
    NSArray *chunks = [replacementString componentsSeparatedByString:@"."];
    if ([chunks count] > 2) //trying to place more than 1 .
      shouldChange = NO;
    
    if ([chunks count] == 2)
    {
      NSString *cents = [chunks objectAtIndex:1]; //trying to have more than 2 decimals
      if (cents.length > 2)
        shouldChange = NO;
    }
  }
  return shouldChange;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self done:nil];
}

@end
