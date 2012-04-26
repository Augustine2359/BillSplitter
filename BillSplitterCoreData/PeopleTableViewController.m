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
@property (nonatomic) BOOL isDeleting;

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
@synthesize isDeleting;

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
  
  self.peopleTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.peopleTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  self.peopleTableView.dataSource = self;
  self.peopleTableView.delegate = self;
  [self.view addSubview:self.peopleTableView];
  
  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
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
  self.isDeleting = !self.isDeleting;
  if (self.isDeleting)
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
  if (!self.isDeleting)
    numberOfRows++;
  return numberOfRows;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] numberOfObjects])
    if (self.isDeleting)
      NSLog(@"delete mode, cannot add");
    else
      [self addPerson];
  else
  {
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.isDeleting)
    {
      for (Contribution *contribution in person.contributions)
        [self.context deleteObject:contribution];
      
      [self.context deleteObject:person];
      [self fetchByTag];
      [self.peopleTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
      return;
    }
    EditPersonViewController *editPersonViewController = [[EditPersonViewController alloc] initWithPerson:person];
    [self.navigationController pushViewController:editPersonViewController animated:YES];    
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

@end