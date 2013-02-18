//
//  PreyChatViewController.m
//  CityGame
//
//  Created by Sven Timmermans on 7/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "LogViewController.h"
#import "PreyChatViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface PreyChatViewController ()

@end

@implementation PreyChatViewController

//variabelen declareren
NSNumber *lastMessageID;
NSString *cbPreyHunter;
NSString *cbPreyLeader;
NSString *selectedChatBox;
NSString *baseURL;


- (void)viewDidLoad
{
    [super viewDidLoad];

    //basisURL
    baseURL = @"http://webservice.citygamephl.be/CityGameWS/resources/generic/";
    lastMessageID = [[NSNumber alloc] initWithInt:0];
    
    //chat berichten opvragen
    [self getMessages];
    
    //timer voor het opvragen van de chatberichten
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getMessages) userInfo:nil repeats: YES];
    
    //velden leegmaken voor concat
    cbPreyHunter = @"";
    cbPreyLeader = @"";
    
    [self performSelector: @selector(btnHunter:) withObject:self afterDelay: 3.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.txtChatbox scrollRangeToVisible:NSMakeRange([self.txtChatbox.text length], 0)];
}

-(void)getMessages{
    
    @try {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSDate *methodStart = [NSDate date];
        
        //parameters toevoegen aan de url
        NSString *strURL = [baseURL stringByAppendingString:[NSString stringWithFormat:@"getMessages/%@/%@/%@",appDelegate.gameID,appDelegate.role,lastMessageID]];

        NSURL * webserviceURL = [NSURL URLWithString:strURL];
        
        //background queue aanmaken om data op te halen en te tonen
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            webserviceURL];
            
            //logged hoe lang het duurde om de data op te halen
            NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"Chatberichten opvragen"];
            
            [self performSelectorOnMainThread:@selector(fetchedMessages:)
                                   withObject:data waitUntilDone:YES];
            
            //logged hoe lang het in totaal duurde
            executionTime = [[NSDate date] timeIntervalSinceDate:methodStart];
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
        // haalt de specifieke waarden uit de json
        NSNumber* messageID = [user objectForKey:@"message_ID"];
        NSString* message =  [user objectForKey:@"message"];
        NSString* player =  [user objectForKey:@"player"];
        NSString* chatbox =  [user objectForKey:@"chatbox"];
        
        //zorgen dat het nr van de laatst opgehaalde boodschap opgeslagen wordt
        lastMessageID = messageID;
        
        // berichten aan de juiste chatbox toevoegen
        if ([chatbox isEqualToString:@"Prooi-Jager"]){
            cbPreyHunter =  [cbPreyHunter stringByAppendingString:[NSString stringWithFormat: @"%@: %@\n", player, message]];
            
        }else{
            cbPreyLeader =  [cbPreyLeader stringByAppendingString:[NSString stringWithFormat: @"%@: %@\n", player, message]];
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
    // juiste variabelen ophalen
    NSNumber *game = appDelegate.gameID;
    NSNumber *player = appDelegate.playerID;
    NSString *message = self.txtChatInput.text;
    
    // request aanmaken en juiste gegevens toevoegen
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/sendMessage"]];
    [request setPostValue:game forKey:@"gameID"];
    [request setPostValue:player forKey:@"playerID"];
    [request setPostValue:message forKey:@"message"];
    [request setPostValue:selectedChatBox forKey:@"chatbox"];
    
    //uitvoeren en zonodig error tonen
    [request startSynchronous];
    NSError *error = [request error];
    if (error) {
        NSLog(@"error: %@", error);
        [LogViewController logMethodDuration:9 :error.description];
    }
    // loggen hoe lang het duurde om het bericht te versturen
    NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:methodStart];
    [LogViewController logMethodDuration:executionTime :@"Chatbericht doorsturen"];
    
    self.txtChatInput.text = @"";
}

- (IBAction)btnHunter:(UIBarButtonItem *)sender {
    selectedChatBox = @"Prooi-Jager";
    self.txtChatbox.text = cbPreyHunter;
    
    self.btnHunter.style = UIBarButtonItemStyleDone;
    self.btnLeader.style = UIBarButtonItemStyleBordered;
}

- (IBAction)btnLeader:(UIBarButtonItem *)sender {
    selectedChatBox = @"Prooi-Spelleider";
    self.txtChatbox.text = cbPreyLeader;
    self.btnHunter.style = UIBarButtonItemStyleBordered;
    self.btnLeader.style = UIBarButtonItemStyleDone;
}

- (void)viewDidUnload {
    [self setBtnHunter:nil];
    [self setBtnLeader:nil];
    [super viewDidUnload];
}
@end
