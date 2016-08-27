//
//  JWTaggedScrollView.h
//  JWTaggedScrollView
//
//  Created by 黄嘉伟 on 16/8/26.
//  Copyright © 2016年 huangjw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JWTaggedScrollViewDataSource <NSObject>
@required
- (NSInteger)numberOfTags;
- (NSString *)textForTag:(NSUInteger)index;
- (UIView *)viewForTag:(NSUInteger)index;
@optional
- (UIColor *)colorForSelectedTag;
- (CGFloat)tagHeight;
- (BOOL)canSwipe;
@end

@protocol JWTaggedScrollViewDelegate <NSObject>
@optional
- (void)didSelectTag:(NSUInteger)index;
@end

@interface JWTaggedScrollView : UIView
@property (nonatomic, weak) id<JWTaggedScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<JWTaggedScrollViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)reloadData;
@end
