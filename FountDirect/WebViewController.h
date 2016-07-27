//
//  WebViewController.h
//  Spree
//
//  Created by Zhang Xu on 11/8/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic,readwrite) NSString *buyURLStr;
@property (nonatomic,readwrite) NSString *sellerName;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
