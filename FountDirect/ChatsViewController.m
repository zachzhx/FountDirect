//
//  ChatsViewController.m
//  FountDirect
//
//  Created by Zhang Xu on 6/27/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ChatsViewController.h"
#import "UIColor+CustomColors.h"
#import "Constants.h"
#import "NSAttributedString+StringStyles.h"
#import "SingleChatTableViewCell.h"
#import "ServiceLayer.h"
#import "ShoppingCartTableViewController.h"
#import "ConversationViewController.h"
#import "SingleChatModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ChatsViewController (){
    UIButton *shoppingCartButton;
    NSInteger pageNumber;
    NSMutableArray *arrayofChatGroups;
    NSInteger userId;
    BOOL isEndOfLoading;
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation ChatsViewController

static NSString *singleChatCellIdentifier = @"SingleChatCell";

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    pageNumber = 1;
    arrayofChatGroups = [NSMutableArray new];
    [activityIndicator startAnimating];
    self.tableView.userInteractionEnabled = NO;
    [self getApiResponse];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userId = [[[ServiceLayer alloc]init]getUserId];
//    arrayofChatGroups = [NSMutableArray new];
//    pageNumber = 1;
    self.tabBarController.tabBar.tintColor = [UIColor themeColor];
    [self setupNavigationBar];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleChatTableViewCell" bundle:nil] forCellReuseIdentifier:singleChatCellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    //For spinner
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.color = [UIColor themeColor];
        activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-80);//Center of the frame
        //        NSLog(@"%f , %f", self.view.frame.size.width, self.view.frame.size.height);
        activityIndicator.tag = 12; //The tag to identify view objects
        [self.tableView addSubview:activityIndicator];  //Addsubview:Spinner
    }
}

#pragma mark - Setup Methods
-(void)setupNavigationBar{
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"MESSAGE"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    [self setupShoppingCart];
    
    [[[ServiceLayer alloc] init] getCartProducts:^(NSArray *array) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:array.count forKey:kNumberOfItemsInCartKey];
        [self setupShoppingCart];
    }];
}

-(void)setupShoppingCart{
    UILabel *lbl = [[UILabel alloc] init];
    lbl.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0f];
    lbl.textColor = [UIColor themeColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    
    NSInteger productsInCartCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
    
    lbl.text = [NSString stringWithFormat:@"%li", (long)productsInCartCount];
    [lbl sizeToFit];
    
    shoppingCartButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    shoppingCartButton.frame = CGRectMake(0,0, 35, 35);
    shoppingCartButton.tintColor = [UIColor themeColor];
    [shoppingCartButton setBackgroundImage:[[UIImage imageNamed:@"cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shoppingCartButton addTarget:self action:@selector(cartClicked) forControlEvents:UIControlEventTouchUpInside];
    
    lbl.frame = CGRectMake(shoppingCartButton.layer.position.x - 4, shoppingCartButton.layer.position.y - 4.5, 15, 10);
    
    [shoppingCartButton addSubview:lbl];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:shoppingCartButton];
    self.navigationItem.rightBarButtonItem = barBtn;
}

-(void)getApiResponse{
    
    [[[ServiceLayer alloc]init]getChatMessageListWithPageNumber:pageNumber completion:^(NSArray *array) {
       // NSLog(@"%@",array);
        if (array.count > 0){
            for (NSDictionary *chatGroupsDictionary in array) {
                SingleChatModel *chatModel = [[SingleChatModel alloc] initWithDictionary:chatGroupsDictionary];
                [arrayofChatGroups addObject:chatModel];
            }
            [self.tableView reloadData];
            if (array.count <20) {
                isEndOfLoading = YES;
            }else{
                pageNumber += 1;
            }
        }
        [activityIndicator stopAnimating];
        self.tableView.userInteractionEnabled = YES;
    }];
}

#pragma mark - UITableView Delegate & Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayofChatGroups.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SingleChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:singleChatCellIdentifier forIndexPath:indexPath];
    SingleChatModel *singleChat = arrayofChatGroups[indexPath.row];
    
    if ([singleChat.chatGroupModel.type isEqualToString:@"ONETOONE"]) {
        
        cell.profileImageView2.hidden = YES;
        NSArray *anotherUserArray;
        
        for (int i = 0 ; i < singleChat.chatGroupModel.usersMutableArray.count; i++) {
            
            anotherUserArray = [singleChat.chatGroupModel.usersMutableArray objectAtIndex:i];
            
            if (userId != [[anotherUserArray valueForKey:@"userId"]integerValue]) {
                break;
            }
        }
        cell.nameLabel.text = [anotherUserArray valueForKey:@"displayName"];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[anotherUserArray valueForKey:@"profilePicture"]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        cell.dataLabel.text = singleChat.messageTimePassed;
        
    }else{
        
        cell.profileImageView2.hidden = NO;
        NSMutableArray *usersArray = [[NSMutableArray alloc]init];
        usersArray = singleChat.chatGroupModel.usersMutableArray;
        NSInteger userIndex;
        
        for (int i = 0 ; i < usersArray.count; i++) {
            
            if (userId == [[[usersArray objectAtIndex:i] valueForKey:@"userId"]integerValue]) {
                userIndex = i;
                [usersArray removeObjectAtIndex:i];
                break;
            }
        }
        
        cell.nameLabel.text = singleChat.chatGroupModel.names;
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[usersArray[0] valueForKey:@"profilePicture"]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        [cell.profileImageView2 sd_setImageWithURL:[NSURL URLWithString:[usersArray[1] valueForKey:@"profilePicture"]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        cell.dataLabel.text = singleChat.messageTimePassed;
    }
    
    if ([singleChat.messageType isEqualToString:@"TEXT"]) {
        cell.messageLabel.text = singleChat.messageTextContent;
    }else if ([singleChat.messageType isEqualToString:@"MEDIA"]){
        cell.messageLabel.text = @"Sent you a post";
    }else{
        cell.messageLabel.text = @"sent you a product";
    }

    
    if (arrayofChatGroups.count-12 == indexPath.row) {
        if (!isEndOfLoading) {
            [self loadMoreDataWithPageNumber:pageNumber];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    SingleChatModel *singleChat = arrayofChatGroups[indexPath.row];
    
    NSMutableArray *usersArray = [[NSMutableArray alloc]init];
    usersArray = singleChat.chatGroupModel.usersMutableArray;
    NSInteger userIndex;
    
    for (int i = 0 ; i < usersArray.count; i++) {
        
        if (userId == [[[usersArray objectAtIndex:i] valueForKey:@"userId"]integerValue]) {
            userIndex = i;
            [usersArray removeObjectAtIndex:i];
            break;
        }
    }
    
    NSMutableArray *profileImagesArray = [NSMutableArray new];
    [profileImagesArray addObjectsFromArray:[usersArray valueForKey:@"profilePicture"]];
     
    ConversationViewController *conversationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"conversationVC"];
    conversationVC.groupId = singleChat.chatGroupModel.id;
    conversationVC.profileImagesArray = profileImagesArray;
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController pushViewController:conversationVC animated:YES];
}

#pragma mark - Button Action
-(void)cartClicked{
    
    [ServiceLayer googleTrackEventWithCategory:@"Shopping Cart Clicked" actionName:@"Discover Page's Cart Clicked" label:nil value:1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShoppingCart" bundle:nil];
    ShoppingCartTableViewController *aCartTableView = [storyboard instantiateInitialViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aCartTableView];
    [self.navigationController presentViewController:nav animated:YES completion:nil];

}

-(void)loadMoreDataWithPageNumber:(NSInteger)number{
    
    [[[ServiceLayer alloc]init]getChatMessageListWithPageNumber:number completion:^(NSArray *array) {
        
        for (NSDictionary *chatGroupsDictionary in array) {
            SingleChatModel *chatModel = [[SingleChatModel alloc] initWithDictionary:chatGroupsDictionary];
            [arrayofChatGroups addObject:chatModel];
        }
        [self.tableView reloadData];
        if (array.count <20) {
            isEndOfLoading = YES;
        }else{
            pageNumber += 1;
        }
    }];
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

@end
