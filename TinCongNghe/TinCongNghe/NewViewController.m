//
//  NewViewController.m
//  TinCongNghe
//
//  Created by Khai on 30/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "NewViewController.h"

@interface NewViewController ()
@property(strong, nonatomic)  NSOperationQueue *queueHTMLParse;
@end

@implementation NewViewController{
    CarbonSwipeRefresh *refreshControl;
    NSMutableArray *listArticle;
    UILabel *label,*labelheader;
    NSInteger pageNumber;
    BOOL isloadmore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tbvNew.dataSource = self;
    self.tbvNew.delegate = self;
    // Do any additional setup after loading the view.
    
    self.url = @"tin-moi.chn";
    pageNumber = 0; isloadmore = false;

    self.queueHTMLParse = [[NSOperationQueue alloc] init];
    [self.queueHTMLParse setName:kQueueNameHTMLParse];
    
    self.tbvNew.estimatedRowHeight = UITableViewAutomaticDimension;
    
    refreshControl = [[CarbonSwipeRefresh alloc] initWithScrollView:self.tbvNew];
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
    __weak typeof(self) weakSelf = self;
    //set up loadmore
    [self.tbvNew addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadpage];
    }];
    [self loadNew];
}

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
        [weakSelf loadNew];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't download data because : %@",error);
    }];
    [weakSelf.queueHTMLParse addOperation:operation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadNew{
    NSString *url = [NSString stringWithFormat:kGenkURL,self.url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *document = [[TFHpple alloc]initWithHTMLData:responseObject];
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
        [self.tbvNew reloadData];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(listArticle.count >= 30){
        return listArticle.count;
    }
    return 30;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Article *newArticle = [listArticle objectAtIndex:indexPath.row];
    ReadingViewController *content = [self.storyboard instantiateViewControllerWithIdentifier:@"ReadingViewController"];
    content.url = [NSString stringWithFormat:kGenkURL,newArticle.mainUrl];
    content.imagehead = newArticle.imageUrl;
    [self.navigationController pushViewController:content animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    if(listArticle.count != 0){
        Article *newArticle = [listArticle objectAtIndex:indexPath.row];
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:1000];
        label = (UILabel *)[cell viewWithTag:1001];
        labelheader = (UILabel *)[cell viewWithTag:1002];
        label.text = newArticle.title;
        labelheader.text = newArticle.timePost;
        [imageview sd_setImageWithURL:[NSURL URLWithString:newArticle.imageUrl] placeholderImage:[UIImage imageNamed:@"imgres"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        if (indexPath.row == listArticle.count - 1) {
            [self loadpage];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
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
