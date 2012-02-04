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
#import "DataModel.h"

@interface PeopleTableViewController()

@property (nonatomic, strong) UITableView *peopleTableView;

@property (nonatomic, strong) NSMutableArray *peopleArray;

- (void)addPerson:(UIBarButtonItem *)barButton;

@end

@implementation PeopleTableViewController

@synthesize peopleArray;
@synthesize peopleTableView;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.title = @"People";
    self.peopleArray = [DataModel sharedInstance].peopleArray;
  }
  return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.peopleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.origin.y - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
  self.peopleTableView.dataSource = self;
  self.peopleTableView.delegate = self;
  [self.view addSubview:self.peopleTableView];
  
  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson:)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self.peopleTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  self.peopleTableView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.origin.y - self.navigationController.navigationBar.frame.size.height);
}

#pragma mark - Action methods

- (IBAction)addPerson:(UIBarButtonItem *)barButton
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.peopleArray count] inSection:0];
  NSArray *array = [NSArray arrayWithObject:indexPath];
  
  NSManagedObjectContext *context = [DataModel sharedInstance].context;
  
  Person *person = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
  person.name = [NSString stringWithFormat:@"Person %c", [self.peopleArray count] + 65]; //use ASCII
  person.contributions = [NSMutableSet set];
  
  [self.peopleTableView beginUpdates];
  [self.peopleArray addObject:person];
  [self.peopleTableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
  [self.peopleTableView endUpdates];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString* MyIdentifier = @"MyIdentifier";
  
  UITableViewCell *cell = [self.peopleTableView dequeueReusableCellWithIdentifier:MyIdentifier];
  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
  
  Person *person = [self.peopleArray objectAtIndex:indexPath.row];
  cell.textLabel.text = person.name;
  
  cell.selectionStyle=UITableViewCellSelectionStyleNone;
  
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.peopleArray count];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Person *person = [self.peopleArray objectAtIndex:indexPath.row];
  EditPersonViewController *editPersonViewController = [[EditPersonViewController alloc] initWithPerson:person];
  [self.navigationController pushViewController:editPersonViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

@end
