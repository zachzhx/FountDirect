//
//  ShopMainCell.h
//  Spree
//
//  Created by Xu Zhang on 10/14/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopMainCell : UITableViewCell
@property (nonatomic,retain) IBOutlet UIButton *aSelectBtn;
@property (nonatomic,strong)IBOutlet UIImageView *aThumbImg;
@property (nonatomic,strong)IBOutlet UILabel *brandNameLbl,*aColorLbl,*aSizeLbl;
@property (nonatomic,strong)IBOutlet UILabel *aPriceLbl,*aQuantityLbl,*aShopLbl;
@property (weak, nonatomic) IBOutlet UILabel *aFitLbl;
@property (weak, nonatomic) IBOutlet UILabel *aInseamLbl;


@end
