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

@interface ItemsTableViewController()

@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)callActionSheet;
- (void)addItem;
- (void)toggleDeletingMode;
- (void)arrangeAlphabetically;
- (void)fetchByTag;

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
  }
  return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.itemsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.itemsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.itemsTableView.dataSource = self;
  self.itemsTableView.delegate = self;
  [self.view addSubview:self.itemsTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
  self.itemsTableView.editing = NO;

  [self fetchByTag];
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
  item.basePrice = [NSNumber numberWithFloat:100];
  item.finalPrice = [NSNumber numberWithFloat:100];
  item.tag = [NSNumber numberWithInt:[self.fetchedResultsController.fetchedObjects count]];
  [item setContributions:[NSSet set]];

  [self.itemsTableView beginUpdates];
  [self.itemsTableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
  [self fetchByTag];
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