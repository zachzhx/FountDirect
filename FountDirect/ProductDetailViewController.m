//
//  ProductDetailViewController.m
//  Spree
//
//  Created by Rush on 9/21/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ALScrollViewPaging.h"
#import "ServiceLayer.h"
#import "Constants.h"
#import "UIColor+CustomColors.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "SelectColorAndSizeViewController.h"
#import "WebViewController.h"
//#import "MediaDetailCollectionViewController.h"
#import "Media.h"
#import "PDPAddToCartModel.h"
#import "ShoppingCartTableViewController.h"
#import <Google/Analytics.h>
//#import "PublicProfileViewController.h"
#import "LikesPeopleTableViewController.h"
#import "ProductOutOfStockViewController.h"
#import "Product.h"
#import <QuartzCore/QuartzCore.h>
#import "NSAttributedString+StringStyles.h"
#import <SDWebImage/UIImageView+WebCache.h>
//#import "GuestPromptViewController.h"
//#import "SYWViewController.h"
//#import "SYWDetailPageViewController.h"
#import "ChatsViewController.h"
//#import "DirectMessageViewController.h"

#define direction_bottom kCATransitionFromTop
static NSString * const cellID = @"cellID";

@interface ProductDetailViewController ()
{
    CGFloat ypos;
    NSMutableDictionary *productDetailDict;
    UILabel *aBrndLbl;
    UIView *aBrandview;
    UIButton *aCartBtn;
    int count;
    //for Table
    NSMutableArray *menuArray,*ExpArr,*cerArray,*thirdArray,*sectionsArray;
    int otherExpand;
    int  checker;
    CGFloat webheight;
    CGFloat aHeight;
    NSArray *imgsArray;
    UILabel *cartLbl;
    UIButton *cartBtn;
    NSDictionary *twoTapDictionary;
    NSMutableArray *relevantPostsArray;
    UIView *aSizeView;
    NSMutableArray *aSizeArray,*aColorArray, *aColorImgArray;
    
    NSArray *fieldNamesArray;
    NSString *loadone;
    NSDictionary *failedCart;
    BOOL isInStock;
    
    NSString *likeAction;
    //    ALScrollViewPaging *ALSVpaging;
    NSString *qualityStr;
    NSMutableDictionary *detailArray;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *coverView;
    __block NSTimer* timer;
    NSString *relevantPostId;
    NSInteger userId;
    NSString *visualTagId;
    NSString *cheapShipping;
    NSString *fieldName0;
    
    NSMutableArray *likesPeopleInfoArray;
    
    UIButton *totalLikesBtn;
    int pageControlY;
    UIRefreshControl *refreshControl;
    UIView *aStockView;
    BOOL timesUp;
    Product *productModel;
    ProductOutOfStockViewController *stock;
    BOOL isFromNotice;
}
@property(strong,nonatomic)ALScrollViewPaging *scrollView;

@end

@implementation ProductDetailViewController
@synthesize aBgScrollVw;
@synthesize scrollView;
@synthesize aProductId;
@synthesize menuTableView;
@synthesize myWebView;
@synthesize aac,stockDataArray;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor themeColor];
    
    //Remove back button's text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    count=0;
    ypos = 0;
    aHeight = 0;
    
    userId = [[[ServiceLayer alloc]init] getUserId];
    layout=[[UICollectionViewFlowLayout alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDismissColorSizeVC) name:@"ColorSizeVCDismissed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appOpenPushReceived:) name:kPushAppActiveNotificationName object:nil];

    //Pull to Refresh:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView:)
                                                 name:@"refreshView"
                                               object:nil];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor themeColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(getLatestMedia) forControlEvents:UIControlEventValueChanged];
    [aBgScrollVw addSubview:refreshControl];
    
    //For spinner
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.color = [UIColor themeColor];
        activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-80);//Center of the frame
        //        NSLog(@"%f , %f", self.view.frame.size.width, self.view.frame.size.height);
        activityIndicator.tag = 12; //The tag to identify view objects
        [aBgScrollVw addSubview:activityIndicator];  //Addsubview:Spinner
        [activityIndicator startAnimating];
    }
    
#pragma navigationbar setup
    
    //[self setupCustomBarButtonItem];
    
#pragma arrays allocation
    productDetailDict = [NSMutableDictionary dictionary];
    imgsArray = [NSArray array];
    relevantPostsArray = [NSMutableArray array];
    aSizeArray = [NSMutableArray array];
    aColorArray = [NSMutableArray array];
    aColorImgArray = [NSMutableArray array];
    fieldNamesArray = [NSArray array];
    
    NSLog(@"id:%@",aProductId);
    //aProductId = @"1701076";
    
    //PDP More Likes API:
    [[[ServiceLayer alloc]init]getPDPMoreLikesWithProductId:aProductId PageNumber:1 completion:^(NSArray *array) {
        //NSLog(@"%@",array);
        likesPeopleInfoArray = [array mutableCopy];
    }];
    
    
    aBgScrollVw.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(goToWebsite:) name:@"NEWNotification" object:nil];
    
#pragma  Calling Product Detail API
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self loadProductDetailData]; //Call API
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupCustomBarButtonItem];
    self.navigationController.navigationBar.translucent = YES;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:kProductDetailPageName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

//UI layout for relevant Post CollectionView
-(UICollectionView*)createCollectionView{
    CGFloat height = relevantPostsArray.count*self.view.frame.size.width;
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height) collectionViewLayout:layout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    [_collectionView setScrollEnabled:NO];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView reloadData];
    
    return _collectionView;
}

#pragma mark NavigationBar Button Items
-(void) setupCustomBarButtonItem {
    
    if (self.presentedModally) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backbuttonimage"] style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    }
    if(self.fromNavigate==YES){
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backbuttonimage"] style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    }
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"PRODUCT"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //Message Icon Button
    UIButton *btn2 =  [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(0,3,28,24);
    btn2.tintColor = [UIColor themeColor];
    btn2.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btn2 setBackgroundImage:[[UIImage imageNamed:@"message"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(messageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Shopping Cart Button
    cartLbl = [[UILabel alloc] init];
    cartLbl.font = [UIFont fontWithName:@"Gill Sans" size:15.0f];
    cartLbl.textColor = [UIColor themeColor];
    cartLbl.textAlignment = NSTextAlignmentCenter;
    
    //NSLog(@"NUM IN CART:%tu", [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey]);
    
    cartLbl.text = [NSString stringWithFormat:@"%tu", [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey]];
    [cartLbl sizeToFit];
    
    cartBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    cartBtn.frame = CGRectMake(45,0,30,30);
    cartBtn.tintColor = [UIColor themeColor];
    [cartBtn setBackgroundImage:[[UIImage imageNamed:@"cart2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [cartBtn addTarget:self action:@selector(cartClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //cartLbl.frame = CGRectMake(cartBtn.layer.position.x - 4, cartBtn.layer.position.y - 4.5, 15, 10);
    cartLbl.frame = CGRectMake(cartBtn.bounds.origin.x + 9, cartBtn.bounds.origin.y + 5, 15, 14);
    [cartBtn addSubview:cartLbl];
    
    UIView *newView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 75, 30)];
    [newView addSubview:cartBtn];
    [newView addSubview:btn2];
    
    //Message Badge View
    NSInteger numOfGroupsWithUnreadMsg = [[NSUserDefaults standardUserDefaults]integerForKey:kNumOfGroupsWithUnreadMsg];
    UIImageView *badgeView = [[UIImageView alloc]initWithFrame:CGRectMake(btn2.frame.origin.x + 15, -2, 20, 20)];
    badgeView.image = [UIImage imageNamed:@"messagebadge"];
    UILabel *badgeLabel = [[UILabel alloc]init];
    badgeLabel.font = [UIFont fontWithName:@"Gill Sans" size:14.0f];
    badgeLabel.textColor = [UIColor whiteColor];
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    badgeLabel.text = [NSString stringWithFormat:@"%tu",numOfGroupsWithUnreadMsg];
    [badgeLabel sizeToFit];
    [badgeView addSubview:badgeLabel];
    [badgeLabel setCenter:CGPointMake(badgeView.frame.size.width/2, badgeView.frame.size.height/2)];
    [newView addSubview:badgeView];
    
    if (numOfGroupsWithUnreadMsg > 0) {
        badgeView.hidden = NO;
    }else{
        badgeView.hidden = YES;
    }
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:newView];
    self.navigationItem.rightBarButtonItem = barBtn;
}

#pragma mark - Button Clicks
-(void) cartClicked {
    
    [ServiceLayer googleTrackEventWithCategory:@"Shopping Cart Clicked" actionName:@"Product Detail Page's Cart Clicked" label:nil value:1];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShoppingCart" bundle:nil];
    ShoppingCartTableViewController *aCartTableView = [storyboard instantiateInitialViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aCartTableView];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)messageButtonClicked{
    [ServiceLayer googleTrackEventWithCategory:@"Shopping Cart Clicked" actionName:@"Discover Page's Cart Clicked" label:nil value:1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Message" bundle:nil];
    ChatsViewController *chatsVC = [storyboard instantiateInitialViewController];
    
    [self.navigationController pushViewController:chatsVC animated:YES];
}

#pragma mark - landing to page and API call
-(void)loadProductDetailData{
    
    [[[ServiceLayer alloc] init] getProductDetailsWithProductId:aProductId completion:^(NSDictionary *aDict) {
        if ([productDetailDict count]>0) {
            [productDetailDict removeAllObjects];
        }
        // NSLog(@"adict:%@",aDict);
//        NSError * err;
//        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:aDict options:0 error:&err];
//        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        productDetailDict = [aDict mutableCopy];
        [activityIndicator stopAnimating]; //Stop Spinning
        //InStock:
        isInStock = [productDetailDict[@"inStock"]boolValue];
        NSDictionary *twoTapDataDict = productDetailDict[@"twoTapData"];
        //NSLog(@"adict:%@",twoTapDataDict);
        
        NSDictionary *sitesdict = twoTapDataDict[@"sites"];
        NSDictionary *cart_dict = [sitesdict objectForKey:[[sitesdict allKeys] objectAtIndex:0]];
        
        cheapShipping = [[cart_dict objectForKey:@"shipping_options"] valueForKey:@"cheapest"];
        
        NSDictionary *addToCart = cart_dict[@"add_to_cart"];
        likeAction = [productDetailDict[@"socialActionUserProduct"] valueForKey:@"liked"];
        
        //failedCart = cart_dict[@"failed_to_add_to_cart"];//TTData fail to add to cart
        
        NSDictionary *dict = [addToCart objectForKey:[[addToCart allKeys] objectAtIndex:0]];
        twoTapDictionary = dict;
        
        BOOL isEmpty = ([twoTapDictionary count] == 0);
        if (isEmpty) {
            [activityIndicator stopAnimating];
            [coverView removeFromSuperview];
        }else{
            
        }
        
        NSDictionary *fieldDict = [dict objectForKey:@"required_field_values"];
        NSArray *array  = [fieldDict objectForKey:@"color"];
        
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = obj;
            [aColorArray addObject:[dict valueForKey:@"text"]];
            NSDictionary *sizeDict = [dict objectForKey:@"dep"];
            NSMutableArray *sizeArray = [sizeDict objectForKey:@"size"];
            [sizeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict2 = obj;
                [aSizeArray addObject:[dict2 valueForKey:@"value"]];
            }];
            *stop = YES;
        }];
        imgsArray = [dict objectForKey:@"alt_images"];
        [self loadCollectionViewForRelevantPosts];
        fieldNamesArray = [dict objectForKey:@"required_field_names"];
        if (fieldNamesArray != nil) {
            fieldName0 = [fieldNamesArray objectAtIndex:0];
        }
    }];
}

#pragma mark - UI Design
-(void)loadDetailView{
    //  self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Gill Sans" size:18], NSForegroundColorAttributeName: [UIColor themeColor]};
    
    //    NSLog(@"%f",self.view.frame.size.width);
    scrollView = [[ALScrollViewPaging alloc] initWithFrame:CGRectMake(0, ypos, self.view.frame.size.width, 350)];
    
    ypos = 0;
   // NSLog(@"%f",self.view.frame.size.width);
    if (!isInStock|| timesUp) {
        scrollView = [[ALScrollViewPaging alloc] initWithFrame:CGRectMake(0, ypos+60, self.view.frame.size.width, 350)];
    }else{
        scrollView = [[ALScrollViewPaging alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
    }
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    //    [scrollView.button addTarget:self
    //                          action:@selector(aLikeMethod:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //    scrollView.button.exclusiveTouch = YES;
    
    //array for views to add to the scrollview
    NSMutableArray *views = [[NSMutableArray alloc] init];
    
    //Pass the data to ALScrollViewPaging
    scrollView.productID = aProductId;
    scrollView.likeBooleam = likeAction;
    NSString *likes=[NSString stringWithFormat:@"%@", [productDetailDict  valueForKey:@"likes"]];
    scrollView.likesQuantity = likes;
    
    //YPOS postion increasing
    if (!isInStock||timesUp) {
        ypos=ypos+aStockView.frame.size.height+60;
    }
    
    //creates product image views for the scrollview
    if ([imgsArray count]>0) {
        
        for (int i = 0; i < imgsArray.count; i++) {
            // UIImageView *aImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 250)];
            UIImageView *aImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,ypos, self.view.frame.size.width, 250)];
            
            aImgview.contentMode = UIViewContentModeScaleAspectFit; //Aspect Fit
            aImgview.image = nil;
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [imgsArray objectAtIndex:i]]];
                
               // NSLog(@"URL:%@", [imgsArray objectAtIndex:i]);
                
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mainImage = [UIImage imageWithData:data];
                    aImgview.image = self.mainImage;
                });
            });
            
            
            [views addObject:aImgview];
        }
        [scrollView addPages:views];
        [aBgScrollVw addSubview:scrollView];
        [scrollView setHasPageControl:YES];
        //  [scrollView setHasLikeMethod:YES];
        
    }else{
        //UIImageView *aImgview= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
        UIImageView *aImgview= [[UIImageView alloc] initWithFrame:CGRectMake(0, ypos, self.view.frame.size.width, 240)];
        
        aImgview.contentMode = UIViewContentModeScaleAspectFit;
        
        aImgview.image = nil;
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [productDetailDict valueForKey:@"imageURL"]]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mainImage = [UIImage imageWithData:data];
                aImgview.image = self.mainImage;
            });
        });
        
        [views addObject:aImgview];
        [scrollView addPages:views];
        [aBgScrollVw addSubview:scrollView];
        //[scrollView setHasLikeMethod:YES];
    }
    
//First Separating Line:
    ypos = ypos+scrollView.frame.size.height+30;
    UIView *aLineview = [[UIView alloc] initWithFrame:CGRectMake(0, ypos, self.view.frame.size.width, 2)];
    [aLineview setBackgroundColor:[UIColor selectedGrayColor]];
    [aBgScrollVw addSubview:aLineview];
    
    ypos = ypos+aLineview.frame.size.height+1;
    
//Share&Like&DM Buttons Section:
    UIView *Productview=[[UIView alloc]initWithFrame:CGRectMake(0, ypos, self.view.frame.size.width, 40)];
    Productview.backgroundColor=[UIColor clearColor];
    
    //DM Product Message Button
    UIButton *dmMessageButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/6-20, 5, 40, 30)];
    [dmMessageButton setImage:[UIImage imageNamed:@"directmessage"] forState:UIControlStateNormal];
    [dmMessageButton addTarget:self action:@selector(dmMessageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [Productview addSubview:dmMessageButton];
    
    UIView *verticalLine2 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3-2, 0, 2, 40)];
    [verticalLine2 setBackgroundColor:[UIColor selectedGrayColor]];
    [Productview addSubview:verticalLine2];
    
    //Like Button
    CGFloat likeButtonX = round (self.view.frame.size.width/2);
    UIButton *rightLikeButton=[[UIButton alloc]initWithFrame:CGRectMake(likeButtonX-20, 5, 40, 30)];
    rightLikeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    rightLikeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightLikeButton.contentMode=UIViewContentModeScaleToFill;
    
    if([likeAction intValue]){
        [rightLikeButton setImage:[UIImage imageNamed:@"likesfilled"] forState:UIControlStateNormal];
        [rightLikeButton setTintColor:[UIColor themeColor]];
        
    }else{
        [rightLikeButton setImage:[UIImage imageNamed:@"likes"] forState:UIControlStateNormal];
        [rightLikeButton setTintColor:[UIColor lightGrayColor]];
    }
    
    [rightLikeButton addTarget:self action:@selector(rightlikebuttonclicked:) forControlEvents:UIControlEventTouchUpInside];
    [Productview addSubview:rightLikeButton];
    
    UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*2/3-2, 0, 2, 40)];
    [verticalLine setBackgroundColor:[UIColor selectedGrayColor]];
    [Productview addSubview:verticalLine];
    
    //Share Button
    UIButton *shareButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width*5/6-20, 5, 40, 30)];
    //leftsharebutton.backgroundColor=[UIColor lightGrayColor];
    [shareButton setImage:[[UIImage imageNamed:@"share"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonclicked:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setBackgroundColor:[UIColor clearColor]];
    [shareButton setTintColor:[UIColor lightGrayColor]];
    [Productview addSubview:shareButton];
    
    [aBgScrollVw addSubview:Productview];

//Second Separating Line:
    ypos = ypos+Productview.frame.size.height+1;
    UIView *aLineProductview = [[UIView alloc] initWithFrame:CGRectMake(0, ypos+2, self.view.frame.size.width, 2)];
    [aLineProductview setBackgroundColor:[UIColor selectedGrayColor]];
    [aBgScrollVw addSubview:aLineProductview];
    ypos = ypos+aLineProductview.frame.size.height+1;
    
    NSString *likesStr = [[productDetailDict valueForKey:@"likes"] stringValue];
    
//Liked Users Section:
    if (![likesStr isEqualToString:@"0"]) {
        //Like View Section: (Second section）
        UIView *aLikesView = [[UIView alloc] initWithFrame:CGRectMake(0, ypos+2, self.view.frame.size.width, 50)];
        aLikesView.backgroundColor = [UIColor clearColor];
        
        totalLikesBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        totalLikesBtn.frame = CGRectMake(10, 5, 70, 40);
        totalLikesBtn.tintColor=[UIColor lightGrayColor];
        totalLikesBtn.backgroundColor = [UIColor clearColor];
        totalLikesBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        totalLikesBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //btn.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 5);
        //btn.titleEdgeInsets = UIEdgeInsetsMake(10, 5, 0, 0);
        NSString *likes=[NSString stringWithFormat:@"%@ Likes", [productDetailDict  valueForKey:@"likes"]];
        [totalLikesBtn setTitle:likes forState:UIControlStateNormal];
        //[btn setTitle:@"9999 Likes" forState:UIControlStateNormal];
        totalLikesBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //[btn setImage:[UIImage imageNamed:@"likes"] forState:UIControlStateNormal];
        [aLikesView addSubview:totalLikesBtn];
        
        //Vertical Seperator Line:
        UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(83, 0, 2, 50)];
        //[verticalLine setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]]];
        [verticalLine setBackgroundColor:[UIColor selectedGrayColor]];
        [aLikesView addSubview:verticalLine];
        
        //More Button:
        //NSLog(@"%f",self.view.frame.size.width);
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        moreBtn.frame = CGRectMake(aLikesView.frame.size.width-100, 5, 100, 40);
        moreBtn.backgroundColor = [UIColor clearColor];
        moreBtn.tintColor=[UIColor lightGrayColor];
        if (self.view.frame.size.width>320) {
            NSString *moreLikes=[NSString stringWithFormat:@"%@ Likes", [productDetailDict  valueForKey:@"moreLikes"]];
            [moreBtn setTitle:[NSString stringWithFormat:@"%@+",[self abbreviateNumber:[moreLikes intValue] withDecimal:2]] forState:UIControlStateNormal];
            //[moreBtn setTitle:@"9999 Likes+" forState:UIControlStateNormal];
        }
        
        [moreBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        moreBtn.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        moreBtn.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        moreBtn.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        [moreBtn setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreLikesClicked:) forControlEvents:UIControlEventTouchUpInside];
        //moreBtn.titleLabel.font = [UIFont fontWithName:@"Gill Sans" size:16];
        moreBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [aLikesView addSubview:moreBtn];
        
        //Liked Users' Profile Image:
        NSMutableArray *likesArray=[productDetailDict valueForKey:@"likedUsers"];
        //float x=btn.frame.origin.x+btn.frame.size.width;
        float x= 90;
        //float width=(aLikesView.frame.size.width-205)/4;
        for (int i=0;(i<4)&(i<likesArray.count);i++){
            UIImageView *aImgLikeview = [[UIImageView alloc] initWithFrame:CGRectMake(x, 5, 42.5, 42.5)];
            NSString *urlString = [[likesArray objectAtIndex:i]valueForKey:@"fountProfilePicture"];
            if (!urlString) {
                urlString = [[likesArray objectAtIndex:i]valueForKey:@"igProfilePicture"];
            }
            [aImgLikeview sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (!error) {
                    aImgLikeview.image = image;
                } else {
                    aImgLikeview.image = [UIImage imageNamed:@"placeholderprofile"];
                }
            }];
            
            aImgLikeview.layer.cornerRadius = aImgLikeview.frame.size.height/2;
            aImgLikeview.layer.masksToBounds = YES;
            [aLikesView addSubview:aImgLikeview];
            x=aImgLikeview.frame.size.width+aImgLikeview.frame.origin.x+5;
            aImgLikeview.userInteractionEnabled = YES;
            aImgLikeview.tag = i;
            UITapGestureRecognizer *profileTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTapped:)];
            [aImgLikeview addGestureRecognizer:profileTapGesture];
            
        }
        //        UIImageView *emptyImgView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 5, 42.5, 42.5)];
        //        emptyImgView.image = [UIImage imageNamed:@"emptyProfile.png"];
        //        [aLikesView addSubview:emptyImgView];
        
        [aBgScrollVw addSubview:aLikesView];
        
        ypos = ypos+aLikesView.frame.size.height+2;
        
//Third Separating Line:
        UIView *aLineviewNew = [[UIView alloc] initWithFrame:CGRectMake(0, aLikesView.frame.size.height+aLikesView.frame.origin.y+1, self.view.frame.size.width, 2)];
        [aLineviewNew setBackgroundColor:[UIColor selectedGrayColor]];
        [aBgScrollVw addSubview:aLineviewNew];
        ypos = ypos+aLineviewNew.frame.size.height+1;
    }
    
//Product Information Section:
    //BrandLabel
    aBrandview = [[UIView alloc] initWithFrame:CGRectMake(0, ypos+2, self.view.frame.size.width, 200)];
    CGFloat y;
    y = 2;
    
    aBrndLbl = [[UILabel alloc] init];
    aBrndLbl.textColor = [UIColor themeColor];
    aBrndLbl.backgroundColor=[UIColor clearColor];
    aBrndLbl.font = [UIFont boldSystemFontOfSize:16];
    aBrndLbl.text= [[[productDetailDict objectForKey:@"brand"] valueForKey:@"name"]uppercaseString];
    //NSLog(@"productName %@",[[productDetailDict objectForKey:@"brand"] valueForKey:@"name"]);
    aBrndLbl.numberOfLines = 0;
    aBrndLbl.lineBreakMode = NSLineBreakByWordWrapping;
    aBrndLbl.userInteractionEnabled= YES;
    UITapGestureRecognizer *TapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(brandNameTapped:)];
    [aBrndLbl addGestureRecognizer:TapGesture];
    //    NSInteger brandId = (int)[[[productDetailDict objectForKey:@"brand"]valueForKey:@"id"]integerValue];
    //    [[[ServiceLayer alloc]init]getBrandInfoWithBrandId:brandId completion:^(NSDictionary *dictionary) {
    //        NSLog(@"%@",dictionary);
    //    }];
    //
    //    [[[ServiceLayer alloc]init]getBrandPostsWithBrandId:brandId pageNumber:0 completion:^(NSArray *array) {
    //        NSLog(@"%@",array);
    //    }];
    
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize = [aBrndLbl sizeThatFits:maximumLabelSize];
    CGRect newFrame = aBrndLbl.frame;
    newFrame.size.width = expectedLabelSize.width+20;
    newFrame.size.height = expectedLabelSize.height+5;
    aBrndLbl.frame = newFrame;
    aBrndLbl.frame = CGRectMake(10, y, aBrndLbl.frame.size.width, aBrndLbl.frame.size.height);
    [aBrandview addSubview:aBrndLbl];
    
    y = y+aBrndLbl.frame.size.height+2;
    
    //NameLabel
    UILabel* aNameLbl = [[UILabel alloc] init];
    aNameLbl.textColor = [UIColor darkGrayColor];
    aNameLbl.backgroundColor=[UIColor clearColor];
    aNameLbl.font = [UIFont boldSystemFontOfSize:14];
    aNameLbl.text= [productDetailDict valueForKey:@"name"];
    aNameLbl.numberOfLines = 0;
    aNameLbl.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize maximumSize = CGSizeMake(289,9999);
    CGSize expectedSize = [aNameLbl sizeThatFits:maximumSize];
    CGRect frame = aNameLbl.frame;
    frame.size.width = expectedSize.width+20;
    frame.size.height = expectedSize.height+5;
    aNameLbl.frame = frame;
    aNameLbl.frame = CGRectMake(10, y,aBrandview.frame.size.width-100, aNameLbl.frame.size.height);
    [aBrandview addSubview:aNameLbl];
    
    y = y+aNameLbl.frame.size.height+2;
    
    //PriceLabel
    UILabel* aPriceLbl = [[UILabel alloc] initWithFrame:CGRectMake(aBrandview.frame.origin.x+aBrandview.frame.size.width-200, aBrndLbl.frame.origin.y+2, 195, 20)];
    aPriceLbl.textColor = [UIColor darkGrayColor];
    aPriceLbl.textAlignment = NSTextAlignmentRight;
    aPriceLbl.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
    [aBrandview addSubview:aPriceLbl];
    
    //salePriceLbel
    UILabel* salePriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(aBrandview.frame.origin.x+aBrandview.frame.size.width-180, aPriceLbl.frame.origin.y+20, 175, 20)];
    salePriceLabel.textColor = [UIColor darkGrayColor];
    salePriceLabel.textAlignment = NSTextAlignmentRight;
    salePriceLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
    [aBrandview addSubview:salePriceLabel];
    
    if (twoTapDictionary) {
        //NSLog(@"%@",[twoTapDictionary valueForKey:@"price"]);
        //aPriceLbl.text = [NSString stringWithFormat:@"%@", [twoTapDictionary valueForKey:@"original_price"]];
        NSString *price = [twoTapDictionary valueForKey:@"original_price"];
        NSString *salePrice = [twoTapDictionary valueForKey:@"price"];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        
        salePrice = [salePrice stringByReplacingOccurrencesOfString:formatter.internationalCurrencySymbol withString:@""];
        float saleValue = [formatter numberFromString:salePrice].floatValue;
        price = [price stringByReplacingOccurrencesOfString:formatter.internationalCurrencySymbol withString:@""];
        float originalValue = [formatter numberFromString:price].floatValue;
        
        NSString *salePriceText = [NSNumberFormatter localizedStringFromNumber:@(saleValue)
                                                                   numberStyle:NSNumberFormatterCurrencyStyle];
        NSString *originalPriceText =[NSString stringWithFormat:@"%@" ,[NSNumberFormatter localizedStringFromNumber:@(originalValue)
                                                                                                        numberStyle:NSNumberFormatterCurrencyStyle]];
        
        if (!price||price==salePrice) {
            aPriceLbl.hidden = YES;
            salePriceLabel.text = [NSString stringWithFormat:@"%@", salePriceText];
        } else {
            aPriceLbl.hidden = NO;
            
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:originalPriceText];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            
            aPriceLbl.attributedText = attributeString;
            salePriceLabel.text = [NSString stringWithFormat:@"%@", salePriceText];
        }
        
    }else{
        CGFloat salePriceCG=[[productDetailDict valueForKey:@"salePrice"]floatValue];
        CGFloat priceCG=[[productDetailDict valueForKey:@"price"] floatValue];
        
        NSString *originalPriceText =[NSNumberFormatter localizedStringFromNumber:@(priceCG)numberStyle:NSNumberFormatterCurrencyStyle];
        NSString *salePriceText = [NSNumberFormatter localizedStringFromNumber:@(salePriceCG) numberStyle:NSNumberFormatterCurrencyStyle];
        
        if (salePriceCG==0.00 || salePriceCG == priceCG) {
            aPriceLbl.hidden = YES;
            salePriceLabel.frame = CGRectMake(aBrandview.frame.origin.x+aBrandview.frame.size.width-180, aNameLbl.frame.origin.y, 175, 20);
            salePriceLabel.text = [NSString stringWithFormat:@"%@", originalPriceText];
        } else {
            aPriceLbl.hidden = NO;
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", originalPriceText]];
            
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            aPriceLbl.attributedText = attributeString;
            salePriceLabel.text = [NSString stringWithFormat:@"%@", salePriceText];
        }
    }
    
    
//Fourth Separating Line
    UIView *aLineview2 = [[UIView alloc] initWithFrame:CGRectMake(0, aNameLbl.frame.origin.y+aNameLbl.frame.size.height+8, self.view.frame.size.width, 2)];
    [aLineview2 setBackgroundColor:[UIColor selectedGrayColor]];
    [aBrandview addSubview:aLineview2];
    
    y = y+aLineview2.frame.size.height;
    
//SYW Rewords Section
    if (isInStock && [[productDetailDict valueForKey:@"shopperPoints"]integerValue]>0) {
        
        UIView *sywView = [[UIView alloc]initWithFrame:CGRectMake(0, aLineview2.frame.origin.y+2, self.view.frame.size.width, 60)];
        sywView.backgroundColor = [UIColor colorFromHexString:@"#f8f8f8"];
        [aBrandview addSubview:sywView];
        
        //SYW Logo
        UIImageView *sywImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sywlogo"]];
        sywImageView.frame = CGRectMake(10, 2, 65, 55);
        sywImageView.contentMode = UIViewContentModeScaleAspectFit;
        //sywImageView.backgroundColor = [UIColor greenColor];
        [sywView addSubview:sywImageView];
        
        //Vertical Separating line
        UIView *verticalLine1 = [[UIView alloc]initWithFrame:CGRectMake(83, 1, 2, 60-2)];
        [verticalLine1 setBackgroundColor:[UIColor selectedGrayColor]];
        [sywView addSubview:verticalLine1];
        
        //SYW Account Button
        UIButton *sywButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsSywConnected]) {
            sywButton.frame = CGRectMake(self.view.frame.size.width-100, 15, 95, 30);
            sywButton.layer.cornerRadius = 14;
            sywButton.backgroundColor = [UIColor colorFromHexString:@"#4ad1c0"];
            sywButton.tintColor = [UIColor whiteColor];
            [sywButton setTitle:@"MY ACCOUNT" forState:UIControlStateNormal];
            sywButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [sywView addSubview:sywButton];
            [sywButton addTarget:self action:@selector(accountButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            sywButton.frame = CGRectMake(self.view.frame.size.width-100, 10, 95, 25);
            sywButton.layer.cornerRadius = 13;
            sywButton.backgroundColor = [UIColor colorFromHexString:@"#4ad1c0"];
            sywButton.tintColor = [UIColor whiteColor];
            [sywButton setTitle:@"Join or Activate" forState:UIControlStateNormal];
            sywButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
            [sywView addSubview:sywButton];
            [sywButton addTarget:self action:@selector(activateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
            //Detail words Label
            UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100, sywButton.frame.origin.y+25, 95, 20)];
            //detailLabel.backgroundColor = [UIColor greenColor];
            detailLabel.textColor = [UIColor grayColor];
            detailLabel.font = [UIFont fontWithName:@"Gill Sans" size:8];
            detailLabel.text = @"If you don't have a Shop Your Way account linked to Fount";
            detailLabel.textAlignment = NSTextAlignmentCenter;
            detailLabel.numberOfLines = 2;
            [sywView addSubview:detailLabel];
        }
        
        //Vertical Separating Line
        UIView *verticalLine2 = [[UIView alloc]initWithFrame:CGRectMake(sywButton.frame.origin.x-7, 1, 2, 60-2)];
        [verticalLine2 setBackgroundColor:[UIColor selectedGrayColor]];
        [sywView addSubview:verticalLine2];
        
        //SYW Points Labels
        CGFloat pointsDetailPartWidth = verticalLine2.frame.origin.x - verticalLine1.frame.origin.x - 2;
        UILabel *noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(verticalLine1.frame.origin.x+2+5, 5, pointsDetailPartWidth-10, 30)];
        //noticeLabel.backgroundColor = [UIColor greenColor];
        noticeLabel.font = [UIFont boldSystemFontOfSize:11];
        //noticeLabel.font = [UIFont fontWithName:@"Gill Sans" size:10];
        noticeLabel.text = @"YOU CAN EARN ON THIS PRODUCT:";
        noticeLabel.textColor = [UIColor themeColor];
        noticeLabel.textAlignment = NSTextAlignmentLeft;
        noticeLabel.numberOfLines = 2;
        [sywView addSubview:noticeLabel];
        
        UILabel *pointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(noticeLabel.frame.origin.x, noticeLabel.frame.origin.y+30-2, noticeLabel.frame.size.width, 20)];
        //pointsLabel.backgroundColor = [UIColor redColor];
        pointsLabel.font = [UIFont boldSystemFontOfSize:12];
        NSUInteger pointsNumber = [[productDetailDict objectForKey:@"shopperPoints"]integerValue];
        NSString *pointsString = [self addCommas:pointsNumber];
        pointsLabel.text = [NSString stringWithFormat:@"%@ POINTS", pointsString];
        pointsLabel.textColor = [UIColor colorFromHexString:@"#f46d15"];
        pointsLabel.textAlignment = NSTextAlignmentLeft;
        [sywView addSubview:pointsLabel];
        
        //Fifth Separating Line
        UIView *aLineView23 = [[UIView alloc] initWithFrame:CGRectMake(0, sywView.frame.origin.y+60, self.view.frame.size.width, 2)];
        [aLineView23 setBackgroundColor:[UIColor selectedGrayColor]];
        [aBrandview addSubview:aLineView23];
        
        y = y + 60 + 2;
    }
    
//AddToCartButton
    NSDictionary *sellerArray = productDetailDict[@"seller"];
    qualityStr = [sellerArray valueForKey:@"quality"];
    NSString *sellerName = [sellerArray valueForKey:@"name"];
    
    if ([qualityStr isEqualToString:@"LOW"]) {
        aCartBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [aCartBtn addTarget:self
                     action:@selector(goToWebsite:)
           forControlEvents:UIControlEventTouchUpInside];
        aCartBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        aCartBtn.backgroundColor = [UIColor themeColor];
        aCartBtn.tintColor = [UIColor whiteColor];
        [aCartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [aCartBtn.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [aCartBtn setTitle: [NSString stringWithFormat:@"BUY NOW on %@" ,sellerName] forState:UIControlStateNormal];
        aCartBtn.frame = CGRectMake(30.0, y+14, aBrandview.frame.size.width-60.0, 40.0);
        aCartBtn.layer.cornerRadius = 5;
        if (!isInStock) {
            aCartBtn.userInteractionEnabled=NO;
            aCartBtn.alpha = 0.5;
        }
        
    }else{
        
        aCartBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [aCartBtn addTarget:self
                     action:@selector(addTocartMethod:)
           forControlEvents:UIControlEventTouchUpInside];
        aCartBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        aCartBtn.backgroundColor = [UIColor themeColor];
        aCartBtn.tintColor = [UIColor whiteColor];
        [aCartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIImage *img=[UIImage imageNamed:@"cart"];
        aCartBtn.imageEdgeInsets = UIEdgeInsetsMake(0., aCartBtn.frame.size.width - (img.size.width + 15.), 0., 0.);
        [aCartBtn setImage:img forState:UIControlStateNormal];
        [aCartBtn setTitle:@"ADD TO CART" forState:UIControlStateNormal];
        aCartBtn.frame = CGRectMake(30.0, y+14, aBrandview.frame.size.width-60.0, 40.0);
        aCartBtn.layer.cornerRadius = 5;
    }
    
    [aBrandview addSubview:aCartBtn];
    
    CGFloat yval= aCartBtn.frame.origin.y+aCartBtn.frame.size.height+7;
    
    aBrandview.frame = CGRectMake(0, aBrandview.frame.origin.y, aBrandview.frame.size.width, yval);
    
// SeperatorLine
    UIView *aLineview3 = [[UIView alloc] initWithFrame:CGRectMake(0, aBrandview.frame.origin.y+aBrandview.frame.size.height, self.view.frame.size.width, 1)];
    [aLineview3 setBackgroundColor:[UIColor lightGrayColor]];
    [aBgScrollVw addSubview:aLineview3];
    [aBgScrollVw addSubview:aBrandview];
    
    ypos = ypos+aBrandview.frame.size.height+2;
    aHeight = ypos+aBrandview.frame.size.height+2;
    
//UI layout for Description, Color&Size, RelevantPost MenuTableView
    menuArray = [[NSMutableArray alloc] initWithObjects:@"Description",@"Color & Size",@"Relevant Posts", nil];
    
    menuTableView = [[UITableView alloc] initWithFrame:
                     CGRectMake(0, ypos,self.view.frame.size.width, 200) style:UITableViewStylePlain];
    menuTableView.estimatedRowHeight = 50.0f;
    menuTableView.backgroundColor = [UIColor clearColor];
    menuTableView.scrollEnabled = NO;
    [self.menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [menuTableView setHidden:NO];
    menuTableView.rowHeight=50;
    menuTableView.opaque=NO;
    [aBgScrollVw addSubview:menuTableView];
    menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    menuTableView.delegate = self;
    menuTableView.dataSource = self;
    [menuTableView reloadData];
    ypos = ypos+menuTableView.frame.size.height;
    
    ExpArr=[[NSMutableArray alloc]initWithObjects:@"Row 0", nil];
    cerArray=[[NSMutableArray alloc]initWithObjects:@"Row 1", nil];
    thirdArray=[[NSMutableArray alloc]initWithObjects:@"Row 2",nil];
    sectionsArray=[[NSMutableArray alloc]initWithObjects:ExpArr,cerArray,thirdArray, nil];
    otherExpand=100;
    checker=100;
    aBgScrollVw.contentSize =CGSizeMake(self.view.frame.size.width, ypos-30);
    
  //  if ([qualityStr isEqualToString:@"HIGH"]) {
    if (!isInStock||timesUp) {
                   aCartBtn.enabled = NO;
        aCartBtn.alpha = 0.5;
        [self loadStockView];
        }
   // }
}

-(void)loadStockView{
    aStockView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    aStockView.backgroundColor=[UIColor lightGrayBackgroundColor];
    aStockView.alpha=0.8;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 25, 40)];
    //    imageView.backgroundColor = [UIColor greenColor];
    imageView.image = [UIImage imageNamed:@"pull.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [aStockView addSubview:imageView];
    
    UILabel *topStockLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 30)];
    topStockLabel.text=@"This item is out of stock";
    topStockLabel.textColor = [UIColor darkGrayColor];
    //topStockLabel.backgroundColor = [UIColor lightGrayBackgroundColor];
    topStockLabel.font=[UIFont fontWithName:@"Gill Sans" size:16];
    topStockLabel.textAlignment = NSTextAlignmentCenter;
    [aStockView addSubview:topStockLabel];
    
    UILabel *StocktopDownLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 25, self.view.frame.size.width, 30)];
    StocktopDownLabel.text=@"Pull down to let us find similar ones for you";
    StocktopDownLabel.font=[UIFont fontWithName:@"Gill Sans" size:12];
    StocktopDownLabel.textColor=[UIColor grayColor];
    StocktopDownLabel.textAlignment=NSTextAlignmentCenter;
    //StocktopDownLabel.backgroundColor = [UIColor lightGrayColor];
    [aStockView addSubview:StocktopDownLabel];
    
    [aBgScrollVw addSubview:aStockView];
    
}

//RelevantPost API and VisualTagId API:
-(void)loadCollectionViewForRelevantPosts{
    
    //relevent posts api call
    [[[ServiceLayer alloc] init] getReleventPostsWithProductId:aProductId pageNumber:@"0" completion:^(NSArray *array) {
        relevantPostsArray = [array mutableCopy];
        relevantPostId = [relevantPostsArray valueForKey:@"id"];
        
        BOOL isEmpty = ([relevantPostsArray count] == 0);
        if (!isEmpty) {
            [[[ServiceLayer alloc] init] getVisualTagId:relevantPostId productId:aProductId completion:^(NSDictionary *dictionary) {
                NSMutableDictionary *visualIdDict = [[NSMutableDictionary alloc]init];
                visualIdDict = [dictionary mutableCopy];
                //NSLog(@"VISUALTAGEID:%@",visualIdDict);
                visualTagId = [[visualIdDict objectForKey:@"payload"] valueForKey:@"VISUAL_TAG_ID"];
                
            }];
        }
        
        
        [self loadDetailView];
    }];
    
    
    aBgScrollVw.contentSize =CGSizeMake(self.view.frame.size.width, ypos+200);
}

#pragma mark GoToWebsite Button Actions
-(void)goToWebsite:(id)sender{
    [self performSegueWithIdentifier:@"webViewSegue" sender:self];
//    [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
//        [self setupCustomBarButtonItem];
//    }];
}

#pragma mark AddToCart button action
-(void)addTocartMethod:(id)sender{
    //aCartBtn.userInteractionEnabled = NO;
    //aCartBtn.alpha = 0.5;
    [self loadProductDetail];
    
    BOOL isEmpty = ([twoTapDictionary count] == 0);
    
    if (isEmpty) {
        [self loadCoverView];
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target: self selector: @selector(aAddCartMethodToLoadTwoTap) userInfo: nil repeats: YES];
        
        //Update the icon cart numbers
//        [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
//            [self setupCustomBarButtonItem];
//        }];
        
    } else {
        
        [timer invalidate];
        
        timer = nil;
        
        if (fieldNamesArray.count > 1) {
            
            [self performSegueWithIdentifier:@"chooseColorSizeSegue" sender:self];//popup the Color&size section
            
//            [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
//                [self setupCustomBarButtonItem];
//            }];
            
        }else if(fieldNamesArray.count==1 &&![fieldNamesArray[0] isEqualToString:@"quantity"]){
            [self performSegueWithIdentifier:@"chooseColorSizeSegue" sender:self];//popup the Color&size section
            
//            [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
//                [self setupCustomBarButtonItem];
//            }];
            
        } else {
            //            NSLog(@"%ld",[relevantPostsArray count]);
            BOOL isEmpty = ([relevantPostsArray count] == 0);
            if (isEmpty){
                //POST ShopAddToCart API
                //                NSLog(@"%@",aProductId);
                ServiceLayer *aService = [[ServiceLayer alloc]init];
                [aService postShopAddToCart:[self shopAddParametersDict] completion:^(NSDictionary *dictionary) {
                    aCartBtn.userInteractionEnabled=NO;
                    aCartBtn.alpha = 0.5;
//                    [self setupCustomBarButtonItem];
                    
//                    //Update the icon cart numbers
//                    [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
//                        [self setupCustomBarButtonItem];
//                    }];
                }];
                
                
            } else {
                //POST DiscoverAddToCart API
                ServiceLayer *aService = [[ServiceLayer alloc]init];
                
                [aService postAddToCart:[self formatedParametersDict] completion:^(NSDictionary *dictionary) {
//                                        NSLog(@"dict :%@",dictionary);
                    aCartBtn.userInteractionEnabled = NO;
                    aCartBtn.alpha = 0.5;
                    
                    //Update the icon cart numbers
//                    [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
//                        [self setupCustomBarButtonItem];
//                    }];
                }];
            }
        }
    }
}

-(void)aAddCartMethodToLoadTwoTap{
    
    [activityIndicator startAnimating];
    //    NSLog(@"isrunnning");
    count=count+1;
    //    NSLog(@"count%d",count);
    
    if(count<3){
        
        NSDictionary *twoTapData = productDetailDict[@"twoTapData"];
        BOOL isEmpty = ([twoTapData count] == 0);
        if (isEmpty) {
            if (!coverView) {
                [self loadCoverView];
            }
            [self loadProductDetail]; // To call the API when clicked on the button
            
        }else{
            [self methodToCheck];
        }
    }else{
        [self methodToCheck];
        
    }
    
}
-(void)methodToCheck{
    if(count>=3){
        [timer invalidate];
        timer = nil;
        [activityIndicator stopAnimating];
        [coverView removeFromSuperview];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        self.navigationController.view.userInteractionEnabled = YES;
    }
    
    NSDictionary *twoTapData = productDetailDict[@"twoTapData"];
    
    if ([twoTapData count]>0){
        if (!isInStock) {
            [self loadStockView];
            if (!isInStock) {
                
                scrollView.frame = CGRectMake(0,60, self.view.frame.size.width,320);
                scrollView.scrollEnabled=NO;
                aBgScrollVw.contentSize=CGSizeMake(self.view.frame.size.width,900);
                [aBgScrollVw addSubview:scrollView];
            }
            else{
                scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, 350);
                
            }
            aCartBtn.enabled = NO;
            aCartBtn.alpha = 0.5;
            [timer invalidate];
            timer = nil;
            [activityIndicator stopAnimating];
            [coverView removeFromSuperview];
            self.navigationController.navigationBar.userInteractionEnabled = YES;
            self.navigationController.view.userInteractionEnabled = YES;
        }
        else if (fieldNamesArray.count >1) {
            [timer invalidate];
            timer = nil;
            [activityIndicator stopAnimating];
            [coverView removeFromSuperview];
            self.navigationController.navigationBar.userInteractionEnabled = YES;
            self.navigationController.view.userInteractionEnabled = YES;
            [self performSegueWithIdentifier:@"chooseColorSizeSegue" sender:self];//popup the Color&size section
            
        }else if(fieldNamesArray.count==1 &&![fieldNamesArray[0] isEqualToString:@"quantity"]){
            [timer invalidate];
            timer = nil;
            [activityIndicator stopAnimating];
            [coverView removeFromSuperview];
            self.navigationController.navigationBar.userInteractionEnabled = YES;
            self.navigationController.view.userInteractionEnabled = YES;
            [self performSegueWithIdentifier:@"chooseColorSizeSegue" sender:self];//popup the Color&size section
        }
        else{
            [timer invalidate];
            timer = nil;
            [activityIndicator stopAnimating];
            [coverView removeFromSuperview];
            self.navigationController.navigationBar.userInteractionEnabled = YES;
            self.navigationController.view.userInteractionEnabled = YES;
            
            //            NSLog(@"%ld",[relevantPostsArray count]);
            BOOL isEmpty = ([relevantPostsArray count] == 0);
            if(isEmpty){
                //POST ShopAddToCart API
                //                NSLog(@"%@",aProductId);
                ServiceLayer *aService = [[ServiceLayer alloc]init];
                [aService postShopAddToCart:[self shopAddParametersDict] completion:^(NSDictionary *dictionary) {
                    aCartBtn.userInteractionEnabled=NO;
                    aCartBtn.alpha = 0.5;
                    [self setupCustomBarButtonItem];
                }];
            }else{
                //POST DiscoverAddToCart API
                ServiceLayer *aService = [[ServiceLayer alloc]init];
                [aService postAddToCart:[self formatedParametersDict] completion:^(NSDictionary *dictionary) {
                    aCartBtn.userInteractionEnabled=NO;
                    aCartBtn.alpha = 0.5;
                    //                    NSLog(@"dict :%@",dictionary);
                    [self setupCustomBarButtonItem];
                }];
            }
        }
    }else if (count >=3){
        timesUp = YES;
        [self loadStockView];
        
        scrollView.frame = CGRectMake(0,60, self.view.frame.size.width,320);
        scrollView.scrollEnabled=NO;
        
        aBgScrollVw.contentSize=CGSizeMake(self.view.frame.size.width,900);
        [aBgScrollVw addSubview:scrollView];
        
        aCartBtn.enabled = NO;
        aCartBtn.alpha = 0.5;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        self.navigationController.view.userInteractionEnabled = YES;
        
    }
}

-(void)loadProductDetail{
    
    [[[ServiceLayer alloc] init] getProductDetailsWithProductId:aProductId completion:^(NSDictionary *aDict) {
        if ([productDetailDict count]>0) {
            [productDetailDict removeAllObjects];
        }
        productDetailDict = [aDict mutableCopy];
        //[activityIndicator stopAnimating];
        isInStock = [productDetailDict[@"inStock"]boolValue];
        NSDictionary *twoTapDataDict = productDetailDict[@"twoTapData"];
        //        if ([twoTapDataDict count]>0) {
        //            [activityIndicator stopAnimating];
        //        }
        NSDictionary *sitesdict = twoTapDataDict[@"sites"];
        NSDictionary *cart_dict = [sitesdict objectForKey:[[sitesdict allKeys] objectAtIndex:0]];
        NSDictionary *addToCart = cart_dict[@"add_to_cart"];
        NSDictionary *shippingOption = cart_dict[@"shipping_options"];
        cheapShipping = [shippingOption valueForKey:@"cheapest"];
        likeAction = [productDetailDict[@"socialActionUserProduct"] valueForKey:@"liked"];
        //TwoTapFailedCart:
        //failedCart = cart_dict[@"failed_to_add_to_cart"];//Fail to add to cart
        NSDictionary *dict = [addToCart objectForKey:[[addToCart allKeys] objectAtIndex:0]];
        twoTapDictionary = dict;
        
        NSDictionary *fieldDict = [dict objectForKey:@"required_field_values"];
        NSArray *array  = [fieldDict objectForKey:@"color"];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = obj;
            [aColorArray addObject:[dict valueForKey:@"text"]];
            NSDictionary *sizeDict = [dict objectForKey:@"dep"];
            NSMutableArray *sizeArray = [sizeDict objectForKey:@"size"];
            [sizeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict2 = obj;
                [aSizeArray addObject:[dict2 valueForKey:@"value"]];
            }];
            *stop = YES;
        }];
        imgsArray = [dict objectForKey:@"alt_images"];
        fieldNamesArray = [dict objectForKey:@"required_field_names"];
        fieldName0 = [fieldNamesArray objectAtIndex:0];
    }];
//    [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
//        [self setupCustomBarButtonItem];
//    }];
}

-(PDPAddToCartModel*)getAddtocartModel:(NSDictionary*)productDict{
    
    ServiceLayer *aService = [[ServiceLayer alloc] init];
    
    userId = [aService getUserId];
    NSString* aUserIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    
    PDPAddToCartModel *aModel = [[PDPAddToCartModel alloc] init];
    aModel.userId = aUserIdStr;
    aModel.productId = productDict[@"id"];
    aModel.productMetadata_productId =productDict[@"id"];
    aModel.mediaId = relevantPostId;
    aModel.visualTagId = visualTagId;
    aModel.productMetadata_option = @" ";
    aModel.productMetadata_fit = @" ";
    aModel.productMetadata_color = @" ";
    aModel.productMetadata_size = @" ";
    aModel.productMetadata_options = @" ";
    aModel.productMetadata_inseam = @" ";
    aModel.productMetadata_style = @" ";
    aModel.productMetadata_option1 = @" ";
    aModel.productMetadata_option2 = @" ";
    aModel.productMetadata_option3 = @" ";
    aModel.productMetadata_option4 = @" ";
    //aModel.price = productDict[@"finalPrice"];
    NSString *priceWOSign = [[twoTapDictionary valueForKey:@"price"] stringByReplacingOccurrencesOfString:@"$" withString:@""];
    aModel.price = priceWOSign;
    aModel.productMetadata_availability = @"AVAILABLE";
    aModel.quantity = @"1";
    
    NSDictionary *sitesdict = [[productDict objectForKey:@"twoTapData"] objectForKey:@"sites"];
    NSDictionary *shipping_options = [sitesdict objectForKey:[[sitesdict allKeys] objectAtIndex:0]];
    NSString *shippingOption = [[shipping_options objectForKey:@"shipping_options"] valueForKey:@"cheapest"];
    //    NSLog(@"shippingOption :%@",shippingOption);
    
    aModel.shippingMethod = shippingOption;
    aModel.originalUrl = productDict[@"buyURL"];
    
    return aModel;
}

-(void)loadCoverView{
    
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.navigationController.view.userInteractionEnabled = NO;
    
    coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+500)];
    coverView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    
    UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 80)];
    loadingView.center = aBgScrollVw.center;
    loadingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    [loadingView.layer setCornerRadius:5.0f];
    
    UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 25, loadingView.bounds.size.width-10, 60)];
    loadingLabel.text = [NSString stringWithFormat:@"Getting updated inventory from the retailer"];
    loadingLabel.numberOfLines = 2;
    loadingLabel.lineBreakMode = NSLineBreakByCharWrapping;
    //loadingLabel.lineBreakMode = UILineBreakModeWordWrap;
    loadingLabel.textColor = [UIColor whiteColor];
    [loadingLabel setFont:[UIFont fontWithName:@"Gill Sans" size:18]];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.backgroundColor = [UIColor clearColor];
    
    //if (!activityIndicator) {
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake(0, 5, self.view.frame.size.width-40, 40);
    activityIndicator.backgroundColor = [UIColor clearColor];
    [activityIndicator startAnimating];
    // }
    [loadingView addSubview:loadingLabel];
    [loadingView addSubview:activityIndicator];
    [coverView addSubview:loadingView];
    [aBgScrollVw addSubview:coverView];
}



#pragma mark - Button Clicks
-(void)doneButtonClicked:(UIBarButtonItem *)sender {
    aProductId = nil;
    productDetailDict = nil;
    [productDetailDict removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark UITableView Delegates
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return menuArray.count;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(otherExpand==section){
        if(section==0){
            return  ExpArr.count;
        }if(section==2){
            return   ExpArr.count;
        }else{
            return  cerArray.count;
        }
    }
    return  0;
}

-(BOOL)tableView:(UITableView *)table canCollapse:(NSIndexPath *)indexPath{
    return NO;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    webheight=0;
    static NSString *Identifier=@"Cell";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    if(indexPath.section==0){
        myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width , cell.bounds.size.height)];
        myWebView.tag = indexPath.row;
        myWebView.userInteractionEnabled = NO;
        myWebView.delegate=self;
        myWebView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:myWebView];
        [myWebView loadHTMLString:[NSString stringWithFormat:@"<html><body style=\"; font-size: 16; font-family: Gill Sans; color: #808080\">%@</body></html>", [productDetailDict valueForKey:@"description"]] baseURL: nil];
        CGSize mWebViewTextSize = [myWebView sizeThatFits:CGSizeMake(1.0f, 1.0f)];
        CGRect mWebViewFrame = myWebView.frame;
        mWebViewFrame.size.height = mWebViewTextSize.height;
        myWebView.frame = mWebViewFrame;
        webheight=myWebView.frame.size.height;
        cell.contentView.frame=myWebView.frame;
        webheight=cell.contentView.frame.size.height;
    }
    if(indexPath.section==1){
        [self performSegueWithIdentifier:@"chooseColorSizeSegue" sender:self];
        
    }
    if(indexPath.section==2){
        webheight = 0;
        CGRect tableFrame = self.menuTableView.bounds;
        tableFrame.origin.y = aBrandview.frame.origin.y+aBrandview.frame.size.height;
        self.menuTableView.frame = tableFrame;
        UICollectionView *collectionView = [self createCollectionView];
        [cell.contentView addSubview:collectionView];
        webheight = collectionView.frame.size.height;
    }
    
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    //NSLog(@"%lu",fieldNamesArray.count);
    if(section==1){
        if(fieldNamesArray.count > 1){
            if ([qualityStr isEqualToString:@"LOW"]){
                return 50;
            }else{
                return 50;
            }
        }else if(fieldNamesArray.count==1 &&![fieldNamesArray[0] isEqualToString:@"quantity"]){
            return 50;
        }else{
            return 0;
        }
    }else if(section==2){
        if(relevantPostsArray.count==0){
            return 0;
        }else{
            return 50;
        }
    }else{
        return 50;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return webheight;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view1=[[UIView alloc]initWithFrame:CGRectMake(0, 5, tableView.frame.size.width, 50)];
    
    view1.layer.borderWidth=3;
    view1.layer.borderColor=[UIColor whiteColor].CGColor;
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, tableView.frame.size.width, 50);
    btn.backgroundColor=[UIColor appBackgroundColor];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:[menuArray objectAtIndex:section] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.font = [UIFont fontWithName:@"Gill Sans" size:16.0];
    btn.tag=section;
    [btn addTarget:self action:@selector(Btntap:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *img=[UIImage imageNamed:@"Add.png"];
    [btn setImage:img forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0., btn.frame.size.width - (img.size.width + 15.), 0., 0.);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., img.size.width);
    [view1 addSubview:btn];
    
    if(section==2 && loadone==nil){
        loadone = @"loaded";
        [self Btntap:btn];
    }
    return view1;
}

-(void)Btntap : (UIButton *)btn
{
    if(otherExpand!=100)
    {
        if (otherExpand==btn.tag)
        {
            NSMutableArray *tempArr2=[[NSMutableArray alloc]init];
            for(int j=0;j<[[sectionsArray objectAtIndex:btn.tag]count];j++)
            {
                NSIndexPath *indexx1=[NSIndexPath indexPathForRow:j inSection:otherExpand];
                [tempArr2 addObject:indexx1];
            }
            checker=0;
            otherExpand=100;
            [menuTableView deleteRowsAtIndexPaths:tempArr2 withRowAnimation:UITableViewRowAnimationAutomatic];
            CGFloat height = 50;
            height *= menuArray.count;
            
            CGRect tableFrame = self.menuTableView.bounds;
            tableFrame.origin.x = 0;
            tableFrame.origin.y = aBrandview.frame.origin.y+aBrandview.frame.size.height;
            tableFrame.size.height = height;
            self.menuTableView.frame = tableFrame;
            menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            menuTableView.delegate=self;
            menuTableView.dataSource=self;
            [self.menuTableView reloadData];
            aBgScrollVw.contentSize =CGSizeMake(self.view.frame.size.width,ypos-30);
        }
        else
        {
            NSMutableArray *tempArr2=[[NSMutableArray alloc]init];
            for(int j=0;j<[[sectionsArray objectAtIndex:btn.tag]count];j++)
            {
                NSIndexPath *indexx1=[NSIndexPath indexPathForRow:j inSection:otherExpand];
                [tempArr2 addObject:indexx1];
            }
            checker=1;
            otherExpand=100;
            
            CGFloat height = 50;
            height *= tempArr2.count;
            CGRect tableFrame = self.menuTableView.bounds;
            tableFrame.origin.x = 0;
            tableFrame.origin.y = aBrandview.frame.origin.y+aBrandview.frame.size.height;
            tableFrame.size.height = height;
            menuTableView.frame = tableFrame;
            menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            menuTableView.delegate = self;
            menuTableView.dataSource = self;
            [self.menuTableView reloadData];
            aBgScrollVw.contentSize =CGSizeMake(self.view.frame.size.width,ypos-30);
        }
    }
    
    if(checker!=0)
    {
        otherExpand=(int)btn.tag;
        NSMutableArray *tempArr=[[NSMutableArray alloc]init];
        for(int i=0;i<[[sectionsArray objectAtIndex:btn.tag]count];i++)
        {
            NSIndexPath *indexx=[NSIndexPath indexPathForRow:i inSection:btn.tag];
            [tempArr addObject:indexx];
        }
        [menuTableView insertRowsAtIndexPaths:tempArr withRowAnimation:UITableViewRowAnimationAutomatic];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        
        CGFloat height = 50;
        height *= menuArray.count+tempArr.count;
        CGRect tableFrame = self.menuTableView.bounds;
        tableFrame.origin.x = 0;
        tableFrame.origin.y = aBrandview.frame.origin.y+aBrandview.frame.size.height;
        tableFrame.size.height = height+_collectionView.frame.size.height;
        menuTableView.frame = tableFrame;
        menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        aBgScrollVw.contentSize =CGSizeMake(self.view.frame.size.width,aHeight+menuTableView.frame.size.height-150);
        //        UIImage *minImg = [UIImage imageNamed:@"minus"];
        //        UIImage *minusImg = [minImg
        
        
        if ([btn.currentImage isEqual:[UIImage imageNamed:@"Add.png"]])
        { [btn setImage:[UIImage imageNamed:@"minus"] forState:UIControlStateNormal];
            btn.tintColor = [UIColor blackColor];
        }
        else if ([btn.currentImage isEqual:[UIImage imageNamed:@"minus"]])
        { [btn setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
            btn.tintColor = [UIColor blackColor];
        }
        
        checker=1;
    }
    checker=100;
}

-(void)aCloseMethod:(id)sender{
    otherExpand = 100;
    [menuTableView reloadData];
    [aSizeView removeFromSuperview];
}

#pragma mark-webviewDelegateMethods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    
    frame.size.height = 5.0f;
    
    webView.frame = frame;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [menuTableView beginUpdates];
    
    webheight=0;
    CGSize mWebViewTextSize = [webView sizeThatFits:CGSizeMake(1.0f, 1.0f)];
    CGRect mWebViewFrame = webView.frame;
    mWebViewFrame.size.height = mWebViewTextSize.height;
    mWebViewFrame.size.width=mWebViewTextSize.width;
    webView.frame = CGRectMake(0, 0, mWebViewFrame.size.width ,   mWebViewFrame.size.height );
    webheight= webView.frame.size.height;
    menuTableView.frame=CGRectMake(menuTableView.frame.origin.x, menuTableView.frame.origin.y, menuTableView.frame.size.width, webheight+menuArray.count*50);
    aBgScrollVw.contentSize =CGSizeMake(self.view.frame.size.width,menuTableView.frame.origin.y+menuTableView.frame.size.height+20);
    [menuTableView endUpdates];
}


#pragma mark UICollectionView Delegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [relevantPostsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    UIView*  containerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.width/2+50)];
    containerView.layer.borderColor = [UIColor grayColor].CGColor;
    UIImageView *recipeImageView = [[UIImageView alloc]init];
    recipeImageView.frame=CGRectMake(2, 25, self.view.frame.size.width/2-5, self.view.frame.size.width/2-5);
    recipeImageView.contentMode = UIViewContentModeScaleAspectFit;
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
//        NSLog(@"THE URL%@", [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"lowResolutionURL"]);
        
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"lowResolutionURL"]]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            recipeImageView.image = [UIImage imageWithData:data];
        });
    });
    
    //    NSLog(@"%@",relevantPostId);
    recipeImageView.tag = 10000;
    recipeImageView.userInteractionEnabled = YES;
    [containerView addSubview:recipeImageView];
    
    UIImageView *aProfilePicImg =[[UIImageView alloc] initWithFrame:CGRectMake(5,10,29,29)];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        NSDictionary *mediaDict = [relevantPostsArray objectAtIndex:indexPath.row];
        
        NSData * data;
        
        if ([[mediaDict objectForKey:@"mediaSource"] isEqualToString:@"IG"]) {
            data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"instagramUserProfileUrl"]]];
        } else {
            data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"fountUserProfileUrl"]]];
        }
        
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            aProfilePicImg.image = [UIImage imageWithData:data];
            
        });
    });
    [containerView addSubview:aProfilePicImg];
    
    UILabel* aUserNameLbl=[[UILabel alloc]initWithFrame:CGRectMake(40, 2, self.view.frame.size.width/2-5, 20)];
    
    NSDictionary *relArrDict = [relevantPostsArray objectAtIndex:indexPath.row];
    
    if ([[relArrDict objectForKey:@"mediaSource"] isEqualToString:@"IG"] ) {
        aUserNameLbl.text=[NSString stringWithFormat:@"%@",[[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"instagramUserName"]];
    } else {
        aUserNameLbl.text=[NSString stringWithFormat:@"%@",[[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"fountUserName"]];
    }
    
    
    
    aUserNameLbl.textAlignment=NSTextAlignmentLeft;
    aUserNameLbl.font = [UIFont fontWithName:@"Gill Sans" size:12.0f];
    aUserNameLbl.textColor=[UIColor darkGrayColor];
    aUserNameLbl.backgroundColor=[UIColor clearColor];
    [containerView addSubview:aUserNameLbl];
    
    [cell addSubview:containerView];
    
    float newHeight = _collectionView.collectionViewLayout.collectionViewContentSize.height;
    _collectionView.frame=CGRectMake(0, 0, self.view.frame.size.width, newHeight);
    menuTableView.frame=CGRectMake(menuTableView.frame.origin.x, aBrandview.frame.origin.y+aBrandview.frame.size.height, menuTableView.frame.size.width, newHeight+menuArray.count*50);
    aBgScrollVw.contentSize =CGSizeMake(self.view.frame.size.width,menuTableView.frame.origin.y+menuTableView.frame.size.height-100);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MediaDetail" bundle:nil];
//    MediaDetailCollectionViewController *MediaVC = [storyBoard instantiateInitialViewController];
//    
//    NSDictionary *mediaDictionary = relevantPostsArray[indexPath.row];
    
//    MediaVC.media = [Media new];
//    Media *media = [[Media alloc] initWithDictionary:mediaDictionary];
//
//    MediaVC.media = media;
    
//    MediaVC.media.mediaId = [[[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"id"] intValue];
//    MediaVC.media.standardResolutionURL = [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"standardResolutionURL"];
//    MediaVC.media.instagramProfileURL = [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"instagramUserProfileUrl"];
//    MediaVC.media.caption = [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"caption"];
//    MediaVC.media.likes = (int)[[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"likes"];
//    MediaVC.media.liked = [[[relevantPostsArray objectAtIndex:indexPath.row] objectForKey:@"socialActionUserMedia"] valueForKey:@"liked"];
//    MediaVC.media.instagramUserName = [[relevantPostsArray objectAtIndex:indexPath.row] valueForKey:@"instagramUserName"];
    
//    MediaVC.presentedModally = YES;
    //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:MediaVC];
    //    [self.navigationController presentViewController:nav animated:YES completion:nil];
//    [self.navigationController pushViewController:MediaVC animated:YES];
}


#pragma mark Collection view layout things
// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize mElementSize = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.width/2+20);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    collectionView.backgroundColor = [UIColor clearColor];
    return 3.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5,0,5,0);  // top, left, bottom, right
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"chooseColorSizeSegue"]) {
        
        [ServiceLayer googleTrackEventWithCategory:kEventCategoryAddToCart actionName:kEventActionAddToCart label:kEventLabelGoingToOptionsSelection value:1];
        
        SelectColorAndSizeViewController *vc = [segue destinationViewController];
        TwoTapModel *model = [TwoTapModel new];
        [model setupWithDictionary:twoTapDictionary];
        vc.dataSource = model;
        vc.aModel = [self getAddtocartModel:productDetailDict];
        vc.mediaArray = relevantPostsArray;
        vc.fieldName0 = fieldName0;
        vc.qualityStr = qualityStr;
        NSDictionary *sellerArray = productDetailDict[@"seller"];
        NSString *sellerName = [sellerArray valueForKey:@"name"];
        vc.sellerName = sellerName;
        vc.buyURL = [productDetailDict valueForKey:@"buyURL"];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDismissColorSizeVC) name:@"ColorSizeVCDismissed" object:nil];
        //vc.hidesBottomBarWhenPushed= YES;
        if(self.fromOut==YES){
            [[[UIApplication sharedApplication] keyWindow] insertSubview:self.view atIndex:1];
            
        }else{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFromNoticePage"]){
                [[[UIApplication sharedApplication] keyWindow] insertSubview:self.view atIndex:1];
            }else{
                [[[UIApplication sharedApplication] keyWindow] insertSubview:self.view atIndex:0];

            }
        }
    }
    else if ([[segue identifier] isEqualToString:@"webViewSegue"]){
        
        [ServiceLayer googleTrackEventWithCategory:kEventCategoryAddToCart actionName:kEventActionAddToCart label:kEventLabelGoingToWeb value:1];
        
        WebViewController *destController=[segue destinationViewController];
        destController.buyURLStr = [productDetailDict valueForKey:@"buyURL"];
        
//        NSLog(@"WEB URL:%@", [productDetailDict valueForKey:@"buyURL"]);
        
        destController.sellerName = [[productDetailDict objectForKey:@"seller"] valueForKey:@"name"];
        //        NSLog(@"%@",destController.buyURLStr);
        destController.hidesBottomBarWhenPushed = YES;
    }
}

-(void)didDismissColorSizeVC{
    [self setupCustomBarButtonItem];
    aCartBtn.userInteractionEnabled=NO;
    aCartBtn.alpha = 0.5;
}

-(NSDictionary*)formatedParametersDict{
    //    NSLog(@"%@",[productDetailDict valueForKey:@"buyURL"]);
    NSString *userIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    //    NSLog(@"%@ /// %@",relevantPostId,visualTagId);
    //    NSLog(@"%@",cheapShipping);
    NSDictionary *parameters = @{@"user[id]": userIdStr,
                                 @"product[id]":aProductId ,
                                 @"media[id]":relevantPostId,
                                 @"visualTag[id]":visualTagId,
                                 @"productMetadata[product][id]":aProductId,
                                 @"productMetadata[option]":[NSNull null] ,
                                 @"productMetadata[fit]":[NSNull null] ,
                                 @"productMetadata[color]":[NSNull null] ,
                                 @"productMetadata[size]":[NSNull null],
                                 @"productMetadata[options]":[NSNull null],
                                 @"productMetadata[inseam]":[NSNull null] ,
                                 @"productMetadata[style]": [NSNull null],
                                 @"productMetadata[option1]":[NSNull null],
                                 @"productMetadata[option2]":[NSNull null] ,
                                 @"productMetadata[option3]":[NSNull null] ,
                                 @"productMetadata[option4]":[NSNull null] ,
                                 //@"productMetadata[price]":[productDetailDict valueForKey:@"finalPrice"] ,
                                 @"productMetadata[price]":[twoTapDictionary valueForKey:@"price"]?[[twoTapDictionary valueForKey:@"price"] stringByReplacingOccurrencesOfString:@"$" withString:@""]:[NSNull null],
                                 @"productMetadata[availability]":@"AVAILABLE",
                                 @"quantity":@"1" ,
                                 @"shippingMethod":(cheapShipping) ? cheapShipping : [NSNull null],
                                 @"originalUrl":[productDetailDict valueForKey:@"buyURL"],
                                 };
    
    NSLog(@"FORMATTED PARAM:%@", parameters);
    
    return parameters;
}

-(NSDictionary*)shopAddParametersDict{
    //    NSLog(@"%@",[productDetailDict valueForKey:@"buyURL"]);
    NSString *userIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    //    NSLog(@"%@",cheapShipping);
    NSDictionary *parameters = @{@"user[id]": userIdStr,
                                 @"product[id]":aProductId ,
                                 @"productMetadata[product][id]":aProductId,
                                 @"productMetadata[option]":[NSNull null] ,
                                 @"productMetadata[fit]":[NSNull null] ,
                                 @"productMetadata[color]":[NSNull null] ,
                                 @"productMetadata[size]":[NSNull null],
                                 @"productMetadata[options]":[NSNull null],
                                 @"productMetadata[inseam]":[NSNull null] ,
                                 @"productMetadata[style]": [NSNull null],
                                 @"productMetadata[option1]":[NSNull null],
                                 @"productMetadata[option2]":[NSNull null] ,
                                 @"productMetadata[option3]":[NSNull null] ,
                                 @"productMetadata[option4]":[NSNull null] ,
                                 //@"productMetadata[price]":[productDetailDict valueForKey:@"finalPrice"] ,
                                 @"productMetadata[price]":[twoTapDictionary valueForKey:@"price"]?[[twoTapDictionary valueForKey:@"price"] stringByReplacingOccurrencesOfString:@"$" withString:@""]:[NSNull null],
                                 @"productMetadata[availability]":@"AVAILABLE",
                                 @"quantity":@"1" ,
                                 @"shippingMethod":(cheapShipping) ? cheapShipping : [NSNull null],
                                 @"originalUrl":[productDetailDict valueForKey:@"buyURL"],
                                 };
    
    return parameters;
}

-(void) brandNameTapped:(UITapGestureRecognizer *) recognizer {
    
    NSInteger brandId = (int)[[[productDetailDict objectForKey:@"brand"]valueForKey:@"id"]integerValue];
//    NSString *entityName = [[productDetailDict objectForKey:@"brand"]valueForKey:@"entityName"];
    NSString *brandName = [[productDetailDict objectForKey:@"brand"]valueForKey:@"name"];
    
//    PublicProfileViewController *publicProfileVC = [[PublicProfileViewController alloc] initWithBrandId:brandId];
//    publicProfileVC.displayName = brandName;
//    [self.navigationController pushViewController:publicProfileVC animated:YES];
}

-(void)attributedPriceText:(NSString *)str{
    
    
}

-(NSString *)abbreviateNumber:(int)num withDecimal:(int)dec {
    
    NSString *abbrevNum;
    float number = (float)num;
    if(num>1000){
        NSArray *abbrev = [[NSArray alloc]initWithObjects:@"K", @"M", @"B",nil];
        
        for (int i=(int)abbrev.count-1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Here, we multiply by decPlaces, round, and then divide by decPlaces.
                // This gives us nice rounding to a particular decimal place.
                number = round(number*dec/size)/dec;
                
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
                
                //                NSLog(@"%@", abbrevNum);
                
            }
            
        }
    }else{
        
        abbrevNum = [NSString stringWithFormat:@"%D Likes",(int)number];
    }
    
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48 || c == 46) { // 0 or .
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
    }
    
    return ret;
}

#pragma marks - Button Action
//More Likes Clicked
-(void)moreLikesClicked:(id)sender{
    LikesPeopleTableViewController *tableVc = [[LikesPeopleTableViewController alloc]init];
    tableVc.likesPeopleInfoArray = likesPeopleInfoArray;
    tableVc.productId=aProductId;
    [self.navigationController pushViewController:tableVc animated:YES];
}

-(void)profileImageTapped:(UITapGestureRecognizer *) recognizer{
    
//    NSString *mediaOwnerName = [[[productDetailDict valueForKey:@"likedUsers"] objectAtIndex:recognizer.view.tag]valueForKey:@"fountUserDisplayName"];
//    
//    NSInteger userIdToUse = [[[[productDetailDict valueForKey:@"likedUsers"] objectAtIndex:recognizer.view.tag]valueForKey:@"fountUserId"] integerValue];

//    PublicProfileViewController *publicProfileVC = [[PublicProfileViewController alloc] initWithUserId:userIdToUse];
//    publicProfileVC.displayName = mediaOwnerName;
//    [self.navigationController pushViewController:publicProfileVC animated:YES];
}

//Direct Message Product Button Clicked
-(void)dmMessageButtonClicked:(id)sender{
    
    [ServiceLayer googleTrackEventWithCategory:@"ProductDetailPage Direct Message button" actionName:@"ProductDetailPage Direct Message button clicked" label:nil value:1];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
//    DirectMessageViewController *directMessageVC = [storyboard instantiateViewControllerWithIdentifier:@"DirectMessage"];
//    directMessageVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    directMessageVC.productDetailDictionary = productDetailDict;
//    [self.navigationController presentViewController:directMessageVC animated:YES completion:nil];
}

-(void)shareButtonclicked:(id)sender{
    //    NSLog(@"%@",productDetailDict);
    
    NSString *productName = [productDetailDict valueForKey:@"name"];
    NSString *productId = [productDetailDict valueForKey:@"id"];
    NSString *productName1 = [productName stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    NSString *finalProductName = [productName1 stringByReplacingOccurrencesOfString:@" " withString: @"-"];
    
    NSString *textToShare = @"Check out this item I found on Fount!";
    NSString *urlLink =[NSString stringWithFormat:@"\nhttps://fountit.com/lifestyle/pdl/%@_%@",finalProductName, productId];
//    NSURL *myWebLink = [NSURL URLWithString:[urlLink stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSArray *objectsToShare;
    
    //Product Image:
    UIImage *sharedImg;
    NSString *imageString = [productDetailDict valueForKey:@"imageURL"];
    
    if (imageString == nil) {
        objectsToShare = @[textToShare,@"\r",urlLink];
    }else{
      //  NSLog(@"%@",[imgsArray objectAtIndex:0]);
        NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[productDetailDict valueForKey:@"imageURL"]]];
        //NSURL *imageUrl = [NSURL URLWithString:[productDetailDict valueForKey:@"imageURL"]];
        sharedImg = [UIImage imageWithData:data];
        objectsToShare = @[textToShare, urlLink, sharedImg];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [activityVC setValue:@"Check out this item I found on Fount!" forKey:@"subject"];
    NSArray *excludeActivity = @[UIActivityTypeSaveToCameraRoll];
    activityVC.excludedActivityTypes = excludeActivity;
    //activityVC.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(void) presentGuestPromptViewController {
//    GuestPromptViewController *guestPromptVC = [[GuestPromptViewController alloc] init];
//    guestPromptVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    
//    [self presentViewController:guestPromptVC animated:YES completion:nil];
}

-(void)rightlikebuttonclicked:(id)sender{
    
    BOOL sessionExists = [[NSUserDefaults standardUserDefaults] boolForKey:kSessionKey];

    if (sessionExists) {

        UIButton *btn = (UIButton*)sender;
        
        if ([btn.currentImage isEqual:[UIImage imageNamed:@"likes"]]){
            [btn setImage:[UIImage imageNamed:@"likesfilled"] forState:UIControlStateNormal];
            btn.tintColor = [UIColor themeColor];
            //        NSLog(@"%@",aProductId);
            [[[ServiceLayer alloc]init]getRecommendProductsWithProductId:aProductId.integerValue completion:^(NSArray *array) {
                //  NSLog(@"%@",array);
            }];
            
            [[[ServiceLayer alloc] init] likeProductWithProductId:[aProductId intValue] completion:^(NSDictionary *dictionary) {
                //            NSLog(@"%@",dictionary);
                NSString *likesStr = [[[[dictionary objectForKey:@"payload"]objectForKey:@"PRODUCT"]valueForKey:@"likes"] stringValue];
                NSString *likes=[NSString stringWithFormat:@"%@ Likes", likesStr];
                [totalLikesBtn setTitle:likes forState:UIControlStateNormal];
            }];
            
        }else{
            [btn setImage:[UIImage imageNamed:@"likes"] forState:UIControlStateNormal];
            btn.tintColor = [UIColor lightGrayColor];
            [[[ServiceLayer alloc] init] unlikeProductWithProductId:[aProductId intValue] completion:^(NSDictionary *dictionary) {
                NSString *likesStr = [[[[dictionary objectForKey:@"payload"]objectForKey:@"PRODUCT"]valueForKey:@"likes"] stringValue];
                NSString *likes=[NSString stringWithFormat:@"%@ Likes", likesStr];
                [totalLikesBtn setTitle:likes forState:UIControlStateNormal];
            }];
        }
        
    } else {

        [self presentGuestPromptViewController];
    }
}

-(void)activateButtonClicked{
    [ServiceLayer googleTrackEventWithCategory:@"SYW Join or Activate Button Clicked" actionName:@"Product Detail Page's SYW Join or Activate Button Clicked" label:nil value:1];
//
//    SYWViewController *syw=[[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"sywView"];
//    self.navigationController.navigationBar.topItem.title = @"Shop Your Way Rewords";
//    [self.navigationController pushViewController:syw animated:YES];
}

-(void)accountButtonClicked{
    [ServiceLayer googleTrackEventWithCategory:@"SYW Account Button Clicked" actionName:@"Product Detail Page's SYW Account Button Clicked" label:nil value:1];
    
//        SYWDetailPageViewController *detail=[[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailPage"];
//        self.navigationController.navigationBar.topItem.title = @"";
//        [self.navigationController pushViewController:detail animated:YES];
}

-(void)refreshView:(NSNotification *) notification{
    if([[notification object]isEqualToString:@"1"]){
        if (self == self.navigationController.topViewController)
            [menuTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
}

//Pull down to get similar products:
-(void) getLatestMedia {
    
    NSString *productName=[productDetailDict valueForKey:@"name"];
    if (!isInStock || timesUp) {
        
        [[[ServiceLayer alloc]init]getSearchedProductsWithKeyword:productName sortyBy:@"relevancy" pageNumber:1 sellerIds:nil categoryIds:nil brandIds:nil priceRangesArray:nil sale:0 availability:@"IN_STOCK" completion:^(NSDictionary *dictionary) {
            
            //        [[[ServiceLayer alloc]init]getSearchedProductsWithKeyword:productName sortyBy:@"relevancy" pageNumber:1 completion:^(NSDictionary *dictionary) {
            //  NSLog(@"product%@",[dictionary valueForKey:@"PRODUCTS"]);
            
            if ([refreshControl isRefreshing]) {
                [refreshControl endRefreshing];
                
                stockDataArray=[dictionary objectForKey:@"PRODUCTS"];
                stock=[self.storyboard instantiateViewControllerWithIdentifier:@"StockId"];
                stock.outOfStockArray=[stockDataArray mutableCopy];
                stock.pdpProductName = productName;
                [self.navigationController presentViewController:stock animated:YES completion:nil];
                //[self.navigationController pushViewController:stock animated:YES];
            }
        }];
    }else{
        [refreshControl endRefreshing];
    }
    
}

-(NSString *) addCommas:(NSUInteger) numberToFormat {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *numberAsString = [formatter stringFromNumber:[NSNumber numberWithInteger:numberToFormat]];
    NSString *newString = [NSString stringWithFormat:@"%@", numberAsString];
    
    return newString;
}

-(void)appOpenPushReceived:(NSNotification *)notification{
    
    NSDictionary *objectDictionary = [notification valueForKey:@"object"];
    NSInteger sentFromId = [[objectDictionary valueForKey:@"SENT_FROM_ID"]integerValue];
    NSString *notificationType = [objectDictionary valueForKey:@"NOTIFICATION_TYPE"];
    
    if ([notificationType isEqualToString:@"CHAT_MESSAGE_POST"] && sentFromId != userId) {
        
        NSInteger numOfGroupsWithUnreadMsg = [[objectDictionary valueForKey:@"NO_OF_GROUPS_UNREAD_MSG"]integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:numOfGroupsWithUnreadMsg forKey:kNumOfGroupsWithUnreadMsg];
        [self setupCustomBarButtonItem];
    }
}

#pragma mark - Memory Warnings
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
