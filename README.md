LRScrollingSidebarController
============================

A scrolling based sidebar controller

### The problem about current implementations

Sidebar controllers are certainly one the the most implemented UX patterns in iOS. They became very popular due to Facebook and Path implementation. Nowadays, there are a lot of them, [too may](http://bitly.com/bundles/o_27ukkruo5l/1) I'd say. They've replaced a lot of the tab-bar based apps, but unfortunately, they all share the same problem, they are all wrong in terms of physics. Yes, there are some out there that are [kind of cool](https://github.com/monospacecollective/MSDynamicsDrawerViewController/) based on iOS 7 dynamics, but still, they don't work the way I expect this kind of controls to work. When you drag and release the panels, you feel like they stop suddenly, sharply, the panels don't flow and slide like they should. Mimicking physics as most of the libraries try is very, very difficult, you won't do it perfectly and you will feel this sudden speed changes or sharpness and abruptness when releasing the finger with a certain velocity.

So? What's the solution? Pretty simple actually: use a scroll view. That simple. We are all used to the scroll view physics... Why just don't use it for this very purpose? The result is a sidebar controller that is a pleasure to use... Install it on your device and use it, you'll se the difference.

This library is one of the reasons why everybody loves to use [iShows](http://ishowsapp.com/)

### Installation

1. **Using CocoaPods**

   Add LRScrollingSidebarController to your Podfile:

   ```
   platform :ios, "6.0"
   pod 'LRScrollingSidebarController'
   ```

   Run the following command:

   ```
   pod install
   ```

2. **Manually**

   Clone the project or add it as a submodule. Drag the whole LRScrollingSidebarController folder to your project.

### Usage

To instanciate the container controller, just provide the three child view controllers and a gap.

```
- (instancetype)initWithLeftViewController:(ISSidePanelController)leftViewController
                        mainViewController:(ISSidePanelController)mainViewController
                       rightViewController:(ISSidePanelController)rightViewController
                     mainViewControllerGap:(CGFloat)mainViewControllerGap;
```

Then, you can just assign the result as your window root view controller. That's enough to get started.

There are some other cool features you can do with LRScrollingSidebarController.

Customize the animation time.

```
@property (nonatomic) NSTimeInterval animationTime;
```

Specify a bounce animation displacement.

```
@property (nonatomic) CGFloat animationBounce;
```

Of course you can disable the bounce animation as well as the default parallax effect in the side panels.

```
@property (nonatomic) BOOL allowBouncing;
@property (nonatomic) BOOL allowParallax;
```

By default, the main panel has an overlay on top of it. You can customize the alpha and color of it.

```
@property (nonatomic, strong) UIColor *mainViewControllerOverlayColor;
@property (nonatomic) CGFloat mainViewControllerOverlayMaxAlpha;
```

Once you have the container controller configured with the three child controllers, you can just show them with the following methods:

```
- (void)showLeftViewControllerAnimated:(BOOL)animated;
- (void)showMainViewControllerAnimated:(BOOL)animated;
- (void)showRightViewControllerAnimated:(BOOL)animated;
```

You can also replace any of the child controllers at any moment:

```
- (void)replaceLeftViewController:(ISSidePanelController)leftViewController;
- (void)replaceMainViewController:(ISSidePanelController)mainViewController;
- (void)replaceRightViewController:(ISSidePanelController)rightViewController;

- (void)showLeftViewController:(ISSidePanelController)leftViewController
                      animated:(BOOL)animated;

- (void)showMainViewController:(ISSidePanelController)mainViewController
                      animated:(BOOL)animated;

- (void)showRightViewController:(ISSidePanelController)rightViewController
                       animated:(BOOL)animated;
```

To get the visible controller.

```
- (UIViewController *)visibleController;
```

The category UIViewController+LRScrollingSidebarController aims at making every view controller have a scrollingSidebarController property (the very same way every view controller has a navigationController, a tabBarController or a splitViewController property). If a view controller is embedded in the scrolling sidebar controller, it will have property pointing weakly to the container, otherwise, it will be nil. This way, you can be at a child controller, and interact directly with the sidebar controller.

```
[self.scrollingSidebarController showMainViewControllerAnimated:YES];
```

### Requirements

LRScrollingSidebarController requires both iOS 6.0 and ARC.

You can still use LRScrollingSidebarController in your non-arc project. Just set -fobjc-arc compiler flag in every source file.

### Contact

LRScrollingSidebarController was created by Luis Recuenco: [@luisrecuenco](https://twitter.com/luisrecuenco).

### Contributing

If you want to contribute to the project just follow this steps:

1. Fork the repository.
2. Clone your fork to your local machine.
3. Create your feature branch with the appropriate tests.
4. Commit your changes, push to your fork and submit a pull request.

## License

LRScrollingSidebarController is available under the MIT license. See the [LICENSE file](https://github.com/luisrecuenco/LRScrollingSidebarController/blob/master/LICENSE) for more info.
