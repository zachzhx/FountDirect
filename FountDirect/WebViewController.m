//
//  WebViewController.m
//  Spree
//
//  Created by Zhang Xu on 11/8/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "WebViewController.h"
#import "UIColor+CustomColors.h"
#import "Constants.h"
#import "UINavigationBar+DropShadow.h"

@interface WebViewController ()
{
    UILabel *cartLbl;
    UIButton *cartBtn;
    UIProgressView *progressView;
    UIImageView *titleView;
    UIView *loadingView;
}

@end

@implementation WebViewController

@synthesize buyURLStr;
@synthesize sellerName;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //self.tabBarController.tabBar.hidden =YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"BUY URL %@",buyURLStr);
    
    [self setupCustomBarButtonItem];
    [self loadingView];
    NSURL *url = [NSURL URLWithString:buyURLStr];
    //NSLog(@"%@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.scalesPageToFit = YES;
    self.webView.frame = self.view.bounds;
    self.webView.delegate = self;
    self.navigationController.navigationBarHidden=NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [loadingView removeFromSuperview];
    [titleView removeFromSuperview];
}
-(void)loadingView{
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 110)];
    loadingView.center = self.view.center;
    //    loadingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    loadingView.backgroundColor = [UIColor clearColor];
    [loadingView.layer setCornerRadius:5.0f];
    
    UIImage *titleImage = [UIImage imageNamed:@"title"];
    titleView = [[UIImageView alloc]initWithImage:titleImage];
    titleView.center = self.view.center;
    [self.view addSubview:titleView];
    
    UILabel *forwardLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, loadingView.bounds.origin.y+90, loadingView.bounds.size.width, 20)];
    forwardLabel.text = [NSString stringWithFormat:@"Forwarding to %@ website", sellerName];
    forwardLabel.textColor = [UIColor darkGrayColor];
    forwardLabel.font = [UIFont fontWithName:@"Gil Sans" size:6];
    forwardLabel.textAlignment = NSTextAlignmentCenter;
    forwardLabel.backgroundColor = [UIColor clearColor];
    [loadingView addSubview:forwardLabel];
    
    progressView = [[UIProgressView alloc]init];
    progressView.frame = CGRectMake(0, loadingView.bounds.origin.y+85, loadingView.bounds.size.width, 10);
    progressView.backgroundColor = [UIColor clearColor];
    //    progressView.progressTintColor = [UIColor blackColor];
    progressView.trackTintColor = [UIColor grayColor];
    //    progressView.progress = 0.5;
    [progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [loadingView addSubview:progressView];
    
    [self.view addSubview:loadingView];
}


-(void) setupCustomBarButtonItem {
    
    
    UIImage *image = [UIImage imageNamed:@"title"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    [self.navigationController.navigationBar enableDropShadow];
    
   // self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowleft"] style:UIBarButtonItemStyleDone target:self action:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"arrowleft"] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonClicked:)];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:cartBtn];
    self.navigationItem.rightBarButtonItem = barBtn;
}


//-(void)cartClicked{
//    NSLog(@"Shopping Cart Clicked");
//}

-(void)leftButtonClicked:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
