//
//  JWTaggedScrollView.m
//  JWTaggedScrollView
//
//  Created by 黄嘉伟 on 16/8/26.
//  Copyright © 2016年 huangjw. All rights reserved.
//

#import "JWTaggedScrollView.h"

#define TAG_HEIGHT 44.0
#define SELECTED_LINE_HEIGHT 2.0
#define TAG_COLOR [UIColor darkGrayColor]
#define SELECTED_TAG_COLOR [self tintColor]
#define CAN_SWIPE YES

@interface JWTaggedScrollView() <UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *tagLabels;
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) UIView *selectedLine;
@end

@implementation JWTaggedScrollView
{
  NSUInteger _desinationIndex;
  BOOL _motivateByTag;
  
  // From data source
  NSInteger _numberOfTags;
  BOOL _canSwipe;
  CGFloat _tagHeight;
  UIColor *_selectedColor;
}

- (void)layoutSubviews
{
  CGFloat tagWidth = self.frame.size.width / _numberOfTags;
  
  [self.tagLabels enumerateObjectsUsingBlock:^(UILabel *tagLabel, NSUInteger idx, BOOL * _Nonnull stop) {
    tagLabel.frame = CGRectMake(idx * tagWidth, 0, tagWidth, _tagHeight);
  }];
  
  self.contentScrollView.frame = CGRectMake(0, _tagHeight, self.frame.size.width, self.frame.size.height - _tagHeight);
  self.contentScrollView.contentSize = CGSizeMake(_numberOfTags * self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
  
  [self.contentScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
    view.frame = CGRectMake(idx * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height - _tagHeight);
  }];

  self.selectedLine.frame = CGRectMake(self.selectedIndex * tagWidth, _tagHeight - SELECTED_LINE_HEIGHT, tagWidth, SELECTED_LINE_HEIGHT);
  [self scrollToContent:self.selectedIndex];
}

#pragma mark - Properties

- (UIView *)selectedLine
{
  if (!_selectedLine) {
    _selectedLine = [[UIView alloc] init];
  }
  return _selectedLine;
}

- (UIScrollView *)contentScrollView
{
  if (!_contentScrollView) {
    _contentScrollView = [[UIScrollView alloc] init];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.bounces = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_contentScrollView];
  }
  return _contentScrollView;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
  _desinationIndex = selectedIndex;
  [self scrollToContent:selectedIndex];
}

- (void)setDataSource:(id<JWTaggedScrollViewDataSource>)dataSource
{
  _dataSource = dataSource;
  [self reloadData];
}

#pragma mark -

- (UILabel *)tagLabelForIndex:(NSUInteger)index
{
  if (!self.tagLabels) {
    self.tagLabels = [NSMutableArray array];
  }
  UILabel *label;
  if (self.tagLabels.count > index) {
    label = [self.tagLabels objectAtIndex:index];
  } else {
    label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:17.0f];
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.textColor = TAG_COLOR;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTapped:)];
    [label addGestureRecognizer:tap];
    
    [self.tagLabels addObject:label];
  }
  return label;
}

- (void)tagTapped:(UITapGestureRecognizer *)recognizer
{
  UILabel *label = (UILabel *)recognizer.view;
  NSUInteger tapIndex = [self.tagLabels indexOfObject:label];
  if (tapIndex != self.selectedIndex) {
    _motivateByTag = YES;
    self.selectedIndex = tapIndex;
  }
  [self.delegate taggedScrollView:self didSelectTag:tapIndex];
}

- (void)reloadData
{
  [self clean];
  
  _numberOfTags = [self.dataSource numberOfTags:self];
  if ([self.dataSource respondsToSelector:@selector(canSwipe:)]) {
    _canSwipe = [self.dataSource canSwipe:self];
  } else {
    _canSwipe = CAN_SWIPE;
  }
  if ([self.dataSource respondsToSelector:@selector(tagHeight:)]) {
    _tagHeight = [self.dataSource tagHeight:self];
  } else {
    _tagHeight = TAG_HEIGHT;
  }
  if ([self.dataSource respondsToSelector:@selector(colorForSelectedTag:)]) {
    _selectedColor = [self.dataSource colorForSelectedTag:self];
  } else {
    _selectedColor = SELECTED_TAG_COLOR;
  }

  if (_numberOfTags > 0) {
    [self shrinkArray:self.tagLabels neededCount:_numberOfTags];
    
    for (NSInteger i = 0; i < _numberOfTags; ++i) {
      UILabel *tagLabel = [self tagLabelForIndex:i];
      tagLabel.text = [self.dataSource taggedScrollView:self textForTag:i];
      
      if (i == 0) tagLabel.textColor = _selectedColor;
      
      [self addSubview:tagLabel];
        
      UIView *view = [self.dataSource taggedScrollView:self viewForTag:i];
      [self.contentScrollView addSubview:view];
    }
  
    self.contentScrollView.scrollEnabled = _canSwipe;

    self.selectedLine.backgroundColor = _selectedColor;
    [self addSubview:self.selectedLine];
  }
  [self setNeedsLayout];
}

- (void)clean
{
  for (UIView *label in self.tagLabels) {
    [label removeFromSuperview];
  }
  for (UIView *view in self.contentScrollView.subviews) {
    [view removeFromSuperview];
  }
  [self.selectedLine removeFromSuperview];
}

- (void)shrinkArray:(NSMutableArray *)array neededCount:(NSUInteger)neededCount
{
  if (array.count > neededCount) {
    for (NSUInteger i = 0; i < array.count - neededCount; i++) {
      [array removeLastObject];
    }
  }
}

- (void)scrollToLabel:(NSUInteger)index
{
    UILabel *formerLabel = [self.tagLabels objectAtIndex:self.selectedIndex];
    formerLabel.textColor = TAG_COLOR;
    
    UILabel *tagLabel = [self.tagLabels objectAtIndex:index];
    tagLabel.textColor = _selectedColor;
    
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         self.selectedLine.center = CGPointMake(tagLabel.frame.origin.x + tagLabel.frame.size.width / 2, self.selectedLine.center.y);
     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _selectedIndex = index;
                         }
                     }];
}

- (void)scrollToContent:(NSUInteger)index
{
    [self.contentScrollView setContentOffset:CGPointMake(index * self.contentScrollView.frame.size.width, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  NSUInteger index = (scrollView.contentOffset.x + scrollView.frame.size.width / 2) / scrollView.frame.size.width;
  if ((!_motivateByTag && index != self.selectedIndex) || (_motivateByTag && index == _desinationIndex)) {
      _motivateByTag = NO;
     [self scrollToLabel:index];
  }
}

@end
