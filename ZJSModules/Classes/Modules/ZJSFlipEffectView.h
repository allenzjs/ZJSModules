//
//  ZJSFlipEffectView.h
//  Pods-ZJSModules_Example
//
//  Created by 查俊松 on 2019/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJSFlipEffectView : UIView

// 初始化第一个视图
- (void)setupFromView:(nonnull UIView *)fromView;
// 过渡到下一个视图
- (void)flipTransitionToView:(nonnull UIView *)toView duration:(NSTimeInterval)duration completionHandler:(nullable void (^)(void))completionHandler;

@end

NS_ASSUME_NONNULL_END
