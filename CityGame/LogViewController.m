//
//  LogViewController.m
//  cgChatApp
//
//  Created by Wim on 3/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()

@end

@implementation LogViewController

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

}

- (void) viewDidAppear:(BOOL)animated
{
    _txtLog.text = [NSString stringWithFormat:@"%@",test];    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

NSString * test = @"";

+(void)logMethodDuration: (NSTimeInterval) methodDuration : (NSString *) methodName{
    
    test = [test stringByAppendingString:[NSString stringWithFormat:@"%@: %f \n",methodName,methodDuration]];
    
}

- (void)viewDidUnload {
    [self setTxtLog:nil];
    [super viewDidUnload];
}
@end
