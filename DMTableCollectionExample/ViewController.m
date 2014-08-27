//
//  ViewController.m
//  DMTableCollectionExample
//
//  Created by Dmitry Ponomarev on 27/08/14.
//  Copyright (c) 2014 Dmitry Ponomarev. All rights reserved.
//

#import "ViewController.h"

#import "DMTableCollectionViewLayout.h"


@interface TableHeaderView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UIButton *headerLabel;

@end


@implementation TableHeaderView

@end

////////////////////////////////////////////////////////////////////////////////

@interface ViewController ()

@property (nonatomic, strong) UIView * statusView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,320, 20)];
  _statusView.backgroundColor = [UIColor colorWithRed:229/255.f green:43/255.f blue:80/255.f alpha:1];
  _statusView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:_statusView];
  
  // Do any additional setup after loading the view, typically from a nib.
  [_table registerNib:[UINib nibWithNibName:@"TableHeaderView" bundle:nil] forSupplementaryViewOfKind:@"UICollectionReusableView" withReuseIdentifier:@"TableHeaderView"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  _statusView.alpha = UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) ? 0.f : 1.f;
}

#pragma mark – UICollectionViewDelegate

- (void)onHeaderClick:(id)sender
{
  NSLog(@"Head: %td", [(UIButton *)sender tag]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger row = [((DMTableCollectionViewLayout *) collectionView.collectionViewLayout) rowIndexAtIndexPath:indexPath];
  NSLog(@"Row: %td", row);
}

- (BOOL)collectionViewHeaderFixed:(UICollectionView *)collectionView
{
  return YES;
}


- (BOOL)collectionViewStretch:(UICollectionView *)collectionView
{
  return YES;
}


- (NSInteger)collectionViewColumns:(UICollectionView *)collectionView
{
  return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView columnWidth:(NSInteger)column
{
  return 100.f;
}

#pragma mark – UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  UILabel *label = (UILabel *)[cell viewWithTag:1000];
  
  label.text = [NSString stringWithFormat:@"Item %td", indexPath.row];
  
  return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  TableHeaderView *header = (TableHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"TableHeaderView" forIndexPath:indexPath];
  
  [header.headerLabel setTitle:[NSString stringWithFormat:@"Header %td", indexPath.row] forState:UIControlStateNormal];
  [header.headerLabel addTarget:self action:@selector(onHeaderClick:) forControlEvents:UIControlEventTouchUpInside];
  [header.headerLabel setTag:indexPath.item];
  
  return header;
}

@end
