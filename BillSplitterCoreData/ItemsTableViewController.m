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
#import "DataModel.h"
#import "ItemTableViewCell.h"

#define UNSETTLED_ITEM_BACKGROUND_COLOR [UIColor redColor]
#define UNSETTLED_ITEM_TEXT_COLOR [UIColor redColor]
#define SETTLED_ITEM_BACKGROUND_COLOR [UIColor greenColor]
#define SETTLED_ITEM_TEXT_COLOR [UIColor blackColor]

@interface ItemsTableViewController()

@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)addItem;

@end

@implementation ItemsTableViewController

@synthesize itemsTableView;
@synthesize context;
@synthesize fetchedResultsController;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.title = @"Items";
    self.context = [DataModel sharedInstance].context;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
  }
  return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.itemsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.itemsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
  self.itemsTableView.dataSource = self;
  self.itemsTableView.delegate = self;
  [self.view addSubview:self.itemsTableView];
  
  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  NSError *error;
  [self.fetchedResultsController performFetch:&error];
  
  [self.itemsTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

#pragma mark - Action methods

- (IBAction)addItem
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects] inSection:0];
  NSArray *array = [NSArray arrayWithObject:indexPath];

  Item *item = (Item *)[NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.context];
  item.name = [NSString stringWithFormat:@"Item %c",[[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects]
               + 65];
  item.basePrice = [NSNumber numberWithFloat:100];
  item.finalPrice = [NSNumber numberWithFloat:100];
  [item setContributions:[NSSet set]];
  
  [self.itemsTableView beginUpdates];
  [self.itemsTableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
  NSError *error;
  [self.fetchedResultsController performFetch:&error];
  [self.itemsTableView endUpdates];
  indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
  [self.itemsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    cell = [[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier item:item];

  cell.item = item;

  cell.textLabel.text = item.name;
  cell.textLabel.textAlignment = UITextAlignmentLeft;
  if (cell.textLabel.text == nil)
  {
    cell.textLabel.text = @"Tap here to add a new item";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
  }
  cell.selectionStyle=UITableViewCellSelectionStyleNone;
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:item.finalPrice]];
  if (item.finalPrice == nil)
    cell.detailTextLabel.text = nil;
    
  NSNumber *totalContributions = [item calculateContributions];
  if ([totalContributions floatValue] < [item.finalPrice floatValue])
    cell.detailTextLabel.textColor = UNSETTLED_ITEM_TEXT_COLOR;
  else
    cell.detailTextLabel.textColor = SETTLED_ITEM_TEXT_COLOR;

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects] + 1;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

@end