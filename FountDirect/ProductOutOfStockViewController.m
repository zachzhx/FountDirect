//
//  ProductOutOfStockViewController.m
//  Fount
//
//  Created by Xu Zhang on 2/1/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ProductOutOfStockViewController.h"
#import "Product.h"
#import "UIColor+CustomColors.h"
#import "ProductDetailViewController.h"
#import "ViewAllViewController.h"

@interface ProductOutOfStockViewController ()
{
    Product *productModel;
    NSMutableArray *imagesArray,*finalImagesArray,*salePriceArray,*priceArray,*productNameArray,*brandsArray,*finalPriceArray,*TTPriceArray,*TTOrigPriceArray;
    UIScrollView *scrollView;
}
@end

@implementation ProductOutOfStockViewController
@synthesize outOfStockView,outOfStockArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    //outOfStockView.hidden = YES;
    
    outOfStockView.delegate=self;
    outOfStockView.dataSource=self;
    
    salePriceArray = [NSMutableArray array];
    priceArray=[NSMutableArray array];
    productNameArray=[NSMutableArray array];
    imagesArray=[NSMutableArray array];
    finalImagesArray=[NSMutableArray array];
    brandsArray = [NSMutableArray array];
    finalPriceArray = [NSMutableArray array];
    TTPriceArray = [NSMutableArray array];
    TTOrigPriceArray = [NSMutableArray array];
    
    
    for(int i=0;i<outOfStockArray.count;i++){
        productModel=[outOfStockArray objectAtIndex:i];
        NSString *salePriceStr= [NSString stringWithFormat:@"%f",productModel.salePrice];
        NSString *priceStr=[NSString stringWithFormat:@"%f",productModel.price];
        NSString *productNameStr=[NSString stringWithFormat:@"%@",productModel.name];
        NSString *imageStr=[NSString stringWithFormat:@"%@",productModel.imageUrl];
        NSString *brandStr = [NSString stringWithFormat:@"%@",productModel.brand.name];
        NSString *TTPriceStr = [NSString stringWithFormat:@"%@",productModel.TTPrice];
        NSString *TTOriginalPriceStr = [NSString stringWithFormat:@"%@",productModel.TTOriginalPrice];
        
        [salePriceArray addObject:salePriceStr];
        [priceArray addObject:priceStr];
        [productNameArray addObject:productNameStr];
        [imagesArray addObject:imageStr];
        [brandsArray addObject:brandStr];
        [TTPriceArray addObject:TTPriceStr];
        [TTOrigPriceArray addObject:TTOriginalPriceStr];
        
        
    }
    outOfStockView.type = iCarouselTypeCoverFlow;
    [outOfStockView scrollToItemAtIndex:0 animated:NO];
    
    //    UIButton *buttonClose=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, 270, 25, 25)];
    //    [buttonClose addTarget:self action:@selector(ClosebuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    buttonClose.backgroundColor=[UIColor greenColor];
    //    buttonClose.tintColor = [UIColor themeColor];
    //    [buttonClose setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    //    [self.outOfStockView addSubview:buttonClose];
    
    UIButton *viewAllBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-33, 37, 66, 30)];
    viewAllBtn.backgroundColor = [UIColor clearColor];
    [viewAllBtn addTarget:self action:@selector(viewAllClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.outOfStockView addSubview:viewAllBtn];
    
    //Touch Transparent Area to close
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.stockView addGestureRecognizer:recognizer];
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(CaruseolVIEW *)carousel
{
    return outOfStockArray.count;
}
-(NSInteger) numberOfPlaceholdersInCarousel:(CaruseolVIEW *)carousel{
    return 0;
}
- (UIView *)carousel:(CaruseolVIEW *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0,105, 140,160)];
    view.backgroundColor = [UIColor whiteColor];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 150)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.backgroundColor = [UIColor whiteColor];
    //    imgView.layer.borderColor = [UIColor customLightGrayColor].CGColor;
    //    imgView.layer.borderWidth = 1;
    imgView.userInteractionEnabled = YES;
    
    NSString  *escapedDataString =[NSString stringWithFormat:@"%@",[imagesArray objectAtIndex:index]];
    
    imgView.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:escapedDataString]]];
    
    
    UILabel *brandlabel=[[UILabel alloc]initWithFrame:CGRectMake(0,imgView.frame.size.height+6, imgView.frame.size.width, 14)];
    brandlabel.backgroundColor=[UIColor whiteColor];
    brandlabel.textColor=[UIColor blackColor];
    brandlabel.textAlignment = NSTextAlignmentCenter;
    if ([[brandsArray objectAtIndex:index]isEqualToString:@"(null)"]) {
        brandlabel.text = @"";
    }else{
        brandlabel.text=[NSString stringWithFormat:@"%@",[brandsArray objectAtIndex:index]];
    }
    brandlabel.font=[UIFont fontWithName:@"Gill Sans" size:12];
    [view addSubview:brandlabel];
    UILabel *productnamelabel=[[UILabel alloc]initWithFrame:CGRectMake(0,imgView.frame.size.height+20,view.frame.size.width, 14)];
    productnamelabel.backgroundColor=[UIColor whiteColor];
    productnamelabel.font=[UIFont fontWithName:@"Gill Sans" size:12];
    //    productnamelabel.numberOfLines=2;
    //    productnamelabel.lineBreakMode=UILineBreakModeWordWrap;
    productnamelabel.text=[NSString stringWithFormat:@"%@",[productNameArray objectAtIndex:index]];
    productnamelabel.textColor = [UIColor grayColor];
    productnamelabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:productnamelabel];
    
    //Price Label
    UILabel *priceLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,imgView.frame.size.height+34, view.frame.size.width, 14)];
    priceLabel.backgroundColor=[UIColor whiteColor];
    priceLabel.font=[UIFont fontWithName:@"Gill Sans" size:12];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.textColor = [UIColor themeColor];
    //  priceLabel.text=[NSString stringWithFormat:@"%@",[priceArray objectAtIndex:index]];
    [view addSubview:priceLabel];
    
    UILabel *salePricelabel=[[UILabel alloc]initWithFrame:CGRectMake(0,imgView.frame.size.height+48, view.frame.size.width, 14)];
    salePricelabel.backgroundColor=[UIColor whiteColor];
    salePricelabel.font=[UIFont fontWithName:@"Gill Sans" size:12];
    salePricelabel.textAlignment = NSTextAlignmentCenter;
    salePricelabel.textColor=[UIColor themeColor];
    
    [view addSubview:salePricelabel];
    [view addSubview:imgView];
    
    NSString *TTPriceStr = [TTPriceArray objectAtIndex:index];
    if ([TTPriceStr isEqualToString:@"(null)"]) {
        
        //NSString *saleIndexString = [salePriceArray objectAtIndex:index];
        // NSString *priceIndexString = [priceArray objectAtIndex:index];
        
        CGFloat salePrice;
        salePrice = [[salePriceArray objectAtIndex:index]floatValue];
        CGFloat price = [[priceArray objectAtIndex:index]floatValue];
        
        if (price>salePrice && salePrice!=0) {
            NSString *salePriceText = [NSNumberFormatter localizedStringFromNumber:@(salePrice) numberStyle:NSNumberFormatterCurrencyStyle];
            salePricelabel.text=[NSString stringWithFormat:@"%@",salePriceText];
            NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(price) numberStyle:NSNumberFormatterCurrencyStyle];
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",priceText]];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            priceLabel.attributedText = attributeString;
        }else{
            NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(price) numberStyle:NSNumberFormatterCurrencyStyle];
            priceLabel.text = [NSString stringWithFormat:@"%@",priceText];
        }
    }else{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        TTPriceStr = [TTPriceStr stringByReplacingOccurrencesOfString:formatter.internationalCurrencySymbol withString:@""];
        float TTPriceValue = [formatter numberFromString:TTPriceStr].floatValue;
        NSString *TTPriceText = [NSNumberFormatter localizedStringFromNumber:@(TTPriceValue)
                                                                 numberStyle:NSNumberFormatterCurrencyStyle];
        priceLabel.text = [NSString stringWithFormat:@"%@",TTPriceText];
        salePricelabel.hidden = YES;
    }
    
    return view;
    
}

- (void)carouselCurrentItemIndexDidChange:(CaruseolVIEW *)carousel
{
    //NSLog(@"%s", __FUNCTION__);
    
    if (outOfStockView == carousel) {
        self.simItemLabel.text = [NSString stringWithFormat:@"Similar Items (%ld/%lu)",(long)((carousel.currentItemIndex)+1) ,(unsigned long)imagesArray.count];
    }
}

//Infinite Carousel Rolling
- (CGFloat)carousel:(CaruseolVIEW *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
//    if (option == iCarouselOptionSpacing)
//    {
//        return value * 1.1f;
//    }
//    
//    if (option == iCarouselOptionWrap)
//    {
//        return NO;
//    }
//    return value;
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
        default:
        {
            return value;
        }
    }

}


-(void)carousel:(CaruseolVIEW *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductDetail" bundle:nil];
    ProductDetailViewController *productDetailVC = [storyboard instantiateInitialViewController];
    productDetailVC.aProductId = [NSString stringWithFormat:@"%@",[[outOfStockArray objectAtIndex:index] valueForKey:@"productId"]];
    self.fromOut=YES;
    productDetailVC.presentedModally = YES;
    productDetailVC.fromOut=self.fromOut;
    productDetailVC.fromPush = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:productDetailVC];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    // self. navigationController.tabBarController.tabBar.hidden=NO;
    //[self.navigationController pushViewController:productDetailVC animated:YES];
    
}

- (BOOL)carousel:(CaruseolVIEW *)carousel shouldSelectItemAtIndex:(NSInteger)index{
    return YES;
}

- (void)carouselDidScroll:(CaruseolVIEW *)carousel;{
    
}
- (CGFloat)carouselItemWidth:(CaruseolVIEW *)carousel
{
    return 200.0; //your expected width
}

- (CGFloat)carouselItemHeight:(CaruseolVIEW *)carousel
{
    return 200.0; //your expected height
}

- (void)carouselWillBeginDragging:(CaruseolVIEW *)carousel
{
    // NSLog(@"Carousel will begin dragging");
}

- (void)carouselDidEndDragging:(CaruseolVIEW *)carousel willDecelerate:(BOOL)decelerate
{
    /// NSLog(@"Carousel did end dragging and %@ decelerate", decelerate? @"will": @"won't");
}

- (void)carouselWillBeginDecelerating:(CaruseolVIEW *)carousel
{
    // NSLog(@"Carousel will begin decelerating");
}

- (void)carouselDidEndDecelerating:(CaruseolVIEW *)carousel
{
    //NSLog(@"Carousel did end decelerating");
}

- (void)carouselWillBeginScrollingAnimation:(CaruseolVIEW *)carousel
{
    // NSLog(@"Carousel will begin scrolling");
}

- (void)carouselDidEndScrollingAnimation:(CaruseolVIEW *)carousel
{
    // NSLog(@"Carousel did end scrolling");
    
}


-(void)viewAllClicked:(id)sender{
    NSLog(@"%@",self.pdpProductName);
    ViewAllViewController *viewAllVC = [[ViewAllViewController alloc]initWithKeyword:self.pdpProductName];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewAllVC];
    [self presentViewController:navigationController animated:YES completion:nil];    
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.outOfStockView pointInside:[self.outOfStockView convertPoint:location fromView:self.stockView] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.stockView removeGestureRecognizer:sender];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (IBAction)viewAllBtn:(id)sender {
//    NSLog(@"%@",self.pdpProductName);
//    [[ViewAllViewController alloc]initWithKeyword:self.pdpProductName];
//}


@end
