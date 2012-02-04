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

@interface ItemsTableViewController()

@property (nonatomic, strong) UITableView *itemsTableView;

@property (nonatomic, strong) NSMutableArray *itemsArray;

- (void)addPerson:(UIBarButtonItem *)barButton;

@end

@implementation ItemsTableViewController

@synthesize itemsArray;
@synthesize itemsTableView;

- (id)init
{
  self = [super init];
  if (self)
  {
    self.title = @"Items";
    self.itemsArray = [DataModel sharedInstance].itemsArray;
  }
  return self;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.itemsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.origin.y - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
  self.itemsTableView.dataSource = self;
  self.itemsTableView.delegate = self;
  [self.view addSubview:self.itemsTableView];
  
  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
  self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self.itemsTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  self.itemsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.origin.y - self.navigationController.navigationBar.frame.size.height);
}

#pragma mark - Action methods

- (IBAction)addItem:(UIBarButtonItem *)barButton
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.itemsArray count] inSection:0];
  NSArray *array = [NSArray arrayWithObject:indexPath];

  NSManagedObjectContext *context = [DataModel sharedInstance].context;
  
  Item *item = (Item *)[NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:context];
  item.name = [NSString stringWithFormat:@"Item %d", [self.itemsArray count] + 1];
  item.contributions = [NSMutableSet set];
  [self.itemsArray addObject:item];

  [self.itemsTableView beginUpdates];
  NSError *error = nil;
  if (![context save:&error])
  {
    ;
  }

  [self.itemsTableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
  [self.itemsTableView endUpdates];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *MyIdentifier = @"MyIdentifier";

//  UITableViewCell *cell = [self.itemsTableView dequeueReusableCellWithIdentifier:MyIdentifier];
//  Item *item = [self.itemsArray objectAtIndex:indexPath.row];
//  if (cell == nil)
//    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier];
//  
//  cell.textLabel.text = item.name;
//  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
//  cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:item.finalPrice]];
//  cell.selectionStyle=UITableViewCellSelectionStyleNone;

  ItemTableViewCell *cell = [self.itemsTableView dequeueReusableCellWithIdentifier:MyIdentifier];
  Item *item = [self.itemsArray objectAtIndex:indexPath.row];
  if (cell == nil)
    cell = [[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier item:item];
  
  cell.textLabel.text = item.name;
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:item.finalPrice]];
  cell.selectionStyle=UITableViewCellSelectionStyleNone;
  
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.itemsArray count];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Item *item = [self.itemsArray objectAtIndex:indexPath.row];
  EditItemViewController *editItemViewController = [[EditItemViewController alloc] initWithItem:item];
  [self.navigationController pushViewController:editItemViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

@end