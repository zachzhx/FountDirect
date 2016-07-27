//
//  RefineViewController.m
//  Fount
//
//  Created by Rush on 12/14/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "RefineViewController.h"
#import "NSAttributedString+StringStyles.h"
#import "UIColor+CustomColors.h"
#import "RefineBasicTableViewCell.h"
#import "RefineBrandsTableViewCell.h"
#import "ServiceLayer.h"
#import "Constants.h"

@interface RefineViewController () <UITableViewDataSource, UITableViewDelegate> {
    BOOL shouldLoadAggregation;
    NSInteger oldMinPrice;
    NSInteger oldMaxPrice;
    NSInteger oldSaleValue;
    
    BOOL loadingFinished;
}

@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *brandsButton;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UIButton *saleButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *clearAllButton;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) NSArray *storesArray;
@property (nonatomic, strong) NSArray *categoriesArray;
@property (nonatomic, strong) NSDictionary *brandsDictionary;
@property (nonatomic, strong) NSMutableArray *brandsIndexArray;
@property (nonatomic, strong) NSArray *pricesArray;
@property (nonatomic, strong) NSArray *salesArray;

@property (nonatomic, strong) NSArray *salesNameArray;

@property (nonatomic, assign) NSInteger selectedPriceIndex;
@property (nonatomic, assign) NSInteger selectedSalesIndex;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSArray *oldSellerIds, *oldCategoryIds, *oldBrandIds, *oldPriceRangesArray;

@property (nonatomic, assign) NSInteger productCount, newestProductCount;

@end

@implementation RefineViewController

-(NSMutableArray *)sellerIds {
    if (!_sellerIds) {
        _sellerIds = [[NSMutableArray alloc] init];
    }
    return _sellerIds;
}

-(NSMutableArray *)categoryIds {
    if (!_categoryIds) {
        _categoryIds = [[NSMutableArray alloc] init];
    }
    return _categoryIds;
}

-(NSMutableArray *)brandIds {
    if (!_brandIds) {
        _brandIds = [[NSMutableArray alloc] init];
    }
    return _brandIds;
}

-(NSMutableArray *)brandsIndexArray {
    if (!_brandsIndexArray) {
        _brandsIndexArray = [[NSMutableArray alloc] init];
    }
    return _brandsIndexArray;
}

-(NSMutableArray *)priceRangesArray {
    if (!_priceRangesArray) {
        _priceRangesArray = [[NSMutableArray alloc] init];
    }
    return _priceRangesArray;
}

static NSString *reuseIdentifier = @"RefineBasicReuseIdentifier";
static NSString *brandsCellReuseIdentifier = @"RefineBrandReuseIdentifier";

-(void) viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"REFINE"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.navigationController.navigationBar.tintColor = [UIColor themeColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backbuttonimage"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked:)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RefineBasicTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RefineBrandsTableViewCell" bundle:nil] forCellReuseIdentifier:brandsCellReuseIdentifier];
    
    self.checkMarkImageView.image = [UIImage imageNamed:@"checkmark"];
    
    [self setupMenuButton:self.storeButton];
    [self setupMenuButton:self.categoryButton];
    [self setupMenuButton:self.brandsButton];
    [self setupMenuButton:self.priceButton];
    [self setupMenuButton:self.saleButton];
    
    [self setupButton:self.clearAllButton];
    [self setupButton:self.applyButton];
    
    self.salesNameArray = @[@"All Sale Items", @"20% off or more", @"30% off or more", @"40% off or more", @"50% off or more", @"60% off or more", @"70% off or more"];
    
    [self storeButtonClicked:self.storeButton];
    
    self.selectedPriceIndex = -1;
    self.selectedSalesIndex = -1;
    
    shouldLoadAggregation = YES;
    
    self.tableView.estimatedRowHeight = 44.0 ;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.tableView.sectionIndexColor = [UIColor themeColor];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.color = [UIColor themeColor];
    self.spinner.center = CGPointMake( [UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    self.spinner.layer.zPosition = 10;

    [self.view addSubview:self.spinner];

    [self loadRefineFilter];
}

-(void) loadRefineFilter {
    if (shouldLoadAggregation) {
    
        [self.spinner startAnimating];
        loadingFinished = NO;
        
        [[[ServiceLayer alloc] init] getAggregationWithKeyword:self.keyword sellerIds:self.sellerIds categoryIds:self.categoryIds brandIds:self.brandIds priceRangesArray:self.priceRangesArray sale:self.sale completion:^(NSDictionary *dictionary) {
            
            if ([dictionary objectForKey:@"error"]) {
                
                loadingFinished = YES;
                
            } else {
            
                self.storesArray        = [dictionary valueForKeyPath:@"payload.SELLERS"];
                self.categoriesArray    = [dictionary valueForKeyPath:@"payload.CATEGORIES"];
                self.pricesArray        = [dictionary valueForKeyPath:@"payload.PRICES"];
                self.salesArray         = [dictionary valueForKeyPath:@"payload.SALES"];
                self.brandsDictionary   = [dictionary valueForKeyPath:@"payload.BRANDS"];
                
                NSArray *allKeys = [self.brandsDictionary allKeys];
                
                self.brandsIndexArray = [[allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
                
                //Remove sections if there are no brands
                for (NSString *key in allKeys) {
                    NSDictionary *dict = [self.brandsDictionary objectForKey:key];
                    
                    if (dict.count == 0) {
                        [self.brandsIndexArray removeObject:key];
                    }
                }
                
                [self.spinner stopAnimating];
                loadingFinished = YES;
                shouldLoadAggregation = NO;
                
                oldSaleValue = self.sale;
                self.oldSellerIds = [self.sellerIds copy];
                self.oldCategoryIds = [self.categoryIds copy];
                self.oldBrandIds = [self.brandIds copy];
                self.oldPriceRangesArray = [self.priceRangesArray copy];
                
                [self.tableView reloadData];
            }
        }];
    }
}

-(void) setupMenuButton:(UIButton *) sender {
    [sender setAttributedTitle:[NSAttributedString addSpacing:1 color:[UIColor blackColor] string:[sender.titleLabel.attributedText string]] forState:UIControlStateNormal];
}

-(void) setupButton:(UIButton *) sender {
    sender.layer.borderColor = [UIColor grayFontColor].CGColor;
    sender.layer.borderWidth = 1.0;
    sender.layer.cornerRadius = 4.0;
    
    [sender setAttributedTitle:[NSAttributedString addSpacing:1 color:[UIColor blackColor] string:[sender.titleLabel.attributedText string]] forState:UIControlStateNormal];
}

#pragma mark - Table view DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.selectedButton == self.brandsButton) {
        
        NSString *key = self.brandsIndexArray[section];
        NSDictionary *dict = [self.brandsDictionary objectForKey:key];
        NSString *stringToReturn;
        
        if (dict.count == 1) {
             stringToReturn = [NSString stringWithFormat:@"%@ (%tu brand)", key, dict.count];
        } else {
            stringToReturn = [NSString stringWithFormat:@"%@ (%tu brands)", key, dict.count];
        }
        return stringToReturn;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [UIColor grayFontColor];
    header.textLabel.font = [UIFont fontWithName:@"Gill Sans" size:16];
//    view.tintColor = [UIColor colorFromHexString:@"#EEEEEE"];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
//    header.textLabel.textAlignment = NSTextAlignmentCenter;
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.selectedButton == self.brandsButton) {
        return self.brandsIndexArray;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.selectedButton == self.brandsButton) {
        return self.brandsIndexArray.count;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedButton == self.storeButton) {
        
        return self.storesArray.count;
        
    } else if (self.selectedButton == self.categoryButton) {
        
        return self.categoriesArray.count;
        
    } else if (self.selectedButton == self.brandsButton) {
        
        NSString *key = self.brandsIndexArray[section];
        NSArray *brandsArray = [self.brandsDictionary objectForKey:key];

        return brandsArray.count;
        
    } else if (self.selectedButton == self.priceButton) {
        
        return self.pricesArray.count;
        
    } else {
        
        return self.salesArray.count;
    }
}

#pragma mark - Tableview Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedButton == self.brandsButton) {
        
        RefineBrandsTableViewCell *cell = (RefineBrandsTableViewCell *) [tableView dequeueReusableCellWithIdentifier:brandsCellReuseIdentifier];
        
        cell.checkMarkImageView.hidden = YES;
        cell.backgroundColor = [UIColor whiteColor];
        
        NSString *key = self.brandsIndexArray[indexPath.section];
        
        NSArray *brandsArray = [self.brandsDictionary objectForKey:key];
        
        cell.nameLabel.text = [brandsArray[indexPath.row] objectForKey:@"name"];
        
        NSInteger productcount = [[brandsArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
        
//        NSString *countString = [NSString stringWithFormat:@"%tu product", productcount];
//        
//        if (productcount > 1) {
//            countString = [NSString stringWithFormat:@"%tu products", productcount];
//        }
        
        cell.productCountLabel.text = [self addCommas:productcount];
        
        NSDictionary *brandDictionary = brandsArray[indexPath.row];
        
        NSString *currentId = [brandDictionary objectForKey:@"id"];
        
        if ([self.brandIds containsObject:currentId]) {
            [self selectBrandCell:cell];
            self.newestProductCount += [[brandsArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
        }
        
        return cell;
        
    } else {
    
        RefineBasicTableViewCell *cell = (RefineBasicTableViewCell *) [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        [self unselectCell:cell];
        
        if (self.selectedButton == self.storeButton) {
            
            cell.nameLabel.text         = [self.storesArray[indexPath.row] objectForKey:@"name"];
            cell.productCountLabel.text =  [self addCommas:[[self.storesArray[indexPath.row] objectForKey:@"productsCount"] integerValue]];

            NSString *currentId = [self.storesArray[indexPath.row] objectForKey:@"id"];
            
            if ([self.sellerIds containsObject:currentId]) {
                [self selectCell:cell];
            }
            
        } else if (self.selectedButton == self.categoryButton) {
            
            cell.nameLabel.text         = [self.categoriesArray[indexPath.row] objectForKey:@"name"];
            cell.productCountLabel.text = [self addCommas:[[self.categoriesArray[indexPath.row] objectForKey:@"productsCount"] integerValue]];

            NSString *currentId = [self.categoriesArray[indexPath.row] objectForKey:@"id"];
            
            if ([self.categoryIds containsObject:currentId]) {
                [self selectCell:cell];
            }
            
        } else if (self.selectedButton == self.priceButton) {
            
//            NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(self.product.price) numberStyle:NSNumberFormatterCurrencyStyle];
//            self.priceLabel.text = priceText;
            
            NSString *nameString = [self.pricesArray[indexPath.row] objectForKey:@"name"];
            
            if ([nameString containsString:@"5000000"]) {
                cell.nameLabel.text = @"$5,000.0+";
            } else {
                NSArray *splitString = [nameString componentsSeparatedByString:@"-"];
                
                NSInteger minValue = [splitString[0] integerValue];
                NSInteger maxValue = [splitString[1] integerValue];
                
                NSString *formattedMin = [NSNumberFormatter localizedStringFromNumber:@(minValue) numberStyle:NSNumberFormatterCurrencyStyle];
                NSString *formattedMax = [NSNumberFormatter localizedStringFromNumber:@(maxValue) numberStyle:NSNumberFormatterCurrencyStyle];
                
                cell.nameLabel.text = [NSString stringWithFormat:@"%@-%@", formattedMin, formattedMax];
            }
            
            NSDictionary *priceCopyDict = [self.priceRangesArray copy];
            
            for (NSDictionary *priceRangeDictionary in priceCopyDict) {
                NSString *minPrice = [priceRangeDictionary objectForKey:@"minPrice"];
                
                if ([cell.nameLabel.text containsString:minPrice]) {
                    [self selectCell:cell];
                }
            }
            
//            NSLog(@"Prices range:%@", self.priceRangesArray);
            
            cell.productCountLabel.text =  [self addCommas:[[self.pricesArray[indexPath.row] objectForKey:@"productsCount"] integerValue]];
            
            if (self.selectedPriceIndex == indexPath.row) {
                [self selectCell:cell];
            }
            
            if (self.maxPrice > 0) {
                [self selectCell:cell];
                self.selectedPriceIndex = indexPath.row;
                [self selectCellAtIndexPath:indexPath];
                
                self.checkMarkImageView.hidden = YES;
            }
            
        } else {
            
            cell.nameLabel.text         = self.salesNameArray[indexPath.row];
            cell.productCountLabel.text = [self addCommas:[[self.salesArray[indexPath.row] objectForKey:@"productsCount"] integerValue]];
            
            if (self.selectedSalesIndex == indexPath.row) {
                [self selectCell:cell];
            }
            
            if (self.sale == 1) {
                if (indexPath.row == 0) {
                    [self selectCell:cell];
                    [self selectSaleCellAtIndexPath:indexPath];
                }
            } else if (self.sale == 20) {
                if (indexPath.row == 1) {
                    [self selectCell:cell];
                    [self selectSaleCellAtIndexPath:indexPath];
                }
            } else if (self.sale == 30) {
                if (indexPath.row == 2) {
                    [self selectCell:cell];
                    [self selectSaleCellAtIndexPath:indexPath];
                }
            } else if (self.sale == 40) {
                if (indexPath.row == 3) {
                    [self selectCell:cell];
                    [self selectSaleCellAtIndexPath:indexPath];
                }
            } else if (self.sale == 50) {
                if (indexPath.row == 4) {
                    [self selectCell:cell];
                    [self selectSaleCellAtIndexPath:indexPath];
                }
            } else if (self.sale == 60) {
                if (indexPath.row == 5) {
                    [self selectCell:cell];
                    [self selectSaleCellAtIndexPath:indexPath];
                }
            } else if (self.sale == 70) {
                if (indexPath.row == 6) {
                    [self selectCell:cell];
                    [self selectSaleCellAtIndexPath:indexPath];
                }
            }
            
        }
        return cell;
    }
}

-(void) selectSaleCellAtIndexPath:(NSIndexPath *) indexPath {
    self.selectedSalesIndex = indexPath.row;
    [self selectCellAtIndexPath:[NSIndexPath indexPathForRow:self.selectedSalesIndex inSection:0]];
    self.checkMarkImageView.hidden = YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (loadingFinished) {
        
        self.checkMarkImageView.hidden = YES;
        
        if (self.selectedButton == self.storeButton) {
            
            RefineBasicTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.checkMarkImageView.hidden = !cell.checkMarkImageView.hidden;
            
            if (cell.checkMarkImageView.hidden == NO) {
                [self selectCell:cell];
                [self.sellerIds addObject:[self.storesArray[indexPath.row] objectForKey:@"id"]];
                self.newestProductCount += [[self.storesArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
                
            } else {
                [self unselectCell:cell];
                [self.sellerIds removeObject:[self.storesArray[indexPath.row] objectForKey:@"id"]];
                self.newestProductCount -= [[self.storesArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
            }
            
            if ([self.oldSellerIds isEqualToArray:self.sellerIds]) {
                shouldLoadAggregation = NO;
            } else {
                shouldLoadAggregation = YES;
            }
            
        } else if (self.selectedButton == self.categoryButton) {
            RefineBasicTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.checkMarkImageView.hidden = !cell.checkMarkImageView.hidden;
            
            if (cell.checkMarkImageView.hidden == NO) {
                [self selectCell:cell];
                [self.categoryIds addObject:[self.categoriesArray[indexPath.row] objectForKey:@"id"]];
                self.newestProductCount += [[self.categoriesArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
                
            } else {
                [self unselectCell:cell];
                [self.categoryIds removeObject:[self.categoriesArray[indexPath.row] objectForKey:@"id"]];
                self.newestProductCount -= [[self.categoriesArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
            }
            
            if ([self.oldCategoryIds isEqualToArray:self.categoryIds]) {
                shouldLoadAggregation = NO;
            } else {
                shouldLoadAggregation = YES;
            }
            
        } else if (self.selectedButton == self.brandsButton) {
            
            RefineBrandsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.checkMarkImageView.hidden = !cell.checkMarkImageView.hidden;
            
            NSString *key = self.brandsIndexArray[indexPath.section];
            NSArray *brandArray = [self.brandsDictionary objectForKey:key];
            NSDictionary *brandDictionary = brandArray[indexPath.row];
            
//            NSLog(@"BRAND :%@", brandDictionary);
            
            if (cell.checkMarkImageView.hidden == NO) {
                [self selectBrandCell:cell];
                [self.brandIds addObject:[brandDictionary objectForKey:@"id"]];
                
                self.newestProductCount += [[brandDictionary objectForKey:@"productsCount"] integerValue];
                
            } else {
                [self unselectBrandCell:cell];
                [self.brandIds removeObject:[brandDictionary objectForKey:@"id"]];
                self.newestProductCount -= [[brandDictionary objectForKey:@"productsCount"] integerValue];
            }
            
            if ([self.oldBrandIds isEqualToArray:self.brandIds]) {
                shouldLoadAggregation = NO;
            } else {
                shouldLoadAggregation = YES;
            }
            
        } else if (self.selectedButton == self.priceButton) {
    
            RefineBasicTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.checkMarkImageView.hidden = !cell.checkMarkImageView.hidden;
            
            NSString *priceString = [[self.pricesArray objectAtIndex:indexPath.row] objectForKey:@"name"];
//            NSLog(@"prices arr:%@", priceString);
            
            NSArray *minAndMaxSplit = [priceString componentsSeparatedByString:@"-"];
//            NSLog(@"split arr:%@", minAndMaxSplit);
            
            if (cell.checkMarkImageView.hidden == NO) {
                [self selectCell:cell];
//                [self.sellerIds addObject:[self.storesArray[indexPath.row] objectForKey:@"id"]];
//                NSDictionary *test = self.pricesArray
                
                NSDictionary *priceRangeDictionary = @{@"minPrice" : [minAndMaxSplit objectAtIndex:0], @"maxPrice" : [minAndMaxSplit objectAtIndex:1]};
                
//                NSLog(@"price Dict:%@", priceRangeDictionary);
                
                [self.priceRangesArray addObject:priceRangeDictionary];
                self.newestProductCount += [[self.pricesArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
                
            } else {
                [self unselectCell:cell];
                
                NSMutableArray *objectsToRemove = [[NSMutableArray alloc] initWithCapacity:self.priceRangesArray.count];
                
                for (NSDictionary *priceRangeDictionary in self.priceRangesArray) {
                    NSString *minPrice = [priceRangeDictionary objectForKey:@"minPrice"];
                    
                    if ([minPrice isEqualToString:[minAndMaxSplit objectAtIndex:0]]) {
                        [objectsToRemove addObject:priceRangeDictionary];
                    }
                }
                
                for (NSDictionary *dict in objectsToRemove) {
                    [self.priceRangesArray removeObject:dict];
                }
                self.newestProductCount -= [[self.pricesArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
            }
            
//            NSLog(@"PRICE ARR:%@", self.priceRangesArray);
            
            if ([self.oldPriceRangesArray isEqualToArray:self.priceRangesArray]) {
                shouldLoadAggregation = NO;
            } else {
                shouldLoadAggregation = YES;
            }
            
//            RefineBasicTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//
//            //Same cell clicked
//            if (self.selectedPriceIndex == indexPath.row) {
//                cell.checkMarkImageView.hidden = !cell.checkMarkImageView.hidden;
//
//                if (cell.checkMarkImageView.hidden) {
//                    self.selectedPriceIndex = -1;
//                    
//                    oldMinPrice = self.minPrice;
//                    oldMaxPrice = self.maxPrice;
//                    
//                    self.minPrice = 0;
//                    self.maxPrice = 0;
//                    
//                    self.checkMarkImageView.hidden = NO;
//                    cell.backgroundColor = [UIColor whiteColor];
//                    shouldLoadAggregation = YES;
//                }
//                
//            //Nothing/Different cell selected
//            } else {
//                [self unselectCellAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPriceIndex inSection:0]];
//                
//                NSDictionary *priceDictionary = self.pricesArray[indexPath.row];
//                NSString *priceString = [priceDictionary objectForKey:@"name"];
//                
//                [self setMinAndMaxPrice:priceString];
//                
//                self.selectedPriceIndex = indexPath.row;
//                [self selectCell:cell];
//                
//                if (oldMinPrice != self.minPrice && oldMaxPrice != self.maxPrice) {
//                    shouldLoadAggregation = YES;
//                } else {
//                    shouldLoadAggregation = NO;
//                }
//            }
            
        } else {
            RefineBasicTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (self.selectedSalesIndex == indexPath.row) {
                cell.checkMarkImageView.hidden = !cell.checkMarkImageView.hidden;
                
                if (cell.checkMarkImageView.hidden) {
                    cell.backgroundColor = [UIColor whiteColor];
                    self.selectedSalesIndex = -1;
                    
                    self.sale = 0;
                    
                    self.checkMarkImageView.hidden = NO;
                    shouldLoadAggregation = YES;
                    self.newestProductCount = 0;
                }
                
                //Nothing/Different cell selected
            } else {
                
                [self unselectCellAtIndexPath:[NSIndexPath indexPathForRow:self.selectedSalesIndex inSection:0]];
                
                NSDictionary *saleDictionary = self.salesArray[indexPath.row];
                NSString *saleString = [saleDictionary objectForKey:@"name"];
                
                [self setSaleValue:saleString];
                
                self.selectedSalesIndex = indexPath.row;
                [self selectCellAtIndexPath:indexPath];
                self.newestProductCount = [[self.salesArray[indexPath.row] objectForKey:@"productsCount"] integerValue];
                
                if (oldSaleValue != self.sale) {
                    shouldLoadAggregation = YES;
                } else {
                    shouldLoadAggregation = NO;
                }
                
            }
        }
    }
}

#pragma mark - Cell Helper Methods
-(void) selectCell:(RefineBasicTableViewCell *) cell {
    cell.checkMarkImageView.hidden = NO;
    cell.backgroundColor = [UIColor colorFromHexString:@"#EEEEEE"];
}

-(void) unselectCell:(RefineBasicTableViewCell *) cell {
    cell.checkMarkImageView.hidden = YES;
    cell.backgroundColor = [UIColor whiteColor];
}

-(void) selectBrandCell:(RefineBrandsTableViewCell *) cell {
    cell.checkMarkImageView.hidden = NO;
    cell.backgroundColor = [UIColor colorFromHexString:@"#EEEEEE"];
}

-(void) unselectBrandCell:(RefineBrandsTableViewCell *) cell {
    cell.checkMarkImageView.hidden = YES;
    cell.backgroundColor = [UIColor whiteColor];
}

//Used to select/unselect sales price
-(void) selectCellAtIndexPath:(NSIndexPath *) indexPath {
    RefineBasicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self selectCell:cell];
}

-(void) unselectCellAtIndexPath:(NSIndexPath *) indexPath {
    RefineBasicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.checkMarkImageView.hidden = YES;
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Button Clicks
-(void)doneButtonClicked:(UIBarButtonItem *)sender {
    if (self.spinner) {
        [self.spinner stopAnimating];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)storeButtonClicked:(UIButton *)sender {
    self.topLabel.text = @"All Sellers";
    [self menuButtonClicked:sender];
    [self loadRefineFilter];
}

- (IBAction)categoryButtonClicked:(UIButton *)sender {
    self.topLabel.text = @"All Categories";
    [self menuButtonClicked:sender];
    [self loadRefineFilter];
}

- (IBAction)brandsButtonClicked:(UIButton *)sender {
    self.topLabel.text = @"All Brands";
    [self menuButtonClicked:sender];
    [self loadRefineFilter];
}

- (IBAction)priceButtonClicked:(UIButton *)sender {
    self.topLabel.text = @"All Prices";
    [self menuButtonClicked:sender];
    [self loadRefineFilter];
}

- (IBAction)saleButtonClicked:(UIButton *)sender {
    self.topLabel.text = @"Regular and sale items";
    [self menuButtonClicked:sender];
    [self loadRefineFilter];
}

- (IBAction)clearAllButtonClicked:(UIButton *)sender {
    
    if (!self.isASeller) {
        [self.sellerIds removeAllObjects];
    }
    
    [self.categoryIds removeAllObjects];
    
    if (!self.isABrand) {
        [self.brandIds removeAllObjects];
        
//        NSString *key = self.brandsIndexArray[indexPath.section];
//        NSArray *brandArray = [self.brandsDictionary objectForKey:key];
//        NSDictionary *brandDictionary = brandArray[indexPath.row];
//        
        
        
        
        
//        if (cell.checkMarkImageView.hidden == NO) {
//            [self selectBrandCell:cell];
//            [self.brandIds addObject:[brandDictionary objectForKey:@"id"]];
        
//            self.newestProductCount += [[brandDictionary objectForKey:@"productsCount"] integerValue];
    }
    
    
    
    [self.priceRangesArray removeAllObjects];
    self.selectedPriceIndex = -1;
    self.selectedSalesIndex = -1;
//    self.minPrice = 0;
//    self.maxPrice = 0;
    self.sale = 0;
    self.checkMarkImageView.hidden = NO;
    
    shouldLoadAggregation = YES;
    
    [self loadRefineFilter];
}

-(IBAction) applyButtonClicked:(UIButton *)sender {
//    [self.delegate refineViewSearchProductsWithSellerIds:self.sellerIds categoryIds:self.categoryIds brandIds:self.brandIds priceRangesArray:self.priceRangesArray  sale:self.sale];
    
    if (self.newestProductCount > 0) {
        self.productCount = self.newestProductCount;
    }
    
    [self.delegate refineViewSearchProductsWithSellerIds:self.sellerIds categoryIds:self.categoryIds brandIds:self.brandIds priceRangesArray:self.priceRangesArray sale:self.sale productCount:self.productCount];

    if (self.spinner) {
        [self.spinner stopAnimating];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods
-(void) setMinAndMaxPrice:(NSString *) priceString {
    if ([priceString isEqualToString:kPrice0To25]) {
        self.minPrice = 0;
        self.maxPrice = 25;
    } else if ([priceString isEqualToString:kPrice25To50]) {
        self.minPrice = 25;
        self.maxPrice = 50;
    } else if ([priceString isEqualToString:kPrice50To100]) {
        self.minPrice = 50;
        self.maxPrice = 100;
    } else if ([priceString isEqualToString:kPrice100To150]) {
        self.minPrice = 100;
        self.maxPrice = 150;
    } else if ([priceString isEqualToString:kPrice150To250]) {
        self.minPrice = 150;
        self.maxPrice = 250;
    } else if ([priceString isEqualToString:kPrice250To500]) {
        self.minPrice = 250;
        self.maxPrice = 500;
    } else if ([priceString isEqualToString:kPrice500To1000]) {
        self.minPrice = 500;
        self.maxPrice = 1000;
    } else if ([priceString isEqualToString:kPrice1000To2500]) {
        self.minPrice = 1000;
        self.maxPrice = 2500;
    }
}

-(void) setSaleValue:(NSString *) saleString {
    if ([saleString isEqualToString:kSaleAll]) {
        self.sale = 1;
    } else if ([saleString isEqualToString:kSale20Percent]) {
        self.sale = 20;
    } else if ([saleString isEqualToString:kSale30Percent]) {
        self.sale = 30;
    } else if ([saleString isEqualToString:kSale40Percent]) {
        self.sale = 40;
    } else if ([saleString isEqualToString:kSale50Percent]) {
        self.sale = 50;
    } else if ([saleString isEqualToString:kSale60Percent]) {
        self.sale = 60;
    } else if ([saleString isEqualToString:kSale70Percent]) {
        self.sale = 70;
    }
}

-(NSString *) addCommas:(NSInteger) numberToFormat {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *numberAsString = [formatter stringFromNumber:[NSNumber numberWithInteger:numberToFormat]];
    NSString *newString = [NSString stringWithFormat:@"%@", numberAsString];
    
    return newString;
}

-(void) selectButton {
    self.selectedButton.backgroundColor = [UIColor themeColor];
    [self.selectedButton setAttributedTitle:[NSAttributedString addSpacing:1 color:[UIColor whiteColor] string:self.selectedButton.titleLabel.text] forState:UIControlStateNormal];
}

-(void) unselectButton {
    self.selectedButton.backgroundColor = [UIColor clearColor];
    
    if (self.selectedButton.titleLabel.attributedText) {
        [self.selectedButton setAttributedTitle:[NSAttributedString addSpacing:1 color:[UIColor blackColor] string:self.selectedButton.titleLabel.text] forState:UIControlStateNormal];
    }
}

-(void) menuButtonClicked:(UIButton *) sender {
    //Reset productCount
    if (self.newestProductCount > 0) {
        self.productCount = self.newestProductCount;
    }
    self.newestProductCount = 0;
    
    if ( self.tableView.numberOfSections > 0) {
        NSIndexPath *top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    [self unselectButton];
    self.selectedButton = sender;
    [self selectButton];
    [self.tableView reloadData];
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
