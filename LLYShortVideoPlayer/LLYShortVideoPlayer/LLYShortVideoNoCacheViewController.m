//
//  LLYShortVideoNoCacheViewController.m
//  LLYShortVideoPlayer
//
//  Created by lly on 2019/2/20.
//  Copyright © 2019 lly. All rights reserved.
//

#import "LLYShortVideoNoCacheViewController.h"
#import <Masonry.h>
#import "LLYCollectionViewCell.h"

@interface LLYShortVideoNoCacheViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *mCollectionView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) LLYCollectionViewCell *curVisibleCell;
@property (nonatomic, strong) LLYCollectionViewCell *lastVisibleCell;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation LLYShortVideoNoCacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //开始播放第一个
    [self p_startPlayer];
}

- (void)initUI{
    
    [self.view addSubview:self.mCollectionView];
    [self.mCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.left.mas_equalTo(60);
        make.top.mas_equalTo(50);
    }];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LLYCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LLYCollectionViewCell" forIndexPath:indexPath];
    [cell configWithUrl:self.dataSourceArray[indexPath.row] idx:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(OCWidth, OCHeight);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    self.lastVisibleCell = self.mCollectionView.visibleCells.lastObject;
    //    NSLog(@"lastVisibleCell = %@",self.lastVisibleCell);
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint contentOffsetPt = self.mCollectionView.contentOffset;
    NSInteger yIdx = contentOffsetPt.y / OCHeight;
    self.curVisibleCell = (LLYCollectionViewCell *)[self.mCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:yIdx inSection:0]];
    //    NSLog(@"curVisibleCell = %@",self.curVisibleCell);
    
    if (self.lastVisibleCell != self.curVisibleCell) {
        [self.lastVisibleCell stop];
        [self.curVisibleCell play];
    }
    
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Getter/Setter

- (UICollectionView *)mCollectionView{
    if (!_mCollectionView) {
        
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.minimumLineSpacing = 0.f;
        flow.minimumInteritemSpacing = 0.f;
        
        _mCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        _mCollectionView.delegate = self;
        _mCollectionView.dataSource = self;
        _mCollectionView.backgroundColor = [UIColor whiteColor];
        _mCollectionView.pagingEnabled = YES;
        
        [_mCollectionView registerClass:[LLYCollectionViewCell class] forCellWithReuseIdentifier:@"LLYCollectionViewCell"];
    }
    return _mCollectionView;
}

- (NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray arrayWithArray:@[@"http://jmdianbostag.ks3-cn-beijing.ksyun.com/MjQ0NzY5NDU2/MTUxNjY5NzAzNTgwNg_E_E/OTQ2NTc2MA_E_E/MDY2OTVDOUItMzYwNi00MUM1LUJFRUQtRjJCQkJGOThFOTIyLk1PVg_E_E_default.mp4",
                                                            @"http://jmdianbostag.ks3-cn-beijing.ksyun.com/MTE1NzIzNzAz/MTUxNjUzNzA4MDk4Nw_E_E/MTAyNzE1NDM_E/dHJpbS4wN0JDOTEzMy01M0VELTQ5OUQtOTY2RS1GNUM4NDZEMUY5OTAuTU9W_default.mp4",
                                                            @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MjA2ODI4OQ_E_E/Mjg1NTk4OQ_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOThiNGUyNzEzMzIyMGMyMTdhZmU2Y2FhMWEyYTZlZDUvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTA4MjUxMA_E_E/Mzg0NTAxMA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTdkNDRlNTQ5NTM5NjZhMWZmZDA1OTRlYzhlNzQwYmMvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTM1NTUwNDYxNQ_E_E/MjEyNzc3MA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MjQwOTQ0MzEzMjk1MjA5MDQvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MjA5MzQ4Ng_E_E/MjcwNTgwOA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOThiYTA0MTZiNTU3NGVhN2QxMjA4MGZlMzdiYmI0MWIvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTkwMDA3MA_E_E/NDA0NDkzNA_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTg3N2Y3ZTM2YTYzN2I2ZjY2OTE0ZGU1YjIxNDFkZDQvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo1.jumei.com/MQ_E_E/MTUxOTY0MTA2NTQ1OA_E_E/NDE0OTE2Nw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZmlsZV84OTkyMTMtOTdjZWI5ODk3Yzk1NTY1MjBmY2E0NjZmZTI4MmQ0MmUvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo.jumei.com/MQ_E_E/MTUzMzcxMjMxMzcxNw_E_E/MTEwODU4Nw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MjcxNjgzNTE2NjIyNDcxODEvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQyMTU4NzczMQ_E_E/MjE1MzE0Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MzgxNzU0MzQ5MDU4ODE4NjMvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjQzNDc5MTUwOA_E_E/ODk3Mjg1/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1ODA4OTQwOTI1Mzg5NDA2NzYvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo.jumei.com/MQ_E_E/MTUzMjUxMjE1NDY2Nw_E_E/OTI1ODU4Mg_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1Njc5ODM4NTg0Mzg5MDA5OTUvdmlkZW8ubXA0.mp4",
                                                            @"http://jmvideo.jumei.com/MQ_E_E/MTUyMjY1NDAwOTg3Nw_E_E/MjYxMTg2Mw_E_E/L2hvbWUvd3d3L2xvZ3MvdmlkZW8vZG91eWluXzY1MTkyNDcwMzQ4NjY3MzIzMDIvdmlkZW8ubXA0.mp4"]];
    }
    return _dataSourceArray;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark - Private Method

- (void)p_startPlayer{
    
    self.curVisibleCell = (LLYCollectionViewCell *)[self.mCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.curVisibleCell play];
    
}

- (void)backBtnClicked:(id)sender{
    [self.curVisibleCell stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
