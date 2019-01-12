//
//  ZJSFlipEffectView.m
//  Pods-ZJSModules_Example
//
//  Created by 查俊松 on 2019/1/10.
//

#import "ZJSFlipEffectView.h"

#define kZJSFlipEffectViewDefaultDuration 1.0

@interface ZJSFlipEffectView ()

@property (nonatomic, strong) UIView *baseView; //基础视图
@property (nonatomic, strong) UIImageView *fromTopView; //fromTopView动画层
@property (nonatomic, strong) UIImageView *fromBottomView; //fromBottomView动画层
@property (nonatomic, strong) UIImageView *toTopView; //toTopView动画层

@property (nonatomic, strong) UIView *fromView; //开始视图
@property (nonatomic, strong) UIView *toView; //结束视图
@property (nonatomic, assign) NSTimeInterval duration; //过渡时间

@property (nonatomic, strong) UIImage *fromTopImg; //开始视图上半部分
@property (nonatomic, strong) UIImage *fromBottomImg; //开始视图下半部分
@property (nonatomic, strong) UIImage *toTopImg; //结束视图上半部分
@property (nonatomic, strong) UIImage *toBottomImg; //结束视图下半部分

@property (nonatomic, assign) BOOL isAnimating; //是否正在动画中

@property (nonatomic, copy) void (^completionHandler)(void); //动画完成回调

@end

@implementation ZJSFlipEffectView

#pragma mark - 重写初始化方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // 基础视图
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.baseView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.baseView];
        
    }
    return self;
}

#pragma mark - 生成开始视图图片素材
- (void)createFromImg
{
    NSArray<UIImage *> *fromImages = [self createImagesWithContentView:self.fromView];
    self.fromTopImg = fromImages.firstObject;
    self.fromBottomImg = fromImages.lastObject;
}

#pragma mark - 生成结束视图图片素材
- (void)createToImg
{
    NSArray<UIImage *> *toImages = [self createImagesWithContentView:self.toView];
    self.toTopImg = toImages.firstObject;
    self.toBottomImg = toImages.lastObject;
}

#pragma mark - 生成图片素材
- (NSArray<UIImage *> *)createImagesWithContentView:(UIView *)contentView
{
    // 生成完整图片素材
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(contentView.bounds.size.width, contentView.bounds.size.height), NO, [UIScreen mainScreen].scale);
    
    [contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 裁剪出上半部分和下半部分
    CGImageRef topTargetImageRef = CGImageCreateWithImageInRect(resultingImage.CGImage, CGRectMake(0, 0, resultingImage.size.width*resultingImage.scale, resultingImage.size.height/2.f*resultingImage.scale));
    UIImage *topTargetImage = [UIImage imageWithCGImage:topTargetImageRef scale:resultingImage.scale orientation:UIImageOrientationUp];
    CGImageRef bottomTargetImageRef = CGImageCreateWithImageInRect(resultingImage.CGImage, CGRectMake(0, resultingImage.size.height/2.f*resultingImage.scale, resultingImage.size.width*resultingImage.scale, resultingImage.size.height/2.f*resultingImage.scale));
    UIImage *bottomTargetImage = [UIImage imageWithCGImage:bottomTargetImageRef scale:resultingImage.scale orientation:UIImageOrientationUp];
    
    return @[topTargetImage, bottomTargetImage];
}

#pragma mark - 初始化第一个视图
- (void)setupFromView:(nonnull UIView *)fromView
{
    // 安全判断
    if (!fromView) {
        return;
    }
    self.fromView = fromView;
    if (self.baseView.subviews.firstObject) {
        [self.baseView.subviews.firstObject removeFromSuperview];
    }
    [self.baseView addSubview:fromView];
    [self createFromImg];
}

#pragma mark - 过渡到下一个视图
- (void)flipTransitionToView:(nonnull UIView *)toView duration:(NSTimeInterval)duration completionHandler:(nullable void (^)(void))completionHandler
{
    // 安全判断
    if (!toView || self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    self.userInteractionEnabled = NO;
    // 赋值
    self.toView = toView;
    self.duration = (duration > 0) ? duration : kZJSFlipEffectViewDefaultDuration;
    self.completionHandler = completionHandler;
    // fromTopView动画层
    self.fromTopView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/2.f)];
    self.fromTopView.image = self.fromTopImg;
    [self addSubview:self.fromTopView];
    // fromBottomView动画层
    self.fromBottomView = [[UIImageView alloc] initWithImage:self.fromBottomImg];
    self.fromBottomView.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/2.f);
    self.fromBottomView.layer.position = CGPointMake(self.bounds.size.width/2.f, self.bounds.size.height/2.f);
    self.fromBottomView.layer.anchorPoint = CGPointMake(0.5, 0);
    [self addSubview:self.fromBottomView];
    // baseView
    if (self.baseView.subviews.firstObject) {
        [self.baseView.subviews.firstObject removeFromSuperview];
    }
    [self.baseView addSubview:toView];
    [self createToImg];
    // 动画第一部分
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:self.duration/2.f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.fromBottomView.layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.fromBottomView removeFromSuperview];
        
        // toTopView动画层
        strongSelf.toTopView = [[UIImageView alloc] initWithImage:strongSelf.toTopImg];
        strongSelf.toTopView.bounds = CGRectMake(0, 0, strongSelf.bounds.size.width, strongSelf.bounds.size.height/2.f);
        strongSelf.toTopView.layer.position = CGPointMake(strongSelf.bounds.size.width/2.f, strongSelf.bounds.size.height/2.f);
        strongSelf.toTopView.layer.anchorPoint = CGPointMake(0.5, 1);
        strongSelf.toTopView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 1, 0, 0);
        [strongSelf addSubview:strongSelf.toTopView];
        // 动画第二部分
        [UIView animateWithDuration:strongSelf.duration/2.f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            strongSelf.toTopView.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            [strongSelf.fromTopView removeFromSuperview];
            [strongSelf.toTopView removeFromSuperview];
            // 动画完成
            strongSelf.fromView = strongSelf.toView;
            strongSelf.toView = nil;
            strongSelf.fromTopImg = strongSelf.toTopImg;
            strongSelf.fromBottomImg = strongSelf.toBottomImg;
            strongSelf.toTopImg = nil;
            strongSelf.toBottomImg = nil;
            strongSelf.isAnimating = NO;
            strongSelf.userInteractionEnabled = YES;
            // 回调
            if (strongSelf.completionHandler) {
                strongSelf.completionHandler();
            }
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
