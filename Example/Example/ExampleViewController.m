//
//  ExampleViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ExampleViewController.h"
#import "SettingsViewController.h"
@import XZRefreshing;
@import XZExtensions;

@interface ExampleViewController () <XZRefreshingDelegate> {
    NSInteger _numberOfCells;
    CGFloat _rowHeight;
}
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rowHeight = 57.0;
    _numberOfCells = 10;
    
    // 使用默认样式
    [self.tableView xz_headerRefreshingView];
    [self.tableView xz_footerRefreshingView];
    
    self.tableView.xz_headerRefreshingView.adjustment = XZRefreshingAdjustmentNone;
    self.tableView.xz_footerRefreshingView.adjustment = XZRefreshingAdjustmentNone;
    
    // 为了方便查看，设置了背景色。
    self.tableView.xz_headerRefreshingView.backgroundColor = rgb(0xf1f2f3);
    self.tableView.xz_footerRefreshingView.backgroundColor = rgb(0xf1f2f3);
}

- (IBAction)navBarHeaderButtonAction:(UIBarButtonItem *)sender {
    if (self.tableView.xz_headerRefreshingView.isAnimating) {
        [self.tableView.xz_headerRefreshingView endAnimating];
    } else {
        [self.tableView.xz_headerRefreshingView beginAnimating];
    }
}

- (IBAction)navBarFooterButtonAction:(UIBarButtonItem *)sender {
    if (self.tableView.xz_footerRefreshingView.isAnimating) {
        [self.tableView.xz_footerRefreshingView endAnimating];
    } else {
        [self.tableView.xz_footerRefreshingView beginAnimating];
    }
}

- (void)scrollView:(__kindof UIScrollView *)scrollView headerRefreshingViewDidBeginAnimating:(__kindof XZRefreshingView *)headerRefreshingView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_numberOfCells = arc4random_uniform(8) + 2;
        [self.tableView reloadData];
        [headerRefreshingView endAnimating];
    });
}

- (void)scrollView:(__kindof UIScrollView *)scrollView footerRefreshingViewDidBeginAnimating:(__kindof XZRefreshingView *)footerRefreshingView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_numberOfCells < 15) {
            self->_numberOfCells += arc4random_uniform(5) + 2;
        }
        [self.tableView reloadData];
        [footerRefreshingView endAnimating];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)navBarInsertButtonAction:(UIBarButtonItem *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_numberOfCells inSection:0];
    _numberOfCells += 1;
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
}

- (IBAction)navBarDeleteButtonAction:(UIBarButtonItem *)sender {
    if (_numberOfCells > 0) {
        _numberOfCells -= 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_numberOfCells inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationRight)];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numberOfCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"No.%02ld", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settings"]) {
        SettingsViewController *vc = segue.destinationViewController;
        vc.headerAdjustment = self.tableView.xz_headerRefreshingView.adjustment;
        vc.headerOffset = self.tableView.xz_headerRefreshingView.offset;
        vc.footerAdjustment = self.tableView.xz_footerRefreshingView.adjustment;
        vc.footerOffset = self.tableView.xz_footerRefreshingView.offset;
    }
}

- (IBAction)unwindToHeaderAdjustment:(UIStoryboardSegue *)unwindSegue {
    NSString *identifier = unwindSegue.identifier;
    if ([identifier isEqualToString:@"header-adjustment-0"]) {
        self.tableView.xz_headerRefreshingView.adjustment = XZRefreshingAdjustmentAutomatic;
    } else if ([identifier isEqualToString:@"header-adjustment-1"]) {
        self.tableView.xz_headerRefreshingView.adjustment = XZRefreshingAdjustmentNormal;
    } else if ([identifier isEqualToString:@"header-adjustment-2"]) {
        self.tableView.xz_headerRefreshingView.adjustment = XZRefreshingAdjustmentNone;
    }
}

- (IBAction)unwindToHeaderOffset:(UIStoryboardSegue *)unwindSegue {
    NSString *identifier = unwindSegue.identifier;
    if ([identifier isEqualToString:@"header-offset-0"]) {
        self.tableView.xz_headerRefreshingView.offset = 0;
    } else if ([identifier isEqualToString:@"header-offset-1"]) {
        self.tableView.xz_headerRefreshingView.offset = 50;
    } else if ([identifier isEqualToString:@"header-offset-2"]) {
        self.tableView.xz_headerRefreshingView.offset = -50;
    }
}

- (IBAction)unwindToFooterAdjustment:(UIStoryboardSegue *)unwindSegue {
    NSString *identifier = unwindSegue.identifier;
    if ([identifier isEqualToString:@"footer-adjustment-0"]) {
        self.tableView.xz_footerRefreshingView.adjustment = XZRefreshingAdjustmentAutomatic;
    } else if ([identifier isEqualToString:@"footer-adjustment-1"]) {
        self.tableView.xz_footerRefreshingView.adjustment = XZRefreshingAdjustmentNormal;
    } else if ([identifier isEqualToString:@"footer-adjustment-2"]) {
        self.tableView.xz_footerRefreshingView.adjustment = XZRefreshingAdjustmentNone;
    }
}

- (IBAction)unwindToFooterOffset:(UIStoryboardSegue *)unwindSegue {
    NSString *identifier = unwindSegue.identifier;
    if ([identifier isEqualToString:@"footer-offset-0"]) {
        self.tableView.xz_footerRefreshingView.offset = 0;
    } else if ([identifier isEqualToString:@"footer-offset-1"]) {
        self.tableView.xz_footerRefreshingView.offset = +50;
    } else if ([identifier isEqualToString:@"footer-offset-2"]) {
        self.tableView.xz_footerRefreshingView.offset = -50;
    }
}

@end
