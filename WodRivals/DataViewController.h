//
//  DataViewController.h
//  WodRivals
//
//  Created by Chester O'Neill on 7/20/14.
//  Copyright (c) 2014 ThrowsException. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface DataViewController : UIViewController <FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;
@property (strong, nonatomic) id dataObject;

@end
