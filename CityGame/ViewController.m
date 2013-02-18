//
//  ViewController.m
//  CityGame
//
//  Created by Sven Timmermans on 7/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

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
    
    /*NSLog(@"%@", @"fuck you, tab bar");
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate.role isEqualToString:@"Hunter"])
    {
        NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
        [newArray removeObject:self];
        
        [self.tabBarController setViewControllers:newArray animated:YES];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
