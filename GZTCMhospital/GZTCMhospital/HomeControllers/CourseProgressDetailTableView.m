//
//  CourseProgressDetailTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/9.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "CourseProgressDetailTableView.h"

#import "UITableView+Improve.h"

#import "CourseProgressDetailCell.h"
#import "CourseProgressListModel.h"

@interface CourseProgressDetailTableView ()

@property (nonatomic, strong) CourseProgressListModel *courseProgressListModel;
@property (nonatomic, strong) NSArray *completedCourseSysCodeIDArray;

@end

@implementation CourseProgressDetailTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    self.completedCourseSysCodeIDArray = [self.completedCourseSysCodeID componentsSeparatedByString:@","];
    
    self.title = [NSString stringWithFormat:@"%@%@", self.tableViewTitle, CourseProgress];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数组对象初始化

- (NSArray *)completedCourseSysCodeIDArray {
    if (!_completedCourseSysCodeIDArray) {
        self.completedCourseSysCodeIDArray = [NSArray array];
    }
    return _completedCourseSysCodeIDArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courseProgressListModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    CourseProgressDetailCell *courseProgressDetailCell = [tableView dequeueReusableCellWithIdentifier:@"courseProgressDetailCell" forIndexPath:indexPath];
    self.courseProgressListModel = self.courseProgressListModels[indexPath.row];
    
    courseProgressDetailCell.courseNameLable.text = self.courseProgressListModel.SysCodeContent;
    
    if ([self.completedCourseSysCodeIDArray containsObject:self.courseProgressListModel.SysCodeID]) {
        courseProgressDetailCell.completeStatusImage.image = [UIImage imageNamed:@"course_finished"];
    } else {
        courseProgressDetailCell.completeStatusImage.image = [UIImage imageNamed:@"course_unfinished"];
    }
    return courseProgressDetailCell;
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
