//
//  TwitterClient.h
//  twitter
//
//  Created by Tanooj Luthra on 2/22/15.
//  Copyright (c) 2015 Tanooj Luthra. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;
- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void) tweetWithString: (NSString *) tweetText;
- (void) replyToTweet: (Tweet *)tweet withString: (NSString *) replyText;
- (void) retweetTweet: (Tweet *)tweet;
- (void) favoriteTweet: (Tweet *)tweet;
- (void) unfavoriteTweet: (Tweet *)tweet;

@end
