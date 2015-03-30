//
//  DataViewController.m
//  WodRivals
//
//  Created by Chester O'Neill on 7/20/14.
//  Copyright (c) 2014 ThrowsException. All rights reserved.
//

#import "DataViewController.h"
#import "CompletedWorkoutsViewController.h"

#import "AppDelegate.h"
static NSString* kBackendURL = @"http://localhost:3000/auth/facebook/token";
// Remote cache - date format
static NSString* kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";

@interface DataViewController () {}

@property (strong, nonatomic) IBOutlet UIButton *authButton;

@end

@implementation DataViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}

#pragma mark - Helper methods

/*
 * Configure the logged in versus logged out UI
 */
- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self.authButton setTitle:@"Log out" forState:UIControlStateNormal];
    } else {
        [self.authButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    }
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    [self performSegueWithIdentifier:@"AppBegin" sender:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.loginView.delegate = self;
    
    // Register for notifications on FB session state changes
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)authButtonAction:(id)sender {
//    AppDelegate *appDelegate =
//    [[UIApplication sharedApplication] delegate];
//    
//    // If the user is authenticated, log out when the button is clicked.
//    // If the user is not authenticated, log in when the button is clicked.
//    if (FBSession.activeSession.isOpen) {
//        [appDelegate closeSession];
//    } else {
//        // The user has initiated a login, so call the openSession method
//        // and show the login UX if necessary.
//        [appDelegate openSessionWithAllowLoginUI:YES];
//    }
    
    NSString *token = [[[FBSession activeSession] accessTokenData] accessToken];
    NSError *error = nil;
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"http://localhost:3000/auth/facebook/token?access_token=%@", token]];
    NSURLResponse *response = nil;
    
    // Set up a URL request to the back-end server
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: url];
    // Configure an HTTP Get
    [urlRequest setHTTPMethod:@"GET"];
    
    // Make a synchronous request
    NSData *responseData = (NSMutableData *)[NSURLConnection
                                             sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                             error:&error];
    // Process the returned data
    if([self handleResponse:responseData] != nil)
    {
        CompletedWorkoutsViewController *viewController = [CompletedWorkoutsViewController alloc];
        
        [self.navigationController pushViewController:viewController animated:YES];
    }

}

/*
*
* Helper method to check the back-end server response
* for both reads and writes.
*/
- (NSDictionary *) handleResponse:(NSData *)responseData {
    NSError *jsonError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:responseData
                                                options:0
                                                  error:&jsonError];
    if (jsonError) {
        return nil;
    }
    // Check for a properly formatted response
    if ([result isKindOfClass:[NSDictionary class]] &&
        result[@"status"]) {
        // Check if we got a success case back
        BOOL success = [result[@"status"] boolValue];
        if (!success) {
            // Handle the error case
            NSLog(@"Error: %@", result[@"errorMessage"]);
            return nil;
        } else {
            // Check for returned token data (in the case of read requests)
            if (result[@"token_info"]) {
                // Create an NSDictionary of the token data
                NSData *jsonData = [result[@"token_info"]
                                    dataUsingEncoding:NSUTF8StringEncoding];
                if (jsonData) {
                    jsonError = nil;
                    NSDictionary *tokenResult =
                    [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:0
                                                      error:&jsonError];
                    if (jsonError) {
                        return nil;
                    }
                    
                    // Check if valid data returned, i.e. not nil
                    if ([tokenResult isKindOfClass:[NSDictionary class]]) {
                        // Parse the results to handle conversion for
                        // date values.
                        return [self dictionaryDateParse:tokenResult];
                    } else {
                        return nil;
                    }
                } else {
                    return nil;
                }
            } else {
                return nil;
            }
        }
    } else {
        NSLog(@"Error, did not get any data back");
        return nil;
    }
}

/*
 * Helper method to look for strings that represent dates and
 * convert them to NSDate objects.
 */
- (NSMutableDictionary *) dictionaryDateParse: (NSDictionary *) data {
    // Date format for date checks
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat];
    // Dictionary to return
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    // Enumerate through the input dictionary
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // Check if strings are dates
        if ([obj isKindOfClass:[NSString class]]) {
            NSDate *objDate = nil;
            BOOL isDate = [dateFormatter getObjectValue:&objDate
                                              forString:obj
                                       errorDescription:nil];
            if (isDate) {
                resultDictionary[key] = objDate;
                [resultDictionary setObject:objDate forKey:key];
            } else {
                resultDictionary[key] = obj;
            }
        } else {
            // Non-string, just keep as-is
            resultDictionary[key] = obj;
        }
    }];
    return resultDictionary;
}


- (void)viewDidUnload {
    [self setAuthButton:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"ICalled Myself");
    
    NSLog(@"Source Controller = %@", [segue sourceViewController]);
    NSLog(@"Destination Controller = %@", [segue destinationViewController]);
    NSLog(@"Segue Identifier = %@", [segue identifier]);
    
    if ([segue.identifier isEqualToString:@"mysegue"])
    {
        NSLog(@"coming here");
        
        CompletedWorkoutsViewController *completedWorkoutsController = (CompletedWorkoutsViewController *)segue.destinationViewController;
        
        //SecondViewController *navigationController = [[UINavigationController alloc]init];
        
        [self presentViewController:completedWorkoutsController animated:YES completion:nil];
        
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
