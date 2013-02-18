//
//  PreyChatViewController.h
//  CityGame
//
//  Created by Sven Timmermans on 7/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreyChatViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *txtChatInput;
@property (strong, nonatomic) IBOutlet UITextView *txtChatbox;
- (IBAction)chatInputEnd:(id)sender;

- (IBAction)btnHunter:(UIBarButtonItem *)sender;
- (IBAction)btnLeader:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnHunter;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnLeader;

@end