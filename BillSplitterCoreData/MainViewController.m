//
//  ViewController.m
//  BillSplitter
//
//  Created by Augustine on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "ItemsTableViewController.h"
#import "PeopleTableViewController.h"
#import "SplitTableViewController.h"
#import "DataModel.h"
#import "DiscountsViewController.h"

@interface MainViewController()

@property (nonatomic, strong) UIButton *itemsButton;
@property (nonatomic, strong) UIButton *peopleButton;
@property (nonatomic, strong) UIButton *splitBillButton;
@property (nonatomic, strong) UIButton *discountsButton;
@property (nonatomic, strong) ItemsTableViewController *itemsTableViewController;
@property (nonatomic, strong) PeopleTableViewController *peopleTableViewController;
@property (nonatomic, strong) SplitTableViewController *splitTableViewController;
@property (nonatomic, strong) DiscountsViewController *discountsViewController;
@property (nonatomic, strong) UISwitch *gstSwitch;
@property (nonatomic, strong) UISwitch *serviceTaxSwitch;

- (IBAction)itemsButtonPressed:(UIButton *)button;
- (IBAction)peopleButtonPressed:(UIButton *)button;
- (IBAction)splitButtonPressed:(UIButton *)button;
- (IBAction)discountsButtonPressed:(UIButton *)button;
- (IBAction)gstToggle:(UISwitch *)theSwitch;
- (IBAction)serviceTaxToggle:(UISwitch *)theSwitch;

@end

@implementation MainViewController

@synthesize context;
@synthesize itemsButton;
@synthesize peopleButton;
@synthesize splitBillButton;
@synthesize discountsButton;
@synthesize itemsTableViewController;
@synthesize peopleTableViewController;
@synthesize splitTableViewController;
@synthesize discountsViewController;
@synthesize gstSwitch;
@synthesize serviceTaxSwitch;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (id)init
{
  self = [super init];
  if (self)
  {
    self.itemsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.itemsButton setTitle:@"Add items\non receipt" forState:UIControlStateNormal];
    self.itemsButton.titleLabel.numberOfLines = 0;
    [self.itemsButton addTarget:self action:@selector(itemsButtonPressed:) forControlEvents:UIControlEventTouchDown];    
    
    self.peopleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.peopleButton setTitle:@"Add people paying" forState:UIControlStateNormal];
    self.peopleButton.titleLabel.numberOfLines = 0;
    [self.peopleButton addTarget:self action:@selector(peopleButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    self.splitBillButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.splitBillButton setTitle:@"Split the bill!" forState:UIControlStateNormal];
    self.splitBillButton.titleLabel.numberOfLines = 0;
    [self.splitBillButton addTarget:self action:@selector(splitButtonPressed:) forControlEvents:UIControlEventTouchDown];

    self.discountsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.discountsButton setTitle:@"Calculate discounts" forState:UIControlStateNormal];
    self.discountsButton.titleLabel.numberOfLines = 0;
    [self.discountsButton addTarget:self action:@selector(discountsButtonPressed:) forControlEvents:UIControlEventTouchDown];

    self.gstSwitch = [[UISwitch alloc] init];
    [self.gstSwitch addTarget:self action:@selector(gstToggle:) forControlEvents:UIControlEventValueChanged];
    self.serviceTaxSwitch = [[UISwitch alloc] init];
    [self.serviceTaxSwitch addTarget:self action:@selector(serviceTaxToggle:) forControlEvents:UIControlEventValueChanged];
    
    self.itemsTableViewController = [[ItemsTableViewController alloc] init];
    self.peopleTableViewController = [[PeopleTableViewController alloc] init];
    self.splitTableViewController = [[SplitTableViewController alloc] init];
    self.discountsViewController = [[DiscountsViewController alloc] init];
    
    [DataModel sharedInstance];
  }
  return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"BillSplitter";

  self.edgesForExtendedLayout = UIRectEdgeNone;
  
  self.itemsButton.frame = CGRectMake(0, 0, self.view.frame.size.width/2, 100);
  self.itemsButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.itemsButton];
  
  self.peopleButton.frame = CGRectMake(CGRectGetMaxX(self.itemsButton.frame) + 1, 0, self.view.frame.size.width/2 - 1, 100);
  self.peopleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.peopleButton];
  
  self.splitBillButton.frame = CGRectMake(0, CGRectGetMaxY(self.itemsButton.frame) + 1, self.view.frame.size.width, 100);
  self.splitBillButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.splitBillButton];

  self.discountsButton.frame = CGRectMake(0, CGRectGetMaxY(self.splitBillButton.frame) + 1, self.view.frame.size.width, 100);
  self.discountsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
  [self.view addSubview:self.discountsButton];

  for (UIButton *button in self.view.subviews) {
    button.backgroundColor = [UIColor whiteColor];
  }

  UILabel *gstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.discountsButton.frame) + 1, self.view.frame.size.width/2, 50)];
  gstLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
  gstLabel.text = @"GST";
  gstLabel.textAlignment = NSTextAlignmentCenter;
  gstLabel.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:gstLabel];

  UILabel *serviceTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(gstLabel.frame) + 1, CGRectGetMaxY(self.discountsButton.frame) + 1, self.view.frame.size.width/2 - 1, 50)];
  serviceTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
  serviceTextLabel.text = @"Service Tax";
  serviceTextLabel.textAlignment = NSTextAlignmentCenter;
  serviceTextLabel.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:serviceTextLabel];

  self.gstSwitch.frame = CGRectMake(0, CGRectGetMaxY(gstLabel.frame), self.view.frame.size.width/2, 50);
  self.gstSwitch.center = CGPointMake(gstLabel.center.x, gstSwitch.center.y);
  self.gstSwitch.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
  [self.view addSubview:self.gstSwitch];
  
  self.serviceTaxSwitch.frame = CGRectMake(self.view.frame.size.width/2, CGRectGetMaxY(serviceTextLabel.frame), self.view.frame.size.width/2, 50);
  self.serviceTaxSwitch.center = CGPointMake(serviceTextLabel.center.x, self.serviceTaxSwitch.center.y);
  self.serviceTaxSwitch.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self.view addSubview:self.serviceTaxSwitch];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

#pragma mark - Action methods

- (IBAction)itemsButtonPressed:(UIButton *)button
{  
  [self.navigationController pushViewController:self.itemsTableViewController animated:YES];
}

- (IBAction)peopleButtonPressed:(UIButton *)button
{  
  [self.navigationController pushViewController:self.peopleTableViewController animated:YES];
}

- (IBAction)splitButtonPressed:(UIButton *)button
{
  [self.navigationController pushViewController:self.splitTableViewController animated:YES];
}

- (IBAction)discountsButtonPressed:(UIButton *)button
{
  [self.navigationController pushViewController:self.discountsViewController animated:YES];
}

- (IBAction)gstToggle:(UISwitch *)theSwitch
{
  [DataModel sharedInstance].isGstIncluded = theSwitch.isOn;
  [[DataModel sharedInstance] updateFinalPrices];
}

- (IBAction)serviceTaxToggle:(UISwitch *)theSwitch
{
  [DataModel sharedInstance].isServiceTaxIncluded = theSwitch.isOn;
  [[DataModel sharedInstance] updateFinalPrices];
}

@end
