//
//  BloodPressureCell.h
//  
//
//  Created by Chris on 15/10/10.
//
//

#import <UIKit/UIKit.h>

@interface BloodPressureCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *measuredTime;
@property (weak, nonatomic) IBOutlet UILabel *SBPLabel;
@property (weak, nonatomic) IBOutlet UILabel *DBPLabel;
@property (weak, nonatomic) IBOutlet UILabel *pulseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;

@end
