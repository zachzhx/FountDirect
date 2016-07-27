//
//  ALScrollViewPaging.m
//  ScrollViewPaging
//
//
//
//

#import "ALScrollViewPaging.h"
#import "UIColor+CustomColors.h"
#import "ServiceLayer.h"
#import "ProductDetailViewController.h"

@implementation ALScrollViewPaging
@synthesize button;
const int kDotWidth = 7;
int pageControlY;

@synthesize likeBooleam;
@synthesize productID;

#pragma mark - Init



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //setting the 'must have' properties
        [self setBackgroundColor:[UIColor clearColor]];
        self.pagingEnabled = YES;
        self.delegate = self;
        pageControlBeingUsed = NO;
        self.bounces = NO;
        pageControl = [[UIPageControl alloc] init];
        //        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andPages:(NSArray *)pages
{
    self = [super initWithFrame:frame];
    if (self) {
        //add pages to scrollview
        [self addPages:pages];
    }
    return self;
}

#pragma mark - Setter

//setter for hasPageControl property
//if is YES, we can create the page control and place it under the scrollview
- (void)setHasPageControl:(BOOL)hasPageControl {
    _hasPageControl = hasPageControl;
    //if hasPageControl is true
    if (hasPageControl) {
        //set number of page based on number of pages to show and set current page to the first object
        [pageControl setNumberOfPages:[_pages count]];
        [pageControl setCurrentPage:0];
        //calculate the page control width considering that a dot is 20px, so we can multiply by the number of page to have the width of the page control
        int pWidth = (int)kDotWidth * (int)[_pages count];
        //calculate the scroll view center
        CGFloat scrollViewCenterPointX = self.frame.size.width / 2;
        //calculate the X and Y coordinates of the page control
        int pageControlX = scrollViewCenterPointX - (pWidth / 2);
        pageControlY = self.frame.origin.y + self.frame.size.height;
        //set the frame of the page control
        [pageControl setFrame:CGRectMake(pageControlX, pageControlY, pWidth, 36)];
        //set target and selector for page control
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        //set colors for indicators
        [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [pageControl setCurrentPageIndicatorTintColor:[UIColor themeColor]];
        //add page control to superview
        [[self superview] addSubview:pageControl];
        
        //        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //
        //        [button setImage:[UIImage imageNamed:@"hart-icon.png"] forState:UIControlStateNormal];
        //        button.frame = CGRectMake([self superview].frame.size.width-40, pageControlY-10, 28.0, 28.0);
        //        [button addTarget:self
        //                   action:@selector(aLikeMethod:)
        //         forControlEvents:UIControlEventTouchUpInside];
        //        [[self superview] addSubview:button];
        
    } else {
        //remove the page control from superview
        for (UIPageControl *pControl in [[self superview] subviews]) {
            if ([pControl isEqual:pageControl]) {
                [pageControl removeFromSuperview];
            }
        }
    }
}



-(void)setHasLikeMethod:(BOOL)hasLikeMethod{
        pageControlY = self.frame.origin.y + self.frame.size.height;
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSLog(@"%@",productID);
        NSLog(@"%@",likeBooleam);
        if([likeBooleam intValue]){
            [button setImage:[UIImage imageNamed:@"likesfilled"] forState:UIControlStateNormal];
            button.tintColor = [UIColor themeColor];
        }else{
            [button setImage:[UIImage imageNamed:@"likes"] forState:UIControlStateNormal];
            button.tintColor = [UIColor themeColor];
        }
        button.frame = CGRectMake([self superview].frame.size.width-55, pageControlY-1, 50.0, 28.0);
        button.backgroundColor = [UIColor greenColor];
        [button setTitle:self.likesQuantity forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Gill Sans" size:14];
    //    button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    button.imageView.backgroundColor = [UIColor selectedGrayColor];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [button addTarget:self
                   action:@selector(aLikeMethod:)
         forControlEvents:UIControlEventTouchUpInside];
        [[self superview] addSubview:button];
}


-(void)aLikeMethod:(id)sender{
    
        UIButton *btn = (UIButton*)sender;
        if ([btn.currentImage isEqual:[UIImage imageNamed:@"likes"]]){
            [btn setImage:[UIImage imageNamed:@"likesfilled"] forState:UIControlStateNormal];
            btn.tintColor = [UIColor themeColor];
            NSLog(@"%@",self.productID);
            [[[ServiceLayer alloc] init] likeProductWithProductId:[productID intValue] completion:^(NSDictionary *dictionary) {
                NSLog(@"%@",dictionary);
                NSString *likesStr = [[[[dictionary objectForKey:@"payload"]objectForKey:@"PRODUCT"]valueForKey:@"likes"] stringValue];
                [button setTitle:likesStr forState:UIControlStateNormal];
            }];
        }else{
            [btn setImage:[UIImage imageNamed:@"likes"] forState:UIControlStateNormal];
            btn.tintColor = [UIColor themeColor];
            [[[ServiceLayer alloc] init] unlikeProductWithProductId:[productID intValue] completion:^(NSDictionary *dictionary) {
                NSString *likesStr = [[[[dictionary objectForKey:@"payload"]objectForKey:@"PRODUCT"]valueForKey:@"likes"] stringValue];
                [button setTitle:likesStr forState:UIControlStateNormal];
            }];
        }
    
}

//set the color of the current page dot
- (void)setPageControlCurrentPageColor:(UIColor *)pageControlCurrentPageColor {
    _pageControlCurrentPageColor = pageControlCurrentPageColor;
    pageControl.currentPageIndicatorTintColor = pageControlCurrentPageColor;
}

//set the color of the others pages indicators
- (void)setPageControlOtherPagesColor:(UIColor *)pageControlOtherPagesColor {
    _pageControlOtherPagesColor = pageControlOtherPagesColor;
    pageControl.pageIndicatorTintColor = pageControlOtherPagesColor;
}

#pragma mark - Add pages

//add pages to the scrollview
- (void)addPages:(NSArray *)pages {
    _pages = pages;
    int numberOfPages = (int)[pages count];
    for (int i = 0; i < [pages count]; i++) {
        CGRect frame;
        frame.origin.x = self.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.frame.size;
        UIView *view = [pages objectAtIndex:i];
        [view setFrame:frame];
        [self addSubview:view];
    }
    self.contentSize = CGSizeMake(self.frame.size.width * numberOfPages, self.frame.size.height);
}

#pragma mark - Change page through page control

//method for paging
- (void)changePage:(id)sender {
    //update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.frame.size;
    [self scrollRectToVisible:frame animated:YES];
    pageControlBeingUsed = YES;
}

#pragma mark - ScrollView delegate

//methods for paging
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (!pageControlBeingUsed) {
        //switch the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.frame.size.width;
        NSInteger page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.currentPage =(int) page;
        pageControl.currentPage = self.currentPage;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

@end
