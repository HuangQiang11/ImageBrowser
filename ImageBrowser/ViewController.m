//
//  ViewController.m
//  ImageBrowser
//
//  Created by huangqiang on 16/11/23.
//  Copyright © 2016年 huangqiang. All rights reserved.
//

#import "ViewController.h"
#import "HQBrowerController.h"
@interface ViewController ()<BrowerDelegate>
@property (strong, nonatomic)  NSArray * imageArr;
@property (strong, nonatomic)  UIScrollView * scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat w = CGRectGetWidth(self.view.frame);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, w, w)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.imageArr.count*w, w);
    [self.view addSubview:self.scrollView];
    
    for (int i = 0; i<self.imageArr.count; i++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*w, 0,w, w)];
        imageView.image = [UIImage imageNamed:self.imageArr[i]];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
        imageView.tag = i;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
    }
}


- (void)tapAction:(UITapGestureRecognizer *)tap{
    HQBrowerController * vc = [[HQBrowerController alloc] init];
    vc.delegate = self;
    vc.imageArr = self.imageArr;
    vc.tag = tap.view.tag;
    vc.originalRect = [self.scrollView convertRect:tap.view.frame toView:self.view];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissViewWithTurnToTag:(NSInteger)tag{
    self.scrollView.contentOffset = CGPointMake(tag*CGRectGetWidth(self.view.frame), 0);
}

- (NSArray *)imageArr{
    if (!_imageArr) {
        _imageArr = @[@"1",@"2",@"3"];
    }
    return _imageArr;
}


@end