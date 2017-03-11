//
//  JWTaggedScrollView.h
//  JWTaggedScrollView
//
//  Created by 黄嘉伟 on 16/8/26.
//  Copyright © 2016年 huangjw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JWTaggedScrollView;

@protocol JWTaggedScrollViewDataSource <NSObject>
@required
- (NSInteger)numberOfTags:(JWTaggedScrollView *)taggedScrollView;
- (NSString *)taggedScrollView:(JWTaggedScrollView *)taggedScrollView textForTag:(NSUInteger)index;
- (UIView *)taggedScrollView:(JWTaggedScrollView *)taggedScrollView viewForTag:(NSUInteger)index;
@optional
- (UIColor *)colorForSelectedTag:(JWTaggedScrollView *)taggedScrollView;
- (CGFloat)tagHeight:(JWTaggedScrollView *)taggedScrollView;
- (BOOL)canSwipe:(JWTaggedScrollView *)taggedScrollView;
@end

@protocol JWTaggedScrollViewDelegate <NSObject>
@optional
- (void)taggedScrollView:(JWTaggedScrollView *)taggedScrollView didSelectTag:(NSUInteger)index;
@end

@interface JWTaggedScrollView : UIView
@property (nonatomic, weak) id<JWTaggedScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<JWTaggedScrollViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedIndex;
- (void)reloadData;
@end
