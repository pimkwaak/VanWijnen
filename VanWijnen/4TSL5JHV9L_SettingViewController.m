//
//  4TSL5JHV9L_SettingViewController.m
//  VanWijnen
//
//  Created by Pim van der Kwaak on 18-06-14.
//  Copyright (c) 2014 Pim van der Kwaak. All rights reserved.
//

#import "4TSL5JHV9L_SettingViewController.h"
#import "_TSL5JHV9LAppDelegate.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

@interface _TSL5JHV9L_SettingViewController (){

NSMutableArray *_objects;

// A dictionary object
    NSDictionary *dictionary;

// Define keys
    NSString *vestiging;
    NSString *actief;

// Define main reusable strings
    NSString *token;
    NSString *userName;
}
@end

@implementation _TSL5JHV9L_SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshAll];
}

-(IBAction)LogOut:(id)sender
{
    _TSL5JHV9LAppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil];
    [keychainWrapper resetKeychainItem];
    
    [appDelegate logout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)refreshAll
{
    //[self.refreshControl beginRefreshing];
    
    @try {
                // Load data from the keychain
                KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil]    ;
                
                userName = [keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
                token = [keychainWrapper objectForKey:(__bridge id)(kSecValueData)];
                NSLog(@"Username is: %@", userName);
                NSLog(@"token is: %@", token);
                
                // Link to secure data
                NSURL *url=[NSURL URLWithString:@"http://vanwijnen.thegreatnew.nl/api/v1/locations/"];
                
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
        
                //id jsonHits = [[jsonObjects objectForKey:@"id"] objectForKey:@"id"];
        
                //NSLog(@"id: %@", jsonObjects);
                
                for (NSDictionary *dataDict in jsonObjects) {
                    //NSLog(@"token is: %@", [[jsonObjects valueForKey:@"1"]objectForKey:@"name"]);
                    NSString *idNumber = dataDict.description;
                    NSString *vestiging1 = [[jsonObjects valueForKey:dataDict.description] objectForKey:@"name"];
                    NSString *activated = [[jsonObjects objectForKey:dataDict.description] objectForKey:@"active"];
                    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                  idNumber, @"id",
                                  vestiging1, @"Vestiging",
                                  activated, @"Active",
                                  nil];
                    [_objects addObject:dictionary];
                    [self.Vestigingen reloadData];
                    NSLog(@"dictionary: %@", dictionary);
                    
                }
        
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Het ophalen van de vestigingen is mislukt" :@"Verbinding mislukt" :0];
    }
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
    
    text = [NSMutableString stringWithFormat:@"%@",[tmpDict objectForKey:@"Vestiging"]];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = text;
    [cell.textLabel sizeToFit];
    
    if ([[tmpDict objectForKey:@"Active"]boolValue]==TRUE) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Fixed cell height
    return 50;
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

    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil]    ;
    
    userName = [keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    token = [keychainWrapper objectForKey:(__bridge id)(kSecValueData)];
    
    //NSLog(@"Response code: %ld", (long)[response statusCode]);
    NSDictionary *tmpDict = [_objects objectAtIndex:indexPath.row];
    
    if ([[tmpDict objectForKey:@"Active"]boolValue]==TRUE) {
        
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                      [tmpDict objectForKey:@"id"], @"id",
                      [tmpDict objectForKey:@"Vestiging"], @"Vestiging",
                      @"0", @"Active",
                      nil];
        [_objects replaceObjectAtIndex:indexPath.row withObject:dictionary];
        
        NSLog(@"dictionary true row: %@", _objects);
        
        [self.Vestigingen cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        
        [self PostValues];
        
    }else{
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                      [tmpDict objectForKey:@"id"], @"id",
                      [tmpDict objectForKey:@"Vestiging"], @"Vestiging",
                      @"1", @"Active",
                      nil];
        [_objects replaceObjectAtIndex:indexPath.row withObject:dictionary];
        
        NSLog(@"dictionary false2: %@", _objects);
        
        [self.Vestigingen cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
        [self PostValues];
    }
    //NSString *urlString = [_siteAddresses objectAtIndex:indexPath.row];
    //NSURL *url = [NSURL URLWithString:urlString];
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //self.detailViewController.webView.scalesPageToFit = YES;
    
    //[self.detailViewController.webView loadRequest:request];
    
    //_objects = [_objects objectAtIndex:indexPath.row];
    //[self performSegueWithIdentifier:@"showDetail" sender:self];
}
-(void) PostValues{
    
    //NSDictionary *tmpDict = _objects;
    
    NSString *postString = @"";
    NSString *tmp;
    
    for (int x=0; x < [_objects count]; x++){
        
        NSDictionary *tmpDict = [_objects objectAtIndex:x];
        
        //NSLog(@"loop: %@", [tmpDict objectForKey:@"Active"]);
        
        if ([[tmpDict objectForKey:@"Active"]boolValue]==TRUE) {
            
            tmp = [NSString stringWithFormat:@"%@%@%@", @"locations=", [tmpDict objectForKey:@"id"], @"&"];
            postString = [postString stringByAppendingString:tmp];
        
            NSLog(@"loop: %@", postString);
        }
    }
    
    //NSString *post =[[NSString alloc] initWithFormat:postString];
    NSLog(@"PostData: %@",postString);
    
    NSURL *url=[NSURL URLWithString:@"http://vanwijnen.thegreatnew.nl/api/v1/locations/"];
    
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:token forHTTPHeaderField:@"App-Auth-Token"];
    [request setValue:userName forHTTPHeaderField:@"App-Device-Id"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *response = nil;
    //NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
