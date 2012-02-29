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
#import "SplitItemTableViewCell.h"

@interface SplitItemViewController()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedContributionResultsController;
@property (nonatomic, strong) UITableView *contributionsTableView;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) NSArray *peopleArray;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *totalAmountContributedLabel;
@property (nonatomic, strong) NSArray *contributionsArray;
@property (nonatomic, strong) NSMutableArray *cellIsExpandedArray;
@property (nonatomic, strong) NSMutableArray *headerViewsArray;

- (void)calculateTotalAmountContributed;
- (void)splitEvenly;
- (void)toggleExpanded:(id)sender;

@end

@implementation SplitItemViewController

@synthesize context;
@synthesize fetchedContributionResultsController;
@synthesize contributionsTableView;
@synthesize item;
@synthesize peopleArray;
@synthesize priceLabel;
@synthesize totalAmountContributedLabel;
@synthesize cellIsExpandedArray;
@synthesize contributionsArray;
@synthesize headerViewsArray;

- (id)initWithItem:(Item *)theItem andPeople:(NSArray *)people
{
  self = [super init];
  if (self)
  {
    self.item = theItem;
    self.title = self.item.name;
    self.peopleArray = people;
    self.context = [DataModel sharedInstance].context;

    for (Contribution *contribution in self.item.contributions)
      if (![self.peopleArray containsObject:contribution.person])
        [contribution deleteFromContext:self.context];

    self.cellIsExpandedArray = [NSMutableArray array];
    self.headerViewsArray = [NSMutableArray array];
    
    for (Person *person in self.peopleArray)
    {
      [self.cellIsExpandedArray addObject:[NSNumber numberWithBool:NO]];
      [self.headerViewsArray addObject:[NSNull null]];
      BOOL isContributor = NO;
      for (Contribution *contribution in person.contributions)
      {
        if ([contribution.item isEqual:self.item])
          isContributor = YES;
        break;
      }

      if (!isContributor)
      {
        Contribution *contribution = (Contribution *)[NSEntityDescription insertNewObjectForEntityForName:@"Contribution"
                                                                                   inManagedObjectContext:self.context];
        contribution.amount = [NSNumber numberWithFloat:0];
        contribution.person = person;
        contribution.item = self.item;
        [contribution addToRelatedObjects];
      }
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"person.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *array = [NSArray arrayWithObject:sortDescriptor];
    self.contributionsArray = [[self.item.contributions allObjects] sortedArrayUsingDescriptors:array];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Split evenly" 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:self
                                                                             action:@selector(splitEvenly)];

    if ([self.item.calculateContributions isEqualToNumber:[NSNumber numberWithFloat:0]])
      [self splitEvenly];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40.0, self.view.bounds.size.width/2, 40)];
  self.priceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
  NSNumberFormatter *numberFormatter = [DataModel sharedInstance].currencyFormatter;
  self.priceLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:item.finalPrice]];
  [self.view addSubview:self.priceLabel];
  
  self.totalAmountContributedLabel = [[UILabel alloc] initWithFrame:CGRectOffset(self.priceLabel.frame, self.view.bounds.size.width/2, 0)];
  self.totalAmountContributedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self calculateTotalAmountContributed];
  [self.view addSubview:self.totalAmountContributedLabel];
  
  self.contributionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.priceLabel.frame.size.height - 1) style:UITableViewStylePlain];
  self.contributionsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
  self.contributionsTableView.dataSource = self;
  self.contributionsTableView.delegate = self;
  [self.view addSubview:self.contributionsTableView];  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
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

#pragma mark - Action methods

- (void)splitEvenly
{
  for (Contribution *contribution in self.item.contributions)
    contribution.amount = [NSNumber numberWithFloat:[self.item.finalPrice floatValue] / [self.item.contributions count]];
    
  [self.contributionsTableView reloadData];
  for (SplitItemTableViewCell *cell in self.contributionsTableView.visibleCells)
    [cell updateContributions];
  [self calculateTotalAmountContributed];
}

- (void)toggleExpanded:(id)sender
{
  UIButton *button = sender;

  [self.cellIsExpandedArray replaceObjectAtIndex:button.tag withObject:[NSNumber numberWithBool:![[self.cellIsExpandedArray objectAtIndex:button.tag] boolValue]]];
  
  [self.contributionsTableView reloadData];

  if ([[self.cellIsExpandedArray objectAtIndex:button.tag] boolValue])
    [self.contributionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)sliderValueChanged:(UISlider *)slider
{
  Contribution *contribution = [self.contributionsArray objectAtIndex:slider.tag];
  CGFloat ratio = [contribution.amount floatValue] / [self.item.finalPrice floatValue];
  CGFloat oldContributionAmount = [contribution.amount floatValue];
  CGFloat newContributionAmount = slider.value * [self.item.finalPrice floatValue] / 100;

  [self.contributionsTableView beginUpdates];
  contribution.amount = [NSNumber numberWithFloat:newContributionAmount];
  for (SplitItemTableViewCell *cell in self.contributionsTableView.visibleCells)
    [cell updateContributions];

  //it's a reduction in contribution
  if (slider.value < ratio * 100)
  {
    for (SplitItemTableViewCell *cell in self.contributionsTableView.visibleCells)
      if (cell.percentageSlider.tag == slider.tag)
        [cell updateContributions];
  }
  //it's an increase in contribution
  else
  {
    NSNumber *unpaidPortion = [self.item unpaidPortion];
    CGFloat changeInAmount = newContributionAmount - oldContributionAmount;
    if (changeInAmount > [unpaidPortion floatValue]) //if there's no spare amount that hasn't been paid for
    {
      NSUInteger numberOfZeroContributions = 0;
      for (Contribution *otherContribution in self.contributionsArray)
        if ((![otherContribution isEqual:contribution])&&([otherContribution.amount floatValue] == 0))
          numberOfZeroContributions++;
      
      changeInAmount /= [self.contributionsArray count] - 1 - numberOfZeroContributions; //the eaten part is split evenly

      for (Contribution *otherContribution in self.contributionsArray)
      {
        if ([otherContribution isEqual:contribution])
          continue;
        CGFloat amount = [otherContribution.amount floatValue]; //their current amount
        if (amount > changeInAmount)
          otherContribution.amount = [NSNumber numberWithFloat:amount - changeInAmount]; //reduce by however much
        else
          otherContribution.amount = [NSNumber numberWithFloat:0];
      }
      for (SplitItemTableViewCell *cell in self.contributionsTableView.visibleCells)
        [cell updateContributions];
    }
    for (SplitItemTableViewCell *cell in self.contributionsTableView.visibleCells)
      if (cell.percentageSlider.tag == slider.tag)
        [cell updateContributions];
  }
  
  [self.contributionsTableView endUpdates];
  
  [self calculateTotalAmountContributed];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString* MyIdentifier = @"MyIdentifier";
  Contribution *contribution = [self.contributionsArray objectAtIndex:indexPath.row];

  SplitItemTableViewCell *cell = [self.contributionsTableView dequeueReusableCellWithIdentifier:MyIdentifier];
  if (cell == nil)
  {
    cell = [[SplitItemTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier contribution:contribution];
  }
  cell.contribution = contribution;
  cell.nameLabel.text = contribution.person.name;
  cell.selectionStyle=UITableViewCellSelectionStyleNone;
  cell.percentageSlider.tag = indexPath.row;
  [cell.percentageSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  cell.expandToggleButton.tag = indexPath.row;
  [cell.expandToggleButton addTarget:self action:@selector(toggleExpanded:) forControlEvents:UIControlEventTouchDown];
  
  [cell updateContributions];

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.contributionsArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  return 0;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([[self.cellIsExpandedArray objectAtIndex:indexPath.row] boolValue])
    return 80;
  else
    return 40;
}

@end
