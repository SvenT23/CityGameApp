//
//  LoginScreen.m
//  CityGame
//
//  Created by Wim on 17/12/12.
//  Copyright (c) 2012 Wim. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "LoginScreen.h"
#import "LogViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"

@interface LoginScreen ()
@end

@implementation LoginScreen
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLogin:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSDate *methodStart = [NSDate date];
    
    NSString *user = _txtUser.text;
    NSString *password = [self sha1:_txtPassword.text];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/loginPost"]];
    [request setPostValue:user forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSData *webData = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary* json = [NSJSONSerialization
                         JSONObjectWithData:webData //1
                         
                         options:kNilOptions
                         error:&error];
        
        //Houdt de waarden bij in globale waarden
        
        appDelegate.gameID = [json objectForKey:@"gameID"];     //..to write
        NSLog(@"gameID: %@",appDelegate.gameID);
        appDelegate.intervalHunter = [json objectForKey:@"intervalHunter"];
        NSLog(@"interval jager: %@",appDelegate.intervalHunter);
        appDelegate.intervalPrey = [json objectForKey:@"intervalPrey"];
        NSLog(@"interval prooi: %@",appDelegate.intervalPrey);
        appDelegate.playerID = [json objectForKey:@"playerID"];
        NSLog(@"playerID: %@",appDelegate.playerID);
        appDelegate.role = [json objectForKey:@"role"];
        NSLog(@"role: %@",appDelegate.role);
    } else {
        [LogViewController logMethodDuration:9 :error.description];
        NSLog(@"error: %@", error);
    }
    
    // timen hoe lang het duurde om de inlogdata te versturen naar de server
    NSDate *methodEnd = [NSDate date];
    NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodStart];
    [LogViewController logMethodDuration:executionTime :@"login"];
    
    if(appDelegate.playerID!=NULL){
        [self performSegueWithIdentifier: @"segueGo" sender: self];
    }else {
        _txtUser.text = @"";
        _txtPassword.text = @"";
    }
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

- (IBAction)textFieldDoneEditing:(id)sender;{
    [sender resignFirstResponder];
}

//Code om ervoor te zorgen dat keyboard de tekstvelden niet bedekt


- (void)viewDidUnload {
    [self setTxtUser:nil];
    [self setTxtPassword:nil];
    [self setTxtPassword:nil];
    [self setTxtPassword:nil];
    [super viewDidUnload];
}
@end
