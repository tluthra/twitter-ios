//
//  TweetsViewController.m
//  twitter
//
//  Created by Tanooj Luthra on 2/22/15.
//  Copyright (c) 2015 Tanooj Luthra. All rights reserved.
//

#import "TweetsViewController.h"
#import "TweetViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "ComposeViewController.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL reloading;

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *globalTint = [[[UIApplication sharedApplication] delegate] window].tintColor;

    self.title = @"Home";
    
    UIBarButtonItem *leftBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    UIBarButtonItem *rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onCompose)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tweets = [[NSMutableArray alloc] init];
    
    UINib *tweetCellNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetCell"];

    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 125.0; // set to whatever your "average" cell height is
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:globalTint];
    [self.tableView addSubview:self.refreshControl];

    self.reloading = NO;

    
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reload {
    [self reloadWithOffset:[NSNumber numberWithInt:0]];
}

- (void)reloadWithOffset:(NSNumber *)offset {
    self.reloading = YES;
    // Do any additional setup after loading the view from its nib.
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"count"] = offset;
    [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        self.tweets = [NSMutableArray arrayWithArray:tweets];
        [self.refreshControl endRefreshing];
        
        [self.tableView reloadData];
        self.reloading = NO;

    }];
}


- (void)onLogout {
    [User logout];
}

- (void)onCompose {
    [self.navigationController pushViewController:[[ComposeViewController alloc] init] animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    [cell setTweet:self.tweets[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Tweet *tweet = self.tweets[indexPath.row];
    
    TweetViewController *tvc = [[TweetViewController alloc] init];
    tvc.tweet = tweet;
    [self.navigationController pushViewController:tvc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - (self.tableView.frame.size.height - 5);
    if ((actualPosition >= contentHeight) && !self.reloading) {
        NSLog(@"reload more data");
        [self reloadWithOffset:[NSNumber numberWithLong:(self.tweets.count + 20)]];
    }
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
