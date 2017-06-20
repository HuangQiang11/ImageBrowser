//
//  HQBrowerController.h
//  ImageBrowser
//
//  Created by huangqiang on 16/11/23.
//  Copyright © 2016年 huangqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BrowerDelegate<NSObject>
- (void)dismissViewWithTurnToTag:(NSInteger)tag;
@end
@interface HQBrowerController : UIViewController
@property (copy, nonatomic) NSArray * imageArr;
@property (assign, nonatomic) NSUInteger tag;
@property (assign, nonatomic) CGRect originalRect;
@property (assign, nonatomic) id<BrowerDelegate>delegate;
@end
