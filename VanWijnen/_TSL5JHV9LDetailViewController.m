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
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
