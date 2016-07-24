//
//  ViewController.m
//  TinCongNghe
//
//  Created by Khai on 23/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "ViewMain.h"
#import "View+MASShorthandAdditions.h"
#import "Detect3GorWifiViewController.h"
#import "FaceViewController.h"

@interface ViewMain ()<CarbonTabSwipeNavigationDelegate>
{
    NSArray *items;
    CarbonTabSwipeNavigation *carbonTabSwipeNavigation;
    UIButton *Menu,*expand,*Home,*New;
    NSMutableArray *categoriesUrl;
    HomeViewController *home;
    NewViewController *new;
    ContentViewController *content;
    Detect3GorWifiViewController *network;
}
@property(strong, nonatomic)  NSOperationQueue *queueHTMLParse;
@end

@implementation ViewMain

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ViewMain *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ViewMain alloc]init];
    });
    return sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.queueHTMLParse = [[NSOperationQueue alloc] init];
    [self.queueHTMLParse setName:kQueueNameHTMLParse];
    
    home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    new = [self.storyboard instantiateViewControllerWithIdentifier:@"NewViewController"];
    
    items = @[@"Home",@"New",@"Mobile",@"Internet",@"Tin ICT",@"Khám Phá",@"Trà đá công nghệ",@"Thủ Thuật",@"Apps - Games",@"Đồ Chơi Số"];
    
    categoriesUrl = [[NSMutableArray alloc]init];
    [self getlinkFirstScreen];
    carbonTabSwipeNavigation = [[CarbonTabSwipeNavigation alloc]initWithItems:items delegate:self];
    [carbonTabSwipeNavigation insertIntoRootViewController:self];
    [self style];
    [self customNavigation];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [Menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        // Custom
        // Example sidebar is width 200
        self.revealViewController.rearViewRevealWidth = 250;
        // Cannot drag and see beyond width 200
        self.revealViewController.rearViewRevealOverdraw = 0;
        // Faster slide animation
        self.revealViewController.toggleAnimationDuration = 0.5;
        // Simply ease out. No Spring animation.
        self.revealViewController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;
        // More shadow
        self.revealViewController.frontViewShadowRadius = 5;
        //[revealViewController panGestureRecognizer];
        [home.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)getlinkFirstScreen;
{
    NSString *urlAllCategories = @"http://genk.vn";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAllCategories]];
    AFHTTPRequestOperation *opetation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [opetation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *document = [[TFHpple alloc]initWithHTMLData:responseObject];
        NSArray *NewItem = [document searchWithXPathQuery:@"//div[@class='menu']/ul[@class='clearfix']/li/a"];
        for (TFHppleElement *element in NewItem) {
            NSString *title = [element attributes][@"href"];
            [categoriesUrl addObject:title];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't download data because : %@",error);
    }];
    [self.queueHTMLParse addOperation:opetation];
}

#pragma mark - custom Navigation
-(void)customNavigation{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height + 20)];
    Menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [Menu setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    Menu.frame = CGRectMake(0, 20, 60, self.navigationController.navigationBar.frame.size.height);
    [view addSubview:Menu];
    
    expand = [UIButton buttonWithType:UIButtonTypeCustom];
    [expand addTarget:self action:@selector(contentExpand:)
     forControlEvents:UIControlEventTouchUpInside];
    [expand setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    expand.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 60, 20, 60, self.navigationController.navigationBar.frame.size.height);
    [view addSubview:expand];
    
    UIView *subview = [self customViewHomeandNew];
    subview.layer.cornerRadius = 10.0f;
    subview.layer.borderColor = UIColor.blackColor.CGColor;
    subview.layer.borderWidth = 1;
    subview.clipsToBounds = YES;
    [view addSubview:subview];
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 0, 10, 0);
    [subview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.width.equalTo(@200);
        make.top.equalTo(Menu.mas_top).insets(padding);
        make.bottom.equalTo(Menu.mas_bottom).insets(padding);
    }];
    
    view.backgroundColor = [UIColor redColor];
    
    [self.navigationController.view addSubview:view];
}

-(void)contentExpand:(id)sender{
    FaceViewController *face = [self.storyboard instantiateViewControllerWithIdentifier:@"FaceViewController"];
    [self presentViewController:face animated:YES completion:^{
        
    }];
}

-(void)showContentHome:(BOOL)sender{
    if (!Home.selected) {
        [carbonTabSwipeNavigation setCurrentTabIndex:0 withAnimation:NO];
        Home.selected = YES;
        New.selected = NO;
    }
}

-(void)showContentNew:(id)sender{
    if (!New.selected) {
        [carbonTabSwipeNavigation setCurrentTabIndex:1 withAnimation:NO];
        New.selected = YES;
        Home.selected = NO;
    }
}

-(UIView *)customViewHomeandNew{
    UIView *subview = [[UIView alloc]init];
    
    Home = [UIButton buttonWithType:UIButtonTypeCustom];
    [Home addTarget:self action:@selector(showContentHome:) forControlEvents:UIControlEventTouchUpInside];
    [Home setTitle:NSLocalizedString(@"Home",@"Message") forState:UIControlStateNormal];
    [Home setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateSelected];
    [subview addSubview:Home];
    Home.selected = YES;
    
    New = [UIButton buttonWithType:UIButtonTypeCustom];
    [New addTarget:self action:@selector(showContentNew:) forControlEvents:UIControlEventTouchUpInside];
    [New setTitle:NSLocalizedString(@"New",@"Message") forState:UIControlStateNormal];
    [New setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateSelected];
    [subview addSubview:New];
    
    [Home mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subview.mas_top);
        make.centerX.equalTo(@-50);
        make.centerY.equalTo(@0);
        make.width.equalTo(@100);
        make.height.equalTo(subview.mas_height);
    }];
    
    [New mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subview.mas_top);
        make.centerX.equalTo(@50);
        make.centerY.equalTo(@0);
        make.width.equalTo(@100);
        make.height.equalTo(subview.mas_height);
    }];
    
    return subview;
}

- (void)style {
    
    UIColor *color = [UIColor colorWithRed:24.0 / 255 green:75.0 / 255 blue:152.0 / 255 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    carbonTabSwipeNavigation.toolbar.translucent = NO;
    [carbonTabSwipeNavigation setIndicatorColor:color];
    [carbonTabSwipeNavigation setTabExtraWidth:30];
    [carbonTabSwipeNavigation.carbonSegmentedControl setWidth:0.1 forSegmentAtIndex:0];
    [carbonTabSwipeNavigation.carbonSegmentedControl setWidth:0.1 forSegmentAtIndex:1];
    
    // Custimize segmented control
    [carbonTabSwipeNavigation setNormalColor:[color colorWithAlphaComponent:0.6]
                                        font:[UIFont boldSystemFontOfSize:14]];
    [carbonTabSwipeNavigation setSelectedColor:color font:[UIFont boldSystemFontOfSize:14]];
}


#pragma mark - CarbonTabSwipeNavigation Delegate
// required
- (nonnull UIViewController *)carbonTabSwipeNavigation:
(nonnull CarbonTabSwipeNavigation *)carbontTabSwipeNavigation
                                 viewControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return home;
        case 1:{
            [self customNavigation];
        }
            return new;
        default:{
            content = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentViewController"];
            if (categoriesUrl.count != 0) {
                content.url = [categoriesUrl objectAtIndex:index-1];
            }
        }
            return content;
    }
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                 willMoveAtIndex:(NSUInteger)index {
    if (index == 0) {
        Home.selected = YES;
        New.selected = NO;
    }else if(index == 1){
        Home.selected = NO;
        New.selected = YES;
    }else{
        content.title = [items objectAtIndex:index];
        Home.selected = NO;
        New.selected = NO;
    }
}
-(void)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation didMoveAtIndex:(NSUInteger)index{

}

- (UIBarPosition)barPositionForCarbonTabSwipeNavigation:
(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation {
    return UIBarPositionTop; // default UIBarPositionTop
}

@end
