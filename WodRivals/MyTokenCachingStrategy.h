//
//  MyTokenCachingStrategy.h
//  WodRivals
//
//  Created by Chester O'Neill on 7/20/14.
//  Copyright (c) 2014 ThrowsException. All rights reserved.
//

#import <FacebookSDK/FBSessionTokenCachingStrategy.h>

@interface MyTokenCachingStrategy : FBSessionTokenCachingStrategy

// In a real app this uniquely identifies the user and is something
// the app knows before an FBSession open is attempted.
@property (nonatomic, strong) NSString *thirdPartySessionId;


@end
