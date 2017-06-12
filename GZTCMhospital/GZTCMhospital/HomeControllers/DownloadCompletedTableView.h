//
//  DownloadCompletedTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/8.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadCompletedTableView : UITableViewController

@property (nonatomic, strong) NSMutableArray *downloadedFiles; //存NSDictionary类型key:fileName value:tureFileName
@property (nonatomic, strong) NSMutableArray *selectedData;

- (void)queryDownloadedFile;

@end
