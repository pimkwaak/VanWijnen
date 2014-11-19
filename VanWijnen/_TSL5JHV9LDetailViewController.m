//
//  _TSL5JHV9LDetailViewController.m
//  VanWijnen
//
//  Created by Pim van der Kwaak on 09-06-14.
//  Copyright (c) 2014 Pim van der Kwaak. All rights reserved.
//

#import "_TSL5JHV9LDetailViewController.h"

@interface _TSL5JHV9LDetailViewController ()
- (void)configureView;
@end

@implementation _TSL5JHV9LDetailViewController

@synthesize detailTitle, detailImage,detailMessage, scrollView, detaillView;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        //self.detailTitle.text = [self.detailItem title];
        self.detailMessage.text = [self.detailItem description];
        
        //[detailMessage setFrame:CGRectMake(0.0, 0.0, 274.0, 900.0)];
        //[self.scrollView addSubview:detailMessage];
        
    }
}

-(void)resizeTextView
{
    CGRect  frame = detailMessage.frame;
    frame.size.height = [detailMessage sizeThatFits:CGSizeMake(frame.size.width, INFINITY)].height;
    detailMessage.frame = frame;
    
    [scrollView setContentSize: CGSizeMake(self.view.frame.size.width,[detailMessage sizeThatFits:CGSizeMake(frame.size.width, INFINITY)].height+250)];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDetectedLeft:)];
    //swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    //[self.view addGestureRecognizer:swipeRecognizerLeft];
    
    //UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDetectedRight:)];
    //swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    //[self.view addGestureRecognizer:swipeRecognizerRight];
    
    [self resizeTextView];
    [self configureView];
    detailTitle.text = self.detailTitleText;
    //detailImage.image = self.detailImageSource;

    NSURL *url = [NSURL URLWithString:self.detailImageSource];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc]initWithData:data];
    detailImage.image = img;
    detailImage.contentMode = UIViewContentModeScaleAspectFit;
    [self resizeTextView];
}

//- (void)swipeDetectedRight:(UIGestureRecognizer *)sender {
    
//    NSLog(@"Right Swipe");
    
//}

//- (void)swipeDetectedLeft:(UIGestureRecognizer *)sender {
    
//    NSLog(@"Left Swipe");
    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
