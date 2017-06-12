//
//  CalendarDemoViewController.m
//  CalendarDemo
//
//  Created by Chris on 15/11/17.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "CalendarViewController.h"

#import "NSDate+FSExtension.h"
#import "SSLunarDate.h"
#import "AFHTTPRequestOperationManager.h"
#import "CheckNetWorkStatus.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"

#import "EventCell.h"
#import "OrderMonthViewModel.h"

@interface CalendarViewController ()

@property (nonatomic, strong) NSCalendar *currentCalendar;
@property (nonatomic, strong) SSLunarDate *lunarDate;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *currentPage;
@property (nonatomic, assign) FSCalendarScope monthOrWeekScope;
@property (nonatomic, strong) NSMutableDictionary *eventDictionary;  //事件数据字典
@property (nonatomic, strong) NSMutableArray *tableData;  //事件表视图数据源

@property (nonatomic, strong) NSMutableArray *orderMonthViewModels;  //存放OrderMonthViewModel对象的数组
@property (nonatomic, strong) OrderMonthViewModel *orderMonthViewModel;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.calendarIdentify isEqualToString:@"orderCalendar"]) {
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeId=%@&BeginDate=%@&EndDate=%@&PageID=1&PageSize=20", OrderCalendarBaseUrl, GetOperatorID, self.SyscodeId, [_calendar.today fs_stringWithFormat:@"yyyy-MM-dd"], [[_calendar.today fs_dateByAddingDays:30] fs_stringWithFormat:@"yyyy-MM-dd"]];
        
//        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeId=%@&BeginDate=2015-08-30&EndDate=2015-10-03&PageID=1&PageSize=20", OrderCalendarBaseUrl, GetOperatorID, self.SyscodeId];
        [self loadOrderMonthViewDataWithUrl:url];
    }

    if ([self.calendarIdentify isEqualToString:@"scheduleCalendar"]) {
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeId=%@&BeginDate=%@&EndDate=%@&PageID=1&PageSize=20", ScheduleCalendarBaseUrl, GetOperatorID, self.SyscodeId, [[_calendar.today fs_dateBySubtractingDays:30] fs_stringWithFormat:@"yyyy-MM-dd"], [[_calendar.today fs_dateByAddingDays:30] fs_stringWithFormat:@"yyyy-MM-dd"]];
        
//        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeId=%@&BeginDate=2015-11-29&EndDate=2016-01-02&PageID=1&PageSize=20", ScheduleCalendarBaseUrl, GetOperatorID, self.SyscodeId];
        [self loadOrderMonthViewDataWithUrl:url];
    }
    
    self.theme = 0;
    self.scrollDirection = FSCalendarScrollDirectionVertical;
    self.lunar = YES;
    self.firstWeekday = 1; // Default: Sunday:1 Monday:2
    self.monthOrWeekScope = FSCalendarScopeMonth;
    self.currentPage = _calendar.currentPage;
    
    _currentCalendar = [NSCalendar currentCalendar];
    _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesDefaultCase|FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    //[_calendar selectDate:[NSDate fs_dateWithYear:2015 month:10 day:5]];
    
    _datesShouldNotBeSelected = nil;
    
    //    _datesWithEvent = @[@"2015-11-18",
    //                        @"2015-11-09",
    //                        @"2015-11-15",
    //                        @"2015-11-24",
    //                        @"2015-12-01"];
    
//    _eventDictionary = @{@"2015-11-18": @[@{
//                                              @"09:00-12:00": @{@"content": @"今天上午09-12时要去就诊哦。",
//                                                                @"clinicalDepartment": @"糖尿病专科"
//                                                                }
//                                              },
//                                          @{
//                                              @"15:00-17:00": @"今天下午15-17时去开会。"
//                                              }
//                                          ],
//                         @"2015-11-09": @[@{
//                                              @"07:00-09:00": @"今天上午07-09时要去就诊哦。"
//                                              }
//                                          ],
//                         @"2015-11-15": @[@{
//                                              @"11:00-12:00": @"今天上午11-12时去复诊。"
//                                              }
//                                          ],
//                         @"2015-11-24": @[@{
//                                              @"09:00-12:00": @"今天上午09-12时要去就诊哦。"
//                                              }
//                                          ],
//                         @"2015-12-01": @[@{
//                                              @"09:00-12:00": @"今天上午09-12时去医院还是不去啊？"
//                                              }
//                                          ]
//                         };
    
    // Do any additional setup after loading the view.
    
    NSLog(@"week = %ld", (long)[_calendar weekdayOfDate:[NSDate dateWithTimeInterval: -3 * 24 * 60 * 60 sinceDate:_calendar.today]] - 1);
}

#pragma mark - 数组初始化

- (NSMutableArray *)tableData {
    if (!_tableData) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
}

- (NSMutableArray *)datesWithEvent {
    if (!_datesWithEvent) {
        _datesWithEvent = [NSMutableArray array];
    }
    return _datesWithEvent;
}

- (NSMutableDictionary *)eventDictionary {
    if (!_eventDictionary) {
        _eventDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _eventDictionary;
}

- (NSMutableArray *)orderMonthViewModels {
    if (!_orderMonthViewModels) {
        _orderMonthViewModels = [NSMutableArray array];
    }
    return _orderMonthViewModels;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadOrderMonthViewDataWithUrl: 获取预约月视图数据

- (void)loadOrderMonthViewDataWithUrl:(NSString *)url {
    [self.orderMonthViewModels removeAllObjects];
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.orderMonthViewModels = [OrderMonthViewModel objectArrayWithKeyValuesArray:[[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"DataList"]];
            
            for (NSInteger i = 0; i < self.orderMonthViewModels.count; i++) {
                NSMutableArray *detailEventArr = [NSMutableArray array];
                
                self.orderMonthViewModel = self.orderMonthViewModels[i];
                if (![self.datesWithEvent containsObject:self.orderMonthViewModel.StatisticDate]) {
                    [self.datesWithEvent addObject:self.orderMonthViewModel.StatisticDate];
                    
                    [detailEventArr addObject:@{self.orderMonthViewModel.TimeRang: @{@"content": self.orderMonthViewModel.CountNum, @"clinicalDepartment": self.orderMonthViewModel.ColumnName}}];
                    
                    for (NSInteger j = i + 1; j < self.orderMonthViewModels.count; j++) {
                        OrderMonthViewModel *originalModel = self.orderMonthViewModels[i];
                        OrderMonthViewModel *tempModel = self.orderMonthViewModels[j];
                        
                        if ([originalModel.StatisticDate isEqualToString:tempModel.StatisticDate]) {
                            [detailEventArr addObject:@{tempModel.TimeRang: @{@"content": tempModel.CountNum, @"clinicalDepartment": tempModel.ColumnName}}];
                        }
                    }
                    
                    [self.eventDictionary setObject:detailEventArr forKey:self.orderMonthViewModel.StatisticDate];
                }
            }
            [self calendar:_calendar didSelectDate:_calendar.today];
            [_calendar reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - FSCalendarDataSource

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date {
    if (!_lunar) {
        return nil;
    }
    _lunarDate = [[SSLunarDate alloc] initWithDate:date calendar:_currentCalendar];
    return _lunarDate.dayString;
}

- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date {
    return [_datesWithEvent containsObject:[date fs_stringWithFormat:@"yyyy-MM-dd"]];
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate fs_dateWithYear:2015 month:6 day:1];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
//    return [[NSDate date] fs_dateByAddingDays:230];
    return [calendar.today fs_dateByAddingDays:30];
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date {
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date {
    NSLog(@"Did deselect date %@", [date fs_stringWithFormat:@"yyyy/MM/dd"]);
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date {
    BOOL shouldSelect = ![_datesShouldNotBeSelected containsObject:[date fs_stringWithFormat:@"yyyy/MM/dd"]];
    if (!shouldSelect) {
        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
                                    message:[NSString stringWithFormat:@"FSCalendar delegate forbid %@  to be selected",[date fs_stringWithFormat:@"yyyy/MM/dd"]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {  //选中某一天时调用方法
    self.date = date;
    if ([date isEqualToDate:_calendar.today]) {
        _calendar.appearance.todaySelectionColor = [UIColor redColor];
    } else {
        _calendar.appearance.todayColor = [UIColor clearColor];
        _calendar.appearance.titleTodayColor = [UIColor redColor];
        _calendar.appearance.subtitleTodayColor = [UIColor redColor];
    }
    
    //Show event in the table below
    [self.tableData removeAllObjects];
    
    NSString *key = [date fs_stringWithFormat:@"yyyy-MM-dd"];
    
    if ([self.eventDictionary.allKeys containsObject:key]) {
        [self.tableData addObjectsFromArray:[self.eventDictionary valueForKey:key]];
    }
    
    [self.tableView reloadData];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    if (self.monthOrWeekScope == FSCalendarScopeMonth) {
        if ([[calendar.currentPage fs_stringWithFormat:@"MMMM yyyy"] isEqualToString:[self.currentPage fs_stringWithFormat:@"MMMM yyyy"]]) {
            [calendar selectDate:_calendar.today];
            [self calendar:_calendar didSelectDate:_calendar.today];
        } else {
            [calendar selectDate:calendar.currentPage];
            [self calendar:_calendar didSelectDate:calendar.currentPage];
        }
    } else {
        //        if ([self.date isEqualToDate:_calendar.today]) {
        //            [_calendar selectDate:_calendar.today]
        //        }
    }
}

- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated {
    CGSize size = [calendar sizeThatFits:calendar.frame.size];
    _calendarHeightConstraint.constant = size.height;
    [self.view layoutIfNeeded];
}

#pragma mark - Setter method

- (void)setTheme:(NSInteger)theme {
    _theme = theme;
    _calendar.appearance.weekdayTextColor = FSCalendarStandardTitleTextColor;
    _calendar.appearance.headerTitleColor = [UIColor redColor];
    _calendar.appearance.eventColor = FSCalendarStandardEventDotColor;
    _calendar.appearance.selectionColor = [UIColor blackColor];
    _calendar.appearance.headerDateFormat = @"MMMM yyyy";
    _calendar.appearance.todayColor = [UIColor redColor];
    _calendar.appearance.titleTodayColor = [UIColor whiteColor];
    _calendar.appearance.subtitleTodayColor = [UIColor whiteColor];
    _calendar.appearance.cellShape = FSCalendarCellShapeCircle;
    _calendar.appearance.headerMinimumDissolvedAlpha = 0.2;
    //_calendar.appearance.headerDateFormat = @"yyyy-MM";
    //_calendar.appearance.headerDateFormat = @"yyyy/MM";
    //_calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
    //_calendar.appearance.headerMinimumDissolvedAlpha = 1.0;
    
    if (self.date) {
        [self calendar:_calendar didSelectDate:self.date];
    } else {
        [self calendar:_calendar didSelectDate:_calendar.today];
    }
}

- (void)setLunar:(BOOL)lunar {
    _lunar = lunar;
    [_calendar reloadData];
}

- (void)setScrollDirection:(FSCalendarScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    _calendar.scrollDirection = scrollDirection;
}

- (void)setFirstWeekday:(NSUInteger)firstWeekday {
    _firstWeekday = firstWeekday;
    _calendar.firstWeekday = firstWeekday;
}

#pragma mark - Action method

- (IBAction)todayItemClicked:(UIBarButtonItem *)sender {
    [_calendar setCurrentPage:[NSDate date] animated:YES];
    [_calendar selectDate:_calendar.today];
    [self calendar:_calendar didSelectDate:_calendar.today];
}

- (IBAction)ScopeChange:(UIBarButtonItem *)sender {
    if (self.monthOrWeekScope == FSCalendarScopeMonth) {
        [_calendar setCurrentPage:[NSDate date] animated:YES];
        [_calendar selectDate:_calendar.today];
        [_calendar setScope:FSCalendarScopeWeek animated:YES];
        
        self.monthOrWeekScope = FSCalendarScopeWeek;
        
    } else if (self.monthOrWeekScope == FSCalendarScopeWeek) {
        [_calendar setScope:FSCalendarScopeMonth animated:YES];
        self.monthOrWeekScope = FSCalendarScopeMonth;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(!self.tableData.count) {
        return 3;
    } else {
        return self.tableData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.tableData.count) {
        UITableViewCell *noEventCell = [tableView dequeueReusableCellWithIdentifier:@"noEventCell" forIndexPath:indexPath];
        if (indexPath.row == 1) {
            noEventCell.textLabel.text = NoEventTip;
        } else {
            noEventCell.textLabel.text = nil;
        }
        return noEventCell;
    }
    
    EventCell *eventCell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    eventCell.eventContentLabel.text = [[self.tableData[indexPath.row] allValues].firstObject objectForKey:@"content"];
    eventCell.eventDescriptionLabel.text = [[self.tableData[indexPath.row] allValues].firstObject objectForKey:@"clinicalDepartment"];
    
    if ([[self.tableData[indexPath.row] allKeys].firstObject isEqualToString:@" "]) {
        eventCell.beginTimeLabel.text = AllDayEventTip;
        eventCell.endTimeLabel.text = nil;
    } else {
        eventCell.beginTimeLabel.text = [[self.tableData[indexPath.row] allKeys].firstObject substringToIndex:5];
        eventCell.endTimeLabel.text = [[self.tableData[indexPath.row] allKeys].firstObject substringFromIndex:6];
    }
    eventCell.eventImageView.image = [self createImageWithColor:[UIColor colorWithRed:137.0/255 green:96.0/255 blue:209.0/255 alpha:0.5]];
    
    return eventCell;
}

#pragma mark - createImageWithColor: 根据颜色值创建UIImage

- (UIImage*)createImageWithColor:(UIColor*) color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
