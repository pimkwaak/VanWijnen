//
//  _TSL5JHV9LAppDelegate.m
//  VanWijnen
//
//  Created by Pim van der Kwaak on 09-06-14.
//  Copyright (c) 2014 Pim van der Kwaak. All rights reserved.
//

#import "_TSL5JHV9LAppDelegate.h"
#import "LoginViewController.h"
#import "_TSL5JHV9LMasterViewController.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

@implementation _TSL5JHV9LAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Show login view if not logged in already
    //if(LogIn == 0) {
    //    [self showLoginScreen:NO];
    //}
    
    //[self login];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
        
    } else {
        // <iOS 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

    return YES;}



- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *regid = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    regid = [regid stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil];
    //[keychainWrapper setObject:regid forKey:(__bridge id)(kSecAttrDescription)];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:regid] forKey:@"regid"];
	//NSLog(@"My reg_id is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo  {
    
    if (userInfo) {
        
        if ([userInfo objectForKey:@"aps"]) {
            if([[userInfo objectForKey:@"aps"] objectForKey:@"badgecount"]) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
            }
        }
    }
}

-(void) showLoginScreen:(BOOL)animated
{
    
    // Get login screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *viewController = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:viewController
                                                 animated:animated
                                               completion:nil];
}

-(void) login
{
    NSString *token;
    NSString *userName;
    
    @try {
        
        
        // Load keychain and save token and device id in the keychain
        KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil];
        userName = [keychainWrapper objectForKey:(__bridge id)kSecAttrAccount];
        token = [keychainWrapper objectForKey:(__bridge id)kSecValueData];
        NSLog(@"Username is: %@", userName);
        NSLog(@"token is: %@", token);
        
        // Connect to server with token and device id. If token is valid do not show log-in screen, otherwise do
        NSURL *url=[NSURL URLWithString:@"http://vanwijnen.thegreatnew.nl/api/v1/login/show"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:token forHTTPHeaderField:@"App-Auth-Token"];
        [request setValue:userName forHTTPHeaderField:@"App-Device-Id"];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // Load JSON objects
        NSData *jsonSource = urlData;
        
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:
                          jsonSource options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"auth is: %@", [jsonObjects valueForKey:@"is_authenticated"]);
        
        if ([[jsonObjects valueForKey:@"is_authenticated"]boolValue])
        {
            // Use this code when the token and username is correct
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:1 forKey:@"LogIn"];
            [defaults synchronize];
            //[self showLoginScreen:YES];
            
        } else {

            // Use this code when the token and username is incorrect
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:0 forKey:@"LogIn"];
            [defaults synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self showLoginScreen:NO];});
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Het verbinden met de server is mislukt" :@"Verbinding mislukt" :0];
    }

    
}

-(void) logout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"LogIn"];
    [defaults synchronize];
    
    // Show login screen
    [self showLoginScreen:NO];
    
    
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredForeground"
                                                        object:nil];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    //[[UIApplication sharedApplication] cancelLocalNotification:yournotification];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
