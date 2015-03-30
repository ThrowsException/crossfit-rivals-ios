//
//  CompletedWorkotusControllerViewController.h
//  WodRivals
//
//  Created by Chester O'Neill on 7/27/14.
//  Copyright (c) 2014 ThrowsException. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface CompletedWorkoutsViewController : UIViewController <UIPageViewControllerDelegate,UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
