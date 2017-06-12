//
//  SearchScheduleTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/12.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "SearchScheduleTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"

#import "CheckNetWorkStatus.h"
#import "ScheduleTableView.h"
#import "ProcessingStateModel.h"

@interface SearchScheduleTableView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) ProcessingStateModel *processingStateModel;
@property (nonatomic, copy) NSString *selectedStateID;

@end

@implementation SearchScheduleTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadProcessingStateData];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    // set change the inputView (default is keyboard) to UIPickerView
    self.whetherProcessingFiled.inputView = self.pickerView;
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    UIBarButtonItem *flexibleSpaceItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[cancelItem, flexibleSpaceItem, doneItem];
    
    self.whetherProcessingFiled.inputAccessoryView = toolBar;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadProcessingStateData 加载处理状态数据

- (void)loadProcessingStateData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@", ProcessingStateBaseUrl, GetOperatorID];
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.pickerData = [ProcessingStateModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            
            //设置selectedStateID默认值
            self.processingStateModel = self.pickerData[0];
            self.selectedStateID = self.processingStateModel.syscodeID;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        
    }];
}

- (void)cancelTouched:(UIBarButtonItem *)sender {
    // hide the picker view
    [self.whetherProcessingFiled resignFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender {
    // hide the picker view
    [self.whetherProcessingFiled resignFirstResponder];
    
    // perform some action
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    self.processingStateModel = [self.pickerData objectAtIndex:row];
    self.whetherProcessingFiled.text = self.processingStateModel.syscodeName;
    self.selectedStateID = self.processingStateModel.syscodeID;
}

#pragma  mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消cell灰色选中效果
        [self performSegueWithIdentifier:@"showSearchScheduleJump" sender:nil];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerData.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    self.processingStateModel = self.pickerData[row];
    return self.processingStateModel.syscodeName;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSearchScheduleJump"]) {
        ScheduleTableView *scheduleTableView = segue.destinationViewController;
        scheduleTableView.title = [NSString stringWithFormat:@"%@", ScheduleDepartmentTip];
        
        if ([scheduleTableView respondsToSelector:@selector(setScheduleUrl:)]) {
            
            NSString *url = nil;
            
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&IsHanding=%@&MZDoctor=%@&MZNurse=%@&PatientName=%@&CardID=%@&PageID=1&PageSize=20", ScheduleBaseUrl, GetOperatorID, (long)self.EditionID, self.selectedStateID, self.searchDoctorName.text, self.searchNurseName.text,  self.searchPatientName.text, self.searchIDCard.text];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            [scheduleTableView setValue:url forKey:@"scheduleUrl"];
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
