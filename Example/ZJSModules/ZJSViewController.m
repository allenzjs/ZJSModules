//
//  ZJSViewController.m
//  ZJSModules
//
//  Created by allenzjs on 01/10/2019.
//  Copyright (c) 2019 allenzjs. All rights reserved.
//

#import "ZJSViewController.h"

#import <ZJSModules/ZJSModules.h>

#define kFlipEffectViewMargin 10.f
#define kFlipEffectViewRatio (345.f/165.f)

@interface ZJSViewController ()

@property (nonatomic, strong) ZJSFlipEffectView *flipEffectView;

@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ZJSViewController

- (void)dealloc
{
    [self.timer invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.flipEffectView = ({
        CGFloat width = self.view.bounds.size.width - 2*kFlipEffectViewMargin;
        CGFloat height = round(width/kFlipEffectViewRatio);
        ZJSFlipEffectView *flipEffectView = [[ZJSFlipEffectView alloc] initWithFrame:CGRectMake(kFlipEffectViewMargin, (self.view.bounds.size.height-height)/2.f, width, height)];
        [self.view addSubview:flipEffectView];
        
        flipEffectView;
    });
    
    [self.flipEffectView setupFromView:[self nextContentView]];
    
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.flipEffectView flipTransitionToView:[strongSelf nextContentView] duration:1 completionHandler:nil];
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (UIView *)nextContentView
{
    if (self.index > 2) {
        self.index = 0;
    }
    NSString *imgName = [NSString stringWithFormat:@"test%02ld", self.index];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.flipEffectView.bounds];
    imgView.image = [UIImage imageNamed:imgName];
    self.index++;
    return imgView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
