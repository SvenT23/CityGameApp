//
//  TabController.m
//  CityGame
//
//  Created by Sven Timmermans on 12/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import "TabController.h"
#import "AppDelegate.h"

@interface TabController ()

@end

@implementation TabController

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

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.viewControllers];
    NSLog(@"tabs: %@", newArray);
    
    //zorgt ervoor dat de juiste tabs getoond worden naargelang welke rol de gebruiker heeft
    if([appDelegate.role isEqualToString:@"Prooi"]){
        [newArray removeObjectAtIndex:2];
        [newArray removeObjectAtIndex:2];
    }else{
        [newArray removeObjectAtIndex:1];
        [newArray removeObjectAtIndex:3];
    }
    
    [self setViewControllers:newArray animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
