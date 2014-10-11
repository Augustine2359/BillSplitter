//
//  PeopleTableViewController.m
//  BillSplitter
//
//  Created by Augustine on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "EditPersonViewController.h"
#import "Person.h"
#import "Contribution.h"
#import "DataModel.h"

@interface PeopleTableViewController()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) UITableView *peopleTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)callActionSheet;
- (void)addPerson;
- (void)toggleDeletingMode;
- (void)arrangeAlphabetically;
- (void)fetchByTag;

@end

@implementation PeopleTableViewController

@synthesize context;
@synthesize peopleTableView;
@synthesize fetchedResultsController;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.title = @"People";
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

  self.peopleTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.peopleTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  self.peopleTableView.dataSource = self;
  self.peopleTableView.delegate = self;
  [self.view addSubview:self.peopleTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
  self.peopleTableView.editing = NO;

  [self fetchByTag];
  [self.peopleTableView reloadData];
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

- (void)addPerson
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects] inSection:0];
  NSArray *array = [NSArray arrayWithObject:indexPath];
  
  Person *person = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
  person.name = [NSString stringWithFormat:@"Person %c",[[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects]
                 + 65]; //use ASCII
  person.tag = [NSNumber numberWithInt:[self.fetchedResultsController.fetchedObjects count]];
  person.contributions = [NSSet set];
  
  [self.peopleTableView beginUpdates];
  [self.peopleTableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
  NSError *error;
  [self.fetchedResultsController performFetch:&error];  
  [self.peopleTableView endUpdates];
  indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
  [self.peopleTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)toggleDeletingMode
{
  self.peopleTableView.editing = !self.peopleTableView.editing;

  if (self.peopleTableView.isEditing)
  {
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleDeletingMode)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
  }
  else
  {
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
  }
  
  [self.peopleTableView reloadData];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self tableView:self.peopleTableView numberOfRowsInSection:0] - 1 inSection:0];
  [self.peopleTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)arrangeAlphabetically
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
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
  for (Person *person in [self.fetchedResultsController fetchedObjects])
  {
    person.tag = [NSNumber numberWithInt:index];
    index++;
  }
  
  [self.peopleTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deletingDone
{
  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - Utility methods

- (void)fetchByTag
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
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
      [self addPerson];
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
  static NSString* MyIdentifier = @"MyIdentifier";

  UITableViewCell *cell = [self.peopleTableView dequeueReusableCellWithIdentifier:MyIdentifier];
  Person *person;

  if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] numberOfObjects])
    person = nil;
  else
    person = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];

  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier];

  cell.textLabel.text = person.name;
  cell.textLabel.textAlignment = UITextAlignmentLeft;

  if (cell.textLabel.text == nil)
  {
    cell.textLabel.text = @"Tap here to add a new person";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
  }
  
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[person calculateContributions]]];
  if ([person calculateContributions] == nil)
    cell.detailTextLabel.text = nil;
  
  cell.selectionStyle=UITableViewCellSelectionStyleNone;
  
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger numberOfRows = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
  if (!self.peopleTableView.isEditing)
    numberOfRows++;
  return numberOfRows;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
  for (Contribution *contribution in person.contributions)
    [self.context deleteObject:contribution];

  [self.context deleteObject:person];
  [self fetchByTag];
  [self.peopleTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects])
    [self addPerson];
  else
  {
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    EditPersonViewController *editPersonViewController = [[EditPersonViewController alloc] initWithPerson:person];
    [self.navigationController pushViewController:editPersonViewController animated:YES];
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  return view;
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
