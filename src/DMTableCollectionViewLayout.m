//
//  DMTable2CollectionReusableView.m
//  DMTable2
//
//  Created by Dmitry Ponomarev on 19/08/14.
//  Copyright (c) 2014 AdOnWeb. All rights reserved.
//

#import "DMTableCollectionViewLayout.h"


////////////////////////////////////////////////////////////////////////////////

@implementation DMTableCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
  [super applyLayoutAttributes:layoutAttributes];
  if ([layoutAttributes isKindOfClass:[DMTableCollectionViewLayoutAttributes class]]) {
    self.backgroundColor = ((DMTableCollectionViewLayoutAttributes *) layoutAttributes).backgroundColor;
  }
}

@end

////////////////////////////////////////////////////////////////////////////////

@implementation DMTableCollectionViewLayoutAttributes

- (instancetype)copyWithZone:(NSZone *)zone
{
  DMTableCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];
  copy.backgroundColor = self.backgroundColor;
  return copy;
}

@end

////////////////////////////////////////////////////////////////////////////////

static NSString *kInfoCells = @"cells";
static NSString *kInfoHeaders = @"headers";

@interface DMTableCollectionViewLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSMutableDictionary *columnsInfo;
@property (nonatomic, strong) NSMutableDictionary *rowsInfo;

- (NSInteger)numberOfColumns;
- (CGFloat)borderWidth;
- (CGFloat)borderPadding;
- (UIColor *)borderColor;

@end

@implementation DMTableCollectionViewLayout
{
  CGSize viewContentSizeCache;
  CGRect viewContentRectCache;
  CGFloat tableWidthCache;
}

+ (Class)layoutAttributesClass {
  return [DMTableCollectionViewLayoutAttributes class];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – Initialization
////////////////////////////////////////////////////////////////////////////////

- (id)init
{
  if (self = [super init]) {
    [self setup];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (self = [super initWithCoder:aDecoder]) {
    [self setup];
  }
  return self;
}

- (void)setup
{
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"CVSeparator"];
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"CHSeparator"];
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"HVSeparator"];
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"HHSeparator"];
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"tVSeparator"];
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"tHSeparator"];
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"TVSeparator"];
  [self registerClass:[DMTableCollectionReusableView class] forDecorationViewOfKind:@"THSeparator"];
  viewContentSizeCache = CGSizeZero;
}

// Prepare layout items
- (void)prepareLayout
{
  NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
  NSMutableDictionary *headerLayoutInfo = self.isHeader ? [NSMutableDictionary dictionary] : nil;
  
  const NSInteger columns = self.numberOfColumns;
  const NSInteger sectionCount = [self.collectionView numberOfSections];
  NSIndexPath *indexPath = nil;
  
  for (NSInteger section = 0; section < sectionCount; section++) {
    // Prepare headers
    if (headerLayoutInfo) {
      for (NSInteger item = 0; item < columns; item++) {
        indexPath = [NSIndexPath indexPathForItem:item inSection:section];

        UICollectionViewLayoutAttributes *headerAttributes =
        [DMTableCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"UICollectionReusableView" withIndexPath:indexPath];
        headerAttributes.frame = [self frameForHeaderAtIndexPath:indexPath];
        headerAttributes.transform = CGAffineTransformInvert(headerAttributes.transform);
        headerAttributes.zIndex = 1;

        headerLayoutInfo[indexPath] = headerAttributes;
      }
    }
    
    // Prepare items
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
    
    for (NSInteger item = 0; item < itemCount; item++) {
      indexPath = [NSIndexPath indexPathForItem:item inSection:section];

      UICollectionViewLayoutAttributes *itemAttributes =
      [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
      itemAttributes.frame = [self frameForCellAtIndexPath:indexPath];

      cellLayoutInfo[indexPath] = itemAttributes;
    }
  }
  
  @synchronized (self) {
    self.layoutInfo = @{kInfoHeaders: headerLayoutInfo, kInfoCells: cellLayoutInfo};
    viewContentSizeCache = CGSizeZero;
    tableWidthCache = 0;
    if (self.columnsInfo) {
      [self.columnsInfo removeAllObjects];
    }
    if (self.rowsInfo) {
      [self.rowsInfo removeAllObjects];
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – ViewLayout callbacks
////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
  if (self.isHeaderFixed && self.isHeader && self.layoutInfo[kInfoHeaders]) {
    return YES;
  }
  if (!CGRectEqualToRect(viewContentRectCache, newBounds)) {
    viewContentRectCache = newBounds;
    return YES;
  }
  return NO;
}

- (CGSize)collectionViewContentSize
{
  if (CGSizeEqualToSize(viewContentSizeCache, CGSizeZero)) {
    NSInteger i = self.collectionView.numberOfSections-1;
    NSInteger j = [self.collectionView numberOfItemsInSection:i];
    CGRect rect = [self frameForCellAtIndexPath:[NSIndexPath indexPathForItem:j inSection:i]];
    viewContentSizeCache.width = MAX(self.tableWidth, self.collectionView.frame.size.width);
    viewContentSizeCache.height = rect.origin.y;
  }
  return viewContentSizeCache;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return ((NSDictionary *)self.layoutInfo[kInfoCells])[indexPath];
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//  return [DMTableCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
//}


// Prepare attributes before show
//
// @param decorationViewKind
// @param indexPath
// @return UICollectionViewLayoutAttributes
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
  if (NSOrderedSame == [decorationViewKind compare:@"Separator" options:NSCaseInsensitiveSearch range:NSMakeRange(decorationViewKind.length-9, 9)]) {
    
    DMTableCollectionViewLayoutAttributes *layoutAttributes = [DMTableCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    
    CGRect baseFrame;
    
    switch ([decorationViewKind characterAtIndex:0]) {
      case 't':
      case 'H':
      {
        UICollectionViewLayoutAttributes *headAttributes = [self layoutAttributesForHeaderAtIndexPath:indexPath];
        baseFrame = headAttributes.frame;
        layoutAttributes.zIndex = 1111;
      }break;
      case 'T':
      default:
      {
        UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        baseFrame = cellAttributes.frame;
        layoutAttributes.zIndex = -1;
      }break;
    }

    const CGFloat strokeWidth = self.borderWidth;
    const CGFloat padding = self.borderPadding;
    const unichar c = [decorationViewKind characterAtIndex:0];

    CGFloat spaceToNextItem = 0;
    
    // Prepare Separator
    if (NSOrderedSame == [decorationViewKind compare:@"VSeparator" options:NSCaseInsensitiveSearch range:NSMakeRange(decorationViewKind.length-10, 10)]) {
      // Positions the vertical line for this item.
      CGFloat x = baseFrame.origin.x + (spaceToNextItem - strokeWidth)/2;
      
      if ('T' != c && 't' != c) {
        x += baseFrame.size.width;
      } else if ([self indexPathLastInLine:indexPath]) {
        x += baseFrame.size.width - strokeWidth;
      }
      
      // Fix table border position
      if (x < 0) {
        x = 0;
      }
      
      layoutAttributes.frame = CGRectMake(x,
                                          baseFrame.origin.y + padding,
                                          strokeWidth,
                                          baseFrame.size.height - padding*2);
    } else {
      // Positions the horizontal line for this item.
      layoutAttributes.frame = CGRectMake(baseFrame.origin.x + padding,
                                          baseFrame.origin.y + ('t' == c ? 0 : baseFrame.size.height),
                                          baseFrame.size.width + spaceToNextItem - padding*2,
                                          strokeWidth);
    }
    
    layoutAttributes.backgroundColor = self.borderColor;
    return layoutAttributes;
  }
  return [self layoutAttributesForItemAtIndexPath:indexPath];
}

// Get layouts elements in rect
//
// @param rect
// @retrun array
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];

  // Prepare headers
  [self layoutHeadAttributesForElementsInRect:rect attributes:allAttributes];

  // prepare items
  [self layoutCellAttributesForElementsInRect:rect attributes:allAttributes];
  
  return allAttributes;
}

// Get layouts head elements in rect
//
// @param rect
// @param allAttributes
- (void)layoutHeadAttributesForElementsInRect:(CGRect)rect attributes:(NSMutableArray *)allAttributes
{
  // Table headers
  if (self.isHeader && self.layoutInfo[kInfoHeaders]) {
    // Table border flags
    NSInteger tableBorder = self.tableBorder;

    // Prepare borders
    [self.layoutInfo[kInfoHeaders] enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
      // Update border position
      if (self.isHeaderFixed) {
        attributes.frame = [self frameForHeaderAtIndexPath:attributes.indexPath];
      }

      // Check view position
      if (CGRectIntersectsRect(rect, attributes.frame)) {
        // Add new attributes
        [allAttributes addObject:attributes];

        // Border attributes
        NSInteger cellBorder = [self borderAtIndexPath:attributes.indexPath];
        
        // Table left border
        if (0 != (tableBorder&kDMTableBorderLeft) && [self indexPathFirstInLine:attributes.indexPath]) {
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"tVSeparator" atIndexPath:attributes.indexPath]];
        }
        
        // Table right border
        if (0 != (tableBorder&kDMTableBorderRight) && [self indexPathLastInLine:attributes.indexPath]) {
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"tVSeparator" atIndexPath:attributes.indexPath]];
        }
        
        // Space between items
        if (0 != (cellBorder&(kDMTableBorderLeft|kDMTableBorderRight)) &&
            (!([self indexPathLastInSection:attributes.indexPath] ||
               [self indexPathLastInLine:attributes.indexPath]))) {
          // Table head vertical separator
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"HVSeparator" atIndexPath:attributes.indexPath]];
        }
        
        // Adds horizontal lines when the item isn't in the last line.
        if (0 != (cellBorder&(kDMTableBorderBottom|kDMTableBorderTop))) {
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"HHSeparator" atIndexPath:attributes.indexPath]];
        }
        
        // Top border
        if (0 != (tableBorder&kDMTableBorderTop) && 0 == attributes.indexPath.section) {
          // Table bottom border
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"tHSeparator" atIndexPath:attributes.indexPath]];
        }
      }
    }];
  }
}

// Get layouts cell elements in rect
//
// @param rect
// @param allAttributes
- (void)layoutCellAttributesForElementsInRect:(CGRect)rect attributes:(NSMutableArray *)allAttributes
{
  // Table border flags
  NSInteger tableBorder = self.tableBorder;
  
  // Separators between items
  [self.layoutInfo[kInfoCells] enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [allAttributes addObject:attributes];
      
      if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
        NSInteger cellBorder = [self borderAtIndexPath:attributes.indexPath];
        
        // Adds vertical lines when the item isn't the last in a section or in line.
        
        // Table left border
        if (0 != (tableBorder&kDMTableBorderLeft) && [self indexPathFirstInLine:attributes.indexPath]) {
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"TVSeparator" atIndexPath:attributes.indexPath]];
        }
        
        // Table right border
        if (0 != (tableBorder&kDMTableBorderRight) && [self indexPathLastInLine:attributes.indexPath]) {
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"TVSeparator" atIndexPath:attributes.indexPath]];
        }
        
        // Space between items
        if (0 != (cellBorder&(kDMTableBorderLeft|kDMTableBorderRight)) &&
            (!([self indexPathLastInSection:attributes.indexPath] ||
               [self indexPathLastInLine:attributes.indexPath]))) {
          [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"CVSeparator" atIndexPath:attributes.indexPath]];
        }
        
        // Adds horizontal lines when the item isn't in the last line.
        if (0 != ((tableBorder|cellBorder)&(kDMTableBorderBottom|kDMTableBorderTop))) {
          if (![self indexPathInLastLine:attributes.indexPath]) {
            if (0 != (cellBorder&(kDMTableBorderBottom|kDMTableBorderTop))) {
              // Cell bottom border
              [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"CHSeparator" atIndexPath:attributes.indexPath]];
            }
          } else if (0 != (tableBorder&kDMTableBorderBottom)) {
            // Table bottom border
            [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"THSeparator" atIndexPath:attributes.indexPath]];
          }
        }
      }
    }
  }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark – Getters/Setters
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfColumns
{
  if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewColumns:)]) {
    return [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionViewColumns:self.collectionView];
  }
  return 2;
}

- (CGFloat)collectionViewColumnWidth:(NSInteger)column
{
  CGFloat width;
  if (nil != self.columnsInfo && nil != self.columnsInfo[@(column)]) {
    width = [((NSNumber *)self.columnsInfo[@(column)]) floatValue];
  } else {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:columnWidth:)]) {
      width = [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionView:self.collectionView columnWidth:column];
      if (nil == self.columnsInfo) {
        self.columnsInfo = [NSMutableDictionary dictionary];
      }
      [self.columnsInfo setObject:@(width) forKey:@(column)];
    } else {
      width = self.collectionView.frame.size.width/self.numberOfColumns;
    }
  }
  return width;
}

- (CGFloat)collectionViewSectionHeight:(NSInteger)section
{
  CGFloat height;
  if (nil != self.rowsInfo && nil != self.rowsInfo[@(-section-1)]) {
    height = [((NSNumber *)self.rowsInfo[@(-section-1)]) floatValue];
  } else {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:sectionHeight:)]) {
      height = [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionView:self.collectionView sectionHeight:section];
      if (nil == self.rowsInfo) {
        self.rowsInfo = [NSMutableDictionary dictionary];
      }
      [self.rowsInfo setObject:@(height) forKey:@(-section-1)];
    } else {
      height = 50.f;
    }
  }
  return height;
}

- (CGFloat)collectionViewRowHeight:(NSInteger)row
{
  CGFloat height;
  if (nil != self.rowsInfo && nil != self.rowsInfo[@(row)]) {
    height = [((NSNumber *)self.rowsInfo[@(row)]) floatValue];
  } else {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:rowHeight:)]) {
      height = [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionView:self.collectionView rowHeight:row];
      if (nil == self.rowsInfo) {
        self.rowsInfo = [NSMutableDictionary dictionary];
      }
      [self.rowsInfo setObject:@(height) forKey:@(row)];
    } else {
      height = 50.f;
    }
  }
  return height;
}

- (CGFloat)collectionViewColumnOffset:(NSInteger)column
{
  const BOOL stretch = self.isStretch;
  CGFloat offset;
  if (!stretch) {
    offset = MAX(0, (self.collectionView.frame.size.width - self.tableWidth) / 2);
  } else {
    offset = (MAX(0, (self.collectionView.frame.size.width - self.tableWidth)) / self.numberOfColumns) * column;
  }
  for (NSInteger i=0; i < column; i++) {
    offset += [self collectionViewColumnWidth:i];
  }
  return offset;
}

- (CGFloat)collectionViewRowOffset:(NSInteger)row
{
  CGFloat offset = 0;
  for (NSInteger i=0; i < row; i++) {
    offset += [self collectionViewRowHeight:i];
  }
  return offset;
}

- (CGFloat)tableWidth
{
  if (tableWidthCache <= 0) {
    for (NSInteger i=0; i < self.numberOfColumns; i++) {
      tableWidthCache += [self collectionViewColumnWidth:i];
    }
  }
  return tableWidthCache;
}

- (BOOL)isHeader
{
  if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewHeader:)]) {
    return [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionViewHeader:self.collectionView];
  }
  return YES;
}

- (BOOL)isHeaderFixed
{
  if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewHeaderFixed:)]) {
    return [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionViewHeaderFixed:self.collectionView];
  }
  return NO;
}

- (BOOL)isStretch
{
  if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewStretch:)]) {
    return [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionViewStretch:self.collectionView];
  }
  return NO;
}

- (CGFloat)borderWidth
{
  if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewBorderWidth:)]) {
    return [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionViewBorderWidth:self.collectionView];
  }
  return 1.f;
}

- (CGFloat)borderPadding
{
  if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewBorderWidth:)]) {
    return [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionViewBorderPadding:self.collectionView];
  }
  return 0.f;
}

- (UIColor *)borderColor
{
  if ([self.collectionView.delegate respondsToSelector:@selector(collectionViewBorderColor:)]) {
    return [(id<DMTableCollectionViewDataSource>)(self.collectionView.delegate) collectionViewBorderColor:self.collectionView];
  }
  return [UIColor blackColor];
}

- (NSInteger)borderAtIndexPath:(NSIndexPath *)indexPath
{
  return kDMTableBorderAll;
}

- (NSInteger)headerBorderAtIndexPath:(NSIndexPath *)indexPath
{
  return kDMTableBorderAll;
}

- (NSInteger)tableBorder
{
  return kDMTableBorderAll;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath
{
  const NSInteger row = indexPath.row / self.numberOfColumns;
  const NSInteger column = indexPath.row % self.numberOfColumns;
  CGSize size = {[self collectionViewColumnWidth:column], [self collectionViewRowHeight:row]};
  
  if (self.isStretch) {
    size.width += MAX(0, (self.collectionView.frame.size.width - self.tableWidth)) / self.numberOfColumns;
  }
  
  const CGFloat originX = [self collectionViewColumnOffset:column];
  CGFloat originY = [self collectionViewRowOffset:row];
  
  if (self.isHeader) {
    originY += [self collectionViewSectionHeight:0];
  }
  
  return CGRectMake(originX, originY, size.width, size.height);
}

- (CGRect)frameForHeaderAtIndexPath:(NSIndexPath *)indexPath
{
  const NSInteger column = indexPath.row % self.numberOfColumns;
  CGSize size = {[self collectionViewColumnWidth:column], [self collectionViewRowHeight:0]};
  
  if (self.isStretch) {
    size.width += MAX(0, (self.collectionView.frame.size.width - self.tableWidth)) / self.numberOfColumns;
  }
  
  const CGFloat originX = [self collectionViewColumnOffset:column];
  CGFloat originY = 0;
  
  if (self.isHeaderFixed) {
    const CGFloat offset = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
    if (offset > 0) {
      originY += offset;
    }
  }
  
  return CGRectMake(originX, originY, size.width, size.height);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Helpers
////////////////////////////////////////////////////////////////////////////////

- (UICollectionViewLayoutAttributes *)layoutAttributesForHeaderAtIndexPath:(NSIndexPath *)indexPath
{
  return ((NSDictionary *)self.layoutInfo[kInfoHeaders])[indexPath];
}

- (NSInteger)rowIndexAtIndexPath:(NSIndexPath *)indexPath
{
  return indexPath.item / self.numberOfColumns;
}

- (BOOL)indexPathLastInSection:(NSIndexPath *)indexPath
{
  NSInteger lastItem = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section] - 1;
  return  lastItem == indexPath.row;
}

- (BOOL)indexPathInLastLine:(NSIndexPath *)indexPath
{
  NSInteger lastItemRow = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section] - 1;
  NSIndexPath *lastItem = [NSIndexPath indexPathForItem:lastItemRow inSection:indexPath.section];
  UICollectionViewLayoutAttributes *lastItemAttributes = [self layoutAttributesForItemAtIndexPath:lastItem];
  UICollectionViewLayoutAttributes *thisItemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
  
  return lastItemAttributes.frame.origin.y == thisItemAttributes.frame.origin.y;
}

- (BOOL)indexPathLastInLine:(NSIndexPath *)indexPath
{
  NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
  
  UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
  UICollectionViewLayoutAttributes *nextCellAttributes = [self layoutAttributesForItemAtIndexPath:nextIndexPath];
  
  return !(cellAttributes.frame.origin.y == nextCellAttributes.frame.origin.y);
}

- (BOOL)indexPathFirstInLine:(NSIndexPath *)indexPath
{
  return 0 == indexPath.item % self.numberOfColumns;
}

@end
