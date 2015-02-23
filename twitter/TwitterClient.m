//
//  TwitterClient.m
//  twitter
//
//  Created by Tanooj Luthra on 2/22/15.
//  Copyright (c) 2015 Tanooj Luthra. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString * const kTwitterConsumerKey = @"QvXxZpymK06BFcA4JsZ0hTPwA";
NSString * const kTwitterConsumerSecret = @"DmSXbsz5xDRjmol4dVhcJoG46kWj4sFiv1cxY3sfR0rSo5DMOd";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()
@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"got token");
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        
        [[UIApplication sharedApplication] openURL:authURL];
        
    } failure:^(NSError *error) {
        NSLog(@"error %@", error);
        self.loginCompletion(nil, error);
    }];
}

- (void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"got the access token");
        [self.requestSerializer saveAccessToken:accessToken];

        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"current suer: %@", responseObject);
            
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            
            NSLog(@"username: %@", user.screenname);
            
            self.loginCompletion(user, nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error on curr user");
            self.loginCompletion(nil, error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"error %@", error);
        self.loginCompletion(nil, error);

    }];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", error);

        completion(nil, error);
        
    }];
}

- (void) favoriteTweet: (Tweet *)tweet {
    NSString *url = [NSString stringWithFormat: @"1.1/favorites/create.json?id=%@", tweet.tweetId];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject: tweet.tweetId forKey: @"id"];
    
    [[TwitterClient sharedInstance] POST: url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", error);

    }];
}

- (void) unfavoriteTweet: (Tweet *)tweet {
    NSString *url = [NSString stringWithFormat: @"1.1/favorites/destroy.json?id=%@", tweet.tweetId];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject: tweet.tweetId forKey: @"id"];
    
    [[TwitterClient sharedInstance] POST: url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", error);
        
    }];
}


- (void) retweetTweet: (Tweet *)tweet {
    NSString *url = [NSString stringWithFormat: @"1.1/statuses/retweet/%@.json", tweet.tweetId];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject: tweet.tweetId forKey: @"id"];
    
    [[TwitterClient sharedInstance] POST: url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", error);

    }];
}

- (void) replyToTweet: (Tweet *)tweet withString: (NSString *) replyText {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject: replyText forKey: @"status"];
    [params setObject: tweet.tweetId forKey: @"in_reply_to_status_id"];
    
    [[TwitterClient sharedInstance] POST: @"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", error);

    }];
}

- (void) tweetWithString: (NSString *) tweetText {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject: tweetText forKey: @"status"];
    [[TwitterClient sharedInstance] POST: @"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", error);

    }];
}


@end
