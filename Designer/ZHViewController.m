//
//  ZHViewController.m
//  Designer
//
//  Created by bejoy on 14-3-3.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHViewController.h"
#import "AFNetworking.h"
#import "ProductCCell.h"
#import "CuiKuanCell.h"

#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "OpenUDID.h"
#import <AdSupport/AdSupport.h>
#import "XMLReader.h"
#import "LocationManager.h"
#import "ZHBehaviorViewController.h"
//#import "ZHConstructionViewController.h"
#import "AFNetworking.h"
#import "ZHShiGongViewController.h"
#import "ZHJunGongViewController.h"
#import "ZHMapViewController.h"
#import "ZHEntireCountryViewController.h"



@interface ZHViewController ()
{
    UIView *launchView;
    UIView *mainView;
    
    UIView *menuView;
    UIView *contentView;
    UIImageView *iv;

    UIScrollView *sv;
    


    
    UILabel *nameLabel;
    UILabel *timeLabel;
    UILabel *dateLabel;
    
    
    UIScrollView *infoSV;
    UIImageView *designerImageView;
    
}


@end

@implementation ZHViewController


#pragma mark - openViewController

- (void)loginOut:(UIButton *)button
{
    
    NSString *currentUser = [Cookie getCookie:KCurrentUser];

    [Cookie setCookie:KCurrentUser value:nil];
    [Cookie setCookie:currentUser value:nil];
    ZHAppDelegate *appDelegate =  (ZHAppDelegate *)[[UIApplication sharedApplication] delegate] ;
    
    [appDelegate applicationDidBecomeActive:nil];

    
}



- (void)update
{
    [[Message share] messageAlert:@"您确定要退出吗？" delegate:self];
}



- (void)openViewController:(UIButton *)button
{

    if (currentButton != button && button.tag != 104) {
        currentButton = button;
        for (int i = 1; i< 7; i++) {
            
            UIButton *b =(UIButton *)[menuView viewWithTag:i];
            b.selected = NO;
        }
        button.selected = YES;
    }
    
    
    
    BaseViewController *bv;
    switch (button.tag ) {
        case 1:
        {
//            bv = [[ZHConstructionViewController alloc] init];
            

            break;
        }
        case 2:
        {

            break;
        }
        case 3:
        {


            break;
        }
        case 104:
        {
            [self update];
            return;
            break;
        }
        default:
            break;
    }

    [self animationPush];
    
    bv.view.alpha  = 0;
    [self.view addSubview:bv.view];
    [self addChildViewController:bv]; 
    
    [UIView animateWithDuration:KMiddleDuration animations:^{
        bv.view.alpha  = 1;
    }];


    
}

- (void)openConstruction:(UIButton *)button
{
   


}


- (void)animationPull
{
    [UIView animateWithDuration:KMiddleDuration animations:^{
        
        menuView.frame = RectMake2x(0, 0, 350, 1536);
//        contentView.frame = RectMake2x(350, 0, 1698, 1536 );
        
    }];
}
- (void)animationPush
{
    [UIView animateWithDuration:KMiddleDuration animations:^{
        
        menuView.frame = RectMake2x(-350, 0, 350, 1536);
//        contentView.frame = RectMake2x(2048, 0, 1698, 1536 );
        
    }];
    
    
}
#pragma mark - Action
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (buttonIndex == 1) {
        [self loginOut:nil];
    }
}


#pragma mark - b map



- (void)loadBaiduMapData
{
    _offlineMap = [[BMKOfflineMap alloc] init];
    _offlineMap.delegate = self;
   
    NSArray* records = [_offlineMap searchCity:@"北京"];
    oneRecord = [records objectAtIndex:0];
    [_offlineMap start:oneRecord.cityID];
}


//开始下载离线包
-(IBAction)start:(id)sender
{
    [_offlineMap start:oneRecord.cityID];
}
//停止下载离线包
-(IBAction)stop:(id)sender
{
    [_offlineMap pause:oneRecord.cityID];
}
//扫瞄离线包
-(IBAction)scan:(id)sender
{
    [_offlineMap scan:NO];
    
}
//删除本地离线包
-(IBAction)remove:(id)sender
{
    [_offlineMap remove:oneRecord.cityID];
    
}

#pragma mark -

- (void)putImage:(NSData *)data
{
    
    UIImage *image = [UIImage imageNamed:@"标题图-中期验收"];
    
    NSData *i_data =  UIImageJPEGRepresentation(image, .8);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/soap+xml"];
    
    NSString *strEncoded = [Base64 encode:i_data];
    
    NSDictionary *parameters = @{ @"ImgIn":  strEncoded};
    
    
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@Tositrust.asmx/PutImage", KHomeUrl];

    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        dict = dict[@"OrderState"];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSError *parseError = nil;
//        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:operation.responseObject error:&parseError];
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    
}




- (void)showMenuView
{
    [UIView animateWithDuration:KMiddleDuration animations:^{
        menuView.frame = CGRectMake(0, 0, 55, 768);
    }];
}


- (void)scrollMain
{
    [sv scrollRectToVisible:screen_BOUNDS(1) animated:NO];
}

- (void)loadConstructionNum
{
}

- (void)reloadConstructionsData
{

    SharedAppUser.ID = [Cookie getCookie:@"uuid"];

//    [self loadConstructionNum];
//    [self loadConstructionsData];
    
    nameLabel.text = SharedAppUser.account;

    
    
    [UIView animateWithDuration:KDuration animations:^{
        
        self.baseView.frame = CGRectMake(0, 0, 1024, 768);
        
    }];
}


- (void)loadConstructionsData
{
}

- (void)openControll:(int)tag
{
    BaseViewController *bv = nil;
    switch (tag) {
        case 1000: // 行为
        {
            bv = [[ZHBehaviorViewController alloc] init];
            break;
        }
        case 1001: // 施工
        {
            bv = [[ZHShiGongViewController alloc]  init];
            break;
        }
        case 1002: // 竣工
        {
            bv = [[ZHJunGongViewController alloc] init];
            break;
        }
        case 1003: // 刷新
        {
            break;
        }
        case 1004: // 注销
        {
            
            [self loginOut:nil];
            break;
        }
        case 1005: // 打开地图
        {
            
            [self openMap:@""];
            break;
        }
        default:
            break;
    }
    
    
    
    bv.view.frame = RectMake2x(0, 0, 1888, 1260);
    
    if (bv ) {
        if (currentViewController) {
            [currentViewController removeFromParentViewController];
            [currentViewController.view removeFromSuperview];
        }
        
        currentViewController = bv;
        
        [contentView addSubview:currentViewController.view];
        [self addChildViewController:currentViewController];
    }
}

- (void)control:(UIButton *)button
{
    
//    BaseViewController *bv = nil;
//    switch (button.tag) {
//        case 1000: // 行为
//        {
//            bv = [[ZHBehaviorViewController alloc] init];
//            break;
//        }
//        case 1001: // 施工
//        {
//            bv = [[ZHShiGongViewController alloc]  init];
//            break;
//        }
//        case 1002: // 竣工
//        {
//            bv = [[ZHJunGongViewController alloc] init];
//            break;
//        }
//        case 1003: // 刷新
//        {
//            break;
//        }
//        case 1004: // 注销
//        {
//            
//            [self loginOut:nil];
//            break;
//        }
//        case 1005: // 打开地图
//        {
//            
//            [self openMap:@""];
//            break;
//        }
//        default:
//            break;
//    }
//
//    
//    
//    bv.view.frame = RectMake2x(0, 0, 1888, 1260);
//
//    if (bv ) {
//        if (currentViewController) {
//            [currentViewController removeFromParentViewController];
//            [currentViewController.view removeFromSuperview];
//        }
//    
//        currentViewController = bv;
//        
//        [contentView addSubview:currentViewController.view];
//        [self addChildViewController:currentViewController];
//    }


    [self openControll:button.tag];
}


-(void)openMap:(NSString *)string
{

    ZHEntireCountryViewController *map = [[ZHEntireCountryViewController alloc] initWithNibName:@"ZHEntireCountryViewController" bundle:nil];
    map.view.frame = CGRectMake(1024, 0, 1024, 768);
    
    [self.view addSubview:map.view];
    [self addChildViewController:map];
    
    
    [UIView animateWithDuration:KDuration animations:^{
       
        self.baseView.frame = CGRectMake(-1024, 0, 1024, 768);
        map.view.frame = CGRectMake(0, 0, 1024, 768);
        
    }];
    
}



- (void)loadView
{
    [super loadView];
    

    
    [[Button share] addToView:self.baseView addTarget:self rect:RectMake2x(40, 80, 340, 120) tag:1000 action:@selector(control:) imagePath:@"按钮-行为统计-00"
         highlightedImagePath:@"按钮-行为统计-00"
            SelectedImagePath:@"按钮-行为统计-01"];
    [[Button share] addToView:self.baseView addTarget:self rect:RectMake2x(420, 80, 340, 120) tag:1001 action:@selector(control:) imagePath:@"按钮-施工工地统计-00"
         highlightedImagePath:@"按钮-施工工地统计-00"
            SelectedImagePath:@"按钮-施工工地统计-01"];
    [[Button share] addToView:self.baseView addTarget:self rect:RectMake2x(800, 80, 340, 120) tag:1002 action:@selector(control:) imagePath:@"按钮-竣工工地统计-00"
         highlightedImagePath:@"按钮-竣工工地统计-00"
            SelectedImagePath:@"按钮-竣工工地统计-01"
     ];
    
    
    [[Button share] addToView:self.baseView addTarget:self rect:RectMake2x(1645, 80, 120, 120) tag:1003 action:@selector(control:)
                    imagePath:@"按钮-刷新"];
    [[Button share] addToView:self.baseView addTarget:self rect:RectMake2x(1805, 80, 120, 120) tag:1004 action:@selector(control:)
                    imagePath:@"按钮-注销"
     ];
    
    
    
    [[Button share] addToView:self.baseView addTarget:self rect:RectMake2x(1968, 830, 40, 76) tag:1005 action:@selector(control:)
                    imagePath:@"箭头-右"
     ];
    
    
    
    

    contentView = [[UIView alloc] initWithFrame:RectMake2x(40, 236, 1888, 1260)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.clipsToBounds = YES;
    contentView.layer.cornerRadius = 6;
    

    nameLabel = [[UILabel alloc] initWithFrame:RectMake2x(18, 316, 300, 55)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont boldSystemFontOfSize:30];
    nameLabel.textColor = [[Theme share] giveColorfromStringColor:@"nameLabel"];
    [menuView addSubview:nameLabel];

    timeLabel = [[UILabel alloc] initWithFrame:RectMake2x(96, 396, 150, 55)];
    timeLabel.font = [UIFont systemFontOfSize:30];
    timeLabel.textColor = [[Theme share] giveColorfromStringColor:@"nameLabel"];
    [menuView addSubview:timeLabel];
    
    dateLabel = [[UILabel alloc] initWithFrame:RectMake2x(99, 456, 180, 55)];
    dateLabel.font = [UIFont systemFontOfSize:15];
    dateLabel.textColor = [[Theme share] giveColorfromStringColor:@"nameLabel"];
    [menuView addSubview:dateLabel];
   
    [self.baseView addSubview:contentView];

    
}

- (void)loadData{
    
    
    _viewControllers = [[NSMutableArray alloc] init];
     self.dataMArray  = [[NSMutableArray alloc] init];
    currentProcess = @"1";

    
    

}


- (void)getUserProfileSuccess:(UIButton *)button
{

    nameLabel.text = SharedAppUser.account;

    [self animationPull];
}



- (void)currentDatetime
{
    NSDate *date = [Cookie getCookie:@"datetime"];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    
    [comp setSecond:1];
    
    NSDate *currentDateTime = [[NSCalendar currentCalendar]
                               dateByAddingComponents:comp toDate:date options:0];
    
    
    [Cookie setCookie:@"datetime" value:currentDateTime];

    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"HH:mm"];
	NSString *timeStr = [outputFormatter stringFromDate:currentDateTime];

    timeLabel.text = timeStr;

    
    
    [outputFormatter setDateFormat:@"yyyy/MM/dd"];
    
    
	NSString *dateStr = [outputFormatter stringFromDate:currentDateTime];

    
    

    dateLabel.text = dateStr;

}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadData];
    
    [[LocationManager share] setupLocationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserProfileSuccess:) name:@"Notification_GetUserProfileSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadConstructionsData) name:@"reloadConstructionsData" object:nil];

    [self loadBaiduMapData];


    
    [self currentDatetime];

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(currentDatetime) userInfo:nil repeats:YES];

    

    
    [self openControll:1000];
    
    
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
//    if (SharedAppUser.account  != nil) {
//        [self reloadConst sructionsData];
//        nameLabel.text = SharedAppUser.account;
//
//
//    }
//    [self loadConstructionNum];

    _offlineMap.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放





}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - action

- (void)openProductDetail:(NSIndexPath *)indexPath
{
    
    
    
//    int index = indexPath.row;
//
//    
//    BaseViewController *bv;
//
//    bv = [[ZHConstructionViewController alloc] initWithNibName:@"ZHConstructionViewController" bundle:nil];
//    bv.dataMDict = [self.dataMArray objectAtIndex:index];
//    
//
//    [self animationPush];
//    
//    bv.view.alpha  = 0;
//    [self.view addSubview:bv.view];
//    [self addChildViewController:bv];
//    
//    [UIView animateWithDuration:KMiddleDuration animations:^{
//        bv.view.alpha  = 1;
//    }];
//    
    
    
    
    
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataMArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if ( !   [currentProcess isEqualToString:@"GetConstructionsMoney"] ) {
        ProductCCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCCell" forIndexPath:indexPath];
        cell.type = 0;
        
        NSDictionary *dict = [self.dataMArray objectAtIndex:indexPath.row];
        cell.dict = dict;
        
        return cell;
    }
    else {
        CuiKuanCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"CuiKuanCell" forIndexPath:indexPath];
        cell.type = 0;
        
        NSDictionary *dict = [self.dataMArray objectAtIndex:indexPath.row];

        cell.dict = dict;
        
        return cell;
    }

}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(535/2, 449/2);
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self openProductDetail:indexPath];

}


@end
