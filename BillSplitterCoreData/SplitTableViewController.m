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
#import "Person.h"
#import "DataModel.h"
#import "ItemTableViewCell.h"

@interface SplitTableViewController()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedItemResultsController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedPersonResultsController;
@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) UITableView *peopleTableView;
@property (nonatomic, strong) UITableViewCell *currentlySelectedTableViewCell;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) NSMutableArray *currentlySelectedPeople;

- (void)split:(UIBarButtonItem *)barButton;

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
@synthesize currentlySelectedTableViewCell;
@synthesize rightBarButtonItem;
@synthesize currentlySelectedPeople;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.title = @"Split";
    self.currentlySelectedPeople = [NSMutableArray array];
    
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
  self.peopleTableView.dataSource = self;
  self.peopleTableView.delegate = self;
  [self.view addSubview:self.peopleTableView];
  
  self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Split" style:UIBarButtonItemStyleBordered target:self action:@selector(split:)];
  self.rightBarButtonItem.enabled = NO;
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
  
  //boat
  if (self.currentlySelectedTableViewCell != nil)
  {
    NSIndexPath *indexPath = [self.itemsTableView indexPathForCell:self.currentlySelectedTableViewCell];
    [self.itemsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

#pragma mark - Action methods

- (void)split:(UIBarButtonItem *)barButton
{
  NSIndexPath *indexPath = [self.itemsTableView indexPathForCell:self.currentlySelectedTableViewCell];
  Item *item = [self.fetchedItemResultsController objectAtIndexPath:indexPath];

  SplitItemViewController *splitItemViewController = [[SplitItemViewController alloc] initWithItem:item andPeople:self.currentlySelectedPeople];
  
  [self.navigationController pushViewController:splitItemViewController animated:YES];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *ItemIdentifier = @"ItemIdentifier";
  static NSString *PersonIdentifier = @"PersonIdentifier";
  
  if ([tableView isEqual:self.itemsTableView])
  {
    ItemTableViewCell *cell = [self.itemsTableView dequeueReusableCellWithIdentifier:ItemIdentifier];
    Item *item = [self.fetchedItemResultsController objectAtIndexPath:indexPath];
    if (cell == nil)
      cell = [[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ItemIdentifier item:item];
    cell.textLabel.text = item.name;
    cell.selectionStyle=UITableViewCellSelectionStyleBlue;

    NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
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
    cell.selectionStyle=UITableViewCellSelectionStyleNone;    
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  if ([tableView isEqual:self.itemsTableView])
    if ([cell isEqual:self.currentlySelectedTableViewCell])
    {
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
      self.currentlySelectedTableViewCell = nil;
    }
    else
      self.currentlySelectedTableViewCell = cell;
  
  else
    if ([tableView isEqual:self.peopleTableView])
    {
      [self.peopleTableView beginUpdates];
      Person *person = [self.fetchedPersonResultsController.fetchedObjects objectAtIndex:indexPath.row];
      if (cell.tag == ContributorTag)
      {
        cell.backgroundColor = NonContributorBackgroundColor;
        cell.textLabel.backgroundColor = NonContributorBackgroundColor;
        cell.tag = NonContributorTag;
        [self.currentlySelectedPeople removeObject:person];
      }
      else
      {
        cell.tag = ContributorTag;
        cell.backgroundColor = ContributorBackgroundColor;
        cell.textLabel.backgroundColor = ContributorBackgroundColor;
        [self.currentlySelectedPeople addObject:person];
      }
        
      [self.peopleTableView endUpdates];
    }
  
  if (([self.currentlySelectedPeople count] > 0) && (self.currentlySelectedTableViewCell != nil))
    self.rightBarButtonItem.enabled = YES;
  else
    self.rightBarButtonItem.enabled = NO;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([tableView isEqual:self.peopleTableView])
  {
    if (cell.tag == NonContributorTag)
    {
      cell.backgroundColor = NonContributorBackgroundColor;
      cell.textLabel.backgroundColor = NonContributorBackgroundColor;
    }
    if (cell.tag == ContributorTag)
    {
      cell.backgroundColor = ContributorBackgroundColor;
      cell.textLabel.backgroundColor = ContributorBackgroundColor;
    }
    cell.textLabel.textColor = [UIColor blackColor];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

@end
