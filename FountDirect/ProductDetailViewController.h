
//
//  ProductDetailViewController.h
//  Spree
//
//  Created by Rush on 9/21/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define direction_bottom kCATransitionFromTop

@class Product;

@interface ProductDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>
{
    UITableView *menuTableView;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *layout;
    
}
@property(strong,nonatomic)UIActionSheet *aac;
@property (strong,nonatomic)IBOutlet UIScrollView *aBgScrollVw;
@property (strong,nonatomic)NSString *aProductId;
@property (nonatomic,strong) UITableView *menuTableView;
@property (strong,nonatomic)UIWebView *myWebView;

@property (nonatomic, strong) UIImage *mainImage;
//@property (nonatomic, strong) Product *product;
@property (strong,nonatomic) NSMutableArray *stockDataArray;

@property (nonatomic, assign) BOOL fromPush;
@property (nonatomic, assign) BOOL fromOut;
@property (nonatomic, assign) BOOL presentedModally;
@property (nonatomic, assign) BOOL fromNavigate;


@end
