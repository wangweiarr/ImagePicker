//
//  IPAlbumView.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAlbumView.h"
#import "IPAlbumModel.h"
#import "IPAlbumCell.h"

@interface IPAlbumView ()<UITableViewDataSource,UITableViewDelegate>

/**数据*/
@property (nonatomic, strong)NSArray *dataSource;

/**内容视图*/
@property (nonatomic, weak)UITableView *mainView;

/**背景图*/
@property (nonatomic, weak)UIButton *backView;

@end


@implementation IPAlbumView
+ (instancetype)albumViewWithData:(NSArray *)data{
    IPAlbumView *ablumView = [[self alloc]init];
    ablumView.dataSource = [NSArray arrayWithArray:data];
    return ablumView;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUpViews];
    }
    return self;
}
- (void)setUpViews{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    
//    CATransition * transition=[CATransition animation];
//    transition.duration=0.3f;
//    transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    transition.type=kCATransitionReveal;
//    transition.subtype = kCATransitionFromBottom;
//    
//    
//    transition.delegate=self;
//    [self.layer addAnimation:transition forKey:nil];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor clearColor]];
    
    [btn addTarget:self action:@selector(dismissFromSuper) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    self.backView = btn;
    
    UITableView *tableView =[[UITableView alloc]init];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    self.mainView = tableView;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat height = self.dataSource.count * 50;
    if (height > 325) {
        height = 325;
    }
    self.mainView.frame = CGRectMake(0, 0, self.bounds.size.width, height);
    self.backView.frame = self.bounds;
}

- (void)dismissFromSuper{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldRemoveFrom:)]) {
        [self.delegate shouldRemoveFrom:self];
    }
}
- (void)selectAlbumViewCellForIndex:(NSInteger)index{
    if (index<0) {
        index = 0;
    }
    if (index > self.dataSource.count - 1) {
        index = self.dataSource.count - 1;
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.mainView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (IPAlbumCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *albumID = @"albumCell";
    IPAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:albumID];
    if (cell == nil) {
        cell = [[IPAlbumCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:albumID];
    }
    
    IPAlbumModel *model = self.dataSource[indexPath.row];
    cell.model = model;
   
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellForIndex:ForView:)]) {
        [self.delegate clickCellForIndex:indexPath ForView:self];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
@end
