//
//  SplitItemViewController.m
//  BillSplitter
//
//  Created by Augustine on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitItemViewController.h"
#import "DataModel.h"
#import "Contribution.h"

@interface SplitItemViewController()

@property (nonatomic, strong) UITableView *peopleTableView;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) NSArray *peopleArray;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *totalAmountContributedLabel;

- (void)calculateTotalAmountContributed;

@end

@implementation SplitItemViewController

@synthesize peopleTableView;
@synthesize item;
@synthesize peopleArray;
@synthesize priceLabel;
@synthesize totalAmountContributedLabel;

- (id)initWithItem:(Item *)theItem andPeople:(NSArray *)people
{
  self = [super init];
  if (self)
  {
    self.item = theItem;
    self.title = self.item.name;
    self.peopleArray = people;

    for (Contribution *contribution in self.item.contributions)
    {
      if (![self.peopleArray containsObject:contribution.person])
        [self.item removeContributionObject:contribution];
    }

    NSManagedObjectContext *context = [DataModel sharedInstance].context;
    
    for (Person *person in self.peopleArray)
    {
      BOOL contributorFound = NO;
      for (Contribution *contribution in self.item.contributions)
      {
        if ([contribution.person isEqual:person])
          contributorFound = YES;
        break;
      }
      if (!contributorFound)
      {
        Contribution *contribution = (Contribution *)[NSEntityDescription insertNewObjectForEntityForName:@"Contribution" inManagedObjectContext:context];
        contribution.amount = [NSNumber numberWithFloat:0];
        contribution.person = person;
        contribution.item = self.item;
        
        [self.item.contributions addObject:contribution];
        [person.contributions addObject:contribution];
        
        NSLog(@"%@ %@ nice", contribution.item, contribution.person);
        
      }
    }
  }
  
  NSLog(@"%@ %@", item, item.contributions);
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40.0 - self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width/2, 40)];
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  self.priceLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:item.finalPrice]];
  [self.view addSubview:self.priceLabel];
  
  self.totalAmountContributedLabel = [[UILabel alloc] initWithFrame:CGRectOffset(self.priceLabel.frame, self.view.frame.size.width/2, 0)];
  [self calculateTotalAmountContributed];
  [self.view addSubview:self.totalAmountContributedLabel];
  
  self.peopleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.origin.y - self.navigationController.navigationBar.frame.size.height - self.priceLabel.frame.size.height) style:UITableViewStylePlain];
  self.peopleTableView.dataSource = self;
  self.peopleTableView.delegate = self;
  [self.view addSubview:self.peopleTableView];
}

- (void)calculateTotalAmountContributed
{
  CGFloat totalAmountContributed = 0;
  
  for (Contribution *contribution in self.item.contributions)
    totalAmountContributed += [contribution.amount floatValue];
  
  if (totalAmountContributed < [item.finalPrice floatValue])
    self.totalAmountContributedLabel.textColor = [UIColor redColor];
  else
    self.totalAmountContributedLabel.textColor = [UIColor blackColor];
  
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  self.totalAmountContributedLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmountContributed]]];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString* MyIdentifier = @"MyIdentifier";
  
  UITableViewCell *cell = [self.peopleTableView dequeueReusableCellWithIdentifier:MyIdentifier];
  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier];
  cell.selectionStyle=UITableViewCellSelectionStyleNone;
  
  Person *person = [self.peopleArray objectAtIndex:indexPath.row];
  cell.textLabel.text = person.name;

  NSNumber *amount;
  
  for (Contribution *contribution in person.contributions)
  {
    NSLog(@"%@ %@ boat", contribution.item, contribution.person);

    if ([contribution.item isEqual:self.item])
    {
      amount = contribution.amount;
      break;
    }
  }
    
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:amount]];
    
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.peopleArray.count;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

@end
