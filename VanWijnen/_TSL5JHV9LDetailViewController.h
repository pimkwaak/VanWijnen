//
//  _TSL5JHV9LDetailViewController.h
//  VanWijnen
//
//  Created by Pim van der Kwaak on 09-06-14.
//  Copyright (c) 2014 Pim van der Kwaak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _TSL5JHV9LDetailViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) NSString *detailTitleText;
@property (weak, nonatomic) NSString *detailMessageText;
@property (weak, nonatomic) NSString *detailImageSource;

@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UITextView *detailMessage;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UIView *detaillView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end
