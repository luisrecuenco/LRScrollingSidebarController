// LRScrollingSidebarController.h
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

extern NSString *const kScrollViewWillBeginDraggingNotification;
extern NSString *const kScrollViewDidEndDraggingNotification;
extern NSString *const kScrollViewDidEndDeceleratingNotification;

@protocol LRScrollingSidebarController;
@protocol LRScrollingSidebarControllerDelegate;

typedef UIViewController<LRScrollingSidebarController> *ISSidePanelController;

#pragma mark - LRScrollingSidebarController Interface

@interface LRScrollingSidebarController : UIViewController

@property (nonatomic, strong, readonly) ISSidePanelController leftViewController;
@property (nonatomic, strong, readonly) ISSidePanelController mainViewController;
@property (nonatomic, strong, readonly) ISSidePanelController rightViewController;

@property (nonatomic, readonly) CGFloat mainViewControllerGap;

@property (nonatomic) LRSidebarScrollViewState initialState;

@property (nonatomic) UIColor *mainViewControllerOverlayColor;
@property (nonatomic) CGFloat mainViewControllerOverlayMaxAlpha;

@property (nonatomic) NSTimeInterval animationTime;
@property (nonatomic) CGFloat animationBounce;

@property (nonatomic) BOOL allowBouncing;
@property (nonatomic) BOOL allowParallax;
@property (nonatomic) BOOL allowTabToDismiss;

@property (nonatomic, weak) id<LRScrollingSidebarControllerDelegate> delegate;

- (instancetype)initWithLeftViewController:(ISSidePanelController)leftViewController
                        mainViewController:(ISSidePanelController)mainViewController
                       rightViewController:(ISSidePanelController)rightViewController
                     mainViewControllerGap:(CGFloat)mainViewControllerGap;

- (void)showLeftViewControllerAnimated:(BOOL)animated;
- (void)showMainViewControllerAnimated:(BOOL)animated;
- (void)showRightViewControllerAnimated:(BOOL)animated;

- (void)replaceLeftViewController:(ISSidePanelController)leftViewController;
- (void)replaceMainViewController:(ISSidePanelController)mainViewController;
- (void)replaceRightViewController:(ISSidePanelController)rightViewController;

- (void)showLeftViewController:(ISSidePanelController)leftViewController
                      animated:(BOOL)animated;

- (void)showMainViewController:(ISSidePanelController)mainViewController
                      animated:(BOOL)animated;

- (void)showRightViewController:(ISSidePanelController)rightViewController
                       animated:(BOOL)animated;

- (void)activateScrollingSidebarNavigation;
- (void)deactivateScrollingSidebarNavigation;

- (UIViewController *)visibleController;

@end

#pragma mark - LRScrollingSidebarControllerDelegate

@protocol LRScrollingSidebarControllerDelegate <NSObject>

@optional

- (void)scrollingSidebarController:(LRScrollingSidebarController *)scrollingSidebarController
willBeginDraggingMainPanelWithScrollView:(UIScrollView *)scrollView;

- (void)scrollingSidebarController:(LRScrollingSidebarController *)scrollingSidebarController
  didScrollMainPanelWithScrollView:(UIScrollView *)scrollView;

- (void)scrollingSidebarController:(LRScrollingSidebarController *)scrollingSidebarController
didEndDraggingMainPanelWithScrollView:(UIScrollView *)scrollView;

- (void)scrollingSidebarController:(LRScrollingSidebarController *)scrollingSidebarController
  didEndDeceleratingWithScrollView:(UIScrollView *)scrollView;

@end

#pragma mark - LRScrollingSidebarController Protocol

@protocol LRScrollingSidebarController <NSObject>

@optional

- (void)controllerIsVisible:(BOOL)controllerIsVisible;

@end
