//
//  CheckInternetConnection.h
//  MapkitAppCitygame
//
//  Created by Wim on 30/01/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//


//klasse voor het controleren op internetverbinding
//Bron: http://dipinkrishna.com/blog/2012/04/ios-check-internet-connection/

#import <Foundation/Foundation.h>

@interface CheckInternetConnection : NSObject
- (BOOL) isConnectionAvailable;
@end
