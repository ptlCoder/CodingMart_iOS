//
//  UserInfoViewController.m
//  CodingMart
//
//  Created by Ease on 15/10/11.
//  Copyright © 2015年 net.coding. All rights reserved.
//

#import "UserInfoViewController.h"
#import "WebViewController.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"
#import "User.h"
#import "Login.h"
#import "UIImageView+WebCache.h"

@interface UserInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *user_iconV;
@property (weak, nonatomic) IBOutlet UILabel *user_nameL;
@property (nonatomic, strong) ODRefreshControl *myRefreshControl;

@property (strong, nonatomic) User *curUser;
@end

@implementation UserInfoViewController
+ (UserInfoViewController *)userInfoVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserInfo" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.curUser = [Login curLoginUser];
    [_user_iconV doCircleFrame];
    
//        refresh
    _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [_myRefreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self refreshData];
}

- (void)setCurUser:(User *)curUser{
    _curUser = curUser;
    [_user_iconV sd_setImageWithURL:[_curUser.avatar urlWithCodingPath] placeholderImage:[UIImage imageNamed:@"placeholder_user"]];
    _user_nameL.text = _curUser.name;
}
- (void)refreshData{
    [[Coding_NetAPIManager sharedManager] get_CurrentUserAutoShowError:YES andBlock:^(id data, NSError *error) {
        [self.myRefreshControl endRefreshing];
        if (data) {
            self.curUser = data;
        }
    }];
}

#pragma mark Btn
- (IBAction)myPublishedBtnClicked:(id)sender {
    [self goToWebVCWithUrlStr:@"/published"];
}
- (IBAction)myJoinedBtnClicked:(id)sender {
    [self goToWebVCWithUrlStr:@"/joined"];
}


#pragma mark Table M
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV;
    if (section > 0) {
        headerV = [UIView new];
    }
    return headerV;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat sectionH = 0;
    if (section > 0) {
        sectionH = 10;
    }
    return sectionH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self goToWebVCWithUrlStr:@"/codersay"];
    }else if (indexPath.section == 2){
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"确定要退出当前账号" buttonTitles:nil destructiveTitle:@"确定退出" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [Login doLogout];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }] showInView:self.view];
    }
}

@end
