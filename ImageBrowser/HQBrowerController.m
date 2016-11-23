//
//  HQBrowerController.m
//  ImageBrowser
//
//  Created by huangqiang on 16/11/23.
//  Copyright © 2016年 huangqiang. All rights reserved.
//

#import "HQBrowerController.h"
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define MaxScale 3.0
#define MinScale  1.0
@interface HQBrowerController ()<UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView * bottomScrollView;
@property (assign, nonatomic) CGPoint originalPoint;
@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UIPageControl * pageControl;
@end

@implementation HQBrowerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.imageView) {
         self.originalPoint = self.imageView.center;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    [self setupLayout];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.imageView) {
        [self.view bringSubviewToFront:self.imageView];
        [UIView animateWithDuration:0.5 animations:^{
            self.imageView.center = self.view.center;
        } completion:^(BOOL finished) {
            self.bottomScrollView.hidden = NO;
            self.imageView.hidden = YES;
        }];
    }else{
        self.bottomScrollView.hidden = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return  UIStatusBarStyleLightContent;
}

#pragma mark layout
- (void)setupLayout{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    [self.view addSubview: self.bottomScrollView];
    [self.view addSubview:self.pageControl];
    self.bottomScrollView.contentSize = CGSizeMake(Screen_Width*self.imageArr.count, 0);
    self.bottomScrollView.contentOffset = CGPointMake(Screen_Width*self.tag, 0);
    [self creatView];
}

- (void)creatView{
    for (int i =0; i<self.imageArr.count; i++) {
        UIScrollView * subScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(i*Screen_Width, 0, Screen_Width, Screen_Height)];
        subScrollView.backgroundColor = [UIColor clearColor];
        subScrollView.minimumZoomScale = MinScale;
        subScrollView.maximumZoomScale = MaxScale;
        subScrollView.delegate = self;
        subScrollView.contentSize = CGSizeMake(Screen_Width, Screen_Width);
        [self.bottomScrollView addSubview:subScrollView];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (Screen_Height-Screen_Width)/2.0, Screen_Width, Screen_Width)];
        imageView.image = [UIImage imageNamed:self.imageArr[i]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [subScrollView addSubview:imageView];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
        tapGesture.numberOfTapsRequired = 2;
        [subScrollView addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)];
        tap.numberOfTapsRequired = 1;
        //如果不加下面的话，当单指双击时，会先调用单指单击中的处理，再调用单指双击中的处理
        [tap requireGestureRecognizerToFail:tapGesture];
        [subScrollView addGestureRecognizer:tap];
    }
}

#pragma mark private method
- (void)dismissView:(UITapGestureRecognizer *)tap{
    UIScrollView *scroll = (UIScrollView *)tap.view;
    [scroll setZoomScale:MinScale animated:NO];
    if (self.imageView) {
        UIImageView * imageView = (UIImageView *)scroll.subviews.firstObject;
        self.imageView.image = imageView.image;
        self.imageView.hidden = NO;
        self.bottomScrollView.hidden = YES;
        if (self.delegate) {
            [self.delegate dismissViewWithTurnToTag:(NSInteger)self.bottomScrollView.contentOffset.x/Screen_Width];
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.center = self.originalPoint;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didTapImageView:(UITapGestureRecognizer *)tap
{
    UIScrollView *scroll = (UIScrollView *)tap.view;
    if (scroll.zoomScale == MinScale) {
        CGRect newRect = [self zoomRectByScale:MaxScale Center:[tap locationInView:tap.view]];
        //zoomToRect方法是UIScrollVie对象的方法,将图片相对放大
        [scroll zoomToRect:newRect animated:YES];
    }else {
        [scroll setZoomScale:MinScale animated:YES];
    }
}

- (CGRect)zoomRectByScale:(CGFloat)scale Center:(CGPoint)center
{
    CGRect zoomRect;
    //求出新的长和宽
    zoomRect.size.width = Screen_Width / scale;
    zoomRect.size.height = Screen_Height / scale;
    
    //找到新的原点
    zoomRect.origin.x = center.x * (1 - 1/scale);
    zoomRect.origin.y = center.y * (1 - 1/scale);
    
    return zoomRect;
}

#pragma mark lazy
- (UIScrollView *)bottomScrollView{
    if (!_bottomScrollView) {
        _bottomScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _bottomScrollView.pagingEnabled = YES;
        _bottomScrollView.delegate = self;
        _bottomScrollView.showsVerticalScrollIndicator = NO;
        _bottomScrollView.showsHorizontalScrollIndicator = NO;
        _bottomScrollView.bounces = NO;
        _bottomScrollView.backgroundColor = [UIColor clearColor];
        _bottomScrollView.hidden = YES;
    }
    return _bottomScrollView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.originalRect];
        _imageView.image = [UIImage imageNamed:self.imageArr[self.tag]];
    }
    return _imageView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(20, Screen_Height-30, Screen_Width-40, 20)];
        _pageControl.numberOfPages = self.imageArr.count;
        _pageControl.currentPage = self.tag;
    }
    return _pageControl;
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return scrollView.subviews.firstObject;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    UIImageView * imageView = (UIImageView *)scrollView.subviews.firstObject;
    CGSize originalSize=scrollView.bounds.size;
    CGSize contentSize=scrollView.contentSize;
    CGFloat offsetX=originalSize.width>contentSize.width?(originalSize.width-contentSize.width)/2:0;
    CGFloat offsetY=originalSize.height>contentSize.height?(originalSize.height-contentSize.height)/2:0;
    imageView.center=CGPointMake(contentSize.width/2+offsetX, contentSize.height/2+offsetY);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //翻页恢复最小状态
    for (UIScrollView *tempScroll in scrollView.subviews) {
        if ([tempScroll isKindOfClass:[UIScrollView class]]) {
            tempScroll.zoomScale = MinScale;
        }
    }
    if (scrollView == self.bottomScrollView) {
        self.pageControl.currentPage = self.bottomScrollView.contentOffset.x/Screen_Width;
    }
}

@end
