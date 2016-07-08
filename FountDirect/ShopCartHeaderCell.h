//
//  ShopCartHeaderCell.h
//  Spree
//
//  Created by Xu Zhang on 10/14/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShopCartHeaderCell : UITableViewCell
@property (nonatomic,strong)IBOutlet UIButton* aSelectBtn,*editBtn;
@property (nonatomic,retain)IBOutlet UILabel *aSellerNameLbl;

@property (nonatomic,retain)IBOutlet UIView *aline;


@end
