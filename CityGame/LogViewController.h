//
//  LogViewController.h
//  cgChatApp
//
//  Created by Wim on 3/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *txtLog;

+(void)logMethodDuration: (NSTimeInterval) methodDuration : (NSString *) methodName;

@end
