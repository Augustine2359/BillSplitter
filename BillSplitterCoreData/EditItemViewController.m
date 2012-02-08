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

@property (nonatomic, strong) SplitterTextField *nameTextField;
@property (nonatomic, strong) SplitterTextField *basePriceTextField;
@property (nonatomic, strong) Item *item;

@end

@implementation EditItemViewController

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
  
  //  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(popViewControllerAnimated:)];
  
  self.nameTextField.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 100);
  self.nameTextField.backgroundColor = [UIColor redColor];
  [self.view addSubview:self.nameTextField];
  
  self.basePriceTextField.frame = CGRectMake(0.0, 110.0, self.view.frame.size.width, 100);
  self.basePriceTextField.backgroundColor = [UIColor blueColor];
  [self.view addSubview:self.basePriceTextField];
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
    self.item.name = self.nameTextField.text;
    [self.nameTextField resignFirstResponder];
  }
  else
  {
    CGFloat oldFinalPrice = [self.item.finalPrice floatValue];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    self.item.basePrice = [numberFormatter numberFromString:[self.basePriceTextField.text substringFromIndex:1]];
    CGFloat finalPrice = [self.item.basePrice floatValue];
    if ([DataModel sharedInstance].isGstIncluded)
      finalPrice *= 1.07;
    if ([DataModel sharedInstance].isServiceTaxIncluded)
      finalPrice *= 1.10;

    //    numberFormatter = [DataModel sharedInstance].currencyFormatter;
    self.item.finalPrice = [NSNumber numberWithFloat:finalPrice];

    if ([[self.item calculateContributions] floatValue] > finalPrice)
      [self.item reduceContributions:oldFinalPrice];

    [self.basePriceTextField resignFirstResponder];
  }
  
  [self.navigationController popViewControllerAnimated:YES];
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

@end
