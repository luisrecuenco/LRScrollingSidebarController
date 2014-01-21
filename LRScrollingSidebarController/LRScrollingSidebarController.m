// LRScrollingSidebarController.m
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

#import "LRScrollingSidebarController.h"
#import "LRSidebarScrollView.h"
#import "LRSidebarScrollView+Private.h"
#import "UIViewController+LRScrollingSidebarController.h"

NSString *const kScrollViewWillBeginDraggingNotification = @"kScrollViewWillBeginDraggingNotification";
NSString *const kScrollViewDidEndDraggingNotification = @"kScrollViewDidEndDraggingNotification";
NSString *const kScrollViewDidEndDeceleratingNotification = @"kScrollViewDidEndDeceleratingNotification";

static NSUInteger const kShadowOffset = 45;

@interface LRScrollingSidebarController () <UIScrollViewDelegate>

@property (nonatomic, strong) LRSidebarScrollView *scrollView;

@end

@implementation LRScrollingSidebarController

- (instancetype)initWithLeftViewController:(ISSidePanelController)leftViewController
                        mainViewController:(ISSidePanelController)mainViewController
                       rightViewController:(ISSidePanelController)rightViewController
                     mainViewControllerGap:(CGFloat)mainViewControllerGap
{
    if (!(self = [super init])) return nil;
    
    _leftViewController = leftViewController;
    _mainViewController = mainViewController;
    _rightViewController = rightViewController;

    _mainViewControllerGap = mainViewControllerGap;
    _allowBouncing = YES;
    
    return self;
}

- (void)loadView
{
    self.view =
    ({
        UIView *view = [[UIView alloc] initWithFrame:self.mainViewController.view.frame];
        self.scrollView = [[LRSidebarScrollView alloc] initWithGap:self.mainViewControllerGap];
        self.scrollView.frame = CGRectInset(view.frame, self.mainViewControllerGap, 0);
        self.scrollView.clipsToBounds = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.delegate = self;
        self.scrollView.animationTime = self.animationTime;
        self.scrollView.animationBounce = self.animationBounce;
        self.scrollView.allowBouncing = self.allowBouncing;
        view;
    });
    
    [self buildUpMainHierarchy];
    
    [self showLeftViewControllerAnimated:NO];
    [self activateScrollingSidebarNavigation];
}

- (void)buildUpMainHierarchy
{
    [self replaceLeftViewController:self.leftViewController];
    [self replaceRightViewController:self.rightViewController];
    [self replaceMainViewController:self.mainViewController];
    
    [self.view addSubview:self.scrollView];
}

- (void)replaceLeftViewController:(ISSidePanelController)leftViewController
{
    [self removeSidePanelViewController:_leftViewController];
    _leftViewController = leftViewController;
    [self setScrollingSidebarControllerToChildViewController:_leftViewController];
    
    [self addSidePanelViewController:_leftViewController parentView:self.view];
    [self.view sendSubviewToBack:_leftViewController.view];
}

- (void)replaceMainViewController:(ISSidePanelController)mainViewController
{
    [self removeSidePanelViewController:_mainViewController];
    _mainViewController = mainViewController;
    [self setScrollingSidebarControllerToChildViewController:_mainViewController];
    
    _mainViewController.view.frame =
    ({
        CGRect mainControllerFrame = _mainViewController.view.frame;
        mainControllerFrame.origin.x += self.scrollView.frame.size.width - self.mainViewControllerGap;
        mainControllerFrame;
    });
    
    self.scrollView.mainView = _mainViewController.view;
    
    [self addSidePanelViewController:_mainViewController
                          parentView:self.scrollView];
    [self.view bringSubviewToFront:self.scrollView];
}

- (void)replaceRightViewController:(ISSidePanelController)rightViewController
{
    [self removeSidePanelViewController:_rightViewController];
    _rightViewController = rightViewController;
    [self setScrollingSidebarControllerToChildViewController:_rightViewController];
    
    [self addSidePanelViewController:_rightViewController parentView:self.view];
    [self.view sendSubviewToBack:_rightViewController.view];
}

- (void)showLeftViewController:(ISSidePanelController)leftViewController
                      animated:(BOOL)animated
{
    [self replaceLeftViewController:leftViewController];
    [self showLeftViewControllerAnimated:animated];
}

- (void)showMainViewController:(ISSidePanelController)mainViewController
                      animated:(BOOL)animated
{
    [self replaceMainViewController:mainViewController];
    [self showMainViewControllerAnimated:animated];
}

- (void)showRightViewController:(ISSidePanelController)rightViewController
                       animated:(BOOL)animated
{
    [self replaceRightViewController:rightViewController];
    [self showRightViewControllerAnimated:animated];
}

- (void)showLeftViewControllerAnimated:(BOOL)animated
{
    [self scrollViewWillBeginDragging:self.scrollView];
    
    self.leftViewController.view.hidden = NO;
    self.rightViewController.view.hidden = YES;
    
    [self.scrollView setScrollViewState:LRSidebarScrollViewStateLeft animated:animated];
}

- (void)showMainViewControllerAnimated:(BOOL)animated
{
    [self scrollViewWillBeginDragging:self.scrollView];
    
    [self activateScrollingSidebarNavigation];
    
    if (!self.scrollView.tracking)
    {
        [self.scrollView setScrollViewState:LRSidebarScrollViewStateCenter animated:animated];
    }
}

- (void)showRightViewControllerAnimated:(BOOL)animated
{
    [self scrollViewWillBeginDragging:self.scrollView];
    
    self.leftViewController.view.hidden = YES;
    self.rightViewController.view.hidden = NO;
    
    [self.scrollView setScrollViewState:LRSidebarScrollViewStateRight animated:animated];
}

- (void)addSidePanelViewController:(UIViewController *)childViewController
                        parentView:(UIView *)parentView
{
    [self addChildViewController:childViewController];
    [parentView addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}

- (void)removeSidePanelViewController:(ISSidePanelController)childViewController
{
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
    childViewController.scrollingSidebarController = nil;
}

- (void)setScrollingSidebarControllerToChildViewController:(ISSidePanelController)childViewController
{
    childViewController.scrollingSidebarController = self;
}

#pragma mark - Activate & Deactiviate scrolling sidebar navigation

- (void)activateScrollingSidebarNavigation
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3,
                                             self.scrollView.frame.size.height);
}

- (void)deactivateScrollingSidebarNavigation
{
    // It could also be deactivated via scrollEnabled property in UIScrollView.
    // Doing it this way the user can drag the gap and see that the main panel
    // is actually something to move...
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             self.scrollView.frame.size.height);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kScrollViewWillBeginDraggingNotification
                                                        object:self.scrollView];
    
    if ([self.delegate respondsToSelector:
         @selector(scrollingSidebarController:willBeginDraggingMainPanelWithScrollView:)])
    {
        [self.delegate scrollingSidebarController:self
         willBeginDraggingMainPanelWithScrollView:self.scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:
         @selector(scrollingSidebarController:didScrollMainPanelWithScrollView:)])
    {
        [self.delegate scrollingSidebarController:self
                 didScrollMainPanelWithScrollView:self.scrollView];
    }
    
    if (self.scrollView.scrollEnabled)
    {
        CGFloat scrollViewFrameWidth = self.scrollView.frame.size.width;
        self.rightViewController.view.hidden = self.scrollView.contentOffset.x < scrollViewFrameWidth;
        self.leftViewController.view.hidden = self.scrollView.contentOffset.x > scrollViewFrameWidth;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kScrollViewDidEndDraggingNotification
                                                        object:self.scrollView];
    if ([self.delegate respondsToSelector:
         @selector(scrollingSidebarController:didEndDraggingMainPanelWithScrollView:)])
    {
        [self.delegate scrollingSidebarController:self
            didEndDraggingMainPanelWithScrollView:self.scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self notifyControllerIsVisible:self.leftViewController];
    [self notifyControllerIsVisible:self.mainViewController];
    [self notifyControllerIsVisible:self.rightViewController];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kScrollViewDidEndDeceleratingNotification
                                                        object:self.scrollView];
    
    if ([self.delegate respondsToSelector:
         @selector(scrollingSidebarController:didEndDeceleratingWithScrollView:)])
    {
        [self.delegate scrollingSidebarController:self
                 didEndDeceleratingWithScrollView:self.scrollView];
    }
}

- (void)notifyControllerIsVisible:(ISSidePanelController)viewController
{
    if ([viewController respondsToSelector:@selector(controllerIsVisible:)])
    {
        [viewController controllerIsVisible:self.visibleController == viewController];
    }
}

- (UIViewController *)visibleController
{
    switch (self.scrollView.scrollViewState)
    {
        case LRSidebarScrollViewStateLeft:
            return self.leftViewController;
        case LRSidebarScrollViewStateCenter:
            return self.mainViewController;
        case LRSidebarScrollViewStateRight:
            return self.rightViewController;
        case LRSidebarScrollViewStateUnknown:
            return nil;
    }
}

#pragma mark - Supported Orientations (Only portrait for now)

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
