//
//  UIViewController+LRScrollingSidebarController.m
//  LRScrollingSidebarControllerExample
//
//  Created by Luis Recuenco on 20/01/14.
//  Copyright (c) 2014 Luis Recuenco. All rights reserved.
//

#import "UIViewController+LRScrollingSidebarController.h"
#import <objc/runtime.h>

@implementation UIViewController (LRScrollingSidebarController)

- (LRScrollingSidebarController *)scrollingSidebarController
{
    return objc_getAssociatedObject(self, @selector(scrollingSidebarController));

}

- (void)setScrollingSidebarController:(LRScrollingSidebarController *)scrollingSidebarController
{
    objc_setAssociatedObject(self, @selector(scrollingSidebarController), scrollingSidebarController, OBJC_ASSOCIATION_ASSIGN);
}

@end
