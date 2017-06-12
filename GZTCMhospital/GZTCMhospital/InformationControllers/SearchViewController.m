//
//  SearchViewController.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/17.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "SearchViewController.h"

#import "InformationTableViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self generateUrlWithSearchString:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //    [self generateUrlWithSearchString:searchBar.text];
}

#pragma mark - Search Method

- (void)generateUrlWithSearchString:(NSString *)searchString {
    
    NSString *url = nil;
    if (self.editionID && self.formID) {
        url = [NSString stringWithFormat:@"%@Keyword=%@&EditionID=%@&FormID=%@&ClassID=0&PageID=1&PageSize=20", SearchBaseUrl, searchString, self.editionID, self.formID];
    } else {
        url = [NSString stringWithFormat:@"%@Keyword=%@&EditionID=0&FormID=0&ClassID=0&PageID=1&PageSize=20", SearchBaseUrl, searchString];
    }
    
    url =  [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]; //url汉字编码转换
    
    InformationTableViewController *informationTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"informationTableView"];
    informationTableView.url = url;
    
    
    CGRect newFrame = informationTableView.view.frame;
    newFrame.origin.y = 108;
    newFrame.size.height = self.view.frame.size.height - 108;
    informationTableView.view.frame = newFrame;
    
    [self addChildViewController:informationTableView];
    [self.view addSubview:informationTableView.view];
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
