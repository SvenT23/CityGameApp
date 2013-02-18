//
//  InfoViewController.m
//  CityGame
//
//  Created by Sven Timmermans on 15/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //defines the background queue

#import "LogViewController.h"
#import "AppDelegate.h"
#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDate *methodStart = [NSDate date];

    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:[NSString stringWithFormat:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/getRoleDescription/%@",appDelegate.role]]];
        // roept functie fetchedData op om de data correct weer te geven
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        
        // logged hoe lang het duurde voor alles (inclusief tonen) duurde
        NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:methodStart];
        [LogViewController logMethodDuration:executionTime :@"Info ophalen"];
            
    });
}

- (void)fetchedData:(NSData *)responseData {
    //De gegevens uit de json halen
    NSError* error;
    NSArray* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    for (NSDictionary *user in json) {
        _txtInfo.text =  [user objectForKey:@"roleDescription"];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTxtInfo:nil];
    [super viewDidUnload];
}
@end
