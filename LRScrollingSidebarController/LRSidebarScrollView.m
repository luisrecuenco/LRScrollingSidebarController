// LRSidebarScrollView.m
//
// Copyright (c) 2014 Luis Recuenco
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LRSidebarScrollView.h"
#import "LRSidebarScrollView+Private.h"

static NSTimeInterval const kDefaultAnimationTime = 0.2f;
static CGFloat const kEdgeDraggingFactor = -10.0f;

@interface LRSidebarScrollView ()

@property (nonatomic, weak) UIView *mainView;
@property (nonatomic) CGFloat gap;

@end

@implementation LRSidebarScrollView

- (instancetype)initWithGap:(CGFloat)gap
{
    if (!(self = [super init])) return nil;
    
    _gap = gap;
    
    return self;
}

- (LRSidebarScrollViewState)scrollViewState
{
    if (self.contentOffset.x == CGPointZero.x)
    {
        return LRSidebarScrollViewStateLeft;
    }
    else if (self.contentOffset.x == self.frame.size.width)
    {
        return LRSidebarScrollViewStateCenter;
    }
    else if (self.contentOffset.x == self.frame.size.width * 2)
    {
        return LRSidebarScrollViewStateRight;
    }
    else
    {
        return LRSidebarScrollViewStateUnknown;
    }
}

- (void)setScrollViewState:(LRSidebarScrollViewState)scrollState
{
    [self setScrollViewState:scrollState animated:NO];
}

- (void)setScrollViewState:(LRSidebarScrollViewState)scrollState animated:(BOOL)animated
{
    switch (scrollState)
    {
        case LRSidebarScrollViewStateLeft:
        {
            [self performAnimation:(CGPoint){0 - self.animationBounce, 0}
                       secondPoint:CGPointZero
                          animated:animated];
            break;
        }
        case LRSidebarScrollViewStateCenter:
        {
            CGFloat finalPoint = self.scrollViewState == LRSidebarScrollViewStateLeft ?
                                                         self.animationBounce : -self.animationBounce;
            [self performAnimation:(CGPoint){self.frame.size.width + finalPoint, 0}
                       secondPoint:(CGPoint){self.frame.size.width, 0}
                          animated:animated];
            break;
        }
        case LRSidebarScrollViewStateRight:
        {
            [self performAnimation:(CGPoint){self.frame.size.width * 2 + self.animationBounce, 0}
                       secondPoint:(CGPoint){self.frame.size.width * 2, 0}
                          animated:animated];
            break;
        }
        case LRSidebarScrollViewStateUnknown:
        {
            NSAssert(NO, @"Shouldn't be here");
        }
    }
}

- (void)performAnimation:(CGPoint)firstPoint
             secondPoint:(CGPoint)secondPoint
                animated:(BOOL)animated
{
    void (^completion)(BOOL finished) = ^(BOOL finished){
        [self.delegate scrollViewDidEndDecelerating:self];
    };
    
    if (animated)
    {
        [self performAnimation:firstPoint
                   secondPoint:secondPoint
                    completion:completion];
    }
    else
    {
        self.contentOffset = secondPoint;
        completion(YES);
    }
}

- (void)performAnimation:(CGPoint)firstPoint
             secondPoint:(CGPoint)secondPoint
              completion:(void(^)(BOOL finished))completion
{
    self.scrollEnabled = NO;
    
    [UIView animateWithDuration:self.animationTime
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentOffset = firstPoint;
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:self.animationTime
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.contentOffset = secondPoint;
                                          } completion:^(BOOL finished) {
                                              self.scrollEnabled = YES;
                                              completion(finished);
                                          }];
                     }];
}

- (NSTimeInterval)animationTime
{
    return _animationTime ?: [self defaultAnimationTime];
}

- (CGFloat)animationBounce
{
    CGFloat bounce = 0.0f;
    
    if (self.allowBouncing)
    {
        bounce = _animationBounce ?: [self defaultAnimationBounce];
    }
    
    return bounce;
}

- (NSTimeInterval)defaultAnimationTime
{
    return kDefaultAnimationTime;
}

- (CGFloat)defaultAnimationBounce
{
    return self.gap / 2;
}

#pragma mark - Hit Testing Tweaking

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint([self effectiveFrame], point);
}

- (CGRect)effectiveFrame
{
    return CGRectInset(self.mainView.frame, kEdgeDraggingFactor, 0);
}

@end
