//
//  DMTable2CollectionReusableView.h
//  DMTable2
//
//  Created by Dmitry Ponomarev on 19/08/14.
//  Copyright (c) 2014 AdOnWeb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DMTableSideType) {
  kDMTableBorderNone = 0x0000,
  kDMTableBorderTop = 0x0001,
  kDMTableBorderRight = 0x0002,
  kDMTableBorderBottom = 0x0004,
  kDMTableBorderLeft = 0x0008,

  kDMTableBorderAll = kDMTableBorderTop|kDMTableBorderLeft|kDMTableBorderBottom|kDMTableBorderRight,
};

////////////////////////////////////////////////////////////////////////////////
/// Table extend reusable view
////////////////////////////////////////////////////////////////////////////////

@interface DMTableCollectionReusableView : UICollectionReusableView

@end

////////////////////////////////////////////////////////////////////////////////
/// Table item attribute
////////////////////////////////////////////////////////////////////////////////

@interface DMTableCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) UIColor *backgroundColor;

@end

////////////////////////////////////////////////////////////////////////////////
/// Table data delegate
////////////////////////////////////////////////////////////////////////////////

@protocol DMTableCollectionViewDataSource <UICollectionViewDataSource>

@required

- (NSInteger)collectionViewColumns:(UICollectionView *)collectionView;

@optional

- (BOOL)collectionViewStretch:(UICollectionView *)collectionView;

- (CGFloat)collectionView:(UICollectionView *)collectionView columnWidth:(NSInteger)column;

- (BOOL)collectionViewHeader:(UICollectionView *)collectionView;
- (BOOL)collectionViewHeaderFixed:(UICollectionView *)collectionView;
- (CGFloat)collectionView:(UICollectionView *)collectionView sectionHeight:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView rowHeight:(NSInteger)row;

- (CGFloat)collectionViewBorderWidth:(UICollectionView *)collectionView;
- (CGFloat)collectionViewBorderPadding:(UICollectionView *)collectionView;
- (UIColor *)collectionViewBorderColor:(UICollectionView *)collectionView;

- (NSInteger)collectionView:(UICollectionView *)collectionView borderAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)collectionView:(UICollectionView *)collectionView headerBorderAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)collectionViewTableBorder:(UICollectionView *)collectionView;

@end

////////////////////////////////////////////////////////////////////////////////
/// Table collection layout
////////////////////////////////////////////////////////////////////////////////

@interface DMTableCollectionViewLayout : UICollectionViewLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForHeaderAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark – Getters/Setters

- (NSInteger)numberOfColumns;
- (CGFloat)collectionViewColumnWidth:(NSInteger)column;
- (CGFloat)collectionViewSectionHeight:(NSInteger)section;
- (CGFloat)collectionViewRowHeight:(NSInteger)row;
- (CGFloat)collectionViewColumnOffset:(NSInteger)column;
- (CGFloat)tableWidth;


- (BOOL)isHeader;
- (BOOL)isHeaderFixed;
- (BOOL)isStretch;
- (CGFloat)borderWidth;
- (CGFloat)borderPadding;
- (UIColor *)borderColor;
- (NSInteger)borderAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)headerBorderAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableBorder;

#pragma mark – Helpers

- (NSInteger)rowIndexAtIndexPath:(NSIndexPath *)indexPath;

@end


