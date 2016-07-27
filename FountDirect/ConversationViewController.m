//
//  ConversationsViewController.m
//  Fount
//
//  Created by Zhang Xu on 7/11/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ConversationViewController.h"
#import "UIColor+CustomColors.h"
#import "Constants.h"
#import "NSAttributedString+StringStyles.h"
#import "ServiceLayer.h"
#import "ShoppingCartTableViewController.h"
#import "SendMessageTableViewCell.h"
#import "ReceiveMessageTableViewCell.h"
#import "messageModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DirectMessageServiceLayer.h"
#import "OthersPostImageTableViewCell.h"
#import "MyPostImageTableViewCell.h"
#import "WebViewController.h"
#import "SelectColorAndSizeViewController.h"
#import "TwoTapModel.h"
#import "PDPAddToCartModel.h"
//#import "Media.h"

@interface ConversationViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate, myPostCellDelegate,othersPostCellDelegate>{
    
    NSMutableArray *arrayOfMessages;
    NSInteger userId;
    CGFloat contentLabelHeight;
    UIRefreshControl *refreshControl;
    int pageNumber;
    BOOL isEndOfLoading;
    UIView *coverView;
    NSDictionary *selectedProductDictionary;
    UIButton *shoppingCartButton;
    BOOL firstLandOnThisPage;
    CGFloat tableViewContentHeight;
    BOOL isLastCellNeedInVisibleRect;
}

@end

@implementation ConversationViewController

static NSString *sendMessageIdentifier = @"sendMessageCell";
static NSString *receiveMessageIdentifier = @"receiveMessageCell";
static NSString *othersPostIdentifier = @"OthersPostImageCell";
static NSString *myPostIdentifier = @"MyPostImageCell";

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appOpenPushReceived:) name:kPushAppActiveNotificationName object:nil];
    
    [self setupView];
    self.tabBarController.tabBar.tintColor = [UIColor themeColor];
    [self setupNavigationBar];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    firstLandOnThisPage = YES;
    tableViewContentHeight = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ColorSizeVCDismissed) name:@"ColorSizeVCDismissed" object:nil];
    
    pageNumber = 1;
    arrayOfMessages = [NSMutableArray new];
    userId = [[[ServiceLayer alloc]init]getUserId];
    
    self.messageTextView.layer.borderWidth = 1;
    self.messageTextView.layer.borderColor = [UIColor customLightGrayColor].CGColor;
    self.messageTextView.layer.cornerRadius = 10;
    self.messageTextView.layer.masksToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SendMessageTableViewCell" bundle:nil] forCellReuseIdentifier:sendMessageIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ReceiveMessageTableViewCell" bundle:nil] forCellReuseIdentifier:receiveMessageIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"OthersPostImageTableViewCell" bundle:nil] forCellReuseIdentifier:othersPostIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyPostImageTableViewCell" bundle:nil] forCellReuseIdentifier:myPostIdentifier];
    
    [self getApiResponse];
    
    //Add Pull to Load more:
    refreshControl = [[UIRefreshControl alloc]init];
    //refreshControl.backgroundColor = [UIColor themeColor];
    refreshControl.tintColor = [UIColor themeColor];
    refreshControl.tag = 0;
    [refreshControl addTarget:self action:@selector(pullToLoad:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

#pragma mark - Setup Methods
-(void) setupView {
    
    UITapGestureRecognizer *closeKeyboardTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyboard:)];
    
    //closeKeyboardTapGesture.cancelsTouchesInView = false;
    //[closeKeyboardTapGesture setDelegate:self];
    [self.view addGestureRecognizer:closeKeyboardTapGesture];
    
    self.view.userInteractionEnabled = YES;
    
    self.messageTextView.delegate = self;
    
    //    [self.messageButton setImage:[[UIImage imageNamed:@"comment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

-(void)setupNavigationBar{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor themeColor];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 100 , 40)];
    // view.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *profileImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    UIImageView *profileImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(25, 0, 25, 25)];
    UIImageView *profileImageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(50, 0, 25, 25)];
    UIImageView *profileImageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(75, 0, 25, 25)];
    profileImageView4.image = [UIImage imageNamed:@"emptyProfile.png"];
    profileImageView4.backgroundColor = [UIColor whiteColor];
    
    [self setupProfileImagesWithImageView:profileImageView1];
    [self setupProfileImagesWithImageView:profileImageView2];
    [self setupProfileImagesWithImageView:profileImageView3];
    [self setupProfileImagesWithImageView:profileImageView4];
    
    [profileImageView1 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[0]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    if (self.profileImagesArray.count == 1) {
        
        //profileImageView1.center = [view convertPoint:view.center fromView:view.superview];
        profileImageView1.center = CGPointMake(view.frame.size.width/2, 13);
        [view addSubview:profileImageView1];
        
    }else if (self.profileImagesArray.count == 2){
        
        [profileImageView2 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[1]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60+5, 25)];
        [view2 addSubview:profileImageView1];
        [view2 addSubview:profileImageView2];
        //view2.center = [view convertPoint:view.center fromView:view.superview];
        view2.center = CGPointMake(view.frame.size.width/2, 13);
        [view addSubview:view2];
        
    }else if ( self.profileImagesArray.count == 3){
        
        [profileImageView2 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[1]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        
        [profileImageView3 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[2]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 85+5, 25)];
        [view2 addSubview:profileImageView1];
        [view2 addSubview:profileImageView2];
        [view2 addSubview:profileImageView3];
        //view2.center = [view convertPoint:view.center fromView:view.superview];
        view2.center = CGPointMake(view.frame.size.width/2, 13);
        
        [view addSubview:view2];
        
    }else{
        
        
        [profileImageView2 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[1]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        
        [profileImageView3 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[2]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        
        
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 110+5, 25)];
        // view2.backgroundColor = [UIColor redColor];
        [view2 addSubview:profileImageView1];
        [view2 addSubview:profileImageView2];
        [view2 addSubview:profileImageView3];
        [view2 addSubview:profileImageView4];
        
        //view2.center = [view convertPoint:view.center fromView:view.superview];
        view2.center = CGPointMake(view.frame.size.width/2, 13);
        
        [view addSubview:view2];
    }
    
    UILabel *groupNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 28, view.frame.size.width, 13)];
    groupNameLabel.text = self.groupName;
    groupNameLabel.textAlignment = NSTextAlignmentCenter;
    groupNameLabel.font = [UIFont fontWithName:@"GillSans" size:12];
    groupNameLabel.textColor = [UIColor lightGrayColor];
    //[groupNameLabel sizeToFit];
    
    [view addSubview:groupNameLabel];
    
    self.navigationItem.titleView = view;
    
    [self setupShoppingCart];
    
}

-(void)setupProfileImagesWithImageView:(UIImageView *)imageView{
    //    imageView.frame = CGRectMake(0, 0, 35, 35);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    
}

-(void)setupShoppingCart{
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.font = [UIFont fontWithName:@"Gill Sans" size:15.0f];
    lbl.textColor = [UIColor themeColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    
    NSInteger productsInCartCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
    
    lbl.text = [NSString stringWithFormat:@"%li", (long)productsInCartCount];
    [lbl sizeToFit];
    
    
    shoppingCartButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    shoppingCartButton.frame = CGRectMake(0,0, 30, 30);
    shoppingCartButton.tintColor = [UIColor themeColor];
    [shoppingCartButton setBackgroundImage:[[UIImage imageNamed:@"cart2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shoppingCartButton addTarget:self action:@selector(cartClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //lbl.frame = CGRectMake(shoppingCartButton.layer.position.x - 4, shoppingCartButton.layer.position.y - 4.5, 15, 10);
    lbl.frame = CGRectMake(shoppingCartButton.bounds.origin.x + 9, shoppingCartButton.bounds.origin.y + 5, 15, 14);
    
    [shoppingCartButton addSubview:lbl];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:shoppingCartButton];
    self.navigationItem.rightBarButtonItem = barBtn;
    
}

-(void)getApiResponse{
    
    [[[DirectMessageServiceLayer alloc]init]getConversationWithGroupId:self.groupId pageNumber:1 completion:^(NSArray *array) {
        // NSLog(@"%@",array);
        
        [[[DirectMessageServiceLayer alloc]init]getChatUnreadMessages:^(NSDictionary *dictionary) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:[[dictionary objectForKey:@"NO_OF_GROUPS_UNREAD_MSG"]integerValue] forKey:kNumOfGroupsWithUnreadMsg];
        }];
        
        NSArray *groupArray = [array valueForKey:@"DM_CHAT_GROUP"];
        NSArray *messagesArray = [array valueForKey:@"DM_CHAT_GROUP_MESSAGES"];
        NSString *profileUrlString;
        
        if (self.groupName.length == 0) {
            self.groupName = [groupArray valueForKey:@"name"];
        }
        
        if (self.profileImagesArray.count == 0) {
            
            self.profileImagesArray = [NSMutableArray new];
            NSArray *usersArray = [groupArray valueForKey:@"users"];
            
            for (int i = 0; i < usersArray.count; i++) {
                if ([[[usersArray objectAtIndex:i]valueForKeyPath:@"user.id"]integerValue] != userId){
                    
                    profileUrlString = [[usersArray objectAtIndex:i]valueForKeyPath:@"user.userProfile.profilePicture"];
                    if (profileUrlString.length > 0) {
                        [self.profileImagesArray addObject:profileUrlString];
                    }else{
                        [self.profileImagesArray addObject:@"placeholderprofile"];
                    }
                }
            }
            self.navigationItem.backBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.titleView = nil;
            [self setupNavigationBar];
        }
        
        if (messagesArray.count == 20) {
            pageNumber = 2;
        }
        NSMutableArray *orderArray = [NSMutableArray new];
        int count = (int)messagesArray.count;
        for (int i = count -1 ; i >= 0; i--) {
            [orderArray addObject:[messagesArray objectAtIndex:i]];
        }
        
        for (NSDictionary *conversationDictionary in orderArray) {
            messageModel *messageModel1 = [[messageModel alloc]initWithDictionary:conversationDictionary];
            [arrayOfMessages addObject:messageModel1];
        }
        [self.tableView reloadData];
        //[self scrollToBottom];
        
    }];
}

#pragma mark - Keyboard Movement
-(void)keyboardWillShow:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = self.view.frame;
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        frame.size.height = screenSize.height - keyboardSize.height;
        
        self.view.frame = frame;
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self scrollToBottom];
        }
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification{
    
    [UIView animateWithDuration:0.1 animations:^{
        CGRect frame = self.view.frame;
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        frame.size.height = screenSize.height;
        
        self.view.frame = frame;
        
    }completion:^(BOOL finished) {
        if (finished) {
            [self scrollToBottom];
        }
    }];
}

-(void)closeKeyboard:(UITapGestureRecognizer *)recognizer{
    
    [self.messageTextView resignFirstResponder];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

-(void)scrollToBottom{
    firstLandOnThisPage = NO;
    isLastCellNeedInVisibleRect = YES;
    
    NSArray *visibleCellsIndexPathsArrays = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrayOfMessages.count-1 inSection:0];
    
    if ([visibleCellsIndexPathsArrays containsObject:indexPath]) {
        
        UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.tableView scrollRectToVisible:lastCell.frame animated:NO];
        
    }else{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated: NO];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //    NSLog(@"%f",self.tableView.contentOffset.y);
    //    NSLog(@"tableVIewHairhgt: %f",self.tableView.frame.size.height);
    
}

#pragma mark - UITextView Delegate
//-(void)textViewDidBeginEditing:(UITextView *)textView{
//
//}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (self.messageTextView.text.length >= 2200) {
        return NO;
    }
    
    if ([text isEqualToString:@"\n"] && self.messageTextView.text.length > 0 ) {
        
        //        if (![self.messageTextView.text isEqualToString:@"\n"]) {
        //            [self postButtonClicked:self.postButton];
        //        }
        //[self sendButtonClicked:self.sendButton];
        [_messageTextView resignFirstResponder];
        return NO;
    }
    
    CGSize sizeThatFitsTextView = [self.messageTextView sizeThatFits:CGSizeMake(self.messageTextView.frame.size.width, MAXFLOAT)];
    NSInteger maxHeight = 70;
    
    if (self.messageTextViewHeightConstraint.constant < maxHeight) {
        
        self.messageTextViewHeightConstraint.constant = sizeThatFitsTextView.height + 7;
        self.messageTextView.scrollEnabled = NO;
        
    } else if([text isEqualToString:@""] && sizeThatFitsTextView.height + 7 < maxHeight) {
        
        self.messageTextViewHeightConstraint.constant = sizeThatFitsTextView.height + 7;
        
    } else {
        
        self.messageTextView.scrollEnabled = YES;
    }
    
    return YES;
}

//-(void)textViewDidEndEditing:(UITextView *)textView{
//    [_messageTextView resignFirstResponder];
//}

#pragma mark - UITableView Delegate & Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayOfMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    messageModel *messageModel = arrayOfMessages[indexPath.row];
    
    NSString *textContentString = messageModel.textContent;
    
    //SFUIText-Regular
    //    UIFont * labelFont = [UIFont fontWithName:@"SFUIText-Regular" size:15.0];
    //    CGSize labelSize = [textContentString sizeWithFont:labelFont];
    //    CGFloat labelWidth = labelSize.width;
    //    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (messageModel.fromUserId == userId) {
        
        //MEDIA
        if ([messageModel.type isEqualToString:@"MEDIA"]) {
            
            MyPostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myPostIdentifier forIndexPath:indexPath];
            
            cell.delegate = self;
            cell.messageType = messageModel.type;
            
            if (messageModel.arrayOfProducts.count == 0){
                cell.collectionViewLeadingConstraint.constant = [[UIScreen mainScreen] bounds].size.width - 220;
            }else{
                cell.collectionViewLeadingConstraint.constant = 0;
            }
            
            UIFont *labelFont = [cell.messageLabel.font fontWithSize:15];
            CGSize labelSize = [textContentString sizeWithFont:labelFont];
            CGFloat labelWidth = labelSize.width;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            if (screenSize.width - 25 - 15 - 2*8 >= labelWidth + 2*8) {
                
                cell.messageViewWidthConstraint.constant = labelWidth + 2*8;
                cell.messageLabel.text = textContentString;
                cell.messageViewHeightConstraint.constant = 35;
            }else{
                CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
                CGFloat newSize = ceilf(contentSize) - 1;
                cell.messageViewHeightConstraint.constant = 35 + newSize * 25;
                cell.messageViewWidthConstraint.constant = screenSize.width - 25 - 15 - 2*8;
                cell.messageLabel.text = textContentString;
            }
            
            if (textContentString.length <= 0) {
                cell.messageView.hidden = YES;
                cell.messageViewHeightConstraint.constant = 16;
            }else{
                cell.messageView.hidden = NO;
            }
            
            contentLabelHeight = 31 + cell.messageViewHeightConstraint.constant + 10 + 320 + 37 + 8 + 5 -31;
            
            NSMutableArray *productsMutableArray = [NSMutableArray new];
            [productsMutableArray addObject:@"nilProduct[0]"];
            [productsMutableArray addObjectsFromArray:messageModel.arrayOfProducts];
            cell.productsArray = productsMutableArray;
            cell.contentsCount = productsMutableArray.count;
            
            cell.mediaDictionary = messageModel.mediaDictionary;
            
            [cell.collectionView reloadData];
            
            if (arrayOfMessages.count -1 == indexPath.row && firstLandOnThisPage) {
                [self scrollToBottom];
                
                //                [cell.collectionView performBatchUpdates:^{
                //
                //                } completion:^(BOOL finished) {
                //                    [self scrollToBottom];
                //                }];
            }
            
            return cell;
            
            //PRODUCTS
        }else if ([messageModel.type isEqualToString:@"PRODUCTS"]){
            
            MyPostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myPostIdentifier forIndexPath:indexPath];
            
            cell.delegate = self;
            
            //            if (messageModel.arrayOfRelevantMedias.count == 0){
            //                cell.collectionViewLeadingConstraint.constant = [[UIScreen mainScreen] bounds].size.width - 220;
            //            }else{
            cell.collectionViewLeadingConstraint.constant = 0;
            //            }
            
            UIFont *labelFont = [cell.messageLabel.font fontWithSize:15];
            CGSize labelSize = [textContentString sizeWithFont:labelFont];
            CGFloat labelWidth = labelSize.width;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            if (screenSize.width - 25 - 15 - 2*8 >= labelWidth + 2*8) {
                
                cell.messageViewWidthConstraint.constant = labelWidth + 2*8;
                cell.messageLabel.text = textContentString;
                cell.messageViewHeightConstraint.constant = 35;
            }else{
                
                CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
                CGFloat newSize = ceilf(contentSize) - 1;
                cell.messageViewHeightConstraint.constant = 35 + newSize * 25;
                cell.messageViewWidthConstraint.constant = screenSize.width - 25 - 15 - 2*8;
                cell.messageLabel.text = textContentString;
            }
            
            if (textContentString.length <= 0) {
                cell.messageView.hidden = YES;
                cell.messageViewHeightConstraint.constant = 16;
            }else{
                cell.messageView.hidden = NO;
            }
            
            contentLabelHeight = 31 + cell.messageViewHeightConstraint.constant + 10 + 320 + 37 + 8 + 5 -31;
            
            NSMutableArray *mediaMutableArray = [NSMutableArray new];
            [mediaMutableArray addObject:@"nilMedia[0]"];
            [mediaMutableArray addObjectsFromArray:messageModel.arrayOfRelevantMedias];
            
            cell.contentsCount = mediaMutableArray.count;
            cell.productsArray = messageModel.arrayOfProducts;
            cell.relevantMediaArray = mediaMutableArray;
            cell.messageType = messageModel.type;
            [cell.collectionView reloadData];
            
            if (arrayOfMessages.count -1 == indexPath.row && firstLandOnThisPage) {
                [self scrollToBottom];
            }
            
            return cell;
            
            //TEXT
        }else{
            
            SendMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sendMessageIdentifier forIndexPath:indexPath];
            
            UIFont *labelFont = [cell.messageLabel.font fontWithSize:15];
            CGSize labelSize = [textContentString sizeWithFont:labelFont];
            CGFloat labelWidth = labelSize.width;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            if (screenSize.width - 25 - 15 - 2*8 >= labelWidth + 2*8) {
                
                cell.SendMessageViewWidthConstarint.constant = labelWidth + 2*8;
                cell.messageLabel.text = textContentString;
                contentLabelHeight = 50;
                cell.sendMessageViewHeightConstraint.constant = 35;
                
            }else{
                CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
                CGFloat newSize = ceilf(contentSize) - 1;
                contentLabelHeight = 50 + newSize * 25;
                cell.SendMessageViewWidthConstarint.constant = screenSize.width - 25 - 15 - 2*8;
                cell.messageLabel.text = textContentString;
                cell.sendMessageViewHeightConstraint.constant = 35 + newSize * 20;
            }
            
            if (textContentString.length <= 0) {
                cell.messageView.hidden = YES;
            }else{
                cell.messageView.hidden = NO;
            }
            
            if (arrayOfMessages.count -1 == indexPath.row && firstLandOnThisPage) {
                [self scrollToBottom];
            }
            
            return cell;
        }
        
    }else{
        
        //MEDIA
        if ([messageModel.type isEqualToString:@"MEDIA"]) {
            
            OthersPostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:othersPostIdentifier forIndexPath:indexPath];
            cell.delegate = self;
            cell.messageType = messageModel.type;
            
            UIFont *labelFont = [cell.messageLabel.font fontWithSize:15];
            CGSize labelSize = [textContentString sizeWithFont:labelFont];
            CGFloat labelWidth = labelSize.width;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            if (screenSize.width - 25 - 15 - 2*8 >= labelWidth + 2*8) {
                
                cell.messageViewWidthConstraint.constant = labelWidth + 2*8;
                cell.messageLabel.text = textContentString;
                cell.messageViewHeightConstraint.constant = 35;
                
            }else{
                CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
                CGFloat newSize = ceilf(contentSize) - 1;
                cell.messageViewHeightConstraint.constant = 35 + newSize * 25;
                cell.messageViewWidthConstraint.constant = screenSize.width - 25 - 15 - 2*8;
                cell.messageLabel.text = textContentString;
            }
            
            if (textContentString.length == 0) {
                cell.messageView.hidden = YES;
                cell.messageViewHeightConstraint.constant = 16;
                cell.profileToTopConstraint.constant = 8;
            }else{
                cell.messageView.hidden = NO;
                cell.profileToTopConstraint.constant = 30;
                
            }
            
            contentLabelHeight = 31 + cell.messageViewHeightConstraint.constant + 10 + 320 + 37 + 8 + 5;
            
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.fromProfilePicture] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
            cell.nameLabel.text = messageModel.fromUserDisplayName;
            
            NSMutableArray *productsMutableArray = [NSMutableArray new];
            [productsMutableArray addObject:@"nilProduct[0]"];
            [productsMutableArray addObjectsFromArray:messageModel.arrayOfProducts];
            cell.productsArray = productsMutableArray;
            cell.contentsCount = productsMutableArray.count;
            cell.mediaDictionary = messageModel.mediaDictionary;
            [cell.collectionView reloadData];
            
            if (arrayOfMessages.count -1 == indexPath.row && firstLandOnThisPage) {
                [self scrollToBottom];
            }
            
            return cell;
            
            //PRODUCTS
        }else if ([messageModel.type isEqualToString:@"PRODUCTS"]){
            
            OthersPostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:othersPostIdentifier forIndexPath:indexPath];
            
            cell.delegate = self;
            
            UIFont *labelFont = [cell.messageLabel.font fontWithSize:15];
            CGSize labelSize = [textContentString sizeWithFont:labelFont];
            CGFloat labelWidth = labelSize.width;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            if (screenSize.width - 25 - 15 - 2*8 >= labelWidth + 2*8) {
                
                cell.messageViewWidthConstraint.constant = labelWidth + 2*8;
                cell.messageLabel.text = textContentString;
                cell.messageViewHeightConstraint.constant = 35;
            }else{
                
                CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
                CGFloat newSize = ceilf(contentSize) - 1;
                cell.messageViewHeightConstraint.constant = 35 + newSize * 25;
                cell.messageViewWidthConstraint.constant = screenSize.width - 25 - 15 - 2*8;
                cell.messageLabel.text = textContentString;
            }
            
            if (textContentString.length == 0) {
                cell.messageView.hidden = YES;
                cell.messageViewHeightConstraint.constant = 16;
                cell.profileToTopConstraint.constant = 8;
            }else{
                cell.messageView.hidden = NO;
                cell.profileToTopConstraint.constant = 30;
                
            }
            
            contentLabelHeight = 31 + cell.messageViewHeightConstraint.constant + 10 + 320 + 37 + 8 + 5;
            
            if (messageModel.fromProfilePicture.length != 0) {
                [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.fromProfilePicture] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                }];
            }
            cell.nameLabel.text = messageModel.fromUserDisplayName;
            
            NSMutableArray *mediaMutableArray = [NSMutableArray new];
            [mediaMutableArray addObject:@"nilMedia[0]"];
            [mediaMutableArray addObjectsFromArray:messageModel.arrayOfRelevantMedias];
            
            cell.contentsCount = mediaMutableArray.count;
            cell.productsArray = messageModel.arrayOfProducts;
            cell.relevantMediaArray = mediaMutableArray;
            cell.messageType = messageModel.type;
            [cell.collectionView reloadData];
            
            if (arrayOfMessages.count -1 == indexPath.row && firstLandOnThisPage) {
                [self scrollToBottom];
            }
            return cell;
            
            //TEXT
        }else{
            
            ReceiveMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:receiveMessageIdentifier forIndexPath:indexPath];
            UIFont *labelFont = [cell.messageLabel.font fontWithSize:15];
            CGSize labelSize = [textContentString sizeWithFont:labelFont];
            CGFloat labelWidth = labelSize.width;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            
            [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:messageModel.fromProfilePicture] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
            cell.nameLabel.text = messageModel.fromUserDisplayName;
            
            if (screenSize.width - 34 - 46 - 2*8 >= labelWidth + 2*8) {
                
                cell.receiveMessageViewWidthConstraint.constant = labelWidth + 2*8;
                cell.messageLabel.text = textContentString;
                contentLabelHeight = 70;
                cell.receiveMessageViewHeightConstraint.constant = 35;
                
            }else{
                
                CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
                CGFloat newSize = ceilf(contentSize) - 1;
                contentLabelHeight = 70 + newSize * 25;
                cell.receiveMessageViewWidthConstraint.constant = screenSize.width - 34 - 46 - 2*8;
                cell.messageLabel.text = textContentString;
                cell.receiveMessageViewHeightConstraint.constant = 35 + newSize * 20;
            }
            
            if (textContentString.length <= 0) {
                cell.messageView.hidden = YES;
            }else{
                cell.messageView.hidden = NO;
            }
            
            if (arrayOfMessages.count -1 == indexPath.row && firstLandOnThisPage) {
                [self scrollToBottom];
            }
            
            return cell;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return contentLabelHeight;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((indexPath.row == arrayOfMessages.count -1) && isLastCellNeedInVisibleRect) {
        isLastCellNeedInVisibleRect = NO;
        [self.tableView scrollRectToVisible:cell.frame animated:NO];
    }
}


#pragma mark - Button Action
-(void)cartClicked{
    [ServiceLayer googleTrackEventWithCategory:@"Shopping Cart Clicked" actionName:@"Discover Page's Cart Clicked" label:nil value:1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShoppingCart" bundle:nil];
    ShoppingCartTableViewController *aCartTableView = [storyboard instantiateInitialViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aCartTableView];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)sendButtonClicked:(id)sender {
    
    if (self.messageTextView.text.length > 0) {
        
        NSDictionary *chatDictionary = @{@"chatGroupID":@(self.groupId),@"type":@"TEXT", @"text":self.messageTextView.text};
        
        NSLog(@"%@",self.messageTextView.text);
        
        [[[DirectMessageServiceLayer alloc]init]postDMChatMessageWithChatDictionary:chatDictionary completion:^(NSDictionary *dictionary) {
            
            messageModel *messageModel1 = [[messageModel alloc]initWithDictionary:dictionary];
            messageModel1.textContent = self.messageTextView.text;
            messageModel1.type = @"TEXT";
            messageModel1.isVisible = YES;
            messageModel1.fromUserId = userId;
            
            [arrayOfMessages addObject:messageModel1];
            
            //firstLandOnThisPage = YES;
            [self.tableView reloadData];
            _messageTextView.text = @"";
            [self scrollToBottom];
        }];
    }
    
}

-(void)pullToLoad:(id)sender{
    
    if (pageNumber > 1 && !isEndOfLoading) {
        
        [[[DirectMessageServiceLayer alloc]init]getConversationWithGroupId:self.groupId pageNumber:pageNumber completion:^(NSArray *array) {
            // NSLog(@"%@",array);
            NSArray *messagesArray = [array valueForKey:@"DM_CHAT_GROUP_MESSAGES"];
            
            if (messagesArray.count < 20) {
                isEndOfLoading = YES;
            }else{
                pageNumber += 1;
            }
            for (NSDictionary *conversationDictionary in messagesArray) {
                messageModel *messageModel1 = [[messageModel alloc]initWithDictionary:conversationDictionary];
                //[arrayOfMessages addObject:messageModel1];
                [arrayOfMessages insertObject:messageModel1 atIndex:0];
            }
            [self.tableView reloadData];
        }];
    }
    [refreshControl endRefreshing];
}

#pragma mark - MyPostProductCell Delegate
-(void)myPostGoToWebsite:(NSDictionary *)productDictionary{
    [self goToWebsiteMethodWithProductDictionary:productDictionary];
}

-(void)myPostAddTocart:(NSDictionary *)productDictionary{
    [self adddToCartMethodWithProductDictionary:productDictionary];
}

-(void)scrollToBottomCollectionView{
    //[self scrollToBottom];
}

#pragma mark - OthersPostProductCell Delegate
-(void)othersPostGoToWebsite:(NSDictionary *)productDictionary{
    [self goToWebsiteMethodWithProductDictionary:productDictionary];
}

-(void)othersPostAddTocart:(NSDictionary *)productDictionary{
    
    [self adddToCartMethodWithProductDictionary:productDictionary];
}


#pragma mark - Add to cart and go to website methods
-(void)adddToCartMethodWithProductDictionary:(NSDictionary *)productDictionary{
    
    [ServiceLayer googleTrackEventWithCategory:kEventCategoryAddToCart actionName:kEventActionAddToCart label:kEventLabelGoingToOptionsSelection value:1];
    selectedProductDictionary = [NSDictionary new];
    selectedProductDictionary = productDictionary;
    
    if ([productDictionary valueForKey:@"twoTapDictionary"]) {
        
        NSArray *filedNameArray = [[productDictionary valueForKey:@"twoTapDictionary"]valueForKey:@"required_field_names"];
        if (filedNameArray.count==1 && [[filedNameArray objectAtIndex:0] isEqualToString:@"quantity"] ){
            
            ServiceLayer *aService = [[ServiceLayer alloc]init];
            [aService postShopAddToCart:[self formatedParametersDict] completion:^(NSDictionary *dictionary) {
                if (dictionary.count > 0) {
                    self.navigationItem.rightBarButtonItem = nil;
                    
                    [UIView transitionWithView:shoppingCartButton duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                        [self setupShoppingCart];
                    } completion:^(BOOL finished) {
                    }];
                }
            }];
            
        }else{
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductDetail" bundle:nil];
            SelectColorAndSizeViewController *destController= [storyboard instantiateViewControllerWithIdentifier:@"selectColorAndSizeVC"];
            TwoTapModel *model = [TwoTapModel new];
            [model setupWithDictionary:[productDictionary valueForKey:@"twoTapDictionary"]];
            
            destController.dataSource = model;
            destController.aModel = [self getAddtocartModel:productDictionary];
            //    vc.mediaArray = relevantPostsArray;
            destController.fieldName0 = [filedNameArray objectAtIndex:0];
            destController.qualityStr = @"High";
            destController.sellerName = [productDictionary valueForKeyPath:@"seller.name"];
            destController.buyURL = [productDictionary valueForKey:@"buyURL"];
            
            destController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self.navigationController presentViewController:destController animated:YES completion:nil];
        }
    }
    
}

-(void)goToWebsiteMethodWithProductDictionary:(NSDictionary *)productDictionary{
    [ServiceLayer googleTrackEventWithCategory:kEventCategoryAddToCart actionName:kEventActionAddToCart label:kEventLabelGoingToWeb value:1];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProductDetail" bundle:nil];
    WebViewController *destController= [storyboard instantiateViewControllerWithIdentifier:@"webVC"];
    destController.buyURLStr = [productDictionary valueForKey:@"buyURL"];
    destController.sellerName = [productDictionary valueForKeyPath:@"seller.name"];
    destController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:destController animated:YES];
}

-(PDPAddToCartModel*)getAddtocartModel:(NSDictionary*)productDict{
    
    ServiceLayer *aService = [[ServiceLayer alloc] init];
    
    userId = [aService getUserId];
    NSString* aUserIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    
    PDPAddToCartModel *aModel = [[PDPAddToCartModel alloc] init];
    aModel.userId = aUserIdStr;
    aModel.productId = [productDict valueForKey:@"productId"];
    aModel.productMetadata_productId = [productDict valueForKey:@"productId"];
    //aModel.mediaId = relevantPostId;
    //aModel.visualTagId = visualTagId;
    aModel.productMetadata_option = @" ";
    aModel.productMetadata_fit = @" ";
    aModel.productMetadata_color = @" ";
    aModel.productMetadata_size = @" ";
    aModel.productMetadata_options = @" ";
    aModel.productMetadata_inseam = @" ";
    aModel.productMetadata_style = @" ";
    aModel.productMetadata_option1 = @" ";
    aModel.productMetadata_option2 = @" ";
    aModel.productMetadata_option3 = @" ";
    aModel.productMetadata_option4 = @" ";
    //aModel.price = [productDict valueForKey:@"TTPrice"];
    NSString *priceWOSign = [[productDict valueForKey:@"TTPrice"] stringByReplacingOccurrencesOfString:@"$" withString:@""];
    aModel.price = priceWOSign;
    aModel.productMetadata_availability = @"AVAILABLE";
    aModel.quantity = @"1";
    aModel.shippingMethod = [productDict valueForKey:@"shippingOption"];
    aModel.originalUrl = [productDict valueForKey:@"buyURL"];
    
    return aModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDictionary*)formatedParametersDict{
    //    NSLog(@"%@",[productDetailDict valueForKey:@"buyURL"]);
    NSString *userIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    //    NSLog(@"%@ /// %@",relevantPostId,visualTagId);
    //    NSLog(@"%@",cheapShipping);
    NSDictionary *parameters = @{@"user[id]": userIdStr,
                                 @"product[id]":[selectedProductDictionary valueForKey:@"productId"],
                                 // @"media[id]":relevantPostId,
                                 // @"visualTag[id]":visualTagId,
                                 @"productMetadata[product][id]":[selectedProductDictionary valueForKey:@"productId"],
                                 @"productMetadata[option]":[NSNull null] ,
                                 @"productMetadata[fit]":[NSNull null] ,
                                 @"productMetadata[color]":[NSNull null] ,
                                 @"productMetadata[size]":[NSNull null],
                                 @"productMetadata[options]":[NSNull null],
                                 @"productMetadata[inseam]":[NSNull null] ,
                                 @"productMetadata[style]": [NSNull null],
                                 @"productMetadata[option1]":[NSNull null],
                                 @"productMetadata[option2]":[NSNull null] ,
                                 @"productMetadata[option3]":[NSNull null] ,
                                 @"productMetadata[option4]":[NSNull null] ,
                                 //@"productMetadata[price]":[productDetailDict valueForKey:@"finalPrice"] ,
                                 @"productMetadata[price]":[selectedProductDictionary valueForKey:@"TTPrice"]?[[selectedProductDictionary valueForKey:@"TTPrice"] stringByReplacingOccurrencesOfString:@"$" withString:@""]:[NSNull null],
                                 @"productMetadata[availability]":@"AVAILABLE",
                                 @"quantity":@"1" ,
                                 @"shippingMethod":[selectedProductDictionary valueForKey:@"shippingOption"] ? [selectedProductDictionary valueForKey:@"shippingOption"] : [NSNull null],
                                 @"originalUrl":[selectedProductDictionary valueForKey:@"buyURL"],
                                 };
    
    //NSLog(@"FORMATTED PARAM:%@", parameters);
    
    return parameters;
}

-(void)ColorSizeVCDismissed{
    self.navigationItem.rightBarButtonItem = nil;
    [UIView transitionWithView:shoppingCartButton duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [self setupShoppingCart];
    } completion:^(BOOL finished) {
    }];
}

-(void)appOpenPushReceived:(NSNotification *)notification{
    
    NSDictionary *objectDictionary = [notification valueForKey:@"object"];
    NSString *notificationType = [objectDictionary valueForKey:@"NOTIFICATION_TYPE"];
    NSInteger sentFromId = [[objectDictionary valueForKey:@"SENT_FROM_ID"]integerValue];
    
    if ([notificationType isEqualToString:@"CHAT_MESSAGE_POST"] && sentFromId != userId) {
        
        NSInteger chatReferenceId = [[objectDictionary objectForKey:@"CHAT_REFERENCE_ID"]integerValue];
        
        //NSInteger numOfGroupsWithUnreadMsg = [[objectDictionary valueForKey:@"NO_OF_GROUPS_UNREAD_MSG"]integerValue];
        
        [[[DirectMessageServiceLayer alloc]init]getChatMessageWithReferenceId:chatReferenceId completion:^(NSDictionary *dictionary) {
            
            //Just Get Call to let backend know that I have read this new push notification.
            [[[DirectMessageServiceLayer alloc]init]getChatUnreadMessages:^(NSDictionary *dictionary) {
                
                [[NSUserDefaults standardUserDefaults] setInteger:[[dictionary objectForKey:@"NO_OF_GROUPS_UNREAD_MSG"]integerValue] forKey:kNumOfGroupsWithUnreadMsg];
            }];
            
            NSLog(@"%@",dictionary);
            NSInteger sentFromUserId = [[dictionary valueForKeyPath:@"from.id"]integerValue];
            if (sentFromUserId != userId) {
                messageModel *messageModel1 = [[messageModel alloc]initWithDictionary:dictionary];
                //[arrayOfMessages addObject:messageModel1];
                [arrayOfMessages insertObject:messageModel1 atIndex:arrayOfMessages.count];
                firstLandOnThisPage = YES;
                [self.tableView reloadData];
                [self scrollToBottom];
            }
        }];
    }
    
}

//Get Relevant Post API
//relevent posts api call
//[[[ServiceLayer alloc] init] getReleventPostsWithProductId:aProductId pageNumber:@"0" completion:^(NSArray *array) {
//    relevantPostsArray = [array mutableCopy];
//    relevantPostId = [relevantPostsArray valueForKey:@"id"];
//
//    BOOL isEmpty = ([relevantPostsArray count] == 0);
//    if (!isEmpty) {
//        [[[ServiceLayer alloc] init] getVisualTagId:relevantPostId productId:aProductId completion:^(NSDictionary *dictionary) {
//            NSMutableDictionary *visualIdDict = [[NSMutableDictionary alloc]init];
//            visualIdDict = [dictionary mutableCopy];
//            //NSLog(@"VISUALTAGEID:%@",visualIdDict);
//            visualTagId = [[visualIdDict objectForKey:@"payload"] valueForKey:@"VISUAL_TAG_ID"];
//
//        }];
//    }
//
//
//    [self loadDetailView];
//}];




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
