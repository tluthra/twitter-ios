//
//  TweetViewController.m
//  twitter
//
//  Created by Tanooj Luthra on 2/22/15.
//  Copyright (c) 2015 Tanooj Luthra. All rights reserved.
//

#import "TweetViewController.h"
#import "TwitterClient.h"
#import "UIImageView+AFNetworking.h"

@interface TweetViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (strong, nonatomic) IBOutlet UILabel *retweets;
@property (strong, nonatomic) IBOutlet UILabel *favorites;
@property (assign, nonatomic) BOOL favorited;
@property (assign, nonatomic) BOOL retweeted;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    User *author = self.tweet.author;
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:author.profileImageUrl]];
    [self.profileImageView setImageWithURLRequest:req placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.profileImageView.alpha = 0.0;
        self.profileImageView.image = image;
        [UIView animateWithDuration:0.25 animations:^{
            self.profileImageView.alpha = 1.0;
        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", author.screenname];
    self.createdAtLabel.text = [NSDateFormatter localizedStringFromDate:self.tweet.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
    self.tweetLabel.text = self.tweet.text;
    [self.tweetLabel sizeToFit];
    
    self.retweets.text = [NSString stringWithFormat:@"%@", self.tweet.retweets];

    self.favorites.text = [NSString stringWithFormat:@"%@", self.tweet.favorites];
    
    self.favorited = NO;
    self.retweeted = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFavorite:(id)sender {
    UIButton *favorite = (UIButton *)sender;
    
    if (!self.favorited) {
        [[TwitterClient sharedInstance] favoriteTweet:self.tweet];
        
        [favorite setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
        self.tweet.favorites = [NSNumber numberWithInt:[self.tweet.favorites intValue] + 1];
        
        self.favorites.text = [NSString stringWithFormat:@"%@", self.tweet.favorites];
        self.favorited = YES;
        
    } else {
        [[TwitterClient sharedInstance] unfavoriteTweet:self.tweet];
        
        [favorite setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        self.tweet.favorites = [NSNumber numberWithInt:[self.tweet.favorites intValue] - 1];
        
        self.favorites.text = [NSString stringWithFormat:@"%@", self.tweet.favorites];
        
        self.favorited = NO;

        
    }
    
    
}
- (IBAction)onRetweet:(id)sender {
    [[TwitterClient sharedInstance] retweetTweet:self.tweet];
    
    UIButton *retweet = (UIButton *)sender;
    
    if (!self.retweeted) {
        [[TwitterClient sharedInstance] favoriteTweet:self.tweet];
        
        [retweet setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
        self.tweet.retweets = [NSNumber numberWithInt:[self.tweet.retweets intValue] + 1];
        
        self.retweets.text = [NSString stringWithFormat:@"%@", self.tweet.retweets];
        self.retweeted = YES;
        
    } else {
        
        [retweet setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
        self.tweet.retweets = [NSNumber numberWithInt:[self.tweet.retweets intValue] - 1];
        
        self.retweets.text = [NSString stringWithFormat:@"%@", self.tweet.retweets];
        
        self.retweeted = NO;
        
        
    }

}
- (IBAction)onReply:(id)sender {
    [[TwitterClient sharedInstance] replyToTweet:self.tweet withString:@"Reply Text!"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
