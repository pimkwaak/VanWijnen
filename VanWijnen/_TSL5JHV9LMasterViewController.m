//
//  _TSL5JHV9LMasterViewController.m
//  VanWijnen
//
//  Created by Pim van der Kwaak on 09-06-14.
//  Copyright (c) 2014 Pim van der Kwaak. All rights reserved.
//

#import "_TSL5JHV9LMasterViewController.h"

#import "_TSL5JHV9LDetailViewController.h"
#import "_TSL5JHV9LAppDelegate.h"
#import "KeychainItemWrapper.h"

#import <Security/Security.h>

@interface _TSL5JHV9LMasterViewController () {
    
    NSMutableArray *_objects;
    
    
    // A dictionary object
    NSDictionary *dictionary;
    
    // Define keys
    NSString *title;
    NSString *thumbnail;
    NSString *photo;
    NSString *bericht;
    NSString *categories;
    
    // define main reusable strings
    NSString *token;
    NSString *userName;
    
}
@end

@implementation _TSL5JHV9LMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    _TSL5JHV9LAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate login];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Vernieuw berichten"];
    [refresh addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    NSLog(@"test");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Initiate notificationcenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:)name:@"EnteredForeground"object:nil];
    
    // Connect to appdelegate to see whether the token is valid
    _TSL5JHV9LAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate login];
    
    // Define keys
    title = @"title";    thumbnail = @"image_thumb_url";
    bericht = @"content";
    photo = @"image_url";
    categories = @"categories";
    
    // Initiate refreshcontrol
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Vernieuw berichten"];
    [refresh addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // Refresh tableview
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredForeground"
                                                        object:nil];
    
}

-(void)refreshAll
{
    [self.refreshControl beginRefreshing];
    
    @try {
    if (self.tableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            
            // Load data from the keychain
            KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil]    ;
            
            userName = [keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
            token = [keychainWrapper objectForKey:(__bridge id)(kSecValueData)];
            
            // Link to secure data
            NSURL *url=[NSURL URLWithString:@"http://vanwijnen.thegreatnew.nl/api/v1/feed/"];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"GET"];
            [request setValue:token forHTTPHeaderField:@"App-Auth-Token"];
            [request setValue:userName forHTTPHeaderField:@"App-Device-Id"];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            _objects = [[NSMutableArray alloc] init];
            
            // Load JSON objects
            NSData *jsonSource = urlData;
            
            id jsonObjects = [NSJSONSerialization JSONObjectWithData:
                              jsonSource options:NSJSONReadingMutableContainers error:nil];
            
            //NSLog(@"id: %@", jsonObjects);
            
            for (NSDictionary *dataDict in jsonObjects) {
                NSString *title_data = [dataDict objectForKey:@"title"];
                NSString *thumbnail_data = [dataDict objectForKey:@"image_thumb_url"];
                NSString *photo_data = [dataDict objectForKey:@"image_url"];
                NSString *content_data = [dataDict objectForKey:@"content"];
                
                dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              title_data, title,
                              thumbnail_data, thumbnail,
                              photo_data, photo,
                              content_data, bericht,
                              //categories_data, categories,
                              nil];
                [_objects addObject:dictionary];
                [self.tableView reloadData];
            }
        } completion:^(BOOL finished){
            
            [self.refreshControl endRefreshing];
            
        }];
    }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Het verbinden met de server is mislukt" :@"Verbinding mislukt" :0];
    }
}

- (void)enteredForeground:(id)object {
    
    // Reload the tableview
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger LogIn = [defaults integerForKey:@"LogIn"];
    
    // Check if the token is valid, if not: do not reload
    
    if (LogIn == 1) {
        
        [self refreshAll];
        
    }
}

-(void)refreshView:(UIRefreshControl *)refresh {
    
    // Refresh with the main data loading method
    [self refreshAll];
    
    // Reload tableview data
    [self.tableView reloadData];
    
    
    [refresh endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
    //return [[dictionary objectForKey:@"categories"] count];
    //NSLog(@"%@",[dictionary objectForKey:@"categories"]);
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//return [[[dictionary objectForKey:@"categories"]objectForKey:[_objects objectAtIndex:section]]objectForKey:@"categories"];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell=[[UITableViewCell alloc]initWithStyle:
              UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tmpDict = [_objects objectAtIndex:indexPath.row];
    
    NSMutableString *text;
    //text = [NSString stringWithFormat:@"%@",[tmpDict objectForKey:title]];
    text = [NSMutableString stringWithFormat:@"%@",
            [tmpDict objectForKeyedSubscript:title]];
    
    NSMutableString *detail;
    detail = [NSMutableString stringWithFormat:@"%@",
              [tmpDict objectForKey:bericht]];
    
    //NSMutableString *images;
    //images = [NSMutableString stringWithFormat:@"%@",
    //          [tmpDict objectForKey:thumbnail]];
    
    NSURL *url = [NSURL URLWithString:[tmpDict objectForKey:thumbnail]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc]initWithData:data];
    
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.text = text;
    [cell.textLabel sizeToFit];
    
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text= detail;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    cell.imageView.frame = CGRectMake(0, 0, 70, 70);
    cell.imageView.image = img;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Fixed cell height
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cells are not editable
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *urlString = [_siteAddresses objectAtIndex:indexPath.row];
    //NSURL *url = [NSURL URLWithString:urlString];
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //self.detailViewController.webView.scalesPageToFit = YES;
    
    //[self.detailViewController.webView loadRequest:request];
    
    //_objects = [_objects objectAtIndex:indexPath.row];
    //[self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    NSDictionary *tmpDict = [_objects objectAtIndex:indexPath.row];
    
    NSMutableString *text;
    
    text = [NSMutableString stringWithFormat:@"%@",
            [tmpDict objectForKeyedSubscript:title]];
    
    NSMutableString *detail;
    detail = [NSMutableString stringWithFormat:@"%@",
              [tmpDict objectForKey:bericht]];
    
    //NSMutableString *images;
    //images = [NSMutableString stringWithFormat:@"%@",
    //          [tmpDict objectForKey:photo]];
    
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        // Set Detailview: send data to detailview
        [[segue destinationViewController] setDetailItem:detail];
        [[segue destinationViewController] setDetailTitleText:text];
        [[segue destinationViewController] setDetailImageSource:[tmpDict objectForKey:photo]];
        
    } else if ([[segue identifier] isEqualToString:@"showSettings"]) {
        
        [[segue destinationViewController] setTitle:@"Instellingen"];
        
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)mtitle :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mtitle
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}


@end
