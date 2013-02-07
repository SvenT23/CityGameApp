//
//  ChatViewController.m
//  CityGame
//
//  Created by Wim on 19/01/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "LogViewController.h"
#import "ChatViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ChatViewController ()
@end

@implementation ChatViewController

//variabelen declareren
NSNumber *lastMessageID;
NSString *cbPreyHunter;
NSString *cbHunterHunter;
NSString *cbHunterLeader;
NSString *selectedChatBox;
NSString *baseURL;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //basisURL
    baseURL = @"http://webservice.citygamephl.be/CityGameWS/resources/generic/";
    lastMessageID = [[NSNumber alloc] initWithInt:0];
    
    //chat berichten opvragen
    [self getMessages];
    //timer voor het opvragen van de chatberichten
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getMessages) userInfo:nil repeats: YES];
    //velden leegmaken voor concat
    cbHunterHunter = @"";
    cbHunterLeader = @"";
    cbPreyHunter = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.txtChatbox scrollRangeToVisible:NSMakeRange([self.txtChatbox.text length], 0)];
}

-(void)getMessages{
    
    @try {
        NSDate *methodStart = [NSDate date];
        
        //om te testen gewoon rechtstreeks parameters maken
        NSString * gameID = @"1";
        NSString * role = @"Jager";
        NSLog(@"de waarde is: %@",lastMessageID);
        //parameters toevoegen aan de url
        NSString *strURL = [baseURL stringByAppendingString:[NSString stringWithFormat:@"getMessages/%@/%@/%@",gameID,role,lastMessageID]];
        
        NSLog(@"%@",strURL);
        NSURL * webserviceURL = [NSURL URLWithString:strURL];
        
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            webserviceURL];
            NSDate *methodEnd = [NSDate date];
            NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"Chatberichten opvragen"];
            [self performSelectorOnMainThread:@selector(fetchedMessages:)
                                   withObject:data waitUntilDone:YES];
            methodEnd = [NSDate date];
            executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"Totaal"];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        [LogViewController logMethodDuration:9 :exception.description];
        
    }
    @finally {
    }
}

-(void)fetchedMessages:(NSData *)responseData{
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:responseData //1
                     
                     options:kNilOptions
                     error:&error];
    
    for (NSDictionary *user in json) {
        // Gets the values of the different hunters
        NSNumber* messageID = [user objectForKey:@"message_ID"];
        NSString* message =  [user objectForKey:@"message"];
        NSString* player =  [user objectForKey:@"player"];
        NSString* chatbox =  [user objectForKey:@"chatbox"];
        NSLog(@"%@: %@", player, message);
        //zorgen dat het nr van de laatst opgehaalde boodschap opgeslagen wordt
        lastMessageID = messageID;
        if([chatbox isEqualToString:@"Jager-Jager"])
        {
            cbHunterHunter =  [cbHunterHunter stringByAppendingString:[NSString stringWithFormat: @"%@: %@\n", player, message]];
        }else if ([chatbox isEqualToString:@"Prooi-Jager"]){
            cbPreyHunter =  [cbPreyHunter stringByAppendingString:[NSString stringWithFormat: @"%@: %@\n", player, message]];
            
        }else{
            cbHunterLeader =  [cbHunterLeader stringByAppendingString:[NSString stringWithFormat: @"%@: %@\n", player, message]];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chatInputEnd:(id)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDate *methodStart = [NSDate date];
    
    [sender resignFirstResponder];
    // creates the variables for posting since we don't have a login attached
    NSNumber *game = appDelegate.gameID;
    NSNumber *player = appDelegate.playerID;
    NSString *message = self.txtChatInput.text;
    NSString *chatbox = @"Prooi-Jager";
    
    // creates the request for the post method
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/sendMessage"]];
    [request setPostValue:game forKey:@"gameID"];
    [request setPostValue:player forKey:@"playerID"];
    [request setPostValue:message forKey:@"message"];
    [request setPostValue:chatbox forKey:@"chatbox"];
    
    //executes
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"%@", response);
    } else {
        NSLog(@"error: %@", error);
        [LogViewController logMethodDuration:9 :error.description];
    }
    // logging the time it took to send the message
    NSDate *methodEnd = [NSDate date];
    NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodStart];
    [LogViewController logMethodDuration:executionTime :@"Chatbericht doorsturen"];
    
    
    //self.txtChatbox.text= [self.txtChatInput.text stringByAppendingString:self.txtChatbox.text];
    self.txtChatInput.text = @"";
}

- (IBAction)btnHunter:(UIBarButtonItem *)sender {
    selectedChatBox = cbHunterHunter;
    self.txtChatbox.text = selectedChatBox;
    [self getMessages];
}

- (IBAction)btnPrey:(UIBarButtonItem *)sender {
    selectedChatBox = cbPreyHunter;
    self.txtChatbox.text = selectedChatBox;
    
}

- (IBAction)btnLeader:(UIBarButtonItem *)sender {
    selectedChatBox = cbHunterLeader;
    self.txtChatbox.text = selectedChatBox;
}
@end
