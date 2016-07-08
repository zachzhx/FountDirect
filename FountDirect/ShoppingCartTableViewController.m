//
//  ShoppingCartTableViewController.m
//  Spree
//
//  Created by Xu Zhang on 10/13/15.
//  Copyright © 2015 Syw. All rights reserved.
//


#import "ShoppingCartTableViewController.h"
#import "ServiceLayer.h"
#import "Constants.h"
#import "UIColor+CustomColors.h"
#import "ShopCartHeaderCell.h"
#import "ShopMainCell.h"
#import "ShopCartProductModel.h"
#import "CartProductModel.h"
#import "CartProductMetaData.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "UIImageView+AFNetworking.h"
#import "CheckOutView.h"
//#import "ProductDetailViewController.h"
#import "ShopCartFooterCell.h"
//#import "ViewAllViewController.h"
#import "Product.h"
#import "ShoppingCartProduct.h"
#import "BaseModel.h"
#import "NSAttributedString+StringStyles.h"
//#import "ShippingAddressViewController.h"
#import <Google/Analytics.h>
#import "EmptyShoppingCartTableViewCell.h"

#import "UIView+CustomStyles.h"
//#import "SYWViewController.h"

@interface ShoppingCartTableViewController () {
    UIRefreshControl* refreshControl;
    NSMutableDictionary *aModelDict;
    NSMutableArray *modelArray;
    NSMutableArray *selctArray;
    NSMutableArray *selctedArryValue;
    NSMutableDictionary *sectionSelectDict;
    UIButton *btnn;
    ShopCartHeaderCell * customHeaderCell;
    ShopCartFooterCell * customFooterCell;
    NSMutableArray *array2; //sellersArray
    CheckOutView    *aFooterVW;
    NSMutableDictionary *productsDict;
    NSMutableArray *Pricearr;
    BOOL myBoolean;
    BOOL editboolean;
    BOOL editAllboolean;
    UIView *view;
    NSMutableDictionary  *editDict;
    NSIndexPath *editIndexPath;
    NSMutableArray *rows;
    NSMutableArray *fullArray;
    NSMutableArray *productIdArray;
    NSString *cartId; //for POST API
    NSMutableArray *cartProductId;//for POST API
    float addition;
    NSMutableArray *checkOutModelArray;
    // Product *aProductModel;
    BOOL isEmpty;
    BOOL isSywConnected;
    UIView *sywBannerView;
}

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *startShoppingButton;

@end

@implementation ShoppingCartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSywConnected = [[[NSUserDefaults standardUserDefaults]valueForKey:kIsSywConnected]boolValue];
    isEmpty = 0;
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 104)];
    self.emptyView.backgroundColor = [UIColor whiteColor];
//    self.emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.emptyView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 260, 260)];
    self.imageView.image = [UIImage imageNamed:@"emptycart"];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.emptyView addSubview:self.imageView];
    
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 340, 60)];
    self.label.numberOfLines = 2;
    self.label.textColor = [UIColor themeColor];
    self.label.font = [UIFont fontWithName:@"GillSans" size:18.0f];
    self.label.text = @"Your shopping cart is empty, but it doesn’t have to be.";
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.emptyView addSubview:self.label];

    self.startShoppingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startShoppingButton.backgroundColor = [UIColor themeColor];
    [self.startShoppingButton setTitle:@"START SHOPPING" forState:UIControlStateNormal];
    self.startShoppingButton.frame = CGRectMake(0, 500, 400, 50);
    self.startShoppingButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.startShoppingButton.titleLabel.font = [UIFont fontWithName:@"GillSans" size:18.0f];
    [self.startShoppingButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [UIView addRoundedCornerToView:self.startShoppingButton];
    
    [self.emptyView addSubview:self.startShoppingButton];
    
    NSDictionary *viewsDictionary = @{@"emptyView": self.emptyView, @"imageView": self.imageView, @"label": self.label, @"button": self.startShoppingButton};
    
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(200)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(200)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    [self.imageView addConstraints:constraint_H];
    [self.imageView addConstraints:constraint_V];
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[imageView]-20-[label]-20-[button]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:self.emptyView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.emptyView addConstraint:xCenterConstraint];
    
    [self.emptyView addConstraints:constraint_POS_V];
    
    //Label Constraints
    
    NSLayoutConstraint *labelXCenterConstraint = [NSLayoutConstraint constraintWithItem:self.emptyView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.label attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.emptyView addConstraint:xCenterConstraint];
    
    NSArray *labelWidthConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(220)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    [self.emptyView addConstraint:labelXCenterConstraint];
    [self.emptyView addConstraints:labelWidthConstraint];
    
    //Button Constraint
    NSArray *buttonConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[button]-20-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    
    [self.emptyView addConstraints:buttonConstraint_POS_H];
    
    NSArray *buttonHeightConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(50)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    [self.startShoppingButton addConstraints:buttonHeightConstraint];
    
    self.emptyView.hidden = YES;
    
    [self loadMethod];
    
    //Remove back button's text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //SYW Activate Top View
    if (!isSywConnected && !isEmpty) {
        sywBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        sywBannerView.backgroundColor=[UIColor colorFromHexString:@"#f8f8f8"];
        
        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [joinButton addTarget:self action:@selector(joinButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [joinButton setTitle:@"Join or Activate" forState:UIControlStateNormal];
        joinButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        joinButton.backgroundColor=[UIColor colorFromHexString:@"#4ad1c0"];
        [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        joinButton.frame = CGRectMake(self.view.frame.size.width-95, 10, 90, 30);
        joinButton.layer.cornerRadius = 15;
        [sywBannerView addSubview:joinButton];
        
        UIImageView *sywImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sywlogo"]];
        sywImageView.frame = CGRectMake(5, 5, 65, 40);
        sywImageView.contentMode = UIViewContentModeScaleAspectFit;
        [sywBannerView addSubview:sywImageView];
        
        CGFloat labelPartWidth = joinButton.frame.origin.x - sywImageView.frame.size.width -10;
        UILabel *noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(sywImageView.frame.size.width+10, 3, labelPartWidth-10, 20)];
        noticeLabel.font = [UIFont boldSystemFontOfSize:12];
        //noticeLabel.backgroundColor = [UIColor greenColor];
        noticeLabel.text = @"Account not activated";
        noticeLabel.textColor = [UIColor grayColor];
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        [sywImageView addSubview:noticeLabel];
        
        
        UILabel *noticeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(sywImageView.frame.size.width+10, 18, labelPartWidth-10, 25)];
        noticeLabel2.font = [UIFont fontWithName:@"Gill Sans" size:10];
        noticeLabel2.minimumScaleFactor = 0.5;
        noticeLabel2.adjustsFontSizeToFitWidth = YES;
        //noticeLabel2.backgroundColor = [UIColor redColor];
        noticeLabel2.text = @"You won't get reward points for this purchase.";
        noticeLabel2.textColor = [UIColor lightGrayColor];
        noticeLabel2.textAlignment = NSTextAlignmentCenter;
        noticeLabel2.numberOfLines = 2;
        [sywImageView addSubview:noticeLabel2];
        
        self.tableView.tableHeaderView = sywBannerView;
    }
    else{
        [sywBannerView removeFromSuperview];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadView:) name:@"loadView" object:nil];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:kShoppingCartPageName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //Pull Down Refresh
    if (!refreshControl) {
        
        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor whiteColor];
        refreshControl.backgroundColor = [UIColor themeColor];
        [refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    }
    
}

-(void)loadView:(NSNotification *) notification{
    if([[notification object]isEqualToString:@"loading"]){
        [self loadMethod];
    }
}

-(void)loadMethod{
    editIndexPath=[NSIndexPath indexPathForRow:100 inSection:100];
    
    //Bottom Toolbar
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    //Bar Button fixed space:
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    button.customView=[self loadFooterView];
    
    self.toolbarItems = [NSArray arrayWithObjects:button,nil];
    
    //Arrays alocation
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //For navigation bar
    
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"SHOPPING BAG"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //For navigation bar Buttons
    [self setupCustomBarButtonItem];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:239.0 / 255.0 green:235.0 / 255.0 blue:233.0 / 255.0 alpha:1.0];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    //For spinner
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.color = [UIColor themeColor];
    spinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 64);//Center of the frame
    // NSLog(@"%f , %f", self.view.frame.size.width, self.view.frame.size.height);
    spinner.tag = 12; //The tag to identify view objects
    [self.view addSubview:spinner];  //Addsubview:Spinner
    [spinner startAnimating];
    
    //Calling Api
    
    NSInteger userId = [[[ServiceLayer alloc] init] getUserId];
    //NSLog(@"userId :%ld",(long)userId);
    NSString *aUserIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    
    [[[ServiceLayer alloc] init] getShoppingCartProductsWithUserId:aUserIdStr twoTapForceSync:1 completion:^(NSDictionary *aDict){
        
        selctArray = [NSMutableArray array];
        aModelDict = [NSMutableDictionary dictionary];
        modelArray=[[NSMutableArray alloc]init];
        selctedArryValue= [[NSMutableArray alloc]init];
        sectionSelectDict=[[NSMutableDictionary alloc]init];
        checkOutModelArray  = [NSMutableArray array];
        Pricearr=[NSMutableArray array];
        productIdArray = [[NSMutableArray alloc]init];
        cartProductId = [[NSMutableArray alloc]init];
        fullArray = [[NSMutableArray alloc]init];
        rows = [NSMutableArray array];

        NSArray *cartProductsArray = [aDict objectForKey:@"cartProducts"];
        NSArray* reversedArray = [[cartProductsArray reverseObjectEnumerator] allObjects]; //Reverse the order of cart products
        //  NSLog(@"valuestr:%@",[[reversedArray objectAtIndex:0]valueForKey:@"id"]);
        cartId = [aDict valueForKey:@"id"];
        NSMutableArray *allKeys=[[NSMutableArray alloc]init];

        [ShopCartProductModel getProductData:reversedArray];
        
        for (int i=0;i<[reversedArray count];i++) {
            ShopCartProductModel *aProduct=[[ShopCartProductModel getProductData:reversedArray]objectAtIndex:i];
            CartProductModel *aCart = [aProduct.product objectAtIndex:0];
            NSString *key = [aCart.seller valueForKey:@"name"];
            
            [allKeys addObject:key];
            
            NSMutableArray *arr=[[NSMutableArray alloc]init];
            if ([aModelDict objectForKey:key]) {
                arr = [NSMutableArray arrayWithArray:[aModelDict objectForKey:key]];
                
                [arr addObject:aProduct];
                
            } else {
                arr = [NSMutableArray arrayWithObject:aProduct];
            }
            
            [aModelDict setObject:arr forKey:key];
            
            //NSLog(@"modelArray:%@",aModelDict);
            
        }
        //seller Name array
        array2=[[NSMutableArray alloc]init];
        
        /*  for (id obj in allKeys)
         {
         if (![array2 containsObject:obj])
         {
         [array2 addObject: obj];
         }
         }
         */
        
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:allKeys];
        array2 = [orderedSet mutableCopy];
        
        //group the same seller's products together:
        NSMutableArray *array1 = [[NSMutableArray alloc]init];
        
        for (int i=0; i<[array2 count]; i++) {
            array1 = [NSMutableArray arrayWithArray:[aModelDict objectForKey:[array2 objectAtIndex:i]]];
            [aModelDict setObject:array1 forKey:[array2 objectAtIndex:i]];
            // NSLog(@"aModelDict:%@",aModelDict);
        }
        
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        
        for(int i = 0; i < [array2 count]; i++){
            
            NSMutableArray *IdArray = [[NSMutableArray alloc]init];
            arr = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            for(int r = 0; r < [[aModelDict objectForKey:[array2 objectAtIndex:i]] count];r++){
                
                ShopCartProductModel *cart = (ShopCartProductModel*)[[aModelDict objectForKey:[array2 objectAtIndex:i]] objectAtIndex:r];
                
//                NSLog(@"SHOP CART:%tu", cart.productMetadata.productMetadataId);
                
                CartProductModel *model = [cart.product objectAtIndex:0];
                
//                [cartProductId addObject:cart.cartProductId];
                [cartProductId addObject:@(cart.productMetadata.productMetadataId)];
                
//                 NSLog(@" id :%@",model.aId);
                //[arr addObject:model.aFinalPrice];
                [arr addObject:@(cart.productMetadata.price)];
                
                [IdArray addObject:model.aId];
                [dict setValue:@"NO" forKey:[NSString stringWithFormat:@"%d",r]];
            }
            
            [Pricearr addObject:arr];
//             NSLog(@"Pricearr %@",Pricearr);
            [selctedArryValue addObject:dict];
            
            [productIdArray addObject:IdArray];
            [sectionSelectDict setObject:@"NO" forKey:[NSString stringWithFormat:@"%d",i] ];
            
        }
        
        [spinner stopAnimating]; //Once retrieved the data, stops the spinner
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        // self.tableView.allowsMultipleSelectionDuringEditing = YES;
        if(cartProductsArray.count>0){
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [self.tableView reloadData];
            myBoolean=YES;
            [self selectAllMethod:myBoolean];
            [aFooterVW.selectbutton  setImage:[UIImage imageNamed:@"round-fill1x.png"] forState:UIControlStateNormal];
            myBoolean = NO;
            
            self.emptyView.hidden = YES;
            [self setupRightNavButtonItem];
        } else {
            self.emptyView.hidden = NO;
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
}

-(UIView*)loadFooterView{
    //FooterView CGRECTMAKE:
    aFooterVW=[[CheckOutView alloc]initWithFrame:CGRectMake(
                                                            0,0, self.view.frame.size.width, self.navigationController.toolbar.frame.size.height)];
    [aFooterVW.selectbutton addTarget:self action:@selector(selectAllClicked:) forControlEvents:UIControlEventTouchUpInside];
    [aFooterVW.button addTarget:self action:@selector(checkoutClicked) forControlEvents:UIControlEventTouchUpInside];
    [aFooterVW setBackgroundColor:[UIColor colorWithRed:255.0f/255.0 green:255.0f/255.0 blue:255.0f/255.0 alpha:1.0]];
    
    return aFooterVW;
}

-(void)checkoutClicked {
    NSMutableDictionary *selectDict=[[NSMutableDictionary alloc]init];
    // NSLog(@"%ld",[selctedArryValue count]);
    checkOutModelArray = [NSMutableArray new];
    for(int i=0;i<[selctedArryValue count];i++){
        selectDict=[selctedArryValue objectAtIndex:i];
       // NSMutableArray *arr=[[NSMutableArray alloc]init];
        for(NSString *key in [selectDict allKeys]) {
        //    [arr addObject:[selectDict objectForKey:key]];
     //   }
       // for (int r=0; r<[arr count]; r++) {
            
            if([[selectDict objectForKey:key] isEqualToString:@"YES"]){
                
                ShopCartProductModel *cart = (ShopCartProductModel*)[[aModelDict objectForKey:[array2 objectAtIndex:i]] objectAtIndex:[key integerValue]];
                //CartProductModel *model = [cart.product objectAtIndex:0];
                
                ShoppingCartProduct *cartProduct = [[ShoppingCartProduct alloc] init];
                cartProduct.quantity = [cart.quantity integerValue];
                cartProduct.shippingMethod = cart.shippingMethod;
//                cartProduct.shoppingCartProductId = [cart.cartProductId integerValue];
                cartProduct.shoppingCartProductId = cart.productMetadata.productMetadataId;
                cartProduct.product = [[Product alloc] initWithDictionary:cart.productDict];
                [checkOutModelArray addObject:cartProduct];
            }
        }
    }
    
    if (checkOutModelArray.count > 0) {
        [ServiceLayer googleTrackEventWithCategory:@"Shopping Cart to Shipping" actionName:@"Checkout Clicked" label:nil value:1];
        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Checkout" bundle:nil];
//        ShippingAddressViewController *shippingAddressVC = [storyboard instantiateInitialViewController];
//        shippingAddressVC.shoppingCartProductsArray = checkOutModelArray;
//        
//        [self.navigationController pushViewController:shippingAddressVC animated:YES];
    }
}

-(void)selectAllClicked:(id)sender{
    UIButton *Allbtn=(id)sender;
    if(myBoolean)
    {
        [self selectAllMethod:myBoolean];
        [Allbtn  setImage:[UIImage imageNamed:@"round-fill1x.png"] forState:UIControlStateNormal];
        myBoolean = NO;
        
        
    }else{
        [self selectAllMethod:myBoolean];
        [Allbtn  setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
        [self stringAttributed:0.00];
        myBoolean = YES;
        
    }
    
}


-(void)refreshControlAction{
    [ServiceLayer googleTrackEventWithCategory:@"ShoppingCart Pull to refresh" actionName:@"Pull to refresh the page" label:nil value:1];

    [refreshControl endRefreshing];
    [self loadMethod];
    //[self.tableView reloadData];
}

-(void) setupCustomBarButtonItem {
    
    UIButton *leftBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0,0, 24, 24);
    [leftBtn setBackgroundImage:[[UIImage imageNamed:@"backbuttonimage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    leftBtn.tintColor = [UIColor themeColor];
    leftBtn.backgroundColor = [UIColor whiteColor];
    [leftBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *lbarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = lbarBtn;
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor themeColor];
    self.navigationController.navigationBar.translucent = NO;
}

-(void) setupRightNavButtonItem{
    UIButton *btn =  [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0, 60, 35);
    btn.tintColor = [UIColor themeColor];
    btn.titleLabel.font = [UIFont fontWithName:@"Verdana" size:14];
    [btn setTitle:@"Edit all" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(aEditAllClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barBtn;
}

-(void)backClicked{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)aEditAllClicked:(id)sender
{
    UIButton *editAllbutton=(id)sender;
    if([editAllbutton.currentTitle isEqualToString:@"Edit all"]){
        
        [ServiceLayer googleTrackEventWithCategory:@"Edit All" actionName:@"Edit All Clicked" label:nil value:1];
        
        editAllboolean=YES;
        
        editAllbutton.titleLabel.font = [UIFont fontWithName:@"Verdana" size:14];
        [editAllbutton setTitle:@"Save" forState:UIControlStateNormal];
        [editAllbutton setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
        /* editboolean=YES;
         ShopMainCell *cell = nil;
         static NSString *AutoCompleteRowIdentifier = @"ShopMainCell";
         cell = [self.tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
         for (int r=0; r<[[aModelDict allKeys]count]; r++) {
         rows =[aModelDict objectForKey:[[aModelDict allKeys ]objectAtIndex:r]];
         for (int i=0; i<rows.count; i++) {
         editIndexPath=[NSIndexPath indexPathForRow:i inSection:r];
         [self tableView:self.tableView editingStyleForRowAtIndexPath:editIndexPath];
         }
         }*/
        self.tableView.editing=YES;
        [self.tableView reloadData];
    }else{
        editAllboolean=NO;
        
        [editAllbutton setTitle:@"Edit all" forState:UIControlStateNormal];
        /* editIndexPath=[NSIndexPath indexPathForRow:100 inSection:100];
         editboolean=NO;*/
        self.tableView.editing=NO;
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [array2 count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    
//    NSLog(@"COUNT:%tu", [[aModelDict objectForKey:[array2 objectAtIndex:section]]count]);
    return [[aModelDict objectForKey:[array2 objectAtIndex:section]]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if ([[aModelDict objectForKey:[array2 objectAtIndex:indexPath.section]]count] == 0) {
//        
//        EmptyShoppingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCellRI"];
//        
//        return cell;
//        
//    } else {
    
    ShopMainCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"ShopMainCell";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[ShopMainCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //For Image
    ShopCartProductModel *cart = (ShopCartProductModel*)[[aModelDict objectForKey:[array2 objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    CartProductModel *model = [cart.product objectAtIndex:0];
    
    //Image tapped and go to PDP
    cell.aThumbImg.userInteractionEnabled = YES;
    //cart
    cell.aThumbImg.tag = [model.aId integerValue];
    //NSLog(@"tag :%ld",(long)cell.aThumbImg.tag);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapped:)];
    [cell.aThumbImg addGestureRecognizer:tapGesture];
    
    // 1982176,2787174,526068
    CartProductMetaData *metaData = [cart.cartProductMetadata objectAtIndex:0];
    [cell.aSelectBtn addTarget:self action:@selector(rowSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.aSelectBtn addTarget:self action:@selector(rowSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.aSelectBtn.tag =indexPath.row;
    cell.aSelectBtn.superview.tag=indexPath.section;
    [cell.aSelectBtn setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
    NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)cell.aSelectBtn.tag];
    if([[[selctedArryValue objectAtIndex:indexPath.section]valueForKey:tagStr] isEqualToString:@"YES"]){
        [cell.aSelectBtn setImage:[UIImage imageNamed:@"round-fill.png"] forState:UIControlStateNormal];
    }else{
        [cell.aSelectBtn setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
    }
    
    CGFloat price = [metaData.price floatValue];
    NSString *myString = model.name;
    myString = (myString.length > 18) ? [myString substringToIndex:18] : myString;
    cell.brandNameLbl.text = [NSString stringWithFormat:@"%@",myString];
    
    float quantity = [cart.quantity  floatValue];
    float priceVal = price;
    // Multiply them.
    float totalPrice = quantity * priceVal;
    
    NSString *totalPriceText = [NSNumberFormatter localizedStringFromNumber:@(totalPrice)
                                                                numberStyle:NSNumberFormatterCurrencyStyle];
    cell.aPriceLbl.text = [NSString stringWithFormat:@"%@",totalPriceText];
    NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(price)
                                                           numberStyle:NSNumberFormatterCurrencyStyle];
    cell.aQuantityLbl.text = [NSString stringWithFormat:@"%@ * %@",cart.quantity,priceText];
    NSString *colorString = metaData.color;
    colorString = (colorString.length > 18) ? [colorString substringToIndex:18] : colorString;
    cell.aColorLbl.text = colorString?[NSString stringWithFormat:@"Color: %@",colorString]:@"";
    cell.aSizeLbl.text = metaData.size?[NSString stringWithFormat:@"Size: %@",metaData.size]:@"";
    cell.aFitLbl.text = metaData.fit?[NSString stringWithFormat:@"Fit: %@",metaData.fit]:@"";
    cell.aInseamLbl.text = metaData.inseam?[NSString stringWithFormat:@"Inseam: %@",metaData.inseam]:@"";
    if (metaData.option) {
        cell.aColorLbl.text = metaData.option?[NSString stringWithFormat:@"Option: %@",metaData.option]:@"";
    }
    if (metaData.options) {
        cell.aColorLbl.text = metaData.options?[NSString stringWithFormat:@"Options: %@",metaData.options]:@"";
    }
    if (metaData.style) {
        cell.aColorLbl.text = metaData.style?[NSString stringWithFormat:@"Style: %@",metaData.style]:@"";
    }
    if (metaData.option1) {
        cell.aFitLbl.text = metaData.option1?[NSString stringWithFormat:@"%@",metaData.option1]:@"";
    }
    if (metaData.option2) {
        cell.aColorLbl.text = metaData.option2?[NSString stringWithFormat:@"%@",metaData.option2]:@"";
    }
    if (metaData.option3) {
        cell.aSizeLbl.text = metaData.option3?[NSString stringWithFormat:@"%@",metaData.option3]:@"";
    }
    if (metaData.option4) {
        cell.aInseamLbl.text = metaData.option4?[NSString stringWithFormat:@"%@",metaData.option4]:@"";
    }
    
    NSString  *escapedDataString = [[NSString stringWithFormat:@"%@", model.imageURL ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest  *request = [NSURLRequest requestWithURL:[NSURL URLWithString:escapedDataString]];
    __weak UIImageView *thumbImg = cell.aThumbImg;
    [cell.aThumbImg setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"details_placeholder.png"] success:^(NSURLRequest  *request, NSHTTPURLResponse  *response, UIImage  *image)
     {
         thumbImg.image = image;
         thumbImg.layer.borderWidth = 1.0;
         thumbImg.layer.borderColor = [UIColor customLightGrayColor].CGColor;
         
     } failure:^(NSURLRequest * request, NSHTTPURLResponse  *response, NSError  *error) {
     }];
    
    //For Shoping Label
//    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"*%@",cart.shippingMethod]];
//    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
//                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
//                      range:(NSRange){0,[attString length]}];
//    
//    cell.aShopLbl.attributedText = attString;
    
//#warning Change Model.shopperPooints to metaData.shopperPoints
    //For SYW Shopper Points:
    cell.aShopLbl.font = [UIFont fontWithName:@"GillSans-SemiBold" size:12];
    cell.aShopLbl.textColor = [UIColor colorFromHexString:@"#F4B815"];
    //NSLog(@"%@",metaData);
    if (metaData.shopperPoints > 0){
        if (metaData.shopperPoints>10000) {
            NSString *pointsString = [NSString stringWithFormat:@"Earn %@ points",[self abbreviateNumber:metaData.shopperPoints withDecimal:2]];
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:pointsString];
            [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"#f46d15"] range:NSMakeRange(4, pointsString.length-10)];
            cell.aShopLbl.attributedText = attriString;
        }else{
            NSString *pointsString = [NSString stringWithFormat:@"Earn %@ points",[self addCommas:metaData.shopperPoints]];
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:pointsString];
            [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"#f46d15"] range:NSMakeRange(4, pointsString.length-10)];
            cell.aShopLbl.attributedText = attriString;
        }
        // cell.shopperPointsLabel.text = [NSString stringWithFormat:@"Earn %lu points",shoppingCartProduct.product.shopperPoints];
    }else{
        cell.aShopLbl.text = @"";
    }

//    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu",model.shopperPoints]];
//    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
//                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
//                      range:(NSRange){0,[attString length]}];
//    cell.aShopLbl.attributedText = attString;

    
    
    return cell;
//    }
}


#pragma mark - Tap Gesture
-(void) imageTapped:(UITapGestureRecognizer *) recognizer{
//    [self.navigationController setToolbarHidden:YES animated:YES];
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ProductDetail" bundle:nil];
//    ProductDetailViewController *PDPVC = [storyBoard instantiateInitialViewController];
//    PDPVC.aProductId = [NSString stringWithFormat:@"%tu",recognizer.view.tag];
//    PDPVC.fromPush = YES;
//    
//    self.fromNavigate=YES;
//    PDPVC.fromNavigate=self.fromNavigate;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:PDPVC];
//    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

//- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return CGFLOAT_MIN;
    } else {
        return 40;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return CGFLOAT_MIN;
    } else {
        NSArray *shippingArr= [[[aModelDict  valueForKey:[array2 objectAtIndex:section]]valueForKey:@"product"]valueForKey:@"seller"];
        NSString *shippingThreshold = [[[shippingArr objectAtIndex:0]objectAtIndex:0] valueForKey:@"freeShippingThreshold"];
        //NSLog(@"%.2f",shippingThreshold.floatValue);
        if (shippingThreshold.floatValue < 0) {
            return 0;
        }else{
            return 60;
        }
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return [[UIView alloc] initWithFrame:CGRectZero];
        
    } else {
        customHeaderCell = [tableView dequeueReusableCellWithIdentifier:@"ShopCartHeaderCell"];
        customHeaderCell.tag=section;
        customHeaderCell.aSellerNameLbl.text = [array2 objectAtIndex:section];
        customHeaderCell.aSellerNameLbl.textColor = [UIColor themeColor];
        customHeaderCell.aSellerNameLbl.font = [UIFont systemFontOfSize:17];
        customHeaderCell.aSelectBtn.tag = section;
        if(tableView.editing==YES){
            if((editIndexPath.section==section||editAllboolean==YES)){
                [customHeaderCell.editBtn setTitle:@"Save" forState:UIControlStateNormal];
                if(editAllboolean==YES){
                    customHeaderCell.editBtn.userInteractionEnabled=NO;
                }
            }}else{
                [customHeaderCell.editBtn setTitle:@"Edit" forState:UIControlStateNormal];
                customHeaderCell.editBtn.userInteractionEnabled=YES;
            }
        [customHeaderCell.aSelectBtn setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
        if ([[sectionSelectDict objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] isEqualToString:@"YES"]) {
            
            [customHeaderCell.aSelectBtn setImage:[UIImage imageNamed:@"round-fill.png"] forState:UIControlStateNormal];
        }else{
            [customHeaderCell.aSelectBtn setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
        }
        
        
        [customHeaderCell.contentView setBackgroundColor:[UIColor whiteColor]];
        [customHeaderCell.aSelectBtn addTarget:self action:@selector(sectionSelectionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [customHeaderCell.editBtn addTarget:self action:@selector(aEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        customHeaderCell.editBtn.tag = section;
        
        return customHeaderCell.contentView;
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    } else {
        float shippingValue = 0.0;
        NSArray *shippingArr= [[[aModelDict valueForKey:[array2 objectAtIndex:section]]valueForKey:@"product"]valueForKey:@"seller"];
        NSString *shippingThreshold = [[[shippingArr objectAtIndex:0]objectAtIndex:0] valueForKey:@"freeShippingThreshold"];
        if (shippingThreshold.floatValue < 0) {
            return [[UIView alloc] initWithFrame:CGRectZero];
            
        }else{
            customFooterCell = [tableView dequeueReusableCellWithIdentifier:@"ShopCartFooterCell"];
            customFooterCell.contentView.backgroundColor=[UIColor colorFromHexString:@"#97AD33"];
            customFooterCell.tag = section;
            customFooterCell.shopMoreButton.tag = section;
            [customFooterCell.shopMoreButton addTarget:self action:@selector(shopMoreButton:) forControlEvents:UIControlEventTouchUpInside];
            
            NSMutableDictionary *selectDict=[[NSMutableDictionary alloc]init];
            // addition=0;
            for (int r=0; r<=section; r++) {
                addition = 0;
                selectDict=[selctedArryValue objectAtIndex:r];
                NSMutableArray *arr=[[NSMutableArray alloc]init];
                
                for(NSString *key in [selectDict allKeys]) {
                    [arr addObject:[selectDict objectForKey:key]];
                }
                for(int q=0;q<[arr count];q++){
                    //NSLog(@"%.2f",[[[Pricearr objectAtIndex:r]objectAtIndex:q] floatValue]);
                    addition += [[[Pricearr objectAtIndex:r]objectAtIndex:q] floatValue];
                    // NSLog(@"%.2f",addition);
                    if([[arr objectAtIndex:q] isEqualToString:@"YES"]){
                        if (addition >= shippingThreshold.floatValue){
                            shippingValue = 0;
                        }else{
                            shippingValue = shippingThreshold.floatValue - addition;
                        }
                    }
                    else{
                        //  NSLog(@"%.2f",addition);
                        addition -= [[[Pricearr objectAtIndex:r]objectAtIndex:q] floatValue];
                        //  NSLog(@"%.2f",addition);
                        //  NSLog(@"%.2f",[[[Pricearr objectAtIndex:r]objectAtIndex:q] floatValue]);
                        if (addition >= shippingThreshold.floatValue){
                            shippingValue = 0;
                        }else{
                            shippingValue = shippingThreshold.floatValue - addition;
                        }
                    }
                }
            }
            //        NSString *dollarStr = [NSString stringWithFormat:@"$%.2f",addition];
            //        NSString *shippingLabel = [NSString stringWithFormat:@"you are $%.2f from free shipping",addition];
            //        NSMutableAttributedString *attDollarStr = [[NSMutableAttributedString alloc]initWithString:shippingLabel];
            //        [attDollarStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gill Sans Bold" size:12] range:NSMakeRange(8, [dollarStr length])];
            //        customFooterCell.shippingFeeLabel.attributedText = attDollarStr;
            
            if (shippingValue == 0) {
                //customFooterCell.shippingFeeLabel.text = @"you are eligible for free shipping.*";
                NSString *sample=@"you are eligible for free shipping.*";
                NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",sample]];
                NSString *boldString = @"free shipping";
                NSRange boldRange = [sample rangeOfString:boldString];
                [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"GillSans-Bold" size:11] range:boldRange];
                [customFooterCell.shippingFeeLabel setAttributedText: yourAttributedString];
            }else{
                NSString *sample =[NSString stringWithFormat:@"you are $%.2f from free shipping.*",shippingValue];
                
                NSRange range1 = [sample rangeOfString:@"free shipping"];
                NSRange range2 = [sample rangeOfString:[NSString stringWithFormat:@"$%.2f",shippingValue]];
                
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:sample];
                
                [attributedText addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"GillSans-Bold" size:12] range:range1];
                
                [attributedText addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"GillSans-Bold" size:12] range:range2];
                customFooterCell.shippingFeeLabel.attributedText = attributedText;
                //customFooterCell.shippingFeeLabel.text=[NSString stringWithFormat:@"you are $%.2f from free shipping",shippingValue];
            }
            
            return customFooterCell.contentView;
        }
    }
}

#pragma mark UItableview Edit Delegates

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"SAVE \n FOR LATER" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        //Save For Later
        BOOL sessionExists = [[NSUserDefaults standardUserDefaults] boolForKey:kSessionKey];
        
        if (sessionExists) {
            rows =[aModelDict objectForKey:[array2  objectAtIndex:indexPath.section]];
            ShopCartProductModel *selectedProductModel = [rows objectAtIndex:indexPath.row];
            NSString *selectedProductId = selectedProductModel.cartProductId;
          //  NSInteger productMetaDataId = selectedProductModel.productMetadata.productMetadataId;
            [rows removeObjectAtIndex:indexPath.row];
            NSArray *indexPathsArray = [NSArray arrayWithObject:indexPath];
            
            [tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
            [[ServiceLayer alloc]postSaveForLaterwithProductId:selectedProductId completion:^(NSDictionary *dictionary) {
            }];
            
            [[selctedArryValue objectAtIndex:indexPath.section]removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            NSMutableDictionary *dict1=[selctedArryValue objectAtIndex:indexPath.section];
            NSMutableDictionary *editDict1=[[NSMutableDictionary alloc]init];
            NSMutableArray *sample=[[NSMutableArray alloc]init];
            [sample addObjectsFromArray:[dict1 allValues]];
            
            for (int i=0; i<[[dict1 allValues]count]; i++){
                [editDict1 setObject:[sample objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i]];
            }
            
            [selctedArryValue removeObjectAtIndex:indexPath.section];
            [selctedArryValue insertObject:editDict1 atIndex:indexPath.section];
            
            if(rows.count==0){
                [sectionSelectDict removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
            }if(sectionSelectDict.count==0){
                [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            }else{
                [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                
            }
            [[Pricearr objectAtIndex:indexPath.section]removeObjectAtIndex: indexPath.row];
            
            NSMutableDictionary *selectDict=[[NSMutableDictionary alloc]init];
            float sum=0;
            for (int r=0; r<[selctedArryValue count]; r++) {
                selectDict=[selctedArryValue objectAtIndex:r];
                
                NSMutableArray *arr=[[NSMutableArray alloc]init];
                for(NSString *key in [selectDict allKeys]) {
                    [arr addObject:[selectDict objectForKey:key]];
                    
                }
                for(int q=0;q<[arr count];q++){
                    if([[arr objectAtIndex:q] isEqualToString:@"YES"]){
                        sum=sum+[[[Pricearr objectAtIndex:r]objectAtIndex:q] floatValue];
                    }
                }
            }
            //aFooterVW.lbl.text=[NSString stringWithFormat:@"Subtotal : %.2f",sum];
            [self stringAttributed:sum];
            
            int objectCount = (int)[selctedArryValue count];
            for (int i = 0; i<objectCount; i++) {
                int count2 = (int)[[selctedArryValue objectAtIndex:i]count];
                if (count2==0) {
                    isEmpty = 1;
                    continue;
                }else{
                    isEmpty = 0;
                    break;
                }
            }
            if (isEmpty) {
                self.navigationItem.rightBarButtonItem = nil;
                self.emptyView.hidden = NO;
            }
            
        } else {
            //Guest View:
        }
    }];
    
    moreAction.backgroundColor = [UIColor themeColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"DELETE"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        //Delete Action:
        rows =[aModelDict objectForKey:[ array2 objectAtIndex:indexPath.section]];
        
//        NSString *selectedProduct = [rows objectAtIndex:indexPath.row];
        ShopCartProductModel *selectedProduct = [rows objectAtIndex:indexPath.row];
        
//        NSString *selCartProcutID = [selectedProduct valueForKey:@"cartProductId"];
        NSString *selCartProcutID = selectedProduct.cartProductId;
        NSInteger productMetadataId = selectedProduct.productMetadata.productMetadataId;
        
        [rows removeObjectAtIndex:indexPath.row];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        
        if (rows.count!=0) {
            [tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
            
        }else{
            [tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        }
        
        [[ServiceLayer alloc] postDelectWithShoppingCartId:cartId cartProductId:selCartProcutID productMetaDataId:productMetadataId completion:^(NSDictionary *dictionary) {
            
        }];
        
        [[selctedArryValue objectAtIndex:indexPath.section] removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        
        NSMutableDictionary *dict1=[selctedArryValue objectAtIndex:indexPath.section];
        NSMutableDictionary *editdict=[[NSMutableDictionary alloc]init];
        NSMutableArray *sample=[[NSMutableArray alloc]init];
        [sample addObjectsFromArray:[dict1 allValues]];
        
        for (int i=0; i<[[dict1 allValues]count]; i++) {
            [ editdict setObject:[sample objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i]];
        }
        
        [selctedArryValue removeObjectAtIndex:indexPath.section];
        [selctedArryValue insertObject:editdict atIndex:indexPath.section];
        
        if(rows.count==0){
            [sectionSelectDict removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        }if(sectionSelectDict.count==0){
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }else{
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            
        }
        [[Pricearr objectAtIndex:indexPath.section]removeObjectAtIndex: indexPath.row];
        
        NSMutableDictionary *selectDict=[[NSMutableDictionary alloc]init];
        float sum=0;
        for (int r=0; r<[selctedArryValue count]; r++) {
            selectDict=[selctedArryValue objectAtIndex:r];
            
            NSMutableArray *arr=[[NSMutableArray alloc]init];
            for(NSString *key in [selectDict allKeys]) {
                [arr addObject:[selectDict objectForKey:key]];
                
            }
            for(int q=0;q<[arr count];q++){
                if([[arr objectAtIndex:q] isEqualToString:@"YES"]){
                    sum=sum+[[[Pricearr objectAtIndex:r]objectAtIndex:q] floatValue];
                }
            }
        }
        //aFooterVW.lbl.text=[NSString stringWithFormat:@"Subtotal : %.2f",sum];
        [self stringAttributed:sum];
        
        int objectCount = (int)[selctedArryValue count];
        for (int i = 0; i<objectCount; i++) {
            int count2 = (int)[[selctedArryValue objectAtIndex:i]count];
            if (count2==0) {
                isEmpty = 1;
                continue;
            }else{
                isEmpty = 0;
                break;
            }
        }
        if (isEmpty) {
            self.navigationItem.rightBarButtonItem = nil;
            self.emptyView.hidden = NO;
        }
    }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction, moreAction];
}

- (void)loadingNextView{
    
    view.hidden = YES;
    self.tableView.tableHeaderView=nil;
    
}


// From Master/Detail Xcode template
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView setEditing:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
    
    //return  UITableViewCellEditingStyleDelete;
    /* if(editboolean==NO){
     if(editIndexPath.section ==indexPath.section)
     {
     return  UITableViewCellEditingStyleDelete;
     }else
     {
     [self.tableView setEditing:YES];
     return UITableViewCellEditingStyleDelete;
     }
     }else{
     
     return  UITableViewCellEditingStyleDelete;
     }*/
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //self.tableView.allowsMultipleSelectionDuringEditing = YES;
    if(editboolean==YES){
        if(editIndexPath.section==indexPath.section){
            return YES;
        }else{
            return NO;
        }
    }else{
        
        return YES;
    }
}

#pragma mark Button Actions

-(void)rowSelectBtnAction:(id)sender{
    UIButton *btn = (id)sender;
    
    if ([btn.currentImage isEqual:[UIImage imageNamed:@"round-stoke1x.png"]]){
        [btn setImage:[UIImage imageNamed:@"round-fill.png"] forState:UIControlStateNormal];
        NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)btn.tag];
        [[selctedArryValue objectAtIndex:btn.superview.tag]setValue:@"YES" forKey:tagStr];
    }
    else{
        [btn setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
        NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)btn.tag];
        [[selctedArryValue objectAtIndex:btn.superview.tag]setValue:@"NO" forKey:tagStr];
       // NSLog(@"selctedArryValue %@",selctedArryValue);
    }
    
    NSMutableDictionary *selectDict=[[NSMutableDictionary alloc]init];
    float sum=0;
    for (int r=0; r<[selctedArryValue count]; r++) {
        selectDict=[selctedArryValue objectAtIndex:r];
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        
        for(NSString *key in [selectDict allKeys]) {
            [arr addObject:[selectDict objectForKey:key]];
            if([[selectDict objectForKey:key] isEqualToString:@"YES"]){
                sum=sum+[[[Pricearr objectAtIndex:r]objectAtIndex:[key integerValue]] floatValue];
            }
        }
        
        if ([arr containsObject:@"NO"]) {
            [self.tableView beginUpdates];
            [sectionSelectDict setObject:@"NO" forKey:[NSString stringWithFormat:@"%d",r]];
            [self.tableView reloadData];
            [self.tableView endUpdates];
        }else{
            [self.tableView beginUpdates];
            [sectionSelectDict setObject:@"YES" forKey:[NSString stringWithFormat:@"%d",r]];
            [self.tableView reloadData];
            [self.tableView endUpdates];
            
        }
    }
    [self stringAttributed:sum];
    if( [[sectionSelectDict allValues] containsObject:@"NO"]){
        [aFooterVW.selectbutton  setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
        myBoolean = YES;
    }else{
        [aFooterVW.selectbutton  setImage:[UIImage imageNamed:@"round-fill1x.png"] forState:UIControlStateNormal];
        myBoolean = NO;
    }
    
}

-(void)sectionSelectionBtnAction:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    ShopMainCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"ShopMainCell";
    cell = [self.tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    rows =[aModelDict objectForKey:[array2  objectAtIndex:btn.tag]];
    if ([btn.currentImage isEqual:[UIImage imageNamed:@"round-stoke1x.png"]]){
        [btn setImage:[UIImage imageNamed:@"round-fill.png"] forState:UIControlStateNormal];
        NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)btn.tag];
        [sectionSelectDict setValue:@"YES" forKey:tagStr];
        for (int i=0; i<rows.count; i++) {
            cell= [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:btn.tag]];
            NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)i];
            [[selctedArryValue objectAtIndex:btn.tag]setValue:@"YES" forKey:tagStr];
            [cell.aSelectBtn setImage:[UIImage imageNamed:@"round-fill.png"] forState:UIControlStateNormal];
        }
        
        
    }
    
    else{
        [sectionSelectDict setValue:@"NO" forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
        [btn setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
        
        for (int i=0; i<rows.count; i++) {
            
            cell= [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:btn.tag]];
            [cell.aSelectBtn setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
            NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)i];
            [[selctedArryValue objectAtIndex:btn.tag]setValue:@"NO" forKey:tagStr];
        }
        
    }
    
    [self calculateSubTotal];
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView endUpdates];
    
}

-(void)aEditBtnAction:(UIButton*)sender{
    UIButton *btn = (UIButton*)sender;
    if([btn.currentTitle isEqualToString:@"Edit"]){
        
        [ServiceLayer googleTrackEventWithCategory:@"Edit Clicked" actionName:@"Edit Clicked" label:nil value:1];
        
        ShopMainCell *cell = nil;
        static NSString *AutoCompleteRowIdentifier = @"ShopMainCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
        
        rows =[aModelDict objectForKey:[array2 objectAtIndex:btn.tag]];
        [self.tableView setEditing:YES animated:YES];
        NSString *tagStr = [NSString stringWithFormat:@"%ld",(long)btn.tag];
        [editDict setValue:@"YES" forKey:tagStr];
        editboolean=YES;
        for (int i=0; i<rows.count; i++) {
            editIndexPath=[NSIndexPath indexPathForRow:i inSection:sender.tag];
            [self.tableView reloadData];
        }
        
    }else{
        editboolean=NO;
        editIndexPath=[NSIndexPath indexPathForRow:100 inSection:100];
        
        [self.tableView reloadData];
        [self.tableView setEditing:NO];
        
        [btn setTitle:@"Edit" forState:UIControlStateNormal];
    }
}
-(void)calculateSubTotal{
    if( [[sectionSelectDict allValues] containsObject:@"NO"]){
        [aFooterVW.selectbutton  setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
        myBoolean = YES;
    }else{
        [aFooterVW.selectbutton  setImage:[UIImage imageNamed:@"round-fill1x.png"] forState:UIControlStateNormal];
        myBoolean = NO;
    }
    NSMutableDictionary *selectDict=[[NSMutableDictionary alloc]init];
    float sum=0;
    for (int r=0; r<[selctedArryValue count]; r++) {
        selectDict=[selctedArryValue objectAtIndex:r];
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        
        for(NSString *key in [selectDict allKeys]) {
            [arr addObject:[selectDict objectForKey:key]];
        }
        for(int q=0;q<[arr count];q++){
            
            if([[arr objectAtIndex:q] isEqualToString:@"YES"]){
                sum=sum+[[[Pricearr objectAtIndex:r]objectAtIndex:q] floatValue];
            }
        }
        [self stringAttributed:sum];
    }
}
-(void)selectAllMethod:(BOOL)value{
    
    float sum = 0;
    ShopMainCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"ShopMainCell";
    cell = [self.tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    for (int s = 0; s < self.tableView.numberOfSections; s++)
    {
        
        NSMutableArray *arr=[Pricearr objectAtIndex:s];
        for (int r = 0; r < [self.tableView numberOfRowsInSection:s]; r++)
        {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s] animated:NO scrollPosition:UITableViewScrollPositionNone];
            cell =[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
            
            sum+=[[arr objectAtIndex:r] floatValue];
            [cell.aSelectBtn setImage:[UIImage imageNamed:@"round-fill.png"] forState:UIControlStateNormal];
            if(value==YES){
                [[selctedArryValue objectAtIndex:s]setValue:@"YES" forKey:[NSString stringWithFormat:@"%d",r]];
            }else{
                [[selctedArryValue objectAtIndex:s]setValue:@"NO" forKey:[NSString stringWithFormat:@"%d",r]];
            }
        }
        [self.tableView beginUpdates];
        if(value==YES){
            [sectionSelectDict setObject:@"YES" forKey:[NSString stringWithFormat:@"%d",s]];
        }else{
            [sectionSelectDict setObject:@"NO" forKey:[NSString stringWithFormat:@"%d",s]];
        }
        [self.tableView reloadData];
        [self.tableView endUpdates];
    }
    [self stringAttributed:sum];
}

-(void)joinButtonClicked{
    [ServiceLayer googleTrackEventWithCategory:@"SYW Join or Activate Button Clicked" actionName:@"Shopping Cart Page's SYW Join or Activate Button Clicked" label:nil value:1];
//    SYWViewController *syw=[[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"sywView"];
//    self.navigationController.navigationBar.topItem.title = @"Shop Your Way Rewords";
//    [self.navigationController setToolbarHidden:YES animated:YES];
//    [self.navigationController pushViewController:syw animated:YES];

}

//Assigning Attributed String
-(void)stringAttributed:(float)value{
    
    NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(value)
                                                           numberStyle:NSNumberFormatterCurrencyStyle];
    NSMutableAttributedString * string1 = [[NSMutableAttributedString alloc] initWithString:@"Subtotal: "];
    [string1 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,9)];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:priceText];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor themeColor] range:NSMakeRange(0,[string length])];
    [string1 appendAttributedString:string];
    aFooterVW.lbl.attributedText=string1;
}

-(void)shopMoreButton:(id)sender{
    
//    UIButton *btn = (UIButton*)sender;
//    NSArray *sellerArray = [[[aModelDict valueForKey:[array2 objectAtIndex:btn.tag]]valueForKey:@"product"]valueForKey:@"seller"];
//    //NSArray *sellerArray= [[[array2 objectAtIndex:btn.tag]valueForKey:@"product"]valueForKey:@"seller"];
//    NSString *sellerId = [[[sellerArray objectAtIndex:0]objectAtIndex:0] valueForKey:@"id"];
//    NSArray *modelSellerArray = array2;
//    NSString *sellerName = [modelSellerArray objectAtIndex:btn.tag];
//    
//    ViewAllViewController *viewAllVC = [[ViewAllViewController alloc] initWithSellerId:sellerId.intValue sellerName:sellerName];
//    self.fromViewAll=YES;
//    viewAllVC.fromShoppingCart=YES;
//    
//    //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewAllVC];
//    //    [nav setToolbarHidden:YES animated:YES];
//    //        [self presentViewController:nav animated:YES completion:nil];
//    [self.navigationController setToolbarHidden:YES animated:YES];
//    [self.navigationController pushViewController:viewAllVC animated:YES];
}

-(void)setupDropdownView{
    if(self.dropdownView==nil){
        self.dropdownView=[[UIView alloc]initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
        
        self.dropdownView.backgroundColor=[UIColor whiteColor];
        self.dropdownLabel = [[UILabel alloc]initWithFrame:self.dropdownView.bounds];
        self.dropdownLabel.textAlignment = NSTextAlignmentCenter;
        self.dropdownLabel.font = [UIFont fontWithName:@"Gill Sans" size:14];
        self.dropdownLabel.textColor=[UIColor whiteColor];
        self.dropdownLabel.backgroundColor = [UIColor clearColor];
        [self.dropdownView addSubview:self.dropdownLabel];
        [self.view addSubview:self.dropdownView];
    }
    
}

-(void)animateHeaderViewWithText:(NSString*)text backgroundColor:(UIColor*)backgroundColor{
   
    self.dropdownLabel.text = text;
    [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
        self.dropdownView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
        self.dropdownView.backgroundColor = backgroundColor;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 delay:2 options:0 animations:^{
            self.dropdownView.backgroundColor=[UIColor whiteColor];
            self.dropdownView.frame = CGRectMake(0, -40, self.view.frame.size.width, 40);
            
        } completion:^(BOOL finished) {
            //NSLog(@"Animation Finished");
        }];
        ;
    }];
}

#pragma mark - Format the Number
-(NSString *) addCommas:(NSUInteger) numberToFormat {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *numberAsString = [formatter stringFromNumber:[NSNumber numberWithInteger:numberToFormat]];
    NSString *newString = [NSString stringWithFormat:@"%@", numberAsString];
    
    return newString;
}

-(NSString *)abbreviateNumber:(NSInteger)num withDecimal:(NSInteger)dec {
    
    NSString *abbrevNum;
    CGFloat number = (CGFloat)num;
    if(num > 1000){
        NSArray *abbrev = [[NSArray alloc]initWithObjects:@"K", @"M", @"B",nil];
        
        for (NSInteger i=(NSInteger)abbrev.count-1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            NSInteger size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Here, we multiply by decPlaces, round, and then divide by decPlaces.
                // This gives us nice rounding to a particular decimal place.
                //number = round(number*dec/size)/dec;
                number = number/size;
                
                //NSString *numberString = [self floatToString:number];
                NSString *numberString = [self notRounding:number afterPoint:1];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
                
                //                NSLog(@"%@", abbrevNum);
                
            }
            
        }
    }
    
    return abbrevNum;
}


-(NSString *)notRounding:(float)price afterPoint:(int)position{
    
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    NSDecimalNumber *ouncesDecimal;
    
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
    
}


@end
