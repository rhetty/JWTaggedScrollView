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
    CGFloat _tagHeight;
    UIColor *_selectedColor;
    NSLayoutConstraint *_selectedLineLeftConstraint;
    NSLayoutConstraint *_selectedLineRightConstraint;
    NSUInteger _desinationIndex;
    BOOL _motivateByTag;
}

- (UIView *)selectedLine
{
    if (!_selectedLine) {
        _selectedLine = [[UIView alloc] init];
        _selectedLine.translatesAutoresizingMaskIntoConstraints = NO;
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
        _contentScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentScrollView];
    }
    return _contentScrollView;
}

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
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
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
    [self.delegate didSelectTag:tapIndex];
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

- (void)reloadData
{
    [self clean];
    
    NSInteger tagCount = [self numberOfTags];
    if (tagCount > 0) {
        [self shrinkArray:self.tagLabels neededCount:tagCount];
        CGFloat tagWidth = self.frame.size.width / tagCount;
        _tagHeight = [self tagHeight];
        _selectedColor = [self colorForSelectedTag];
        
        for (NSInteger i = 0; i < tagCount; i++) {
            UILabel *tagLabel = [self tagLabelForIndex:i];
            tagLabel.text = [self textForTag:i];
            tagLabel.frame = CGRectMake(i * tagWidth, 0, tagWidth, _tagHeight);
            if (i == 0) tagLabel.textColor = _selectedColor;
            [self addSubview:tagLabel];
            
            UIView *view = [self viewForTag:i];
            if (view) {
                view.frame = CGRectMake(i * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height - _tagHeight);
                view.translatesAutoresizingMaskIntoConstraints = NO;
                [self.contentScrollView addSubview:view];
            }

        }
        
        self.contentScrollView.scrollEnabled = [self canSwipe];
        self.contentScrollView.frame = CGRectMake(0, _tagHeight, self.frame.size.width, self.frame.size.height - _tagHeight);
        self.contentScrollView.contentSize = CGSizeMake(tagCount * self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
        
        self.selectedLine.backgroundColor = _selectedColor;
        self.selectedLine.frame = CGRectMake(0, _tagHeight - SELECTED_LINE_HEIGHT, tagWidth, SELECTED_LINE_HEIGHT);
        [self addSubview:self.selectedLine];
        
        [self addConstraints];
        self.selectedIndex = 0;
    }
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
                             [self setSelectedLineHorizontalConstraints:tagLabel];
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

#pragma mark - Get DataSource values


- (NSInteger)numberOfTags
{
    if ([self.dataSource respondsToSelector:@selector(numberOfTags)]) {
        return [self.dataSource numberOfTags];
    } else {
        return 0;
    }
}
- (UIColor *)colorForSelectedTag
{
    if ([self.dataSource respondsToSelector:@selector(colorForSelectedTag)]) {
        return [self.dataSource colorForSelectedTag];
    } else {
        return SELECTED_TAG_COLOR;
    }
}

- (NSString *)textForTag:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(textForTag:)]) {
        return [self.dataSource textForTag:index];
    } else {
        return [NSString stringWithFormat:@"标签%lu", (unsigned long)index + 1];
    }
}
- (UIView *)viewForTag:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(viewForTag:)]) {
        return [self.dataSource viewForTag:index];
    } else {
        return nil;
    }
}

- (CGFloat)tagHeight
{
    if ([self.dataSource respondsToSelector:@selector(tagHeight)]) {
        return [self.dataSource tagHeight];
    } else {
        return TAG_HEIGHT;
    }
}

- (BOOL)canSwipe
{
    if ([self.dataSource respondsToSelector:@selector(canSwipe)]) {
        return [self.dataSource canSwipe];
    } else {
        return CAN_SWIPE;
    }
}

#pragma mark - Constraints

- (void)addConstraints
{
    [self removeConstraints:self.constraints];
    
    for (NSInteger i = 0; i < self.tagLabels.count; i++) {
        UILabel *tagLabel = self.tagLabels[i];
        [tagLabel removeConstraints:tagLabel.constraints];
        if (i == 0) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:tagLabel
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1
                                                              constant:0]];
        } else {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:tagLabel
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.tagLabels[i - 1]
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1
                                                              constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:tagLabel
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.tagLabels[i - 1]
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1
                                                              constant:0]];
        }
        if (i == self.tagLabels.count - 1) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:tagLabel
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1
                                                              constant:0]];
        }
        [self addConstraint:[NSLayoutConstraint constraintWithItem:tagLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:0]];
        [tagLabel addConstraint:[NSLayoutConstraint constraintWithItem:tagLabel
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1
                                                              constant:_tagHeight]];
    }
    
    [self.contentScrollView removeConstraints:self.contentScrollView.constraints];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.contentScrollView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:self.contentScrollView
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:self.contentScrollView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:self.contentScrollView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:_tagHeight]]];
    
    [self.selectedLine removeConstraints:self.selectedLine.constraints];
    [self setSelectedLineHorizontalConstraints:self.tagLabels.firstObject];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.selectedLine
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1
                                                         constant:SELECTED_LINE_HEIGHT],
                           [NSLayoutConstraint constraintWithItem:self.selectedLine
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.tagLabels.firstObject
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:0]]];
    
    for (NSInteger i = 0; i < self.contentScrollView.subviews.count; i++) {
        UIView *view = self.contentScrollView.subviews[i];
        [view removeConstraints:view.constraints];
        if (i == 0) {
            [self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentScrollView
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1
                                                              constant:0]];
        } else {
            [self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentScrollView.subviews[i - 1]
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1
                                                              constant:0]];
        }
        if (i == self.contentScrollView.subviews.count - 1) {
            [self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.contentScrollView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1
                                                                                constant:0]];
        }
        [self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.contentScrollView
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1
                                                                            constant:0]];
        [self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.contentScrollView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1
                                                                            constant:0]];
        [self.contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.contentScrollView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1
                                                                            constant:0]];
    }
}

- (void)setSelectedLineHorizontalConstraints:(UILabel *)tagLabel
{
    [self removeConstraint:_selectedLineLeftConstraint];
    [self removeConstraint:_selectedLineRightConstraint];
    _selectedLineLeftConstraint = [NSLayoutConstraint constraintWithItem:self.selectedLine
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:tagLabel
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:0];
    _selectedLineRightConstraint = [NSLayoutConstraint constraintWithItem:self.selectedLine
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:tagLabel
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1
                                                                 constant:0];
    [self addConstraints:@[_selectedLineLeftConstraint, _selectedLineRightConstraint]];
}

@end
