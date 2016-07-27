//
//  LikesPeopleTableViewController.m
//  Fount
//
//  Created by Xu Zhang on 12/22/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "LikesPeopleTableViewController.h"
#import "ServiceLayer.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+CustomColors.h"
#import "likesPeopleTableCell.h"
#import "Constants.h"
#import "NSAttributedString+StringStyles.h"
//#import "GuestPromptViewController.h"
//#import "PublicProfileViewController.h"

@interface LikesPeopleTableViewController ()

@end

@implementation LikesPeopleTableViewController
@synthesize likesPeopleInfoArray;
@synthesize instagramPeopleInfoArray;
@synthesize media;
@synthesize refountUserActionDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"LIKES"];
    if (self.fromRefountUsers){
        titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"REFOUNT"];
    }
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
   // NSLog(@"likesPeopleInfoArray:%@",likesPeopleInfoArray);
   // NSLog(@"instagramPeopleInfoArray:%@",instagramPeopleInfoArray);
    likesPeopleInfoArray=[[NSMutableArray alloc]init];
    instagramPeopleInfoArray=[[NSMutableArray alloc]init];
    refountUserActionDictionary = [[NSMutableDictionary alloc]init];
    
    if(media!=nil){
        if (!self.fromRefountUsers) {
            [self loadMoreInstagramLikes:1];
        }
        [self loadMorelikes:1];
    }else{
        [self loadMorelikes:1];
    }
    
    //Remove back button's text
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void) presentGuestPromptViewController {
//    GuestPromptViewController *guestPromptVC = [[GuestPromptViewController alloc] init];
//    guestPromptVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    
//    [self presentViewController:guestPromptVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(instagramPeopleInfoArray.count>0){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return likesPeopleInfoArray.count;
    }else{
        return instagramPeopleInfoArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"likesPeopleCell";
    
    likesPeopleTableCell  *aLikedCell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // if (aLikedCell == nil) {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"likesPeopleTableCell" owner:self options:nil];
    aLikedCell =(likesPeopleTableCell *) [topLevelObjects objectAtIndex:0];
    //}
    if(indexPath.section==0){
        if(likesPeopleInfoArray.count%20==0){
            
            if(likesPeopleInfoArray.count-1==indexPath.row){
                int page=((int)(indexPath.row+1)/20)+1;
                [self loadMorelikes:page];
            }
        }
        NSString *igUserPicString =[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"igProfilePicture"];
        NSString *userDataString=[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"fountProfilePicture"];
        if (userDataString == nil) {
            userDataString = igUserPicString;
        }
        
        aLikedCell.likedUserName.text=[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"fountUserDisplayName"];
        aLikedCell.likedUserName.textColor=[UIColor themeColor];
        BOOL followBoolStr = [[likesPeopleInfoArray valueForKey:@"socialAction"] containsObject:[NSString stringWithFormat:@"%tu",indexPath.row]];
        
        if (_fromRefountUsers) {
            userDataString = [[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKeyPath:@"userProfile.profilePicture"];
            aLikedCell.likedUserName.text=[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"displayName"];
            NSString *userIdString = [NSString stringWithFormat:@"%@",[[likesPeopleInfoArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
            
            followBoolStr = [[[refountUserActionDictionary valueForKey:userIdString]valueForKey:@"follow"]boolValue];
        }
        
        if (followBoolStr==1) {
            aLikedCell.followButton.backgroundColor = [UIColor themeColor];
            [aLikedCell.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [aLikedCell.followButton setTitle:@"Following" forState:UIControlStateNormal];
        }else{
            BOOL followBool=[[[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"socialAction"]valueForKey:@"follow"]boolValue];
            if (followBool) {
                aLikedCell.followButton.backgroundColor = [UIColor themeColor];
                [aLikedCell.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [aLikedCell.followButton setTitle:@"Following" forState:UIControlStateNormal];
            }else{
                aLikedCell.followButton.backgroundColor = [UIColor clearColor];
                [aLikedCell.followButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                [aLikedCell.followButton setTitle:@"+Follow" forState:UIControlStateNormal];
            }
        }
        
        [aLikedCell.followButton addTarget:self action:@selector(followingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        aLikedCell.followButton.layer.borderColor=[UIColor themeColor].CGColor;
        aLikedCell.followButton.layer.borderWidth=1.0f;
        aLikedCell.followButton.layer.cornerRadius=4.0f;
        aLikedCell.likedUserName.tag=indexPath.row;
        aLikedCell.followButton.tag=[[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"fountUserId"] integerValue];
        //aLikedCell.detailUserLabel.text=[NSString stringWithFormat:@"UserId:%@",[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"igUserId"]];
        if (_fromRefountUsers) {
            aLikedCell.followButton.tag=[[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"id"] integerValue];
        }
        aLikedCell.detailUserLabel.text = [NSString stringWithFormat:@""];
        
#pragma profilePic
        [aLikedCell.profileImage sd_setImageWithURL:[NSURL URLWithString:userDataString] placeholderImage:[UIImage imageNamed:@"placeholderprofile"]];
        aLikedCell.profileImage.userInteractionEnabled = YES;
        aLikedCell.profileImage.tag = indexPath.row;
        UITapGestureRecognizer *profileTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTapped:)];
        [aLikedCell.profileImage addGestureRecognizer:profileTapGesture];
        aLikedCell.profileImage.layer.cornerRadius = aLikedCell.profileImage.frame.size.width / 2;
        aLikedCell.profileImage.clipsToBounds = YES;
        [aLikedCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        aLikedCell.likedUserName.userInteractionEnabled = YES;
        aLikedCell.likedUserName.tag = indexPath.row;
        UITapGestureRecognizer *userNameTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userNameTapped:)];
        [aLikedCell.likedUserName addGestureRecognizer:userNameTapGesture];
        int likedUserId = [[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"fountUserId"] intValue];
        if (_fromRefountUsers) {
            likedUserId = [[[likesPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"id"] intValue];
        }
        if (likedUserId == [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey] intValue]) {
            aLikedCell.followButton.hidden=YES;
            aLikedCell.lineView.hidden=YES;
        }
        
    }else {
        if(instagramPeopleInfoArray.count%20==0 && !_fromRefountUsers){
            
            if(instagramPeopleInfoArray.count-1==indexPath.row){
                int page=((int)(indexPath.row+1)/20)+1;
                
                [self loadMoreInstagramLikes:page];
            }
        }
        NSString *userDataString=[[instagramPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"igProfilePicture"];
        aLikedCell.likedUserName.text=[[instagramPeopleInfoArray objectAtIndex:indexPath.row]valueForKey:@"igUserName"];
        //aLikedCell.likedUserName.textColor=[UIColor colorWithRed:18/255  green:85/255 blue:130/255 alpha:1.0];
        aLikedCell.likedUserName.textColor = [UIColor lightGrayColor];
        [aLikedCell.profileImage sd_setImageWithURL:[NSURL URLWithString:userDataString] placeholderImage:[UIImage imageNamed:@"nopic.png"]];
        aLikedCell.profileImage.layer.cornerRadius = aLikedCell.profileImage.frame.size.width / 2;
        aLikedCell.profileImage.clipsToBounds = YES;
        [aLikedCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        aLikedCell.followButton.hidden=YES;
        aLikedCell.lineView.hidden=YES;
        aLikedCell.detailUserLabel.text = [NSString stringWithFormat:@""];
//        aLikedCell.detailUserLabel.textColor = [UIColor colorFromHexString:@"#cccccc"];
        
    }
    return aLikedCell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return @"On Instagram";
    }
    return  nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((tableView.frame.size.width-40)/2, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"Gill Sans" size:14.0f]];
    
    [label setText:@"On Instagram"];
    label.textColor = [UIColor colorFromHexString:@"#000073"];
    [view addSubview:label];
    
    return view;
}

-(void) profileImageTapped:(UITapGestureRecognizer *) recognizer {
    
    NSString *displayName = [[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"fountUserDisplayName"];
    NSInteger userId = [[[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"fountUserId"] integerValue];
    if (_fromRefountUsers) {
        displayName = [[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"displayName"];
        userId = [[[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"id"] integerValue];
    }
    
//    PublicProfileViewController *publicProfileVC = [[PublicProfileViewController alloc] initWithUserId:userId];
//    publicProfileVC.displayName = displayName;
//    
//    [self.navigationController pushViewController:publicProfileVC animated:YES];
}

-(void) userNameTapped:(UITapGestureRecognizer *) recognizer {
    
    NSString *displayName = [[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"fountUserDisplayName"];
    NSInteger userId = [[[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"fountUserId"] integerValue];
    if (_fromRefountUsers) {
        displayName = [[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"displayName"];
        userId = [[[likesPeopleInfoArray objectAtIndex:recognizer.view.tag] valueForKey:@"id"] integerValue];
    }
    
//    PublicProfileViewController *publicProfileVC = [[PublicProfileViewController alloc] initWithUserId:userId];
//    publicProfileVC.displayName = displayName;
//    
//    [self.navigationController pushViewController:publicProfileVC animated:YES];
}


-(void)followingButtonClicked:(id)sender{
    
    BOOL sessionExists = [[NSUserDefaults standardUserDefaults] boolForKey:kSessionKey];

    if (sessionExists) {
        
        UIButton *followBtn=(id)sender;
        
        if ([followBtn.titleLabel.text isEqualToString:@"+Follow"]) {
            
            [[[ServiceLayer alloc]init]followUser:followBtn.tag completion:^(NSDictionary *dictionary) {
                //NSLog(@"dictionary:%@",dictionary);
                followBtn.backgroundColor = [UIColor themeColor];
                [followBtn setTitle:@"Following" forState:UIControlStateNormal];
                [followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
            }];
        }
        
    } else {

        [self presentGuestPromptViewController];
    }
}

-(void)loadMorelikes:(int)page{
//    if(media!=nil){
//        if (self.fromRefountUsers) {
//            [[ServiceLayer alloc]getRefountUsersWithMediaId:media.mediaId pageNumber:page completion:^(NSArray *array) {
//                [likesPeopleInfoArray addObjectsFromArray:[array valueForKey:@"USERS"]];
//                NSDictionary *dictionary = [array valueForKey:@"USER_SOCIAL_ACTION"];
//                refountUserActionDictionary = [dictionary mutableCopy];
//                [self.tableView reloadData];
//            }];
//        }else{
//            [[ServiceLayer alloc]getMDPMoreLikesWithMediaId:media.mediaId PageNumber:page IGPageNumber:0 completion:^(NSArray *array) {
//                [likesPeopleInfoArray addObjectsFromArray:array];
//                [self.tableView reloadData];
//            }];
//        }
//    }else{
//        [[ServiceLayer alloc]getPDPMoreLikesWithProductId:self.productId PageNumber:page completion:^(NSArray *array) {
//            [likesPeopleInfoArray addObjectsFromArray:array];
//            [self.tableView reloadData];
//            
//        }];
//        
//    }
    
    
}
-(void)loadMoreInstagramLikes:(int)page{
    
//    [[ServiceLayer alloc]getMDPMoreLikesWithMediaId:media.mediaId PageNumber:0 IGPageNumber:page completion:^(NSArray *array) {
//       // NSLog(@"array%@",array);
//        
//        [instagramPeopleInfoArray addObjectsFromArray:array];
//        [self.tableView reloadData];
//    }];
    
}

@end
