//
//  AppDelegate.h
//  CityGame
//
//  Created by Wim on 15/12/12.
//  Copyright (c) 2012 Wim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSNumber *gameID;
    NSNumber *intervalHunter;
    NSNumber *intervalPrey;
    NSNumber *playerID;
    NSString *role;
    NSString *lastTask;
}

@property (nonatomic, retain) NSNumber *gameID;
@property (nonatomic, retain) NSNumber *intervalHunter;
@property (nonatomic, retain) NSNumber *intervalPrey;
@property (nonatomic, retain) NSNumber *playerID;
@property (nonatomic, retain) NSString *role;
@property (nonatomic, retain) NSString *lastTask;

@property (strong, nonatomic) UIWindow *window;

@end
