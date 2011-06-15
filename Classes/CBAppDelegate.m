/*-
 * Copyright (c) 2011, Benedikt Meurer <benedikt.meurer@googlemail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#import "MBProgressHUD.h"

#import "CBAppDelegate.h"
#import "CBClass.h"
#import "CBFramework.h"
#import "CBProtocol.h"
#import "CBSelector.h"


@implementation CBAppDelegate

@synthesize rootViewController = _rootViewController;
@synthesize navigationController = _navigationController;
@synthesize window = _window;

- (void)dealloc
{
    [_rootViewController release];
    [_navigationController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Display a progress HUD while loading the registered runtime components
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.window animated:NO];
    progressHUD.labelText = @"Loading...";
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // We use an extra dispatch_async() on the main queue in order
        // to have the UI updated prior to loading the frameworks
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            NSArray *frameworks = [CBFramework registeredFrameworks];
            NSArray *classes = [CBClass registeredClasses];
            NSArray *protocols = [CBProtocol registeredProtocols];
            NSArray *selectors = [CBSelector registeredSelectors];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                self.rootViewController.frameworks = frameworks;
                self.rootViewController.classes = classes;
                self.rootViewController.protocols = protocols;
                self.rootViewController.selectors = selectors;
                [progressHUD hide:YES];
            });
        });
    });
    [self.window makeKeyAndVisible];
    return YES;
}

@end
