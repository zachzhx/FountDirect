//
//  ALScrollViewPaging.h
//  ScrollViewPaging
//
//

#import <UIKit/UIKit.h>

@interface ALScrollViewPaging : UIScrollView <UIScrollViewDelegate> {
    BOOL pageControlBeingUsed;
    NSArray *_pages;
    UIPageControl *pageControl;
}


@property (nonatomic,retain)  UIButton *button;
@property (nonatomic) int currentPage;
@property (nonatomic) BOOL hasPageControl;
@property (nonatomic, strong) UIColor *pageControlCurrentPageColor;
@property (nonatomic, strong) UIColor *pageControlOtherPagesColor;
@property (nonatomic) BOOL hasLikeMethod;
@property (nonatomic) BOOL unLikeMethod;

@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *likeBooleam;
@property (nonatomic, retain) NSString *likesQuantity;


- (id)initWithFrame:(CGRect)frame andPages:(NSArray *)pages;
- (void)addPages:(NSArray *)pages;

@end
