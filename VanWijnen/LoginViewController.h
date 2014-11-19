//
//  LoginViewController.h
//  VanWijnen
//
//  Created by Pim van der Kwaak on 18-06-14.
//  Copyright (c) 2014 Pim van der Kwaak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

-(IBAction)LogIn:(id)sender;

@end
