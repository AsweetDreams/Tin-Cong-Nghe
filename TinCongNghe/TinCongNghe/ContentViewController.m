//
//  InformViewController.m
//  TinCongNghe
//
//  Created by Khai on 23/06/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()
{
    CarbonSwipeRefresh *refresh;
}
@property(strong, nonatomic)  NSOperationQueue *queueHTMLParse;
@end

@implementation ContentViewController{
    NSMutableArray *listArticle;
    NSInteger pageNumber;
    BOOL isloadmore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.clvContent.delegate = self;
    self.clvContent.dataSource = self;
    
    self.queueHTMLParse = [[NSOperationQueue alloc] init];
    [self.queueHTMLParse setName:kQueueNameHTMLParse];
    pageNumber = 0;
    isloadmore = false;
    refresh = [[CarbonSwipeRefresh alloc]initWithScrollView:self.clvContent];
    [self.view addSubview:refresh];
    [refresh setColors:@[
                         [UIColor blueColor],
                         [UIColor redColor],
                         [UIColor orangeColor],
                         [UIColor greenColor],
                         [UIColor blackColor]
                         ]];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    listArticle = [[NSMutableArray alloc]init];
    listArticle = [[NSMutableArray alloc]init];
    
    __weak typeof(self) weakSelf = self;
    //set up loadmore
    [self.clvContent addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadpage];
    }];
    [self loadInformWithUrl:[NSString stringWithFormat:kGenkURL,self.url]];
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
        [weakSelf loadInformWithUrl:[NSString stringWithFormat:kGenkURL,self.url]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't download data because : %@",error);
    }];
    [weakSelf.queueHTMLParse addOperation:operation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadInformWithUrl:(NSString *)url{
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        TFHpple *document = [[TFHpple alloc]initWithHTMLData:responseObject];
        if (pageNumber == 0) {
            NSString *xPath = @"//div[@class='home-highlight-5 clearfix']/div/div[@class='home-highlight-5-img']";
            if ([url isEqualToString:@"http://genk.vn//tra-da-cong-nghe.chn"]) {
                NSString *urlImg,*title,*mainUrl;
                xPath = @"//div[@class='cafe-hightlight']/div[@class='cafe-hightlight-tire-1']/a";
                NSArray *listAs = [document searchWithXPathQuery:xPath];
                TFHppleElement *element = [listAs objectAtIndex:0];
                title = [element attributes][@"title"];
                mainUrl =   [element attributes][@"href"];
                NSArray *chirld = [element childrenWithTagName:@"img"];
                TFHppleElement *Second = [chirld objectAtIndex:0];
                urlImg = [Second attributes][@"src"];
                Article *newArticle = [[Article alloc]initWithImageUrl:urlImg andTitle:title andMainUrl:mainUrl andTimePost:@""];
                [listArticle addObject:newArticle];
                xPath = @"//div[@class='cafe-hightlight']/ul/li/a";
                listAs = [document searchWithXPathQuery:xPath];
                for (int i = 0; i < 2 ; i++) {
                    TFHppleElement *element = [listAs objectAtIndex:i];
                    title = [element attributes][@"title"];
                    mainUrl =   [element attributes][@"href"];
                    NSArray *chirld = [element childrenWithTagName:@"img"];
                    TFHppleElement *Second = [chirld objectAtIndex:0];
                    urlImg = [Second attributes][@"src"];
                    Article *newArticle = [[Article alloc]initWithImageUrl:urlImg andTitle:title andMainUrl:mainUrl andTimePost:@""];
                    [listArticle addObject:newArticle];
                }
            }
            else{
                NSArray *listAs = [document searchWithXPathQuery:xPath];
                for (int i = 0; i < 3; i++) {
                    TFHppleElement *element = [listAs objectAtIndex:i];
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
        }
        NSArray *listInform = [document searchWithXPathQuery:@"//div[@class='news-stream w690 clearfix']/div"];
        for (TFHppleElement *element in listInform) {
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
        [self.clvContent reloadData];
        if (pageNumber < 3) {
            pageNumber++;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Couldn't download data because : %@",error);
    }];
    [self.queueHTMLParse addOperation:operation];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if(section == 1) {
        return 2;
    }else{
        if (listArticle.count >= 33) {
            return (listArticle.count-3);
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
    }else{
        identify = @"cell3";
        index = indexPath.row + 3;
    }
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (listArticle.count >= 33) {
        Article *newArticle = [listArticle objectAtIndex:index];
        UIImageView *imageview;
        if (indexPath.section == 0) {
            UILabel *label = (UILabel *)[cell viewWithTag:1001];
            label.text = newArticle.title;
            imageview = (UIImageView *)[cell viewWithTag:1000];
        }else if(indexPath.section == 1){
            UILabel *label = (UILabel *)[cell viewWithTag:1003];
            label.text = newArticle.title;
            imageview = (UIImageView *)[cell viewWithTag:1002];
        }else{
            UILabel *label = (UILabel *)[cell viewWithTag:1005];
            UILabel *label2 = (UILabel *)[cell viewWithTag:1006];
            imageview = (UIImageView *)[cell viewWithTag:1004];
            label.text = newArticle.title;
            label2.text = newArticle.timePost;
            [label sizeToFit];
            [label2 sizeToFit];

            label2.frame = CGRectMake(label.frame.origin.x + 10,
                                      label2.frame.origin.y + label.frame.origin.x + label.frame.size.height,
                                      label2.frame.size.width,
                                      label2.frame.size.height);
        }
        [imageview sd_setImageWithURL:[NSURL URLWithString:newArticle.imageUrl] placeholderImage:[UIImage imageNamed:@"imgres"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
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
    }else{
        index = indexPath.row + 3;
    }
    Article *newArticle = [listArticle objectAtIndex:index];
    ReadingViewController *content = [self.storyboard instantiateViewControllerWithIdentifier:@"ReadingViewController"];
    content.url = [NSString stringWithFormat:kGenkURL,newArticle.mainUrl];
    content.imagehead = newArticle.imageUrl;
    [self.navigationController pushViewController:content animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height / 2);
    }else if(indexPath.section == 1){
        return CGSizeMake((self.view.frame.size.width - 30) / 2, 200);
    }else{
        return CGSizeMake(self.view.frame.size.width , 100);
    }
}

#pragma mark - refresh
- (void)refresh:(id)sender {
    NSLog(@"REFRESH");
    [listArticle removeAllObjects];
    pageNumber = 0;
    [self loadpage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [refresh endRefreshing];
    });
}

- (void)endRefreshing {
    [refresh endRefreshing];
}

@end
