//
//  ViewAllViewController.m
//  Fount
//
//  Created by Rush on 2/3/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ViewAllViewController.h"
#import "ProductCollectionViewCell.h"
#import "Product.h"
#import "ServiceLayer.h"
#import "SearchServiceLayer.h"
#import "UIColor+CustomColors.h"
#import "NSAttributedString+StringStyles.h"
#import "ProductDetailViewController.h"
#import "SortByViewController.h"
#import "Constants.h"
#import "RefineViewController.h"
#import <Google/Analytics.h>

@interface ViewAllViewController () <UICollectionViewDataSource, UICollectionViewDelegate, FilterViewDelegate, RefineViewDelegate> {
    
    BOOL isASeller, isABrand;
    BOOL isMoreProducts;
    NSString *currentSortByString;
}

#define kLowestPageNumber 1

@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) NSInteger sellerId;
@property (nonatomic, strong) NSString *keyword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterViewTopConstraint;
@property (nonatomic, assign) NSInteger currentPageNumber;

@property (nonatomic, strong) NSArray *sellerIds;
@property (nonatomic, strong) NSArray *categoryIds;
@property (nonatomic, strong) NSArray *brandIds;
@property (nonatomic, strong) NSArray *priceRangesArray;
@property (nonatomic, assign) NSInteger sale;
@property (nonatomic, strong) NSString *availability;
@property (nonatomic, assign) NSInteger defaultProductCount;

@end

@implementation ViewAllViewController

static NSString * const reuseIdentifier = @"ProductCollectionViewCellRI";

-(NSMutableArray *) dataSourceArray {
    if (!_dataSourceArray) {
        _dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.fromShoppingCart) {
        self.filterViewTopConstraint.constant = 0.0;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"View All Page"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(instancetype)initWithSellerId:(NSInteger) sellerId sellerName:(NSString *) sellerName {
    self = [super init];
    if (self) {
        
        self.sellerIds = @[@(sellerId)];
        isASeller = YES;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.attributedText = [NSAttributedString navigationTitleStyle:[sellerName uppercaseString]];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
    }
    return self;
}

-(instancetype)initWithKeyword:(NSString *) keyword {
    self = [super init];
    if (self) {
        
        isABrand = YES;
        self.keyword = keyword;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.attributedText = [NSAttributedString navigationTitleStyle:[keyword uppercaseString]];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backbuttonimage"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked:)];
    }
    return self;
}

-(void) initVariables {
    isMoreProducts = YES;
    self.currentPageNumber = kLowestPageNumber;
    self.availability = @"IN_STOCK";
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (self.fromShoppingCart) {
        self.filterViewTopConstraint.constant = 0.0;
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    currentSortByString = @"relevancy";
    
    if (self.fromShoppingCart) {
        self.filterViewTopConstraint.constant = 0.0;
    }
    
    [self initVariables];
    
    self.navigationController.navigationBar.tintColor = [UIColor themeColor];
    
//    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Gill Sans" size:21], NSForegroundColorAttributeName: [UIColor themeColor]};
    
    if (isASeller) {
//        self.collectionViewBottomConstraint.constant = 0.0;
        self.filterViewTopConstraint.constant = 0.0;
    }
    
    [ServiceLayer getProductCountWithKeyword:nil sellerIds:self.sellerIds brandIds:self.brandIds categoryIds:self.categoryIds priceRangesArray:self.priceRangesArray sale:self.sale availability:self.availability completion:^(NSDictionary *dictionary) {
        
        self.defaultProductCount = [[dictionary objectForKey:@"COUNT"] integerValue];
        
        self.filterView.numberOfProductsLabel.attributedText = [NSAttributedString getProductLabelWithNumberOfProducts:self.defaultProductCount];
    }];
    
//    self.filterView.refineButton.hidden = YES;
//    self.filterView.refineArrowImageView.hidden = YES;
    self.filterView.delegate = self;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProductCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    //Remove back button's text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self loadNextSet];
}

#pragma mark - Setup Methods
//-(void) setupCustomBarButtonItem {
//    UILabel *lbl = [[UILabel alloc] init];
//    lbl.font = [UIFont fontWithName:@"Gill Sans" size:12.0f];
//    lbl.textColor = [UIColor themeColor];
//    lbl.textAlignment = NSTextAlignmentCenter;
//    
//    lbl.text = [NSString stringWithFormat:@"%i", (int) [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey]];
//    [lbl sizeToFit];
//    
//    UIButton *cartBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
//    cartBtn.frame = CGRectMake(0,0, 35, 35);
//    cartBtn.tintColor = [UIColor themeColor];
//    [cartBtn setBackgroundImage:[[UIImage imageNamed:@"cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [cartBtn addTarget:self action:@selector(cartClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    lbl.frame = CGRectMake(cartBtn.layer.position.x - 4, cartBtn.layer.position.y - 4.5, 15, 10);
//    
//    [cartBtn addSubview:lbl];
//    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:cartBtn];
//    self.navigationItem.rightBarButtonItem = barBtn;
//}

#pragma mark - <UICollectionViewDataSource>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float width = (screenSize.width - 12) / 2;
    
    return CGSizeMake(width, width + 60 + 35);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCollectionViewCell *cell = (ProductCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    Product *product = self.dataSourceArray[indexPath.row];
    
    cell.product = product;
    
    [cell setupCell];
    
    if (self.dataSourceArray.count - 12 == indexPath.row || self.dataSourceArray.count - 1 == indexPath.row) {
        
        [self loadNextSet];
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductDetail" bundle:nil];
    ProductDetailViewController *productDetailVC = [storyboard instantiateInitialViewController];
    
    Product *product = self.dataSourceArray[indexPath.row];
    
    productDetailVC.aProductId = [NSString stringWithFormat:@"%tu", product.productId];
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:productDetailVC];
    //    [self.delegate loadProductDetailPage:productDetailVC productId:[NSString stringWithFormat:@"%i", product.productId]]
    //    ;
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
    if (self.fromShoppingCart){
       // productDetailVC.fromNavigate = YES;
      //  productDetailVC.fromOut = YES;
       // productDetailVC.fromPush = YES;
    }
    [self.navigationController pushViewController:productDetailVC animated:YES];
}

#pragma mark - Button Click Methods
-(void) doneButtonClicked:(UIBarButtonItem *) sender {
    if (self.fromShoppingCart==YES) {
        NSString *load=@"loading";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadView" object:load];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Infinite Scroll
-(void) loadNextSet {
    if (isMoreProducts) {
        
        [self searchWithKeyword:self.keyword sortByString:currentSortByString pageNumber:self.currentPageNumber sellerIds:self.sellerIds categoryIds:self.categoryIds brandIds:self.brandIds priceRangesArray:self.priceRangesArray sale:self.sale availability:self.availability];
    }
}

#pragma mark - FilterView Delegate Methods
-(void)filterRefineClicked:(UIViewController *)viewController {
    RefineViewController *refineVC = (RefineViewController *) viewController;
    //    refineVC.fromProfile = YES;
    
    refineVC.keyword    = self.keyword;
    refineVC.sellerIds  = [self.sellerIds mutableCopy];
    refineVC.categoryIds = [self.categoryIds mutableCopy];
    refineVC.brandIds   = [self.brandIds mutableCopy];
    //    refineVC.minPrice   = self.minPrice;
    //    refineVC.maxPrice   = self.maxPrice;
    refineVC.priceRangesArray = [self.priceRangesArray mutableCopy];
    refineVC.sale       = self.sale;
    refineVC.delegate   = self;
    
    if (isABrand) {
        refineVC.isABrand = YES;
    }
    
    if (isASeller) {
        refineVC.isASeller = YES;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:refineVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
//    [self.delegate filteredProductVCPassRefineVC:refineVC];
}

-(void)refineViewSearchProductsWithSellerIds:(NSArray *)sellerIds categoryIds:(NSArray *)categoryIds brandIds:(NSArray *)brandIds priceRangesArray:(NSArray *)priceRangesArray sale:(NSInteger)sale productCount:(NSInteger)productCount {
    
    if (productCount > 0) {
        self.filterView.numberOfProductsLabel.attributedText = [NSAttributedString getProductLabelWithNumberOfProducts:productCount];
    } else {
        self.filterView.numberOfProductsLabel.attributedText = [NSAttributedString getProductLabelWithNumberOfProducts:self.defaultProductCount];
    }
    
    //    NSLog(@"SeLF SELLER C:%tu -- seller C :%tu -- SELF BRAND C:%tu -- brand C:%tu", self.sellerIds.count, sellerIds.count, self.brandIds.count, brandIds.count);
    
    //    NSLog(@"DEF P C:%tu -- pc:%tu", self.defaultProductCount, productCount);
    
    //    if (self.sellerIds.count > 0 || self.categoryIds.count > 0 || self.brandIds.count > 0 || self.priceRangesArray.count > 0 || self.sale > 0) {
    
    
    
    if (productCount > 0) {
//        self.filterView.numberOfProductsLabel.attributedText = [NSAttributedString getProductLabelWithNumberOfProducts:productCount];
        
        [self.filterView.refineButton setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
        self.filterView.refineArrowImageView.tintColor = [UIColor themeColor];
        self.filterView.refineButton.imageView.tintColor = [UIColor themeColor];
    } else {
        [self.filterView.refineButton setTitleColor:[UIColor grayFontColor] forState:UIControlStateNormal];
        self.filterView.refineArrowImageView.tintColor = [UIColor grayFontColor];
        self.filterView.refineButton.imageView.tintColor = [UIColor grayFontColor];
    }
    
    self.availability = @"IN_STOCK";
    self.currentPageNumber = 1;
    
    self.sellerIds = sellerIds;
    self.categoryIds = categoryIds;
    self.brandIds = brandIds;
    self.priceRangesArray = priceRangesArray;
    self.sale = sale;
    
    [self searchWithKeyword:nil sortByString:currentSortByString pageNumber:self.currentPageNumber sellerIds:self.sellerIds categoryIds:self.categoryIds brandIds:self.brandIds priceRangesArray:self.priceRangesArray sale:self.sale availability:self.availability];
}

-(void)filterSortByClicked:(UIViewController *)viewController {
    SortByViewController *sortByVC = (SortByViewController *) viewController;
    
    CGPoint point = [self.view convertPoint:self.filterView.frame.origin toView:nil];
    sortByVC.tableViewTopConstraint.constant = point.y + self.filterView.frame.size.height;
    [self.navigationController presentViewController:sortByVC animated:YES completion:nil];
}

-(void)filterSortByString:(NSString *)sortByString {
    if ([sortByString isEqualToString:kSortByRelevancy]) {
        [ServiceLayer googleTrackEventWithCategory:@"Tag Search Sort By" actionName:@"Most Relevant" label:nil value:1];
    } else if ([sortByString isEqualToString:kSortByLowToHigh]) {
        [ServiceLayer googleTrackEventWithCategory:@"Tag Search Sort By" actionName:@"Low to High" label:nil value:1];
    } else if ([sortByString isEqualToString:kSortByHighToLow]) {
        [ServiceLayer googleTrackEventWithCategory:@"Tag Search Sort By" actionName:@"High to Low" label:nil value:1];
    } else if ([sortByString isEqualToString:kSortByNewArrivals]) {
        [ServiceLayer googleTrackEventWithCategory:@"Tag Search Sort By" actionName:@"New Arrivals" label:nil value:1];
    }
    
    currentSortByString = sortByString;
    
    [self initVariables];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    
    [self searchWithKeyword:self.keyword sortByString:currentSortByString pageNumber:self.currentPageNumber sellerIds:self.sellerIds categoryIds:self.categoryIds brandIds:self.brandIds priceRangesArray:self.priceRangesArray sale:self.sale availability:self.availability];
}

#pragma mark - Search Helper Methods
-(void) searchWithKeyword:(NSString *)keyword sortByString:(NSString *)sortByString pageNumber:(NSInteger)pageNumber sellerIds:(NSArray *)sellerIds categoryIds:(NSArray *)categoryIds brandIds:(NSArray *)brandIds priceRangesArray:(NSArray *) priceRangesArray sale:(NSInteger)sale availability:(NSString *) availability {
    
    [[[ServiceLayer alloc] init] getSearchedProductsWithKeyword:self.keyword sortyBy:currentSortByString pageNumber:self.currentPageNumber sellerIds:self.sellerIds categoryIds:self.categoryIds brandIds:self.brandIds priceRangesArray:self.priceRangesArray sale:self.sale availability:self.availability completion:^(NSDictionary *dictionary) {

        NSArray *arrayOfProducts = [dictionary objectForKey:@"PRODUCTS"];
        
        //Lowest page number & in stock
        if (self.currentPageNumber == kLowestPageNumber && [self.availability isEqualToString:@"IN_STOCK"]) {
            
//            self.filterView.numberOfProductsLabel.attributedText = [NSAttributedString getProductLabelWithNumberOfProducts:[[dictionary objectForKey:@"COUNT"] integerValue]];
            
            [self.collectionView setContentOffset:CGPointZero animated:NO];
            
            if (self.dataSourceArray.count > 0) {
                [self.dataSourceArray removeAllObjects];
            }
            
        } else if (arrayOfProducts.count < 20 && [self.availability isEqualToString:@"OUT_OF_STOCK"]) {
                    
            isMoreProducts = NO;
        }
        
        if (arrayOfProducts.count > 0) {
            [self.dataSourceArray addObjectsFromArray:arrayOfProducts];
            self.currentPageNumber++;
            [self.collectionView reloadData];
        } else if ([self.availability isEqualToString:@"IN_STOCK"]) {
            self.availability = @"OUT_OF_STOCK";
            self.currentPageNumber = kLowestPageNumber;
            [self loadNextSet];
        }
        
//        [self removeSpinner];
//        self.filterView.hidden = NO;
    }];
}

#pragma mark - Memory Warnings
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
