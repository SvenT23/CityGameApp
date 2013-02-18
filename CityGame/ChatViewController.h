//
//  ChatViewController.h
//  CityGame
//
//  Created by Wim on 19/01/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *txtChatInput;
@property (strong, nonatomic) IBOutlet UITextView *txtChatbox;


- (IBAction)chatInputEnd:(id)sender;


- (IBAction)btnHunter:(UIBarButtonItem *)sender;
- (IBAction)btnPrey:(UIBarButtonItem *)sender;
- (IBAction)btnLeader:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnHunter;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnPrey;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnLeader;


@end
