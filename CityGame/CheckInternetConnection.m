//
//  CheckInternetConnection.m
//  MapkitAppCitygame
//
//  Created by Wim on 30/01/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import "CheckInternetConnection.h"
#import "SystemConfiguration/SystemConfiguration.h"

@implementation CheckInternetConnection

- (BOOL) isConnectionAvailable
{
	SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"dipinkrishna.com" UTF8String]);
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!receivedFlags || (flags == 0) )
    {
        return FALSE;
    } else {
		return TRUE;
	}
}
@end
