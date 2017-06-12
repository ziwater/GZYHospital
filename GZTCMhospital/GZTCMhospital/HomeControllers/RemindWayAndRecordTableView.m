//
//  RemindWayAndRecordTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/2/25.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "RemindWayAndRecordTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "RemindWayAndRecordModel.h"
#import "RemindManageTableView.h"

@interface RemindWayAndRecordTableView ()

@property (nonatomic, strong) NSArray *remindWayAndRecordModels;
@property (nonatomic, strong) RemindWayAndRecordModel *remindWayAndRecordModel;
@property (nonatomic, strong) NSIndexPath *jumpIndexPath;

@end

@implementation RemindWayAndRecordTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRemindRecordNumber:) name:@"updateRemindRecordNumber" object:nil];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    [self loadRemindWayAndRecordData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter 通知方法

- (void)updateRemindRecordNumber:(NSNotification *)notification {
    self.remindWayAndRecordModel = self.remindWayAndRecordModels[self.jumpIndexPath.row];
    self.remindWayAndRecordModel.Count--;
    [self.tableView reloadRowsAtIndexPaths:@[self.jumpIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateRemindRecordNumber" object:nil];
}

#pragma mark - loadRemindWayAndRecordData 加载提醒管理-所有提醒方式和记录条数

- (void)loadRemindWayAndRecordData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        [SVProgressHUD showWithStatus:NetworkDataLoadingTip maskType:SVProgressHUDMaskTypeNone];
        
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&PageID=1&PageSize=20", RemindWayAndRecordNumberBaseUrl, GetOperatorID];
        
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.remindWayAndRecordModels = [RemindWayAndRecordModel objectArrayWithKeyValuesArray:[[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"DataList"]];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.jumpIndexPath = indexPath;
    [self performSegueWithIdentifier:@"showRemindHandleJump" sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.remindWayAndRecordModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"remindWayAndRecordCell" forIndexPath:indexPath];
    self.remindWayAndRecordModel = self.remindWayAndRecordModels[indexPath.row];
    
    cell.textLabel.text = self.remindWayAndRecordModel.MenuTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.remindWayAndRecordModel.Count];
    
    return cell;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRemindHandleJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        self.remindWayAndRecordModel = self.remindWayAndRecordModels[selectedIndexPath.row];
        
        remindManageTableView.title = [NSString stringWithFormat:@"%@", self.remindWayAndRecordModel.MenuTitle];
        if ([remindManageTableView respondsToSelector:@selector(setRemindUrl:)]) {
            NSString *url = nil;
            
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&ClassID=%@&FormID=%@&Cond=%@&PageID=1&PageSize=20", RemindWayDataBaseUrl, GetOperatorID, self.remindWayAndRecordModel.classID, self.remindWayAndRecordModel.FormId, self.remindWayAndRecordModel.Cond];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [remindManageTableView setValue:url forKey:@"remindUrl"];
        }
        
        if ([remindManageTableView respondsToSelector:@selector(setRemindHandleIdentify:)]) {
            [remindManageTableView setValue:@"remindHandle" forKey:@"remindHandleIdentify"];
        }
    }
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
