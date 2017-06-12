//
//  FormListTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/10/13.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "FormListTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "FormListModel.h"
#import "FormDetailTableView.h"

@interface FormListTableView ()

@property (nonatomic, strong) FormListModel *formListModel;

@end

@implementation FormListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFormListData];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadFormListData 加载识别与评估-某个科室病种下量表列表数据

- (void)loadFormListData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        [SVProgressHUD showWithStatus:NetworkDataLoadingTip maskType:SVProgressHUDMaskTypeNone];
        
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&PersonID=%@",FormListBaseUrl, GetOperatorID, self.PersonID];
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.formListModels = [FormListModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.formListModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.formListModel = self.formListModels[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"formListCell" forIndexPath:indexPath];
    cell.textLabel.text = self.formListModel.FormName;
    return cell;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFormDetailJump"]) {
        FormDetailTableView *formDetailTableView = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        
        self.formListModel = self.formListModels[selectedIndexPath.row];
        formDetailTableView.title = self.formListModel.FormName;
        
        formDetailTableView.url = [NSString stringWithFormat:@"%@OperatorID=%@&PersonID=%@&FormID=%@&PageID=1&PageSize=20", FormDetailBaseUrl, GetOperatorID, self.PersonID, self.formListModel.FormID];
        
        if ([formDetailTableView respondsToSelector:@selector(setPersonID:)]) {
            [formDetailTableView setValue:self.PersonID forKey:@"PersonID"];
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
