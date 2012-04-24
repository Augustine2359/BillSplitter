//
//  SplitTableViewController.m
//  BillSplitter
//
//  Created by Augustine on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitTableViewController.h"
#import "SplitItemViewController.h"
#import "Item.h"
#import "Contribution.h"
#import "Person.h"
#import "DataModel.h"
#import "ItemTableViewCell.h"

@interface SplitTableViewController()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedItemResultsController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedPersonResultsController;
@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) UITableView *peopleTableView;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

- (void)assign:(UIBarButtonItem *)barButton;
- (void)deselectContributorsToItem:(NSIndexPath *)indexPath;
- (void)selectContributorsToItem:(NSIndexPath *)indexPath;

@end

@implementation SplitTableViewController

#define UNSETTLED_ITEM_BACKGROUND_COLOR [UIColor redColor]
#define UNSETTLED_ITEM_TEXT_COLOR [UIColor redColor]
#define SETTLED_ITEM_BACKGROUND_COLOR [UIColor greenColor]
#define SETTLED_ITEM_TEXT_COLOR [UIColor blackColor]

#define NonContributorBackgroundColor [UIColor whiteColor]
#define ContributorBackgroundColor [UIColor blueColor]

#define UnselectedItemTag 1
#define SelectedItemTag 2
#define ContributorTag 3
#define NonContributorTag 4

@synthesize context;
@synthesize fetchedItemResultsController;
@synthesize fetchedPersonResultsController;
@synthesize itemsTableView;
@synthesize peopleTableView;
//@synthesize currentlySelectedTableViewCell;
@synthesize rightBarButtonItem;
//@synthesize currentlySelectedPeople;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.title = @"Split";
//    self.currentlySelectedPeople = [NSMutableArray array];
    
    self.context = [DataModel sharedInstance].context;
    NSFetchRequest *fetchItemsRequest = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    fetchItemsRequest.sortDescriptors = sortDescriptors;
    self.fetchedItemResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchItemsRequest 
                                                                            managedObjectContext:self.context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    self.fetchedItemResultsController.delegate = self;
    NSError *error;
    [self.fetchedItemResultsController performFetch:&error];
    
    NSFetchRequest *fetchPeopleRequest = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    fetchPeopleRequest.sortDescriptors = sortDescriptors;
    self.fetchedPersonResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchPeopleRequest 
                                                                              managedObjectContext:self.context
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:nil];
    self.fetchedPersonResultsController.delegate = self;
    [self.fetchedPersonResultsController performFetch:&error];
  }
  return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.itemsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height) style:UITableViewStylePlain];
  self.itemsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  self.itemsTableView.dataSource = self;
  self.itemsTableView.delegate = self;
  [self.view addSubview:self.itemsTableView];
  
  self.peopleTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 + 1, 0, self.view.bounds.size.width/2 - 1, self.view.bounds.size.height) style:UITableViewStylePlain];
  self.peopleTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
  self.peopleTableView.allowsMultipleSelection = YES;
  self.peopleTableView.dataSource = self;
  self.peopleTableView.delegate = self;
  [self.view addSubview:self.peopleTableView];
  
  self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Assign" style:UIBarButtonItemStyleBordered target:self action:@selector(assign:)];
  self.rightBarButtonItem.enabled = YES;
  self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  NSError *error;
  [self.fetchedItemResultsController performFetch:&error];
  [self.fetchedPersonResultsController performFetch:&error];
  
  [self.itemsTableView reloadData];
  [self.peopleTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

#pragma mark - Action methods

- (void)assign:(UIBarButtonItem *)barButton
{
  NSIndexPath *indexPath = [self.itemsTableView indexPathForSelectedRow];
  Item *item = [self.fetchedItemResultsController objectAtIndexPath:indexPath];

  NSMutableArray *currentlySelectedPeople = [NSMutableArray array];
  for (NSIndexPath *indexPath in [self.peopleTableView indexPathsForSelectedRows])
    [currentlySelectedPeople addObject:[self.fetchedPersonResultsController objectAtIndexPath:indexPath]];
  
  SplitItemViewController *splitItemViewController = [[SplitItemViewController alloc] initWithItem:item andPeople:currentlySelectedPeople];
  
  [self.navigationController pushViewController:splitItemViewController animated:YES];
}

#pragma mark - Utility methods

- (void)selectContributorsToItem:(NSIndexPath *)indexPath
{
  Item *item = [self.fetchedItemResultsController objectAtIndexPath:indexPath];
  NSMutableArray *visibleCells = [self.peopleTableView.visibleCells mutableCopy];
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  NSMutableArray *contributions = [item.contributions mutableCopy];
  NSMutableArray *people = [self.fetchedPersonResultsController.fetchedObjects mutableCopy];
  BOOL personWasContributor;
  BOOL cellAtIndexPathWasVisible;
  
  for (Contribution *contribution in contributions)
  {
    personWasContributor = NO;

    for (Person *person in people)
      if ([contribution.person isEqual:person])
      {
        personWasContributor = YES;
        NSUInteger index = [people indexOfObject:person];
        NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSIndexPath *bIndexPath;
        cellAtIndexPathWasVisible = NO;
        for (UITableViewCell *cell in visibleCells)
        {
          bIndexPath = [self.peopleTableView indexPathForCell:cell];
          if ([bIndexPath isEqual:aIndexPath])
          {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:contribution.amount]];
            cellAtIndexPathWasVisible = YES;
            break;
          }
        }
        if (cellAtIndexPathWasVisible)
          [visibleCells removeObject:bIndexPath];
        [self.peopleTableView selectRowAtIndexPath:aIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        break;
      }
  }
}

- (void)deselectContributorsToItem:(NSIndexPath *)indexPath
{
  NSMutableArray *visibleCells = [self.peopleTableView.visibleCells mutableCopy];
  NSIndexPath *bIndexPath;
  BOOL cellAtIndexPathWasVisible;
  
  for (NSIndexPath *aIndexPath in [self.peopleTableView indexPathsForSelectedRows])
  {
    [self.peopleTableView deselectRowAtIndexPath:aIndexPath animated:NO];
    cellAtIndexPathWasVisible = NO;

    for (UITableViewCell *cell in visibleCells)
    {
      bIndexPath = [self.peopleTableView indexPathForCell:cell];
      if ([bIndexPath isEqual:aIndexPath])
      {
        cell.detailTextLabel.text = nil;
        cellAtIndexPathWasVisible = YES;
        break;
      }
    }

    if (cellAtIndexPathWasVisible)
      [visibleCells removeObject:bIndexPath];
  }

}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *ItemIdentifier = @"ItemIdentifier";
  static NSString *PersonIdentifier = @"PersonIdentifier";

  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  
  if ([tableView isEqual:self.itemsTableView])
  {
    ItemTableViewCell *cell = [self.itemsTableView dequeueReusableCellWithIdentifier:ItemIdentifier];
    Item *item = [self.fetchedItemResultsController objectAtIndexPath:indexPath];
    if (cell == nil) {
      cell = [[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ItemIdentifier];
      [cell updateWithItem:nil];
    }
    cell.textLabel.text = item.name;

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:item.finalPrice]];
    NSNumber *totalContributions = [item calculateContributions];
    if ([totalContributions floatValue] < [item.finalPrice floatValue])
    {
      cell.detailTextLabel.textColor = UNSETTLED_ITEM_TEXT_COLOR;
      cell.textLabel.textColor = UNSETTLED_ITEM_TEXT_COLOR;
    }
    else
    {
      cell.detailTextLabel.textColor = SETTLED_ITEM_TEXT_COLOR;
      cell.textLabel.textColor = SETTLED_ITEM_TEXT_COLOR;
    }

    return cell;
  }
  
  if ([tableView isEqual:self.peopleTableView])
  {
    UITableViewCell *cell = [self.peopleTableView dequeueReusableCellWithIdentifier:PersonIdentifier];
    if (cell == nil)
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PersonIdentifier];
    
    Person *person = [self.fetchedPersonResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = nil;

    NSIndexPath *selectedItemIndexPath = [self.itemsTableView indexPathForSelectedRow];
    Item *item = [self.fetchedItemResultsController objectAtIndexPath:selectedItemIndexPath];
    Contribution *contribution;
    if (item != nil)
    {
      for (Contribution *aContribution in item.contributions)
        if ([aContribution.person isEqual:person])
        {
          contribution = aContribution;
          break;
        }
      if (contribution != nil)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:contribution.amount]];
    }
    
    return cell;
  }
  
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger i;
  
  if ([tableView isEqual:self.itemsTableView])
    i = [[[self.fetchedItemResultsController sections] objectAtIndex:section] numberOfObjects];
  if ([tableView isEqual:self.peopleTableView])
    i = [[[self.fetchedPersonResultsController sections] objectAtIndex:section] numberOfObjects];
  return i;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //item is already selected, deselect it
  if (([tableView isEqual:self.itemsTableView]) && ([[tableView indexPathForSelectedRow] isEqual:indexPath]))
  {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self deselectContributorsToItem:indexPath];
    indexPath = nil;
  }
  
  //item not yet selected, select it and its contributors
  else
    if ([tableView isEqual:self.itemsTableView])
    {
      [self deselectContributorsToItem:[self.itemsTableView indexPathForSelectedRow]];
      [UIView animateWithDuration:0 animations:^{} completion:^(BOOL finished) {[self selectContributorsToItem:indexPath];}];
    }

  return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (([tableView isEqual:self.itemsTableView]) && ([[tableView indexPathForSelectedRow] isEqual:indexPath]))
  {
    for (NSIndexPath *aIndexPath in [self.peopleTableView indexPathsForSelectedRows])
    {
      [self.peopleTableView deselectRowAtIndexPath:aIndexPath animated:NO];

    }
  }

  return indexPath;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

@end
