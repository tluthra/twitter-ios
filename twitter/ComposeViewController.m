//
//  ComposeViewController.m
//  twitter
//
//  Created by Tanooj Luthra on 2/22/15.
//  Copyright (c) 2015 Tanooj Luthra. All rights reserved.
//

#import "ComposeViewController.h"
#import "UIImageVIew+AFNetworking.h"
#import "User.h"
#import "TwitterClient.h"

@interface ComposeViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UITextField *tweetText;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];

    UIBarButtonItem *rightBarLabelItem = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:self action:nil];
    rightBarLabelItem.enabled = NO;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightBarButtonItem, rightBarLabelItem, nil];
    
    User *currentUser = [User currentUser];

    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:currentUser.profileImageUrl]];
    [self.profileImageView setImageWithURLRequest:req placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.profileImageView.alpha = 0.0;
        self.profileImageView.image = image;
        [UIView animateWithDuration:0.25 animations:^{
            self.profileImageView.alpha = 1.0;
        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    self.usernameLabel.text = currentUser.screenname;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tweetText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTweet {
    [[TwitterClient sharedInstance] tweetWithString:self.tweetText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onEditingChanged:(UITextField *)sender {
    NSLog(@"num chars: %lu", (unsigned long)sender.text.length);
    
    UIBarButtonItem *rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    
    UIBarButtonItem *rightBarLabelItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%lu", (140 - sender.text.length)] style:UIBarButtonItemStylePlain target:self action:nil];
    rightBarLabelItem.enabled = NO;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightBarButtonItem, rightBarLabelItem, nil];
    
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
