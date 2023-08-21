//
//  SettingsViewController.m
//  Example
//
//  Created by Xezun on 2023/8/15.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewCellAccessoryType (^const GetType)(BOOL) = ^(BOOL isTrue) {
        return isTrue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryDisclosureIndicator;
    };
    switch (indexPath.section) {
        case 0:
            cell.accessoryType = GetType(self.headerAdjustment == indexPath.row);
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.accessoryType = GetType(self.headerOffset == 0);
                    break;
                case 1:
                    cell.accessoryType = GetType(self.headerOffset > 0);
                    break;
                case 2:
                    cell.accessoryType = GetType(self.headerOffset < 0);
                    break;
                default:
                    break;
            }
            break;
        case 2:
            cell.accessoryType = GetType(self.footerAdjustment == indexPath.row);
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell.accessoryType = GetType(self.footerOffset == 0);
                    break;
                case 1:
                    cell.accessoryType = GetType(self.footerOffset > 0);
                    break;
                case 2:
                    cell.accessoryType = GetType(self.footerOffset < 0);
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
