//
//  HomeViewController.m
//  TinCongNghe
//
//  Created by Khai on 24/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewMain.h"
#import "Detect3GorWifiViewController.h"
#import "AppDelegate.h"

@interface HomeViewController ()
@property(strong, nonatomic)  NSOperationQueue *queueHTMLParse;
@end

@implementation HomeViewController{
    CarbonSwipeRefresh *refreshControl;
    NSMutableArray *listArticle;
    NSInteger pageNumber;
    BOOL isloadmore;
    NSInteger ableLoad;
    Reachability *reachability;
    NSArray *listOff;
    ReadingViewController *content;
    AppDelegate *app;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.clvContent.dataSource = self;
    self.clvContent.delegate = self;
    
    app = kAppdelegate;
    pageNumber = 0;
    self.url = @""; isloadmore = false;
    self.queueHTMLParse = [[NSOperationQueue alloc] init];
    [self.queueHTMLParse setName:kQueueNameHTMLParse];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ableLoad = [[defaults objectForKey:kAllstate]integerValue];
    NSLog(@"%lu",ableLoad);
    
    refreshControl = [[CarbonSwipeRefresh alloc] initWithScrollView:self.clvContent];
    [refreshControl setColors:@[
                         [UIColor blueColor],
                         [UIColor redColor],
                         [UIColor orangeColor],
                         [UIColor greenColor],
                         [UIColor blackColor]
                         ]];
    [refreshControl addTarget:self
                       action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refreshControl];
    listArticle = [[NSMutableArray alloc]init];
    content = [[ReadingViewController alloc]init];
    
    __weak typeof(self) weakSelf = self;
    //set up loadmore
    [self.clvContent addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadpage];
    }];
    [self checkConnect];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.clvContent triggerPullToRefresh];
}

#pragma mark - check connect network


-(void)checkConnect{
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        app.connect = false;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                             NSUserDomainMask, YES);
        NSString *cacheDirectoryPath = [paths objectAtIndex:0];
        NSString *filePath = [cacheDirectoryPath stringByAppendingPathComponent:@"Arr.txt"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExisted = [fileManager fileExistsAtPath:filePath];
        NSData *data = [fileManager contentsAtPath:filePath];
        listOff = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        for (NSDictionary *dict in listOff) {
            Article *newArticle = [[Article alloc]init];
            newArticle.title = [dict objectForKey:@"title"];
            newArticle.mainUrl = [dict objectForKey:@"mainUrl"];
            newArticle.timePost = [dict objectForKey:@"postTime"];
            newArticle.imageview = [[UIImageView alloc]initWithImage:[UIImage imageWithData:[dict objectForKey:@"imageData"]]];
            [listArticle addObject:newArticle];
        }
        [self.clvContent reloadData];
    }
    else if (status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        [self loadHome];
        app.connect = true;
    }
}

-(void)offlinewithData:(NSMutableArray *)temp{
    //WiFi
    if (ableLoad) {
        NSMutableArray *listDict = [[NSMutableArray alloc]init];
        for (Article *newArticle in temp) {
            NSString *title = newArticle.title;
            NSString *mainUrl = newArticle.mainUrl;
            NSString *imgUrl = newArticle.imageUrl;
            NSString *postTime = newArticle.timePost;
            UIImageView *imageview = [[UIImageView alloc]init];
            [imageview sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"Jeff-Bezos"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                NSData *imageData;
                NSRange jpgRange = [imgUrl rangeOfString:@"png" options:NSBackwardsSearch];
                if (jpgRange.location != NSNotFound) {
                    imageData = UIImagePNGRepresentation(imageview.image);
                }else{
                    imageData = UIImageJPEGRepresentation(imageview.image, 80.0f);
                }
                
                NSDictionary *dicArticle = [[NSDictionary alloc]initWithObjectsAndKeys:
                                            title ,@"title",
                                            postTime ,@"postTime",
                                            mainUrl ,@"mainUrl",
                                            imageData ,@"imageData", nil];
                [listDict addObject:dicArticle];
                if (listDict.count == temp.count) {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                         NSUserDomainMask, YES);
                    NSString *cacheDirectoryPath = [paths objectAtIndex:0];
                    NSLog(@"cacheDirectoryPath = %@",cacheDirectoryPath);
                    NSString *filePath = [cacheDirectoryPath stringByAppendingPathComponent:@"Arr.txt"];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL fileExisted = [fileManager fileExistsAtPath:filePath];
                    NSLog(@"EXIST BEFORE SAVE: %d", fileExisted);
                    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:listDict];
                    BOOL saveResult = [myData writeToFile:filePath atomically:YES];
                    NSLog(@"SaveResult = %d",saveResult);
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSInteger interger = [[defaults objectForKey:kdataMb]integerValue];
                    [content loadBeforeWithArr:listArticle andOfNumber:interger];
                }
            }];
        }
    }
}

#pragma mark - Load Infomation
-(void)loadpage{
    __weak typeof(self) weakSelf = self;
    NSString *nextPage = [NSString stringWithFormat:kGenkURL,weakSelf.url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:nextPage]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *document = [[TFHpple alloc]initWithHTMLData:responseObject];
        NSArray *listPage = [document searchWithXPathQuery:@"//p[@class='paging-wrap']/a"];
        NSLog(@"count %lu",(unsigned long)listPage.count);
        TFHppleElement *pagenumber = [listPage objectAtIndex:pageNumber];
        weakSelf.url = [pagenumber attributes][@"href"];
        [weakSelf loadHome];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't download data because : %@",error);
    }];
    [weakSelf.queueHTMLParse addOperation:operation];
}

-(void)loadHome{
    NSString *allCategoriesUrl = [NSString stringWithFormat:kGenkURL,self.url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:allCategoriesUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *document = [[TFHpple alloc]initWithHTMLData:responseObject];
        
        if (pageNumber == 0) {
            NSArray *listAs = [document searchWithXPathQuery:@"//div[@class='home-highlight-5']/div/div[@class='home-highlight-5-img']"];
            for (TFHppleElement *element in listAs) {
                NSString *urlImg,*title,*mainUrl;
                for (TFHppleElement *chirld in element.children) {
                    if ([chirld.tagName isEqualToString:@"img"]) {
                        urlImg = [chirld attributes][@"src"];
                        title = [chirld attributes][@"title"];
                    }else if([chirld.tagName isEqualToString:@"a"]){
                        mainUrl = [chirld attributes][@"href"];
                    }
                }
                Article *newArticle = [[Article alloc]initWithImageUrl:urlImg andTitle:title andMainUrl:mainUrl andTimePost:@""];
                [listArticle addObject:newArticle];
            }
        }
        NSArray *listAsTinHot = [document searchWithXPathQuery:@"//div[@class='news-stream w690 clearfix']/div"];
        for (TFHppleElement *element in listAsTinHot) {
            NSString *urlImg,*title,*mainUrl,*timeSkip;
            for (TFHppleElement *chirld in element.children) {
                if ([chirld.tagName isEqualToString:@"div"]) {
                    for (TFHppleElement *chirldSeconnd in chirld.children) {
                        if ([chirldSeconnd.tagName isEqualToString:@"a"]) {
                            title = [chirldSeconnd attributes][@"title"];
                            mainUrl = [chirldSeconnd attributes][@"href"];
                            NSArray *IMG = [chirldSeconnd childrenWithTagName:@"img"];
                            TFHppleElement *ThirdSecond = [IMG objectAtIndex:0];
                            urlImg = [ThirdSecond attributes][@"src"];
                            if(urlImg == nil){
                                urlImg = [ThirdSecond attributes][@"data-original"];
                            }
                        }
                        if ([chirldSeconnd.tagName isEqualToString:@"p"]) {
                            NSArray *TimeSkip = [chirldSeconnd childrenWithTagName:@"a"];
                            if (TimeSkip.count == 2) {
                                TFHppleElement *chirldSeconnd = [TimeSkip objectAtIndex:1];
                                timeSkip = [chirldSeconnd attributes][@"title"];
                            }
                        }
                    }
            }
        }
            Article *newArticle = [[Article alloc]initWithImageUrl:urlImg andTitle:title andMainUrl:mainUrl andTimePost:timeSkip];
            [listArticle addObject:newArticle];
        }
        if (listArticle.count <= 35) {
            [self offlinewithData:listArticle];
        }
        [self.clvContent reloadData];
        if (pageNumber < 4) {
            pageNumber++;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't download data because : %@",error);
    }];
    [self.queueHTMLParse addOperation:operation];
}

- (void)refresh:(id)sender {
    NSLog(@"REFRESH");
    [listArticle removeAllObjects];
    pageNumber = 0;
    [self loadpage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if(section == 1) {
        return 4;
    }else{
        if (listArticle.count >= 35) {
            return (listArticle.count-5);
        }
        return 30;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify;
    NSInteger index = indexPath.row;
    if (indexPath.section == 0) {
        identify = @"cell";
    }
    else if(indexPath.section == 1){
        identify = @"cell2";
        index = indexPath.row + 1;
    }else if(indexPath.section == 2){
        identify = @"cell3";
        index = indexPath.row + 5;
    }
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (listArticle.count != 0) {
        UILabel *label,*label2;
        UIImageView *temp = [[UIImageView alloc]init];
        Article *newArticle = [listArticle objectAtIndex:index];
        UIImageView *imageview;
        if (indexPath.section == 0) {
            label = (UILabel *)[cell viewWithTag:1001];
            label.text = newArticle.title;
            imageview = (UIImageView *)[cell viewWithTag:1000];
        }else if(indexPath.section == 1){
            label = (UILabel *)[cell viewWithTag:1003];
            label.text = newArticle.title;
            imageview = (UIImageView *)[cell viewWithTag:1002];
        }else if(indexPath.section == 2){
            label = (UILabel *)[cell viewWithTag:1005];
            label2 = (UILabel *)[cell viewWithTag:1006];
            imageview = (UIImageView *)[cell viewWithTag:1004];
            label.text = newArticle.title;
            NSString *name;
            if (newArticle.timePost ) {
                label2.text = newArticle.timePost;
            }
        }
        if (app.connect) {
            [imageview sd_setImageWithURL:[NSURL URLWithString:newArticle.imageUrl] placeholderImage:[UIImage imageNamed:@"imgres"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
        }else{
            imageview.image = newArticle.imageview.image;
        }

        if (index == listArticle.count - 1) {
            [self loadpage];
        }
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (indexPath.section == 0) {
    }
    else if(indexPath.section == 1){
        index = indexPath.row + 1;
    }else if(indexPath.section == 2){
        index = indexPath.row + 5;
    }
    Article *newArticle = [listArticle objectAtIndex:index];
    content = [self.storyboard instantiateViewControllerWithIdentifier:@"ReadingViewController"];
    content.url = [NSString stringWithFormat:kGenkURL,newArticle.mainUrl];
    content.imagehead = newArticle.imageUrl;
    content.index = index;
    [self.navigationController pushViewController:content animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width - 15, (self.view.frame.size.height + 50)/ 2);
    }else if(indexPath.section == 1){
        return CGSizeMake((self.view.frame.size.width - 30) / 2, 200 + 30);
    }else{
        return CGSizeMake(self.view.frame.size.width , 100);
    }
}

@end
