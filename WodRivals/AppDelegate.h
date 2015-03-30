//
//  AppDelegate.h
//  WodRivals
//
//  Created by Chester O'Neill on 7/20/14.
//  Copyright (c) 2014 ThrowsException. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTokenCachingStrategy.h"

#import <FacebookSDK/FacebookSDK.h>

extern NSString *const FBSessionStateChangedNotification;

@class DataViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) MyTokenCachingStrategy *tokenCaching;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DataViewController *viewController;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
@end
