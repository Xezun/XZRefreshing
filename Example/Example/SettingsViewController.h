//
//  SettingsViewController.h
//  Example
//
//  Created by Xezun on 2023/8/15.
//

#import <UIKit/UIKit.h>
@import XZRefreshing;

NS_ASSUME_NONNULL_BEGIN

@interface SettingsViewController : UITableViewController

@property (nonatomic) XZRefreshingAdjustment headerAdjustment;
@property (nonatomic) CGFloat headerOffset;

@property (nonatomic) XZRefreshingAdjustment footerAdjustment;
@property (nonatomic) CGFloat footerOffset;

@end

NS_ASSUME_NONNULL_END
