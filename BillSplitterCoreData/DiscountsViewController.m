//
//  DiscountsViewController.m
//  BillSplitterCoreData
//
//  Created by Augustine on 30/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiscountsViewController.h"
#import "DataModel.h"

@interface DiscountsViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UILabel *discountLabel;
@property (nonatomic, strong) UIPickerView *pickerView;

- (void)updateDiscountLabel;
- (void)save:(id)sender;

@end

@implementation DiscountsViewController

@synthesize discountLabel;
@synthesize pickerView;

- (id)init
{
    self = [super init];
    if (self) {
      self.title = @"Discounts";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];

  self.discountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 180)];
  self.discountLabel.textAlignment = UITextAlignmentCenter;
  self.discountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.discountLabel];

  self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.discountLabel.frame), self.view.bounds.size.width, 180)];
  self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  self.pickerView.showsSelectionIndicator = YES;
  self.pickerView.delegate = self;
  self.pickerView.dataSource = self;
  [self.view addSubview:self.pickerView];

  [self updateDiscountLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)updateDiscountLabel
{
  self.discountLabel.text = [NSString stringWithFormat:@"%@%@%@%@%@",
                             [self pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:0] forComponent:0],
                             [self pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:1] forComponent:1],
                             [self pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:2] forComponent:2],
                             [self pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:3] forComponent:3],
                             [self pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:4] forComponent:4]];
}

- (void)save:(id)sender
{
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  NSNumber *discount = [numberFormatter numberFromString:[self.discountLabel.text substringToIndex:[self.discountLabel.text length] - 1]];
  [DataModel sharedInstance].discount = discount;
  [[DataModel sharedInstance] updateFinalPrices];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 5;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  if ((component == 2) || (component == 4))
    return 1;
  return 10;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  [self updateDiscountLabel];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
  return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  if (component == 2)
    return @".";
  if (component == 4)
    return @"%";
  return [NSString stringWithFormat:@"%d", row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
  return 40;
}

@end
