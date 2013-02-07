//
//  TaskViewController.m
//  CityGame
//
//  Created by Sven Timmermans on 6/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //defines the background queue

#import "NSDataAdditions.h"
#import "LogViewController.h"
#import "AppDelegate.h"
#import "TaskViewController.h"

@interface TaskViewController ()

@end

@implementation TaskViewController

NSMutableArray *taskArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    taskArray = [[NSMutableArray alloc] init];
    [NSTimer scheduledTimerWithTimeInterval:20 target:self
                                                       selector:@selector(tick) userInfo:nil repeats:YES];
}

-(void)tick{
    
    // makes the background queue and calls the fetched data function for the tasks
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:[NSString stringWithFormat:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/getLatestTask/%@/%@",appDelegate.gameID,appDelegate.role]]];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
    NSDate *methodStart = [NSDate date];
    
    //haalt de afbeelding van de opdracht op
    if (![appDelegate.role isEqual:@"Prooi"]){
        // makes the background queue and calls the fetched data function
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/getPhoto"]];
            // logs how long it took to get the data
            NSDate *methodEnd = [NSDate date];
            NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"data v foto ophalen"];
        
            [self performSelectorOnMainThread:@selector(fotoData:) withObject:data waitUntilDone:YES];
        
            // logs the total time it took, including converting and displaying the image
            methodEnd = [NSDate date];
            executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"Totaal foto ophalen"];
        
        });
    }
}

- (void)fetchedData:(NSData *)responseData {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    // Gets the values of the prey (there should only be one, so the for loop shouldn't be necessary
    
    NSString* location = [json objectForKey:@"location"];
    NSString* description = [json objectForKey:@"description"];
    NSNumber* longitude = [json objectForKey:@"longitude"];
    NSNumber* latitude = [json objectForKey:@"latitude"];
    // logs the data
    NSString *tempString;
    tempString = [NSString stringWithFormat: @"Task: %@ at %@: longitude: %@ and latitude: %@", description, location, longitude, latitude];
    //NSLog(@"Task: %@ at %@: longitude: %@ and latitude: %@", description, location, longitude, latitude);
    
    if ([appDelegate.lastTask isEqualToString: tempString]){
    }else {
        [taskArray addObject: tempString];
        appDelegate.lastTask = tempString;
        _lblTask.text = [NSString stringWithFormat:@"%@", tempString];
        
    }
    
    NSLog(@"array: %@", taskArray);
}

- (void)fotoData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:responseData //1
                     
                     options:kNilOptions
                     error:&error];
    
    for (NSDictionary *user in json) {
        // Gets the values of the different hunters
        NSString* description = [user objectForKey:@"description"];
        NSLog(@"%@",description);
        NSString* photo = [user objectForKey:@"photo"];
        [self imageFromString :photo];
    }
}

-(void)imageFromString:(NSString *)base64Image{
    //base64 string converteren naar afbeelding
    NSData *data;
    data = [NSData dataWithBase64EncodedString:base64Image];
    _imageView.image = [UIImage imageWithData:data];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLblTask:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
