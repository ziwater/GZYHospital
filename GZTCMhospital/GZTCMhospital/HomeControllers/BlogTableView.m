//
//  BlogTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/19.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "BlogTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "BlogChannelModel.h"
#import "BlogLayoutViewController.h"
#import "InformationChannelModel.h"

@interface BlogTableView ()

@property (nonatomic, strong) NSArray *blogChannelModels;
@property (nonatomic, strong) NSArray *blogChannelModelsToTransfer;
@property (nonatomic, strong) NSMutableArray *tempInformationChannelModels;

@property (nonatomic, strong) BlogChannelModel *blogChannelModel;

@end

@implementation BlogTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    [self loadBlogData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数组初始化

- (NSMutableArray *)tempInformationChannelModels {
    if (!_tempInformationChannelModels) {
        self.tempInformationChannelModels = [NSMutableArray array];
    }
    return _tempInformationChannelModels;
}

#pragma mark - loadBlogData 加载慢病博客分类列表

- (void)loadBlogData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:ChronicDiseaseBlogUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.blogChannelModels = [BlogChannelModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            
            for (BlogChannelModel *blogChannelModel in self.blogChannelModels) {
                InformationChannelModel *tempInformationChannelModel = [[InformationChannelModel alloc] init];
                tempInformationChannelModel.EditionID = blogChannelModel.FatherClassID;
                tempInformationChannelModel.FormID = blogChannelModel.ClassID;
                tempInformationChannelModel.FormName = blogChannelModel.ClassName;
                [self.tempInformationChannelModels addObject:tempInformationChannelModel];
            }

            self.blogChannelModelsToTransfer = self.tempInformationChannelModels;
            
            [self.tableView reloadData];
            
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
    return self.blogChannelModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.blogChannelModel = self.blogChannelModels[indexPath.row];
    
    UITableViewCell *forumCell = [tableView dequeueReusableCellWithIdentifier:@"blogCell" forIndexPath:indexPath];
    forumCell.textLabel.text = self.blogChannelModel.ClassName;
    
    return forumCell;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"blogLayoutJump"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        self.blogChannelModel = self.blogChannelModels[selectedIndexPath.row];
        
        BlogLayoutViewController *blogLayoutViewController = segue.destinationViewController;
        blogLayoutViewController.title = self.blogChannelModel.ClassName;
        
        if ([blogLayoutViewController respondsToSelector:@selector(setClassID:)]) {
            [blogLayoutViewController setValue:self.blogChannelModel.ClassID forKey:@"ClassID"];
        }
        
        if ([blogLayoutViewController respondsToSelector:@selector(setInformationChannelModels:)]) {
            
            [blogLayoutViewController setValue:self.blogChannelModelsToTransfer forKey:@"informationChannelModels"];
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
