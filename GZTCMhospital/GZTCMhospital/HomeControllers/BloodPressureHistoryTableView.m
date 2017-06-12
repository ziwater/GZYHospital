//
//  BloodPressureHistoryTableView.m
//  
//
//  Created by Chris on 15/10/10.
//
//

#import "BloodPressureHistoryTableView.h"

#import "MJExtension.h"

#import "BloodPressureModel.h"
#import "BloodPressureCell.h"
#import "MyDeviceTableView.h"

@interface BloodPressureHistoryTableView ()

@property (nonatomic, strong) BloodPressureModel *bloodPressureModel;

@end

@implementation BloodPressureHistoryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadBloodPressureHistoryData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadBloodPressureHistoryData 加载血压历史数据

- (void)loadBloodPressureHistoryData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bloodPressureHistoryData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    self.bloodPressureModels = [BloodPressureModel objectArrayWithKeyValuesArray:[dict valueForKeyPath:@"List"]];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 178;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 11;
    }
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.bloodPressureModels.count - 1) {
        return 10;
    }
    return 3;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.bloodPressureModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BloodPressureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bloodPressureCell" forIndexPath:indexPath];
    self.bloodPressureModel = self.bloodPressureModels[indexPath.section];
    
    cell.measuredTime.text = self.bloodPressureModel.time;
    cell.SBPLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bloodPressureModel.sbp];
    cell.DBPLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bloodPressureModel.dbp];
    cell.pulseLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bloodPressureModel.pulse];
    cell.resultImageView.image = [self showResultPic:self.bloodPressureModel.risk];
    return cell;
}

- (UIImage *)showResultPic:(KKBloodPressureResult)result {
    if (result == BLOOD_LOW) {
        return [UIImage imageNamed:@"gzy_xueya_blood_mark_low"];
    } else if (result == BLOOD_NORMAL) {
        return [UIImage imageNamed:@"gzy_xueya_blood_mark_normal"];
    } else if (result == BLOOD_NORMAL_HIGH) {
        return [UIImage imageNamed:@"gzy_xueya_blood_mark_normalhigh"];
    } else if (result == BLOOD_HIGH_LIGHT) {
        return [UIImage imageNamed:@"gzy_xueya_blood_mark_light"];
    } else if (result == BLOOD_HIGH_MEDIUM) {
        return [UIImage imageNamed:@"gzy_xueya_blood_mark_medium"];
    } else if (result == BLOOD_HIGH_HEAVY) {
        return [UIImage imageNamed:@"gzy_xueya_blood_mark_heavy"];
    } else if (result == BLOOD_DANCUN) {
        return [UIImage imageNamed:@"gzy_xueya_blood_mark_dancun"];
    } else {
        return nil;
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
