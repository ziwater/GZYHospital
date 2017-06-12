//
//  OfficialDynamicTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/2/22.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "OfficialDynamicTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "InformationChannelModel.h"
#import "InformationTableViewController.h"

@interface OfficialDynamicTableView ()

@property (nonatomic, strong) NSArray *informationChannelModels;
@property (nonatomic, strong) InformationChannelModel *informationChannelModel;

@end

@implementation OfficialDynamicTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    [self loadOfficialDynamicListData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadOfficialDynamicListData加载你问我答分类列表

- (void)loadOfficialDynamicListData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:OfficialDynamicUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            self.informationChannelModels = [InformationChannelModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.informationChannelModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.informationChannelModel = self.informationChannelModels[indexPath.row];
    
    UITableViewCell *forumCell = [tableView dequeueReusableCellWithIdentifier:@"officialDynamicCell" forIndexPath:indexPath];
    forumCell.textLabel.text = self.informationChannelModel.FormName;
    
    return forumCell;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showOfficialDynamicItemJump"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        self.informationChannelModel = self.informationChannelModels[selectedIndexPath.row];
        
        InformationTableViewController *informationTableViewController = segue.destinationViewController;
        informationTableViewController.title = self.informationChannelModel.FormName;
        
        if ([informationTableViewController respondsToSelector:@selector(setUrl:)]) {
            
            NSString *urlString = [NSString stringWithFormat:@"%@FormID=%@&PageID=1&PageSize=20", OfficialDynamicUrlItemBaseUrl, self.informationChannelModel.FormID];
            [informationTableViewController setValue:urlString forKey:@"url"];
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
