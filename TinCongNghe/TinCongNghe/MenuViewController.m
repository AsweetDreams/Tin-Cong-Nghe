//
//  MenuViewController.m
//  TinCongNghe
//
//  Created by Khai on 01/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "MenuViewController.h"
#import "Detect3GorWifiViewController.h"

@interface MenuViewController ()
@property (nonatomic,strong) NSArray *menuItems;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuTbv.dataSource = self;
    self.menuTbv.delegate = self;
    // Do any additional setup after loading the view.
    self.menuItems = kMenuItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)      tableView:(UITableView *)tableView
  heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *cellIdentifier;
    if (indexPath.section == 0) {
        cellIdentifier = @"AppName";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
        cellIdentifier = @"Offline";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                forIndexPath:indexPath];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"%lu",indexPath.section);
    if (indexPath.section == 1) {
        Detect3GorWifiViewController *Detect3GorWifi = [self.storyboard instantiateViewControllerWithIdentifier:@"Detect3GorWifiViewController"];
        [self presentViewController:Detect3GorWifi animated:YES completion:^{
        }];
    }
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
    if ( indexPath.section == 0 ) return nil;
    return indexPath;
}


@end
