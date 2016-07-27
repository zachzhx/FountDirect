//
//  FilterView.m
//  Spree
//
//  Created by Rush on 10/21/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "FilterView.h"
#import "SortByViewController.h"
#import "Constants.h"
#import "UIColor+CustomColors.h"
#import "RefineViewController.h"

@interface FilterView () <UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, SortByDelegate>

//@property (weak, nonatomic) IBOutlet UIButton *sortByButton;

//@property (weak, nonatomic) IBOutlet UIImageView *sortByArrowImageView;


@end

@implementation FilterView

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    
    if ([self.subviews count] == 0) { // (1)
        
        NSString *className = NSStringFromClass([self class]);
        
        NSArray *elementsInNib = [[NSBundle mainBundle] loadNibNamed:className owner:Nil options:nil]; // (2)
        FilterView *realThing = [elementsInNib lastObject];
        
        realThing.frame = self.frame; // (3)
        
//        realThing.delegate = self.delegate;
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        CGRect frame = realThing.frame;
        frame.size.height = 50;
        frame.size.width = screenSize.width;
        
        realThing.frame = frame;
        
        realThing.autoresizingMask = self.autoresizingMask;
        
        return realThing;
    }
    return self;
}

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    
//    self = [super initWithCoder:aDecoder];
//    
//    if (self) {
//        
//    }
//    return self;
//}

//- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
//    if (![self.subviews count]) {
//        
//        NSString *className = NSStringFromClass([self class]);
//        
//        NSBundle *mainBundle = [NSBundle mainBundle];
//        NSArray *loadedViews = [mainBundle loadNibNamed:className owner:nil options:nil];
//        return [loadedViews firstObject];
//    }
//    return self;
//}

//- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
//    if ([self.subviews count] == 0) { // (1)
//        
//        NSString *className = NSStringFromClass([self class]);
//        
//        NSArray *elementsInNib = [[NSBundle mainBundle] loadNibNamed:className owner:Nil options:nil]; // (2)
//        FilterView *realThing = [elementsInNib lastObject];
//        realThing.frame = self.frame; // (3)
//        realThing.autoresizingMask = self.autoresizingMask;
//        return realThing;
//    }
//    return self;
//}


//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        NSString *className = NSStringFromClass([self class]);
//        self.view = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
//        [self addSubview:self.view];
//        
//        //        NSLog(@"view H:%f", self.view.frame.size.height);
//        
//        self.view.backgroundColor = [UIColor filterBackgroundColor];
//        
//        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//        
//        CGRect frame = self.view.frame;
//        frame.size.height = 50;
//        frame.size.width = screenSize.width;
//        
//        self.view.frame = frame;
//        
//        return self;
//    }
//    return nil;
//}

#pragma mark - Button Clicks
- (IBAction) sortByButtonClicked:(UIButton *)sender {
    [self.sortByButton setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
    self.sortByButton.tintColor = [UIColor themeColor];
    //    self.sortByArrowImageView.image = [UIImage imageNamed:@"arrowright"];
    self.sortByArrowImageView.tintColor = [UIColor themeColor];
    
    SortByViewController *sortByVC = [[SortByViewController alloc] initWithNibName:@"SortByViewController" bundle:nil];
    //self.sortByButton.titleLabel.text=@"Sort by";
    if ([self.sortByButton.titleLabel.text isEqualToString:@" Price Low to High"]) {
        
        sortByVC.selectedIndex = 1;
        
    } else if ([self.sortByButton.titleLabel.text isEqualToString:@" Price High to Low"]) {
        
        sortByVC.selectedIndex = 2;
        
    } else if ([self.sortByButton.titleLabel.text isEqualToString:@" New Arrivals"]) {
        
        sortByVC.selectedIndex = 3;
        
    } else {
        sortByVC.selectedIndex = 0;
    }
    
//    NSLog(@"sortBY Title:%@", self.sortByButton.titleLabel.text);
    
    sortByVC.delegate = self;
    [self.delegate filterSortByClicked:sortByVC];
}

-(IBAction) refineButtonClicked:(UIButton *)sender {
    RefineViewController *refineVC = [[RefineViewController alloc] init];
    
    [self.delegate filterRefineClicked:refineVC];
}

#pragma mark - <SortByDelegate>
-(void)sortSelectedWithSelectedIndex:(NSInteger)selectedIndex {
    NSString *sortByString;
    NSString *sortStringToPass;
    
    switch (selectedIndex) {
        case 0:
            sortByString = @" Most Relevant";
            sortStringToPass = kSortByRelevancy;
            break;
            
        case 1:
            sortByString = @" Price Low to High";
            sortStringToPass = kSortByLowToHigh;
            break;
            
        case 2:
            sortByString = @" Price High to Low";
            sortStringToPass = kSortByHighToLow;
            break;
            
        case 3:
            sortByString = @" New Arrivals";
            sortStringToPass = kSortByNewArrivals;
            break;
            
        default:
            break;
    }
    
    [self.sortByButton setTitle:sortByString forState:UIControlStateNormal];
    
    [self.delegate filterSortByString:sortStringToPass];
}

-(void)sortByDismissed {
    [self.sortByButton setTitleColor:[UIColor grayFontColor] forState:UIControlStateNormal];
    self.sortByButton.tintColor = [UIColor grayFontColor];
    //    self.sortByArrowImageView.image = [UIImage imageNamed:@"arrowdown"];
    self.sortByArrowImageView.tintColor = [UIColor grayFontColor];
}

@end
