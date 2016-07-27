//
//  SortByViewController.m
//  Fount
//
//  Created by Rush on 12/7/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "SortByViewController.h"
#import "LeftEntranceAnimationController.h"
#import "SortByPresentationController.h"
#import "SortByTableViewCell.h"
#import "UIColor+CustomColors.h"
#import "Constants.h"

@interface SortByViewController () <UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSArray *sortByCategoriesArray;
@property (weak, nonatomic) IBOutlet UIView *coverView;


@end

@implementation SortByViewController

static NSString * const reuseIdentifier = @"SortByTableViewCellReuseIdentifier";

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedCellIndexPath= [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    [self.tableView selectRowAtIndexPath:selectedCellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tableView.frame = CGRectMake(100, 100, 100, 100);
//    self.tableViewTopConstraint.constant = 70.0;
}

//-(void)updateViewConstraints {
//    [super updateViewConstraints];
//    self.tableViewTopConstraint.constant = 10.0;
//}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if ([self respondsToSelector:@selector(setTransitioningDelegate:)]) {
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.transitioningDelegate = self;
            
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
            
            UITapGestureRecognizer *profileTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped:)];
            [self.tableView addGestureRecognizer:profileTapGesture];
            
            self.transitioningDelegate = self;
            
            //Remove left spacing from tableView
            [self.tableView setSeparatorInset:UIEdgeInsetsZero];
            [self.tableView setLayoutMargins:UIEdgeInsetsZero];
            
//            NSLog(@"TVH:%f", self.tableView.frame.size.height);
            
            self.coverView.backgroundColor = [[UIColor filterBackgroundColor] colorWithAlphaComponent:0.8];
            
//            self.tableView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];
            self.tableView.backgroundColor = [[UIColor filterBackgroundColor] colorWithAlphaComponent:0.8];
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [self.tableView registerNib:[UINib nibWithNibName:@"SortByTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
            
            self.sortByCategoriesArray = @[@"Most Relevant", @"Price Low to High", @"Price High to Low", @"New Arrivals"];
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    [self dismissSortByViewController];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sortByCategoriesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SortByTableViewCell *cell = (SortByTableViewCell *) [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.selected = YES;
    }
    
    cell.mainImageView.image = [UIImage imageNamed:@"checkmark"];
    cell.mainLabel.text = self.sortByCategoriesArray[indexPath.row];;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *sortType;
//    
//    switch (indexPath.row) {
//        case 0:
//            sortType = kSortByRelevancy;
//            break;
//            
//        case 1:
//            sortType = kSortByLowToHigh;
//            break;
//            
//        case 2:
//            sortType = kSortByHighToLow;
//            break;
//            
//        case 3:
//            sortType = kSortByNewArrivals;
//            break;
//            
//        default:
//            break;
//    }
    
//    [self.delegate sortSelectedWithSort:sortType];
    [self.delegate sortSelectedWithSelectedIndex:indexPath.row];
    [self dismissSortByViewController];
}

-(void) tableViewTapped:(UIGestureRecognizer *) recognizer {
    
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath) { //we are in a tableview cell, let the gesture be handled by the view
        recognizer.cancelsTouchesInView = NO;
        
    } else { // anywhere else, do what is needed for your case
        
        [self dismissSortByViewController];
        
    }
}

-(void) dismissSortByViewController {
    [self.delegate sortByDismissed];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if (presented == self) {
        return [[LeftEntranceAnimationController alloc] initWithPresentationBool:YES];
    }
    return nil;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if (dismissed == self) {
        return [[LeftEntranceAnimationController alloc] initWithPresentationBool:NO];
    }
    return nil;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    SortByPresentationController *roundRect = [[SortByPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    roundRect.frameSize = self.view.frame.size;
    
    return roundRect;
}

#pragma mark - Button Click Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
