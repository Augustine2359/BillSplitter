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

@interface EditItemViewController()

@property (nonatomic, strong) SplitterTextField *quantityTextField;
@property (nonatomic, strong) SplitterTextField *nameTextField;
@property (nonatomic, strong) SplitterTextField *basePriceTextField;
@property (nonatomic, strong) Item *item;

@end

@implementation EditItemViewController

@synthesize quantityTextField;
@synthesize nameTextField;
@synthesize basePriceTextField;
@synthesize item;

- (id)initWithItem:(Item *)theItem
{
  self = [super init];
  if (self)
  {
    self.title = @"Edit item";
    self.item = theItem;
    
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
  }
  return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];

  self.quantityTextField.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 50);
  self.quantityTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  self.quantityTextField.backgroundColor = [UIColor redColor];
  [self.view addSubview:self.quantityTextField];
  
  self.nameTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.quantityTextField.frame), self.view.frame.size.width, 50);
  self.nameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  self.nameTextField.backgroundColor = [UIColor greenColor];
  [self.view addSubview:self.nameTextField];
  
  self.basePriceTextField.frame = CGRectMake(0.0, CGRectGetMaxY(self.nameTextField.frame), self.view.frame.size.width, 50);
  self.basePriceTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  self.basePriceTextField.backgroundColor = [UIColor blueColor];
  [self.view addSubview:self.basePriceTextField];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
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

- (IBAction)save:(UIBarButtonItem *)barButton;
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
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
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
  [self save:nil];
}

@end
