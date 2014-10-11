//
//  itemsTableViewController.m
//  BillSplitter
//
//  Created by Augustine on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemsTableViewController.h"
#import "EditItemViewController.h"
#import "Item.h"
#import "Contribution.h"
#import "DataModel.h"
#import "ItemTableViewCell.h"

#define UNSETTLED_TOTAL_BACKGROUND_COLOR [UIColor redColor]
#define UNSETTLED_TOTAL_TEXT_COLOR [UIColor redColor]

@interface ItemsTableViewController()

@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) UILabel *subtotalLabel;
@property (nonatomic, strong) UILabel *gstLabel;
@property (nonatomic, strong) UILabel *serviceTaxLabel;
@property (nonatomic, strong) UILabel *discountLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)callActionSheet;
- (void)addItem;
- (void)toggleDeletingMode;
- (void)arrangeAlphabetically;
- (void)fetchByTag;
- (void)calculateTotals;

@end

@implementation ItemsTableViewController

@synthesize itemsTableView;
@synthesize subtotalLabel;
@synthesize gstLabel;
@synthesize serviceTaxLabel;
@synthesize discountLabel;
@synthesize totalLabel;
@synthesize context;
@synthesize fetchedResultsController;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.title = @"Items";
    self.context = [DataModel sharedInstance].context;
  }
  return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.edgesForExtendedLayout = UIRectEdgeNone;

  self.itemsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.itemsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.itemsTableView.dataSource = self;
  self.itemsTableView.delegate = self;
  CGFloat heightPerLabel = 20;
  [self.view addSubview:self.itemsTableView];
  
  self.subtotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, heightPerLabel)];
  self.subtotalLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.subtotalLabel.textAlignment = UITextAlignmentRight;

  CGFloat labelHeight = 0;
  if ([DataModel sharedInstance].isGstIncluded)
    labelHeight = heightPerLabel;
  self.gstLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.gstLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.gstLabel.textAlignment = UITextAlignmentRight;

  if ([DataModel sharedInstance].isServiceTaxIncluded)
    labelHeight = heightPerLabel;
  else
    labelHeight = 0;
  self.serviceTaxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.serviceTaxLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.serviceTaxLabel.textAlignment = UITextAlignmentRight;

  if ([[DataModel sharedInstance].discount isEqualToNumber:[NSNumber numberWithFloat:0]])
    labelHeight = 0;
  else
    labelHeight = heightPerLabel;
  self.discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.discountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.discountLabel.textAlignment = UITextAlignmentRight;

  labelHeight = heightPerLabel;

  self.totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.totalLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.totalLabel.textAlignment = UITextAlignmentRight;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  NSUInteger numberOfLabels = 1;
  CGFloat heightPerLabel = 20;
  CGFloat labelHeight = 0;

  if ([DataModel sharedInstance].isGstIncluded)
  {
    labelHeight = heightPerLabel;
    numberOfLabels++;
  }
  self.gstLabel.frame = CGRectMake(0, CGRectGetMaxY(self.subtotalLabel.frame), self.view.frame.size.width, labelHeight);

  if ([DataModel sharedInstance].isServiceTaxIncluded)
  {
    labelHeight = heightPerLabel;
    numberOfLabels++;
  }
  else
    labelHeight = 0;
  self.serviceTaxLabel.frame = CGRectMake(0, CGRectGetMaxY(self.gstLabel.frame), self.view.frame.size.width, labelHeight);

  if ([[DataModel sharedInstance].discount isEqualToNumber:[NSNumber numberWithFloat:0]])
    labelHeight = 0;
  else
  {
    labelHeight = heightPerLabel;
    numberOfLabels++;
  }
  self.discountLabel.frame = CGRectMake(0, CGRectGetMaxY(self.serviceTaxLabel.frame), self.view.frame.size.width, labelHeight);

  labelHeight = heightPerLabel;
  if (numberOfLabels == 1)
    self.totalLabel.frame = self.subtotalLabel.frame;
  else
  {
    numberOfLabels++;
    self.totalLabel.frame = CGRectMake(0, CGRectGetMaxY(self.discountLabel.frame), self.view.frame.size.width, labelHeight);
  }

  self.itemsTableView.sectionFooterHeight = numberOfLabels * heightPerLabel;

  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
  self.itemsTableView.editing = NO;

  [self fetchByTag];
  [self calculateTotals];
  [self.itemsTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

#pragma mark - Action methods

- (void)callActionSheet
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add", @"Delete", @"Arrange Alphabetically", nil];
  [actionSheet showInView:self.view];
}

- (void)addItem
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects] inSection:0];
  NSArray *array = [NSArray arrayWithObject:indexPath];

  Item *item = (Item *)[NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.context];
  item.quantity = [NSNumber numberWithInt:1];
  item.name = [NSString stringWithFormat:@"Item %c",[[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects]
               + 65];
  item.basePrice = [NSNumber numberWithFloat:0];
  item.finalPrice = [NSNumber numberWithFloat:0];
  item.tag = [NSNumber numberWithInt:[self.fetchedResultsController.fetchedObjects count]];
  [item setContributions:[NSSet set]];

  [self.itemsTableView beginUpdates];
  [self.itemsTableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
  [self fetchByTag];
  [self calculateTotals];
  [self.itemsTableView endUpdates];

  indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
  [self.itemsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)toggleDeletingMode
{
  self.itemsTableView.editing = !self.itemsTableView.editing;

  if (self.itemsTableView.isEditing)
  {
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleDeletingMode)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
  }
  else
  {
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
  }

  [self.itemsTableView reloadData];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self tableView:self.itemsTableView numberOfRowsInSection:0] - 1 inSection:0];
  [self.itemsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];    
}

- (void)arrangeAlphabetically
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  fetchRequest.sortDescriptors = sortDescriptors;
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                      managedObjectContext:self.context
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
  NSError *error;
  [self.fetchedResultsController performFetch:&error];
  int index = 0;
  for (Item *item in [self.fetchedResultsController fetchedObjects])
  {
    item.tag = [NSNumber numberWithInt:index];
    index++;
  }

  [self.itemsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deletingDone
{
  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - Utility methods

- (void)fetchByTag
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES selector:nil];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  fetchRequest.sortDescriptors = sortDescriptors;
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                      managedObjectContext:self.context
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
  self.fetchedResultsController.delegate = self;
  
  NSError *error;
  [self.fetchedResultsController performFetch:&error];
}

- (void)calculateTotals
{
  CGFloat subtotal = 0;
  for (Item *item in self.fetchedResultsController.fetchedObjects)
    subtotal += [item.basePrice floatValue];
  NSNumber *number = [NSNumber numberWithFloat:subtotal];
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  self.subtotalLabel.text = [NSString stringWithFormat:@"Subtotal: %@", [numberFormatter stringFromNumber:number]];
  
  NSNumber *GST = [NSNumber numberWithFloat:0];
  if ([DataModel sharedInstance].isGstIncluded)
  {
    GST = [NSNumber numberWithFloat:subtotal * 7.0 / 100.0];
    subtotal = subtotal * 107.0 / 100.0;
    number = [NSNumber numberWithFloat:subtotal];
  }
  self.gstLabel.text = [NSString stringWithFormat:@"7%% GST: %@", [numberFormatter stringFromNumber:GST]];

  NSNumber *serviceTax = [NSNumber numberWithFloat:0];
  if ([DataModel sharedInstance].isServiceTaxIncluded)
  {
    serviceTax = [NSNumber numberWithFloat:subtotal * 10.0 / 100.0];
    subtotal = subtotal * 110.0 / 100.0;
    number = [NSNumber numberWithFloat:subtotal];
  }
  self.serviceTaxLabel.text = [NSString stringWithFormat:@"10%% Service Tax: %@", [numberFormatter stringFromNumber:serviceTax]];

  CGFloat discountPercentage = [[DataModel sharedInstance].discount floatValue];
  NSNumber *discount = [NSNumber numberWithFloat:subtotal * discountPercentage / 100.0];
  self.discountLabel.text = [NSString stringWithFormat:@"%.2f%% Discount: %@", discountPercentage, [numberFormatter stringFromNumber:discount]];
  subtotal = subtotal * (100.0 - discountPercentage) / 100.0;
  number = [NSNumber numberWithFloat:subtotal];

  self.totalLabel.text = [NSString stringWithFormat:@"Total: %@", [numberFormatter stringFromNumber:number]];
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  switch (buttonIndex) {
    case 0:
      [self addItem];
      break;
    case 1:
      [self toggleDeletingMode];
      break;
    case 2:
      [self arrangeAlphabetically];
      break;
    default:
      break;
  }
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *MyIdentifier = @"MyIdentifier";

  ItemTableViewCell *cell = [self.itemsTableView dequeueReusableCellWithIdentifier:MyIdentifier];
  Item *item;
  
  if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] numberOfObjects])
    item = nil;
  else
    item = [self.fetchedResultsController objectAtIndexPath:indexPath];

  if (cell == nil)
  {
    cell = [[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
  }

  [cell updateWithItem:item];

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger numberOfRows = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
  if (!self.itemsTableView.isEditing)
    numberOfRows++;
  return  numberOfRows;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
  for (Contribution *contribution in item.contributions)
    [self.context deleteObject:contribution];

  [self.context deleteObject:item];
  [self fetchByTag];
  [self calculateTotals];
  [self.itemsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects])
    [self addItem];
  else
  {
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    EditItemViewController *editItemViewController = [[EditItemViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:editItemViewController animated:YES];
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
  footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [footerView addSubview:subtotalLabel];
  [footerView addSubview:gstLabel];
  [footerView addSubview:serviceTaxLabel];
  [footerView addSubview:discountLabel];
  [footerView addSubview:totalLabel];
  return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 45;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  BOOL canEdit = YES;
  if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] numberOfObjects])
    canEdit = NO;
  return canEdit;
}

@end