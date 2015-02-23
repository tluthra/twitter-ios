//
//  TweetCell.m
//  Twitter
//
//  Created by Tanooj Luthra on 2/22/15.
//  Copyright (c) 2015 Tanooj Luthra. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "NSDate+TimeAgo.h"

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
}

- (void) setTweet: (Tweet *) tweet {
   
    User *author = tweet.author;
    
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
    self.createdAtLabel.text = [tweet.createdAt timeAgo];
    self.tweetLabel.text = tweet.text;
    [self.tweetLabel sizeToFit];
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
