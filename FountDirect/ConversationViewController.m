//
//  ConversationViewController.m
//  Fount Direct
//
//  Created by Zhang Xu on 6/29/16.
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

@interface ConversationViewController (){
    NSMutableArray *arrayOfMessages;
    NSInteger userId;
    CGFloat contentLabelHeight;
    UIRefreshControl *refreshControl;
    int pageNumber;
    BOOL isEndOfLoading;
}

//@property (nonatomic, assign) BOOL shouldShowKeyboard;

@end

@implementation ConversationViewController

static NSString *sendMessageIdentifier = @"sendMessageCell";
static NSString *receiveMessageIdentifier = @"receiveMessageCell";

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    if(self.shouldShowKeyboard){
//        [self.messageTextView becomeFirstResponder];
//    }
//}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    pageNumber = 1;
    arrayOfMessages = [NSMutableArray new];
    userId = [[[ServiceLayer alloc]init]getUserId];
    [self setupView];
    
    self.messageTextView.layer.borderWidth = 1;
    self.messageTextView.layer.borderColor = [UIColor customLightGrayColor].CGColor;
    self.messageTextView.layer.cornerRadius = 10;
    self.messageTextView.layer.masksToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SendMessageTableViewCell" bundle:nil] forCellReuseIdentifier:sendMessageIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ReceiveMessageTableViewCell" bundle:nil] forCellReuseIdentifier:receiveMessageIdentifier];
    
    [self getApiResponse];
    self.tabBarController.tabBar.tintColor = [UIColor themeColor];
    [self setupNavigationBar];
    
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
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 35)];
    //view.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *profileImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    UIImageView *profileImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(25, 0, 35, 35)];
    UIImageView *profileImageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(50, 0, 35, 35)];
    UIImageView *profileImageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(75, 0, 35, 35)];
    profileImageView4.image = [UIImage imageNamed:@"emptyProfile.png"];
    profileImageView4.backgroundColor = [UIColor whiteColor];
    
    [self setupProfileImagesWithImageView:profileImageView1];
    [self setupProfileImagesWithImageView:profileImageView2];
    [self setupProfileImagesWithImageView:profileImageView3];
    [self setupProfileImagesWithImageView:profileImageView4];

    [profileImageView1 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[0]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    if (self.profileImagesArray.count == 1) {
        
        profileImageView1.center = [view convertPoint:view.center fromView:view.superview];
        [view addSubview:profileImageView1];
        
    }else if (self.profileImagesArray.count == 2){
        [profileImageView2 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[1]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60+5, 35)];
        [view2 addSubview:profileImageView1];
        [view2 addSubview:profileImageView2];
        view2.center = [view convertPoint:view.center fromView:view.superview];
        [view addSubview:view2];
        
    }else if ( self.profileImagesArray.count == 3){
        [profileImageView2 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[1]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        [profileImageView3 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[2]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 85+5, 35)];
        [view2 addSubview:profileImageView1];
        [view2 addSubview:profileImageView2];
        [view2 addSubview:profileImageView3];
        view2.center = [view convertPoint:view.center fromView:view.superview];
        [view addSubview:view2];
        
    }else{
        [profileImageView2 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[1]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        [profileImageView3 sd_setImageWithURL:[NSURL URLWithString:self.profileImagesArray[2]] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 110+5, 35)];
        [view2 addSubview:profileImageView1];
        [view2 addSubview:profileImageView2];
        [view2 addSubview:profileImageView3];
        [view2 addSubview:profileImageView4];
        view2.center = [view convertPoint:view.center fromView:view.superview];
        [view addSubview:view2];
    }
    
    self.navigationItem.titleView = view;
    
//    UILabel *titleLabel = [UILabel new];
//    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"MESSAGE"];
//    [titleLabel sizeToFit];
//    self.navigationItem.titleView = titleLabel;
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
    lbl.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0f];
    lbl.textColor = [UIColor themeColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    
    NSInteger productsInCartCount = [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey];
    
    lbl.text = [NSString stringWithFormat:@"%li", (long)productsInCartCount];
    [lbl sizeToFit];
    
    
    UIButton *shoppingCartButton =  [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    [[[ServiceLayer alloc]init]getConversationWithGroupId:self.groupId pageNumber:1 completion:^(NSArray *array) {
       // NSLog(@"%@",array);
        if (array.count == 20) {
            pageNumber = 2;
        }
        NSMutableArray *orderArray = [NSMutableArray new];
        int count = (int)array.count;
        for (int i = count -1 ; i >= 0; i--) {
            [orderArray addObject:[array objectAtIndex:i]];
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
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        frame.size.height = screenSize.height;
        
        self.view.frame = frame;
    }];
}

-(void)closeKeyboard:(UITapGestureRecognizer *)recognizer{
    
    [self.messageTextView resignFirstResponder];
}

-(void)scrollToBottom{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrayOfMessages.count-1 inSection:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:19 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated: NO];
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
        //        [self scrollToBottom];
        
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
    
    if ([messageModel.type isEqualToString:@"MEDIA"] && textContentString.length == 0) {
        textContentString = @"Sent you a post";
    }else if ([messageModel.type isEqualToString:@"PRODUCT"] && textContentString.length == 0){
        textContentString = @"Sent you a product";
    }

    UIFont * labelFont = [UIFont fontWithName:@"SFUIText-Regular" size:15];
    CGSize labelSize = [textContentString sizeWithFont:labelFont];
    CGFloat labelWidth = labelSize.width;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (messageModel.fromUserId == userId) {
        
        SendMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sendMessageIdentifier forIndexPath:indexPath];

        if (screenSize.width - 25 - 15 - 2*8 >= labelWidth + 2*8) {
            
            cell.SendMessageViewWidthConstarint.constant = labelWidth + 2*8;
            cell.messageLabel.text = textContentString;
            contentLabelHeight = 50;
            
        }else{
            CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
            CGFloat newSize = ceilf(contentSize) - 1;
            contentLabelHeight = 50 + newSize * 25;
            cell.SendMessageViewWidthConstarint.constant = screenSize.width - 25 - 15 - 2*8;
            cell.messageLabel.text = textContentString;
        }
        
        if (arrayOfMessages.count -1 == indexPath.row) {
            [self scrollToBottom];
        }
        
        return cell;
        
    }else{
        ReceiveMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:receiveMessageIdentifier forIndexPath:indexPath];
        
        [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:messageModel.fromProfilePicture] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        cell.nameLabel.text = messageModel.fromUserDisplayName;

        if (screenSize.width - 34 - 46 - 2*8 >= labelWidth + 2*8) {
            
            cell.receiveMessageViewWidthConstraint.constant = labelWidth + 2*8;
            cell.messageLabel.text = textContentString;
            contentLabelHeight = 70;
            
        }else{
            
            CGFloat contentSize = (labelWidth + 2*8) / (screenSize.width - 25 - 15 - 2*8);
            CGFloat newSize = ceilf(contentSize) - 1;
            contentLabelHeight = 70 + newSize * 25;
            cell.receiveMessageViewWidthConstraint.constant = screenSize.width - 34 - 46 - 2*8;
            cell.messageLabel.text = textContentString;
        }
        
        if (textContentString.length <= 0) {
            cell.messageView.hidden = YES;
        }else{
            cell.messageView.hidden = NO;
        }
        
        if (arrayOfMessages.count -1 == indexPath.row) {
            [self scrollToBottom];
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

//    messageModel *messageModel = arrayOfMessages[indexPath.row];
//    if (messageModel.fromUserId == userId) {
//        return UITableview
//    }
//
//    if (contentHeightArray.count > 0 && contentHeightArray.count == indexPath.row) {
//        NSLog(@"%@",[contentHeightArray objectAtIndex:indexPath.row - 1]);
////        return [[contentHeightArray objectAtIndex:indexPath.row - 1]floatValue];
//    }else{
//        return 0;
//    }

    return contentLabelHeight;
}

#pragma mark - Button Action
-(void)cartClicked{
    [ServiceLayer googleTrackEventWithCategory:@"Shopping Cart Clicked" actionName:@"Discover Page's Cart Clicked" label:nil value:1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShoppingCart" bundle:nil];
    ShoppingCartTableViewController *aCartTableView = [storyboard instantiateInitialViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aCartTableView];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)sendButtonClicked:(UIButton *)sender {
    
    NSString *messageToPost = self.messageTextView.text;
    
    [[[ServiceLayer alloc]init]postConversationMessageWithChatGroupId:self.groupId messageType:@"TEXT" messageContent:messageToPost completion:^(NSDictionary *dictionary) {
        //NSLog(@"%@",dictionary);
        //NSLog(@"%@",arrayOfMessages);
        
        messageModel *messageModel1 = [[messageModel alloc]initWithDictionary:dictionary];
        messageModel1.textContent = messageToPost;
        messageModel1.type = @"TEXT";
        messageModel1.isVisible = YES;
        messageModel1.fromUserId = userId;
        
        [arrayOfMessages addObject:messageModel1];
        
//        NSIndexPath *indexPathForRow_end = [NSIndexPath indexPathForRow:arrayOfMessages.count-1 inSection:0];
//        
//        [self.tableView beginUpdates];
//        
//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathForRow_end, nil] withRowAnimation:UITableViewRowAnimationTop];
//        
//        [self.tableView endUpdates];
        [self.tableView reloadData];
        
        [self scrollToBottom];
        _messageTextView.text = @"";
        
    }];
}

-(void)pullToLoad:(id)sender{
    
    if (pageNumber > 1 && !isEndOfLoading) {
        
        [[[ServiceLayer alloc]init]getConversationWithGroupId:self.groupId pageNumber:pageNumber completion:^(NSArray *array) {
            // NSLog(@"%@",array);
            if (array.count < 20) {
                isEndOfLoading = YES;
            }
//            NSMutableArray *orderArray = [NSMutableArray new];
//            int count = (int)array.count;
//            for (int i = count -1 ; i >= 0; i--) {
//                [orderArray addObject:[array objectAtIndex:i]];
//            }
            
            for (NSDictionary *conversationDictionary in array) {
                messageModel *messageModel1 = [[messageModel alloc]initWithDictionary:conversationDictionary];
                //[arrayOfMessages addObject:messageModel1];
                [arrayOfMessages insertObject:messageModel1 atIndex:0];
            }
            [self.tableView reloadData];
            //[self scrollToBottom];
            
        }];
    }
    [refreshControl endRefreshing];
    
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
