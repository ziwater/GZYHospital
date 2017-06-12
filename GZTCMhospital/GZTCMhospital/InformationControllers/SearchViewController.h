//
//  SearchViewController.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/17.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController

@property (nonatomic, copy) NSString *editionID;
@property (nonatomic, copy) NSString *formID;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
