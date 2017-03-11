//
//  ViewController.m
//  JWTaggedScrollView
//
//  Created by 黄嘉伟 on 16/8/26.
//  Copyright © 2016年 huangjw. All rights reserved.
//

#import "ViewController.h"
#import "JWTaggedScrollView.h"

@interface ViewController () <JWTaggedScrollViewDataSource, JWTaggedScrollViewDelegate>
@property (weak, nonatomic) IBOutlet JWTaggedScrollView *taggedScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.taggedScrollView.dataSource = self;
    self.taggedScrollView.delegate = self;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//  [self.taggedScrollView reloadData];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JWTaggedScrollViewDataSource

- (NSInteger)numberOfTags:(JWTaggedScrollView *)taggedScrollView
{
    return 3;
}

- (NSString *)taggedScrollView:(JWTaggedScrollView *)taggedScrollView textForTag:(NSUInteger)index
{
    return [NSString stringWithFormat:@"Test%lu", (unsigned long)index + 1];
}

- (UIView *)taggedScrollView:(JWTaggedScrollView *)taggedScrollView viewForTag:(NSUInteger)index
{
    UIView *view = [[UIView alloc] init];
    switch (index) {
        case 0:
            view.backgroundColor = [UIColor redColor];
            break;
        case 1:
            view.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            view.backgroundColor = [UIColor blueColor];
            break;

        default:
            break;
    }
    return view;
}

//- (UIColor *)colorForSelectedTag:(JWTaggedScrollView *)taggedScrollView
//{
//    return [UIColor redColor];
//}

#pragma mark - JWTaggedScrollViewDelegate

- (void)taggedScrollView:(JWTaggedScrollView *)taggedScrollView didSelectTag:(NSUInteger)index
{
    NSLog(@"SELECT: %lu", (unsigned long)index);
}

@end
