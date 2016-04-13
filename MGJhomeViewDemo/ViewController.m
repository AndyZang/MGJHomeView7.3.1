//
//  ViewController.m
//  MGJhomeViewDemo
//
//  Created by Wan's Mac on 3/28/16.
//  Copyright © 2016 Wan's Mac. All rights reserved.
//

#import "ViewController.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

static const CGFloat headerViewHeight = 300.0f;
static const CGFloat filterViewHeight = 50.0f;

@interface ViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController
{
    UIScrollView *mainScrollView;
    UITableView *mainTableView;
    UIView *fakeHeadView;
    UIView *fakeFilterView;
    UIScrollView *headScrollView;
    UIScrollView *filterView;
    NSMutableArray<UITableView *> *tableViewArray;
    NSMutableArray<UIButton *> *buttonArray;
    NSInteger currentTabIndex;
    NSMutableArray *tableViewSignArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tableViewArray = [NSMutableArray array];
    buttonArray = [NSMutableArray array];
    tableViewSignArray = [NSMutableArray array];
    currentTabIndex = 0;
    
    [self setupViews];
}

- (void)setupViews
{
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    mainScrollView.contentSize = CGSizeMake(screenWidth * 10, screenHeight);
    mainScrollView.bounces = NO;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.delegate = self;
    [self.view addSubview:mainScrollView];
    
    fakeHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerViewHeight)];
    fakeHeadView.hidden = YES;
    fakeHeadView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:fakeHeadView];
    [self.view bringSubviewToFront:fakeHeadView];
    
    fakeFilterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth,filterViewHeight)];
    fakeFilterView.hidden = YES;
    fakeFilterView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:fakeFilterView];
    [self.view bringSubviewToFront:fakeFilterView];
    
    headScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerViewHeight -filterViewHeight)];
    headScrollView.contentSize = CGSizeMake(screenWidth * 2, 0);
    headScrollView.backgroundColor = [UIColor greenColor];
    headScrollView.bounces = NO;
    UIView *signView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2, 0, screenWidth, headerViewHeight -filterViewHeight)];
    signView.backgroundColor = [UIColor redColor];
    [headScrollView addSubview:signView];
    
    filterView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 250, screenWidth,filterViewHeight)];
    CGFloat buttonWidth = 60;
    filterView.contentSize = CGSizeMake(buttonWidth * 10,filterViewHeight);
    filterView.backgroundColor = [UIColor orangeColor];
    for (NSInteger i = 0; i < 10; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth * i, 0, buttonWidth,filterViewHeight)];
        button.tag = i;
        [button setTitle:[NSString stringWithFormat:@"table%@",@(i)] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            button.selected = YES;
        }
        [tableViewArray addObject:[UITableView new]];
        [tableViewSignArray addObject:@(NO)];
        [buttonArray addObject:button];
        [filterView addSubview:button];
    }
    
    mainTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.backgroundColor = [UIColor lightGrayColor];
    mainTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, headerViewHeight)];
    [mainTableView.tableHeaderView addSubview:headScrollView];
    [mainTableView.tableHeaderView addSubview:filterView];
    [mainScrollView addSubview:mainTableView];
    
    tableViewArray[0] = mainTableView;
    tableViewSignArray[0] = @(YES);
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    __block NSInteger num;
    [tableViewArray enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == tableView) {
            num = 30 + idx * 5;
        }
    }];
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    [tableViewArray enumerateObjectsUsingBlock:^(UITableView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == tableView) {
            cell.frame = CGRectMake(0, 0, screenWidth, 40);
            cell.textLabel.text = [NSString stringWithFormat:@"table:%@ row:%@",@(idx),@(indexPath.row)];
        }
    }];
    
    return cell;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == mainScrollView) {
        if (mainScrollView.contentOffset.x != currentTabIndex * screenWidth) {
            NSInteger targetIndex = scrollView.contentOffset.x > tableViewArray[currentTabIndex].frame.origin.x? currentTabIndex+1: currentTabIndex-1;
            [self showTableViewWithIndex:targetIndex ifButtonClick:NO];
        }
    } else if(fakeHeadView.hidden) {
        [filterView removeFromSuperview];
        if (scrollView.contentOffset.y >= headerViewHeight - filterViewHeight) {
            fakeFilterView.hidden = NO;
            filterView.frame = CGRectMake(0, 0, screenWidth,filterViewHeight);
            [fakeFilterView addSubview:filterView];
        } else {
            fakeFilterView.hidden = YES;
            filterView.frame = CGRectMake(0, 250, screenWidth,filterViewHeight);
            [tableViewArray[currentTabIndex].tableHeaderView addSubview:filterView];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == mainScrollView) {
        //悬浮headView
        [headScrollView removeFromSuperview];
        fakeHeadView.hidden = NO;
        fakeHeadView.frame = CGRectMake(0, -tableViewArray[currentTabIndex].contentOffset.y, screenWidth, headerViewHeight);
        [fakeHeadView addSubview:headScrollView];
        
        if (tableViewArray[currentTabIndex].contentOffset.y < headerViewHeight - filterViewHeight) {
            [filterView removeFromSuperview];
            [fakeHeadView addSubview:filterView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == mainScrollView) {
        currentTabIndex = scrollView.contentOffset.x / screenWidth;
        [self buttonClicked:buttonArray[currentTabIndex]];
        [self addHeadViewToTableView];
    }
}

#pragma mark - events
- (void)buttonClicked:(UIButton *)sender
{
    for (UIButton *btn in buttonArray) {
        btn.selected = NO;
        if (btn == sender) {
            sender.selected = YES;
            [self showTableViewWithIndex:sender.tag ifButtonClick:YES];
        }
    }
}

- (void)showTableViewWithIndex:(NSInteger)index ifButtonClick:(BOOL)buttonClick
{
    if (![[tableViewSignArray objectAtIndex:index] boolValue]) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(index * screenWidth, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, headerViewHeight)];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [mainScrollView addSubview:tableView];
        tableViewArray[index] = tableView;
        tableViewSignArray[index] = @(YES);
        [tableView reloadData];
    }
    
    UITableView *currentTableView = tableViewArray[currentTabIndex];
    UITableView *targetTableView = [tableViewArray objectAtIndex:index];
    targetTableView.contentOffset = currentTableView.contentOffset.y > headerViewHeight - filterViewHeight? (targetTableView.contentOffset.y > headerViewHeight - filterViewHeight? targetTableView.contentOffset: CGPointMake(targetTableView.contentOffset.x, headerViewHeight - filterViewHeight)): CGPointMake(targetTableView.contentOffset.x, currentTableView.contentOffset.y);
    
    if (buttonClick) {
        currentTabIndex = index;
        mainScrollView.contentOffset = CGPointMake(index * screenWidth, 0);
        [self addHeadViewToTableView];
    }
}

- (void)addHeadViewToTableView;
{
    if (tableViewArray[currentTabIndex].contentOffset.y < headerViewHeight - filterViewHeight) {
        [filterView removeFromSuperview];
        fakeFilterView.hidden = YES;
        [tableViewArray[currentTabIndex].tableHeaderView addSubview:filterView];
    }
    [headScrollView removeFromSuperview];
    fakeHeadView.hidden = YES;
    [tableViewArray[currentTabIndex].tableHeaderView addSubview:headScrollView];
}
@end
