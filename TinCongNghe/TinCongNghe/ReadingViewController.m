//
//  ReadingViewController.m
//  TinCongNghe
//
//  Created by Khai on 01/07/2016.
//  Copyright © 2016 Khai. All rights reserved.
//

#import "ReadingViewController.h"
#import "LinesOfInfor.h"
#import "AppDelegate.h"

@interface ReadingViewController ()<TTTAttributedLabelDelegate>
@property(strong, nonatomic)  NSOperationQueue *queueHTMLParse;
#define kCell1 @"cell1"
#define kCell2 @"cell2"
#define kCell3 @"cell3"
#define kCell4 @"cell4"
#define kCell5 @"cell5"
#define kfont1 @"font1"
#define kfont2 @"font2"
@end

@implementation ReadingViewController{
    NSMutableArray *listContent;
    NSMutableArray *listKey;
    NSMutableArray *listFont;
    Article *newArticle;
    NSMutableArray *newRegular;
    UIView *viewNavigation;
    NSMutableArray *loadOffline;
    AppDelegate *app;
    Reachability *reachability;
    UIImageView *imageview;
    NSInteger number;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tbvMainContent.delegate = self;
    self.tbvMainContent.dataSource = self;
    self.tbvMainContent.separatorColor = [UIColor clearColor];
    [self customNavigation];
    [self addadvertisement];
    // Do any additional setup after loading the view.
    UIImageView *imageViewTemp = [[UIImageView alloc]init];
    imageViewTemp.image = [UIImage imageNamed:@"imgres"];
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add the effect view to the image view
    [imageViewTemp addSubview:effectView];
    [self.btnClose setBackgroundImage:imageViewTemp.image forState:UIControlStateNormal];
    self.btnClose.layer.cornerRadius = 15.0f;
    self.btnClose.layer.borderColor = UIColor.blackColor.CGColor;
    self.btnClose.layer.borderWidth = 1;
    self.btnClose.clipsToBounds = YES;
    // show image

    [self StartInit];
    [self checkConnect];
}

#pragma mark - advertisement
-(void)addadvertisement{
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}

-(void)StartInit{
    self.queueHTMLParse = [[NSOperationQueue alloc] init];
    [self.queueHTMLParse setName:kQueueNameHTMLParse];
    
    listContent = [[NSMutableArray alloc]init];
    listKey = [[NSMutableArray alloc]init];
    newRegular = [[NSMutableArray alloc]init];
    loadOffline = [[NSMutableArray alloc]init];
    newArticle = [[Article alloc]init];
    app = kAppdelegate;
}
-(void)customNavigation{
    viewNavigation = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height + 20)];
    UIButton *toleft = [UIButton buttonWithType:UIButtonTypeCustom];
    [toleft addTarget:self action:@selector(AcClose:) forControlEvents:UIControlEventTouchUpInside];
    [toleft setImage:[UIImage imageNamed:@"to left"] forState:UIControlStateNormal];
    toleft.frame = CGRectMake(0, 30, 60, self.navigationController.navigationBar.frame.size.height - 20);
    [viewNavigation addSubview:toleft];
    
    UIButton *share = [UIButton buttonWithType:UIButtonTypeCustom];
    [share addTarget:self action:@selector(contentSharing:) forControlEvents:UIControlEventTouchUpInside];
    [share setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    share.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 50, 30, 40, self.navigationController.navigationBar.frame.size.height - 20);
    [viewNavigation addSubview:share];
    
    UIButton *comment = [UIButton buttonWithType:UIButtonTypeCustom];
    [comment addTarget:self action:@selector(contentComment:) forControlEvents:UIControlEventTouchUpInside];
    [comment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    comment.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 60 - share.frame.size.width, 30, 40, self.navigationController.navigationBar.frame.size.height - 20);
    [viewNavigation addSubview:comment];
    
    UILabel *labelTitle = [[UILabel alloc]init];
    labelTitle.text = @"Reading";
    labelTitle.textAlignment = UITextAlignmentCenter;
    labelTitle.textColor = [UIColor whiteColor];
    [viewNavigation addSubview:labelTitle];
    [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@24);
        make.centerX.equalTo(@5);
        make.centerY.equalTo(@10);
        make.width.equalTo(@100);
    }];
    
    viewNavigation.backgroundColor = [UIColor blackColor];
    
    [self.navigationController.view addSubview:viewNavigation];
}

-(void)contentSharing:(id)sender{
    NSLog(@"Sharing");
}

-(void)contentComment:(id)sender{
     NSLog(@"Comment");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
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
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}



- (IBAction)AcClose:(id)sender {
    [viewNavigation removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - load before
-(void)loadBeforeWithArr:(NSMutableArray *)listArticle andOfNumber:(NSInteger )Number{
    [self StartInit];
    number = Number;
    for ( int i = 0; i < Number; i++) {
        Article *articleTemp = [listArticle objectAtIndex:i];
        NSString *url = [NSString stringWithFormat:kGenkURL,articleTemp.mainUrl];
            [self loadcontentWithurl:url withCompletionBlock:^(NSMutableArray *tempRead, NSMutableArray *tempKey, NSMutableArray *listRegular, Article *oneArticle) {
                // file main
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                     NSUserDomainMask, YES);
                NSString *cacheDirectoryPath = [paths objectAtIndex:0];
                NSString *filePath = [cacheDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"article%d.txt",i]];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL fileExisted = [fileManager fileExistsAtPath:filePath];
                if (fileExisted) {
                    BOOL removeFile = [fileManager removeItemAtPath:filePath error:nil];
                }
                NSMutableArray *allContents = [[NSMutableArray alloc]init];
                for (int i = 0; i < tempRead.count; i++) {
                    LinesOfInfor *inforOfline = [tempRead objectAtIndex:i];
                    NSString *identify = [tempKey objectAtIndex:i];
                    NSDictionary *Temp = [[NSDictionary alloc]initWithObjectsAndKeys:
                                          inforOfline.textOfCell,@"text",
                                          identify,@"identify",
                                          inforOfline.arrLink,@"arrLink",
                                          inforOfline.locaGetLink,@"getlink", nil];
                    [allContents addObject:Temp];
                }
                NSData *myData1 = [NSKeyedArchiver archivedDataWithRootObject:allContents];
                BOOL saveResult = [myData1 writeToFile:filePath atomically:YES];
                
                NSMutableArray *Regular = [[NSMutableArray alloc]init];
                for (int i = 0; i < newRegular.count; i++) {
                    Article *article = [newRegular objectAtIndex:i];
                    UIImageView *imgview = [[UIImageView alloc]init];
                    [imgview sd_setImageWithURL:[NSURL URLWithString:article.imageUrl] placeholderImage:[UIImage imageNamed:@"notWifi"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        NSData *imageData;
                        NSRange jpgRange = [article.imageUrl rangeOfString:@"png" options:NSBackwardsSearch];
                        if (jpgRange.location != NSNotFound) {
                            imageData = UIImagePNGRepresentation(imgview.image);
                        }else{
                            imageData = UIImageJPEGRepresentation(imgview.image, 80.0f);
                        }
                        NSDictionary *dicArticle = [[NSDictionary alloc]initWithObjectsAndKeys:
                                                    article.title ,@"title",
                                                    imageData ,@"imageData",
                                                    nil];
                        [Regular addObject:dicArticle];
                        if (Regular.count == listRegular.count) {
                            NSString *filePath2 = [cacheDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Regular%d.txt",i]];
                            BOOL fileExisted = [fileManager fileExistsAtPath:filePath2];
                            if (fileExisted) {
                                BOOL removeFile2 = [fileManager removeItemAtPath:filePath2 error:nil];
                            }
                            NSData *myData2 = [NSKeyedArchiver archivedDataWithRootObject:Regular];
                            BOOL saveResult2 = [myData2 writeToFile:filePath2 atomically:YES];
                        }
                    }];
                }
                NSString *filePath3 = [cacheDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Celltail%d.txt",i]];
                BOOL fileExisted3 = [fileManager fileExistsAtPath:filePath3];
                if (fileExisted3) {
                    BOOL removeFile3 = [fileManager removeItemAtPath:filePath3 error:nil];
                }
                NSDictionary *dicArticle = [[NSDictionary alloc]initWithObjectsAndKeys:
                                            oneArticle.title ,@"title",
                                            oneArticle.timePost ,@"postTime",
                                            oneArticle.mainUrl ,@"mainUrl",
                                            nil];
                NSData *myData3 = [NSKeyedArchiver archivedDataWithRootObject:dicArticle];
                BOOL saveResult3 = [myData3 writeToFile:filePath3 atomically:YES];
            }];
    }
}

-(void)checkConnect{
    [self StartInit];
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
        NSString *filePath = [cacheDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"article%ld.txt",(long)self.index]];
        NSString *filePath2 = [cacheDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Regular%ld.txt",(long)self.index]];
        NSString *filePath3 = [cacheDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Celltail%ld.txt",(long)self.index]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExisted = [fileManager fileExistsAtPath:filePath];
        if (fileExisted) {
            NSData *data = [fileManager contentsAtPath:filePath];
            NSMutableArray *listOff = [[NSMutableArray alloc]init];
            listOff = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
            for (NSDictionary *Temp in listOff) {
                NSString *identify = [Temp objectForKey:@"identify"];
                LinesOfInfor *line = [[LinesOfInfor alloc]init];
                line.textOfCell = [Temp objectForKey:@"text"];
                line.locaGetLink = [Temp objectForKey:@"getlink"];
                line.arrLink = [Temp objectForKey:@"arrLink"];
                [listKey addObject:identify];
                [listContent addObject:line];
            }
            
            NSData *data2 = [fileManager contentsAtPath:filePath3];
            NSDictionary *tail = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data2];
            newArticle.title = [tail objectForKey:@"title"];
            newArticle.mainUrl = [tail objectForKey:@"mainUrl"];
            
            NSData *data3 = [fileManager contentsAtPath:filePath2];
            NSMutableArray *Regular = [[NSMutableArray alloc]init];
            Regular = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:data3];
            for (NSDictionary *dict in Regular) {
                Article *article = [[Article alloc]init];
                article.title = [dict objectForKey:@"title"];
                article.imageview = [[UIImageView alloc]initWithImage:[UIImage imageWithData:[dict objectForKey:@"imageData"]]];
                [newRegular addObject:article];
            }
            [self.tbvMainContent reloadData];
        }else{
            imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            imageview.image = [UIImage imageNamed:@"netcheck"];
            [self.view addSubview:imageview];
            [viewNavigation removeFromSuperview];
        }
        
    }
    else if (status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        [self loadcontentWithurl:self.url withCompletionBlock:^(NSMutableArray *tempRead, NSMutableArray *tempKey, NSMutableArray *listRegular, Article *oneArticle) {
            
        }];
        app.connect = true;
    }
}


-(void)loadcontentWithurl:(NSString *)url withCompletionBlock:(void(^)(NSMutableArray *tempRead, NSMutableArray *tempKey,NSMutableArray *listRegular,Article *oneArticle))completion{
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self StartInit];
        TFHpple *document = [[TFHpple alloc]initWithHTMLData:responseObject];
        
        // Timeline Post Article
        NSArray *Array2 = [document searchWithXPathQuery:@"//div[@class='news-showtitle mt10']/div[@class='clearfix']/div[@class='note fl']/a"];
        NSMutableArray *personPost = [[NSMutableArray alloc]init];
        for (TFHppleElement *element in Array2) {
            NSString *A = element.text;
            [personPost addObject:A];
        }
        LinesOfInfor *linesInfo1 = [[LinesOfInfor alloc]init];
        if (personPost.count > 2) {
            UIFont *font = [UIFont fontWithName:@"Georgia-Italic" size:15];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                        forKey:NSFontAttributeName];
            linesInfo1.textOfCell = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ - %@ | %@",[personPost objectAtIndex:0],[personPost objectAtIndex:1],[personPost objectAtIndex:2]] attributes:attrsDictionary];
            
        }else if(personPost.count == 2){
            UIFont *font = [UIFont fontWithName:@"Georgia-Italic" size:15];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                        forKey:NSFontAttributeName];
            linesInfo1.textOfCell = [[NSMutableAttributedString alloc]initWithString:[[NSString stringWithFormat:@"%@ | %@",[personPost objectAtIndex:0],[personPost objectAtIndex:1]] mutableCopy] attributes:attrsDictionary];
            ;
        }else{
            UIFont *font = [UIFont fontWithName:@"Georgia-Italic" size:15];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                        forKey:NSFontAttributeName];
            linesInfo1.textOfCell = [[NSMutableAttributedString alloc]initWithString:[personPost objectAtIndex:0] attributes:attrsDictionary];
        }
        [listContent addObject:linesInfo1];  [listKey addObject:kCell1];
        
        // Title parse
        NSArray *Array1 = [document searchWithXPathQuery:@"//div[@class='news-showtitle mt10']/h1"];
        TFHppleElement *Element1 = [Array1 objectAtIndex:0];
        NSString *text2 = Element1.text;
        NSString *text3 = [text2 substringFromIndex:2];
        LinesOfInfor *linesInfo2 = [[LinesOfInfor alloc]init];
        UIFont *font = [UIFont fontWithName:@"BodoniSvtyTwoOSITCTT-Bold" size:30];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                    forKey:NSFontAttributeName];
        linesInfo2.textOfCell = [[NSMutableAttributedString alloc]initWithString:text3 attributes:attrsDictionary];
        [listContent addObject:linesInfo2];  [listKey addObject:kCell1];
        // image title
        if (self.imagehead != nil) {
            LinesOfInfor *linesInfo3 = [[LinesOfInfor alloc]init];
            linesInfo3.textOfCell = [[NSMutableAttributedString alloc]initWithString:self.imagehead];
             [listContent addObject:linesInfo3];  [listKey addObject:kCell2];
        }
        // Title into article
        NSArray *Array3 = [document searchWithXPathQuery:@"//div[@class='content clearfix']/h2[@class='init_content oh']"];
        TFHppleElement *element2 = [Array3 objectAtIndex:0];
        NSString *text4 = element2.text;
        LinesOfInfor *linesInfo4 = [[LinesOfInfor alloc]init];
        UIFont *font2 = [UIFont fontWithName:@"Times New Roman" size:20];
        NSDictionary *attrsDictionary2 = [NSDictionary dictionaryWithObject:font2
                                                                    forKey:NSFontAttributeName];
        linesInfo4.textOfCell = [[NSMutableAttributedString alloc]initWithString:text4 attributes:attrsDictionary2];
        [listContent addObject:linesInfo4];  [listKey addObject:kCell1];
        
        // Parse main content
        NSArray *Array4 = [document searchWithXPathQuery:@"//div[@class='content clearfix']/div[@id='ContentDetail']"];
        TFHppleElement *element3 = [Array4 objectAtIndex:0];
        for (TFHppleElement *chirld in element3.children) {
            LinesOfInfor *newInfor = [[LinesOfInfor alloc]init];
            // Text
            if ([chirld.tagName isEqualToString:@"p"]) {
                NSString *allText = @"";
                NSMutableArray *arrBold = [[NSMutableArray alloc]init];
                NSMutableArray *arrLink = [[NSMutableArray alloc]init];
                NSMutableArray *locationGetLink = [[NSMutableArray alloc]init];
                for (TFHppleElement *chirld2 in chirld.children) {
                    if ([chirld2.tagName isEqualToString:@"text"]) {
                        allText = [NSString stringWithFormat:@"%@%@",allText,chirld2.content];
                    }
                    if ([chirld2.tagName isEqualToString:@"strong"]) {
                        NSString *bold = chirld2.text;
                        if(bold != nil)
                        {
                            allText = [NSString stringWithFormat:@"%@%@",allText,bold];
                            [arrBold addObject:bold];
                        }
                    }
                    if ([chirld2.tagName isEqualToString:@"a"]) {
                        NSString *link = [chirld2 attributes][@"href"];
                        [arrLink addObject:link];
                        NSString *newtext = [chirld2 attributes][@"title"];
                        if (newtext == nil) {
                            newtext = chirld2.content;
                        }
                        [locationGetLink addObject:newtext];
                        allText = [NSString stringWithFormat:@"%@%@",allText,newtext];
                    }
                    if([chirld2.tagName isEqualToString:@"span"]){
                        for (TFHppleElement *chirld3 in chirld2.children) {
                            if ([chirld3.tagName isEqualToString:@"i"]) {
                                NSString *bold = chirld3.text;
                                if(bold != nil)
                                {
                                    allText = [NSString stringWithFormat:@"%@%@",allText,bold];
                                    [arrBold addObject:bold];
                                }
                            }
                        }
                    }
                }
                UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:20];
                NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                            forKey:NSFontAttributeName];
                NSMutableAttributedString *NewText = [[NSMutableAttributedString alloc]initWithString:allText attributes:attrsDictionary];
                for (int i = 0; i < arrBold.count; i++) {
                    NSRange range = [allText rangeOfString:arrBold[i]];
                    UIFont *font = [UIFont fontWithName:@"BodoniSvtyTwoOSITCTT-Bold" size:22];
                    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                                forKey:NSFontAttributeName];
                    [NewText addAttributes:attrsDictionary range:range];
                }
                newInfor = [newInfor initWithText:NewText andArrLink:arrLink andArrLocaLink:locationGetLink];
                [listContent addObject:newInfor];   [listKey addObject:kCell1];
            }
            // Link Video and Image
            if([chirld.tagName isEqualToString:@"div"]){
                    NSString *LinkVideo = [chirld attributes][@"data-src"];
                    if (LinkVideo != nil && ![@"(null) (null)" isEqualToString:LinkVideo]) {
                        LinesOfInfor *linesInfo5 = [[LinesOfInfor alloc]init];
                        linesInfo5.textOfCell = [[NSMutableAttributedString alloc]initWithString:LinkVideo];
                         [listContent addObject:linesInfo5];  [listKey addObject:kCell3];
                    }else{
                        for (TFHppleElement *chirld3 in chirld.children) {
                            if ([chirld3.tagName isEqualToString:@"div"]) {
                                TFHppleElement *chirld4 = [chirld3 firstChild];
                                NSString *NameImg = [chirld4 attributes][@"src"];
                                if (NameImg != nil) {
                                    LinesOfInfor *linesInfo6 = [[LinesOfInfor alloc]init];
                                    linesInfo6.textOfCell = [[NSMutableAttributedString alloc]initWithString:NameImg];
                                    [listContent addObject:linesInfo6];  [listKey addObject:kCell2];
                                }
                            }
                        }
                    }
                }
        }
        // Quang Cao Cuoi
        NSArray *Arr4 = [document searchWithXPathQuery:@"//div[@class='VCSortableInPreviewMode link-content-footer']/a"];
        if (Arr4.count != 0) {
            TFHppleElement *chirldLast = [Arr4 objectAtIndex:0];
                newArticle.title = [NSString stringWithFormat:@">>>%@",[chirldLast text]];
                newArticle.mainUrl = [chirldLast attributes][@"href"];
        }
       // Cac Tin Doc Nhieu
        NSArray *Arr5 = [document searchWithXPathQuery:@"//div[@class='box-relation-news']/ul/li"];
        if(Arr5.count != 0){
            for (TFHppleElement *element in Arr5) {
                for (TFHppleElement *chirld in element.children) {
                    if ([chirld.tagName isEqualToString:@"a"]) {
                        Article *article = [[Article alloc]init];
                        article.title = [chirld attributes][@"title"];
                        article.mainUrl = [chirld attributes][@"href"];
                        TFHppleElement *second = [chirld firstChild];
                        article.imageUrl = [second attributes][@"src"];
                        [newRegular addObject:article];
                    }
                }
            }
        }
        completion(listContent,listKey,newRegular,newArticle);
        [self.tbvMainContent reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't download data because : %@",error);
    }];
    [self.queueHTMLParse addOperation:operation];
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (listContent.count != 0) {
           if (indexPath.section == 0) {
               NSString *identify;
               identify = [listKey objectAtIndex:indexPath.row];
               UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
               return [self updateCell:cell CellforRowAtIndexPath:indexPath identify:identify];
           }else if(indexPath.section == 1){
               return 100;
           }else{
               return 100;
           }
    }
    return 1;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (listContent.count != 0) {
        if (section == 0) {
            return listContent.count;
        }else if(section == 2){
            return 3;
        }
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identify = kCell1;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (listContent.count != 0) {
        if (indexPath.section == 0) {
            LinesOfInfor *newInfo = [listContent objectAtIndex:indexPath.row];
            identify = [listKey objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:identify];
            [self updateCell:cell CellforRowAtIndexPath:indexPath identify:identify];
            if ([identify isEqualToString:kCell3]) {
                NSString *text = [newInfo.textOfCell string];
                UIWebView *webView = (UIWebView *)[cell viewWithTag:1002];
                NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:text]];
                [webView loadRequest:request];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if(indexPath.section == 1){
                identify = kCell4;
                cell = [tableView dequeueReusableCellWithIdentifier:identify];
                UILabel *label = [cell.contentView viewWithTag:2002];
                label.text = newArticle.title;
        }else{
            identify = kCell5;
            cell = [tableView dequeueReusableCellWithIdentifier:identify];
            UIImageView *imageview1 = [cell.contentView viewWithTag:2000];
            UILabel *label1 = [cell.contentView viewWithTag:2001];
            Article *NewArticle;
            if (newRegular.count >= indexPath.row + 1) {
                NewArticle = [newRegular objectAtIndex:indexPath.row];
                label1.text = NewArticle.title;
                if (app.connect) {
                    [imageview1 sd_setImageWithURL:[NSURL URLWithString:NewArticle.imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    }];
                }else{
                     imageview1.image = NewArticle.imageview.image;
                }
            }
        }
    }
    return cell;
}

-(CGFloat)updateCell:(UITableViewCell *)cell CellforRowAtIndexPath:(NSIndexPath *)indexPath identify:(NSString *)identify{
    cell.backgroundColor = [UIColor clearColor];
    LinesOfInfor *newInfo = [listContent objectAtIndex:indexPath.row];
        if ([identify isEqualToString:kCell1]) {
            TTTAttributedLabel *label = (TTTAttributedLabel *)[cell viewWithTag:1000];
            label.delegate = self;
            label.attributedText = newInfo.textOfCell;
            // get link
            for (int i = 0; i < newInfo.arrLink.count; i++) {
                NSString *loca = [newInfo.locaGetLink objectAtIndex:i];
                NSString *LabelText = [newInfo.textOfCell string];
                NSRange range = [LabelText rangeOfString:loca];
                [label addLinkToURL:[newInfo.arrLink objectAtIndex:i] withRange:range];
            }
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, self.view.frame.size.width, label.frame.size.height);
            [label sizeToFit];
            return label.frame.size.height + label.frame.origin.y + 10;
        }else if([identify isEqualToString:kCell2]){
            NSString *text = [newInfo.textOfCell string];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
            [imageView sd_setImageWithURL:[NSURL URLWithString:text] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    NSLog(@"%@",error);
                }
            }];
            return 300;
        }else if([identify isEqualToString:kCell3]){
            return 300;
        }else if([identify isEqualToString:kCell4]){
            return 50;
        }else{
            return 100;
        }
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    NSString *stringurl = [NSString stringWithFormat:@"%@",url];
    if ([[stringurl substringToIndex:14] isEqualToString:@"http://genk.vn"]) {
        ReadingViewController *reading = [self.storyboard instantiateViewControllerWithIdentifier:@"ReadingViewController"];
        NSString *mainurl = [NSString stringWithFormat:@"%@",url];
        mainurl = [mainurl substringFromIndex:14];
        reading.url = [NSString stringWithFormat:kGenkURL,mainurl];
        [self.navigationController pushViewController:reading animated:YES];
    }else{
       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringurl]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ReadingViewController *reading = [self.storyboard instantiateViewControllerWithIdentifier:@"ReadingViewController"];
    if (indexPath.section == 1) {
        reading.url = newArticle.mainUrl;
    }else if(indexPath.section == 2){
        Article *article = [newRegular objectAtIndex:indexPath.row];
        reading.url = [NSString stringWithFormat:kGenkURL,article.mainUrl];
        reading.imagehead = article.imageUrl;
    }
    reading.index = -1;
    [self.navigationController pushViewController:reading animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
    if ( indexPath.section == 0 ) return nil;
    return indexPath;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return @"Bài viết đọc nhiều";
    }
    return nil;
}
@end
