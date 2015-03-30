//
//  CompletedWorkotusControllerViewController.m
//  WodRivals
//
//  Created by Chester O'Neill on 7/27/14.
//  Copyright (c) 2014 ThrowsException. All rights reserved.
//

#import "CompletedWorkoutsViewController.h"
static NSString * const BaseURLString = @"http://localhost:3000/";

@interface CompletedWorkoutsViewController ()
@property (strong, nonatomic) NSArray *workouts;
@property (strong, nonatomic) NSArray *finishedGooglePlacesArray;

@end

@implementation CompletedWorkoutsViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Here");
    [super viewWillAppear:animated];
    
    NSString *token = [[[FBSession activeSession] accessTokenData] accessToken];
    
    // 1
    NSString *string = [NSString stringWithFormat:@"%@api/completed?access_token=%@", BaseURLString, token];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 3
        NSLog(@"Request Success %@",responseObject);
        self.workouts = responseObject;
        self.title = @"Completed WODs";
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Data"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];

    
    //self.dataLabel.text = [self.dataObject description];
}

- (void)viewDidLoad
{
    NSLog(@"Here");
    
    self.tableView.DataSource = self;
    self.tableView.delegate = self;

    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Do any additional setup after loading the view.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Hello world");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.workouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *tempDictionary= [self.workouts objectAtIndex:indexPath.row];
    
    NSString *s = [tempDictionary objectForKey:@"created"];
    NSDate *date = [dateFormatter dateFromString: s];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MMMM-dd-yyyy";
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ | %@",[tempDictionary objectForKey:@"title"], [format stringFromDate:date]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Score: %@",[tempDictionary objectForKey:@"score"]];
    
    return cell;
    
}


@end
