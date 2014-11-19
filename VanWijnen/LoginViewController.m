//
//  LoginViewController.m
//  VanWijnen
//
//  Created by Pim van der Kwaak on 18-06-14.
//  Copyright (c) 2014 Pim van der Kwaak. All rights reserved.
//

#import "LoginViewController.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

NSString *token;
NSString *userName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)LogIn:(id)sender
{
    
    NSString *success = @"";
    NSString *regid;
    
    userName = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSData *_data = [[NSUserDefaults standardUserDefaults] objectForKey:@"regid"];
    regid = [NSKeyedUnarchiver unarchiveObjectWithData:_data];
    //regid = [dict objectForKey:@"regid"];
    
    @try {
        
        if([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""] ) {
            
            [self alertStatus:@"Geef aub een e-mailadres en wachtwoord op" :@"Inloggen mislukt" :0];
            
        } else {
            //NSLog(@"My reg_id is: %@", );
            
            NSString *post =[[NSString alloc] initWithFormat:@"device_id=%@&username=%@&password=%@&platform=%s&registration_id=%@",userName,[self.txtUsername text],[self.txtPassword text],"ios", regid];
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString:@"http://vanwijnen.thegreatnew.nl/api/v1/login/"];
            
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            
            if ([response statusCode] >= 200 && [response statusCode] < 300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                NSError *error = nil;
                NSDictionary *jsonData = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];
                
                
                success = [jsonData objectForKey:@"status"];
                userName = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                token = [jsonData objectForKey:@"token"];
                NSLog(@"token: %@",token);
                
                KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil];
                [keychainWrapper setObject:@"VanWijnen" forKey:(__bridge id)kSecAttrService];
                [keychainWrapper setObject:userName forKey:(__bridge id)kSecAttrAccount];
                [keychainWrapper setObject:token forKey:(__bridge id)kSecValueData];
                
        
                if([success isEqual: @"ok"])
                {
                    NSLog(@"Login SUCCESS");
                } else {
                    
                    NSString *error_msg = (NSString *) jsonData[@"error_message"];
                    [self alertStatus:error_msg :@"Inloggen mislukt!" :0];
                }
                
            } else {
                //if (error) NSLog(@"Error: %@", error);
                [self alertStatus:@"Verbinding probleem" :@"Inloggen mislukt!" :0];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Verbinding mislukt" :@"Fout!" :0];
    }
    if ([success isEqual: @"ok"]) {
        //[self performSegueWithIdentifier:@"login_success" sender:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:1 forKey:@"LogIn"];
        [defaults synchronize];
        [self loginWasSuccessful];
    }
    
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}


-(void) loginWasSuccessful
{
    
    // Send notification
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessful" object:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredForeground"
                                                        object:nil];
    // Dismiss login screen
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
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
