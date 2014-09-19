//
//  ZHMapViewController.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-6.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHMapViewController.h"
#import "ZHPointAnnotation.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "XMLReader.h"

#import "PdfPopoverController.h"
#import "DateTimePopoverController.h"
#import "UIImageView+WebCache.h"




@interface ZHMapViewController ()
{
    
    BMKPointAnnotation *pointAnnotationView;
    
}
@end

@implementation ZHMapViewController

- (IBAction)back:(UIButton *)button
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMapData" object:nil];
    
    [UIView animateWithDuration:KDuration animations:^{
        self.view.frame = CGRectMake(1024, 0, 1024, 768);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}




- (void)formatDataArray
{
    
    
    
    for (NSMutableDictionary *dict in self.dataMArray) {
        
        
        //      判断时间  30  分钟
        NSString *SoDate = dict[@"SoDate"][@"text"];
        NSString *SiDate = dict[@"SiDate"][@"text"];

        NSDate *soDate = [NSDate dateFromString:SoDate withFormat:@"yyyy/MM/dd hh:mm:ss"];
        NSDate *siDate = [NSDate dateFromString:SiDate withFormat:@"yyyy/MM/dd hh:mm:ss"];
        
        int date_comp = [NSDate dateCommpeMinute:siDate now:soDate];
        if (date_comp < 30) {
            [dict setValue:@"0" forKeyPath:@"Date_Status"];
        }
        else {
            [dict setValue:@"1" forKeyPath:@"Date_Status"];
            
        }
        
        
        
        //      判断距离   1   公里
        
//        int Distance = (int)dict[@"Distance"][@"text"];
        float Distance = [[[dict objectForKey:@"Distance"] objectForKey:@"text"] floatValue];

        if (Distance > 5000) {
            [dict setValue:@"0" forKeyPath:@"Distance_Status"];
        }
        else {
            [dict setValue:@"1" forKeyPath:@"Distance_Status"];
            
        }
        
    }
}

- (void)addAllAnnotation
{
//正常
    [self annotationForType:100];
//太短
    [self annotationForType:101];
//错误
    [self annotationForType:102];

}

- (void)loadMapCenter
{
    
    if ( self.dataMArray[0]) {
        
        NSDictionary *dict = self.dataMArray[0];
        CLLocationCoordinate2D coor;

        float lat = [[[dict objectForKey:@"SiLat"] objectForKey:@"text"] floatValue];
        float lng = [[[dict objectForKey:@"SiLng"] objectForKey:@"text"] floatValue];
        
        coor.latitude = lat;
        coor.longitude = lng;
        
        _baidu_MapView.centerCoordinate = coor;
    }
}


- (NSMutableArray *)arrayFor :(NSMutableArray *)array
{
    
    if ( ! userArray) {
        
        userArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [userArray addObject: dict[@"text"]];
        }
        return userArray;
    }
    
    return nil;
    
}

- (void)loadUserList
{
    
    
    [SVProgressHUD showWithStatus:@"正在刷新数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    __block NSMutableArray *a = [NSMutableArray array];
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/GetAllMonitor", KHomeUrl];
    NSDictionary *parameters = @{ @"subCityCode":  SharedAppUser.SubCityCode};
    
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        dict = dict[@"ArrayOfString"][@"string"];

        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            a = [[NSMutableArray alloc] init];
            return ;
        }
        else {
            [SVProgressHUD dismiss];
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                [a addObject:  dict];
            }
            else {
                a =  dict;
            }
        }
        
        [self arrayFor:a];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    
}

- (void)loadConstructionsData:(int)type name:(NSString *)name date:(NSString *)date
{
    
    [_baidu_MapView removeAnnotations: [NSArray arrayWithArray:_baidu_MapView.annotations]];
    [self.dataMArray removeAllObjects];
    
    [SVProgressHUD showWithStatus:@"正在刷新数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/", KHomeUrl];
    

    if (type == 1) {
        [urlStr appendString:@"XingWeiDiTu"];
    }
    else {
        [urlStr appendString:@"GongDiDiTu"];
    }
    
    NSDictionary *parameters = @{ @"subCityCode":  self.city_code,
                                  @"name": name,
                                  @"queryDate": date};
    
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        if (type == 1) {
            dict = dict[@"ArrayOfXingWeiDiTu"][@"XingWeiDiTu"];
        }
        else {
            dict = dict[@"ArrayOfGongDiDiTu"][@"GongDiDiTu"];
        }
        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            
            self.dataMArray = [[NSMutableArray alloc] init];
            
            return ;
        }
        else {
            [SVProgressHUD dismiss];
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                [self.dataMArray addObject:  dict];
            }
            else {
                self.dataMArray =  dict;
            }
        }
        

        
        if (type == 1) {
            [self formatDataArray];
            [self addAllAnnotation];
            
        }
        else {

            [self annotationGongdi:100];
            [self annotationGongdi:101];
            [self annotationGongdi:102];
            [self annotationGongdi:103];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
}

- (void)getCityCenter
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/GetCityCenter", KHomeUrl];
    

    NSDictionary *parameters = @{ @"subCityCode":  self.city_code };
    
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s options:XMLReaderOptionsProcessNamespaces error:&parseError];
        
//        [Cookie setCookie:@"lat" value:dict[@"Lat"][@"text"]];
//        [Cookie setCookie:@"lng" value:dict[@"Lng"][@"text"]];

        
        double lat = [dict[@"Loaction"][@"Lat"][@"text"] doubleValue];
        double lng = [dict[@"Loaction"][@"Lng"][@"text"] doubleValue];
        
        CLLocationCoordinate2D locat = CLLocationCoordinate2DMake( lat, lng );
        [_baidu_MapView setCenterCoordinate:locat animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];

}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.baseView.alpha = 0;
    currentMapType  = 1;
    
    _baidu_MapView.delegate = self;
    
    self.dataMArray = [[NSMutableArray alloc] init];

    self.city_code = [[NSString alloc] init];
    _gongdiView.alpha = 0;
    
    [self.mView addSubview:_xingweiView];
    [self.mView addSubview:_gongdiView];
    
    


    
    
    _shixiaochuangButton.selected =  YES;
    
    [_xingweiNameButton setTitle:@"所有人" forState:UIControlStateNormal];
    [_xingweiDateButton setTitle:[NSDate stringFromDate:[NSDate date] withFormat:@"YYYY-MM-dd"] forState:UIControlStateNormal] ;
    [_gongdiDateButton setTitle:[NSDate stringFromDate:[NSDate date] withFormat:@"YYYY-MM-dd"] forState:UIControlStateNormal] ;
    
    
    [self loadUserList];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    
    [self getCityCenter];

    
    
    [self loadConstructionsData:currentMapType name:@"" date:@""];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)annotationForType:(int)tag
{
    
    
    for ( NSDictionary *dict in self.dataMArray) {
        
        
        pointAnnotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        
        
        float lat = [[[dict objectForKey:@"SiLat"] objectForKey:@"text"] floatValue];
        float lng = [[[dict objectForKey:@"SiLng"] objectForKey:@"text"] floatValue];
        
        coor.latitude = lat;
        coor.longitude = lng;
        pointAnnotation.coordinate = coor;
        pointAnnotation.title = dict[@"PactNumber"][@"text"];

//        pointAnnotation.title = dict[@"OrderState"][@"text"];
        NSString *subtitle = [NSString stringWithFormat:@"%@%@(点击查看更多信息)",  dict[@"MonitorName"][@"text"], dict[@"OrderState"][@"text"]];
        pointAnnotation.subtitle = subtitle;
        
        
        switch (tag) {
            case 100:
            {
                if ( ![dict[@"Distance_Status"] isEqualToString:@"0"] && ![dict[@"Date_Status"] isEqualToString:@"0"]) {
                    
                    currentMapTagType = MapTagTypeGreen;
                }
                else {
                    continue;
                }
                
                break;
            }
            case 101:
            {
                
                if ( [dict[@"Date_Status"] isEqualToString:@"0"]) {
                    
                    currentMapTagType = MapTagTypePurple;
                }
                else
                    continue;
                
                break;
            }
            case 102:
            {
                if ( [dict[@"Distance_Status"] isEqualToString:@"0"]) {
                    
                    currentMapTagType = MapTagTypeRed;
                }
                else
                    continue;
                break;
            }
            case 103:
            {
                currentMapTagType = MapTagTypeRed;
                
                break;
            }
            default:
                break;
        }
        
        
        
//        _baidu_MapView setCenterCoordinate:<#(CLLocationCoordinate2D)#> animated:<#(BOOL)#>
        
        [_baidu_MapView addAnnotation:pointAnnotation];
        
    }
}


- (void)annotationGongdi:(int)tag
{
    
    int i = 0;
    
    for ( NSDictionary *dict in self.dataMArray) {
        
        
        pointAnnotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        
        float lat = [[[dict objectForKey:@"Lat"] objectForKey:@"text"] floatValue];
        float lng = [[[dict objectForKey:@"Lng"] objectForKey:@"text"] floatValue];
        
        coor.latitude = lat;
        coor.longitude = lng;
        pointAnnotation.coordinate = coor;
        
        
        if ( i == 0) {
            _baidu_MapView.centerCoordinate = coor;
        }
        pointAnnotation.title = dict[@"PactNumber"][@"text"];
//        pointAnnotation.title = dict[@"OrderState"][@"text"];
        NSString *subtitle = [NSString stringWithFormat:@"%@(点击查看更多信息)",  dict[@"MonitorName"][@"text"]];
        pointAnnotation.subtitle = subtitle;
        
        switch (tag) {
            case 100:
            {
                if ( [dict[@"IsDelay"][@"text"] isEqualToString:@"0"] && [dict[@"IsUnPay"][@"text"] isEqualToString:@"0"]
                    && [dict[@"IsWarn"][@"text"] isEqualToString:@"0"]) {
                    currentMapTagType = MapTagTypeGreen;
                }
                else {
                    continue;
                }
                
                break;
            }
            case 101:
            {
                
                if ( [dict[@"IsDelay"][@"text"] isEqualToString:@"1"]) {
                    currentMapTagType = MapTagTypePurple;
                }
                else
                    continue;
                
                break;
            }
            case 102:
            {
                if ( [dict[@"IsUnPay"][@"text"] isEqualToString:@"1"]) {
                    currentMapTagType = MapTagTypeRed;
                }
                else
                    continue;
                break;
            }
            case 103:
            {
                if ( [dict[@"IsWarn"][@"text"] isEqualToString:@"1"]) {
                    currentMapTagType = MapTagTypeBlue;
                }
                else
                    continue;
                break;
                
                break;
            }
            default:
                break;
        }
        
        [_baidu_MapView addAnnotation:pointAnnotation];
        
        
        i ++;
    }
}

- (IBAction)addAnnotationForType:(UIButton *)sender {

    [_baidu_MapView removeAnnotations: [NSArray arrayWithArray:_baidu_MapView.annotations]];

    [self annotationForType:sender.tag];
    
}

- (IBAction)addAnnotationGongdi:(UIButton *)sender {
    [_baidu_MapView removeAnnotations: [NSArray arrayWithArray:_baidu_MapView.annotations]];
    
    [self annotationGongdi:sender.tag];
}

- (IBAction)closeView:(id)sender {
    
    _infoView.alpha = 0;
    imagesScrollView.alpha = 0;
    
}

- (IBAction)switchMap:(UIButton *)sender {
    
    UIButton *b1 = (UIButton *)[self.view viewWithTag:10];
    UIButton *b2 = (UIButton *)[self.view viewWithTag:11];
    
    
    b1.selected = NO;
    b2.selected = NO;
    
    
    sender.selected = YES;
    
    
    
    
    if (sender.tag == 10) {
        
        _gongdiView.alpha = 0;
        _xingweiView.alpha = 1;
        currentMapType = 1;
        
    }
    else {
        
        _gongdiView.alpha = 1;
        _xingweiView.alpha = 0;
        currentMapType  = 2;
    }
    
    
    [self loadConstructionsData:currentMapType name:@"" date:@""];

    
    
}




- (IBAction)openData:(id)sender {
    
    
}

- (IBAction)openDate:(id)sender {
}


- (void)selectPopover:(NSIndexPath *)index
{
    [_popover dismissPopoverAnimated:YES];

    
    
    NSString *name =  userArray[index.row];
    
    [currentButton setTitle:name forState:UIControlStateNormal];
    
    NSString *date = _xingweiDateButton.titleLabel.text;
    
    [self loadConstructionsData:currentMapType name:name date:date];

    
}

- (void)selectDatePopover:(NSDate *)date
{

    NSString *s = [NSDate stringFromDate:date withFormat:@"YYYY-MM-dd"];
    
    [currentButton setTitle:s forState:UIControlStateNormal];
    [_popover dismissPopoverAnimated:YES];

    
    if (currentMapType == 1) {
        
        NSString *date = _xingweiDateButton.titleLabel.text;
        NSString *name = _xingweiNameButton.titleLabel.text;
        
        if ([name isEqualToString:@"所有人"]) {
            name = @"";
        }

        [self loadConstructionsData:currentMapType name:name date:date];

    }
    else {
        [self loadConstructionsData:currentMapType name:@"" date:s];
    }

    
    currentButton = nil;
    
}


- (IBAction)openMapDatePiker:(id)sender {
    
    
    currentButton = (UIButton *)sender;
    
    UIButton *b = (UIButton *)sender;
    DateTimePopoverController *pdfVC = [[DateTimePopoverController alloc] init];
    pdfVC.delegate = self;
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:pdfVC];
    [_popover presentPopoverFromRect:b.frame inView:self.gongdiView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (IBAction)openUserListPopover:(id)sender {
    
    
    currentButton = (UIButton *)sender;
    
    
    UIButton *b = (UIButton *)sender;
    PdfPopoverController *pdfVC = [[PdfPopoverController alloc] init];
    pdfVC.delegate = self;
    pdfVC.fileArrayM = userArray;
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:pdfVC];
    [_popover presentPopoverFromRect:b.frame inView:self.xingweiView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}


#pragma mark -
#pragma mark implement BMKMapViewDelegate

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    NSString *AnnotationViewID = @"renameMark";
//    if (newAnnotation == nil) {
    
        newAnnotation = [[ZHAnnotationView alloc ] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        newAnnotation.canShowCallout = NO;
        switch (currentMapTagType) {
            case MapTagTypeBlue:
                newAnnotation.pinColor = ZHPointAnnotationColorBlue;

                break;
            case MapTagTypeYello:
                newAnnotation.pinColor = ZHPointAnnotationColorYello;
                
                break;
            case MapTagTypeRed:
                newAnnotation.pinColor = ZHPointAnnotationColorRed;
                
                break;
            case MapTagTypeGreen:
                newAnnotation.pinColor = ZHPointAnnotationColorGreen;
                
                break;
            case MapTagTypePurple:
                newAnnotation.pinColor = ZHPointAnnotationColorPurple;
                break;
            default:
                break;
        }
        
//    }
    return newAnnotation;
}
    

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    DLog(@"paopaoclick");

 
}


- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    BMKPointAnnotation *point = view.annotation;
    _infoView.alpha = 1;
    
    
    
    for (UIView *view in _mapButtonView.subviews) {
        [view removeFromSuperview];
    }
    
    
    
    if (currentMapType  == 1) {
        [self viewLoadXingWei:point.title];
    }
    else {
        [self viewLoadGongDi:point.title];
    }
    
    
    
    
}



#pragma mark - 

- (NSDictionary *)dictForDataArray:(NSString *)pid
{
    
    for (NSDictionary  *dict in self.dataMArray) {

        if ([dict[@"PactNumber"][@"text"] isEqualToString:pid] ) {
        
            return dict;
        }
    }
    return nil;
}

- (void)viewLoadXingWei:(NSString *)pactNumber
{
    
    UIImageView *imgView =  [[ImageView share] addToView:_mapButtonView imagePathName:@"形状-1-副本-32" rect:RectMake2x(407, 393, 734, 475)];

    NSDictionary *dict = [self dictForDataArray:pactNumber];
    DLog(@"%@", dict);
    
    
    int hight = 50;
    
    for (int i = 1; i < 7; i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = RectMake2x(0, (i-1) * hight, 734, 50);
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = i +1000;
        [imgView addSubview:label];
    }
    
    
    UILabel *l = (UILabel *)[imgView viewWithTag:1001];
    UILabel *l1 = (UILabel *)[imgView viewWithTag:1002];
    UILabel *l2 = (UILabel *)[imgView viewWithTag:1003];
    UILabel *l3 = (UILabel *)[imgView viewWithTag:1004];
    UILabel *l4 = (UILabel *)[imgView viewWithTag:1005];
    UILabel *l5 = (UILabel *)[imgView viewWithTag:1006];
    
    
    
    l.text = [NSString stringWithFormat:@"实小创：%@", dict[@"MonitorName"][@"text"] ];
    l1.text = [NSString stringWithFormat:@"驻场时长：%@ 分钟", dict[@"Time"][@"text"] ];
    l2.text = [NSString stringWithFormat:@"签入时间：%@", dict[@"SiDate"][@"text"] ];
    l3.text = [NSString stringWithFormat:@"签出时间：%@", dict[@"SoDate"][@"text"] ];
    l4.text = [NSString stringWithFormat:@"订单状态：%@", dict[@"OrderState"][@"text"] ];
    float f = [dict[@"Distance"][@"text"] floatValue];
    l5.text = [NSString stringWithFormat:@"距离：%.2f 米", f];
    
    
    
    
    
}

- (void)viewLoadGongDi:(NSString *)pactNumber
{
    UIImageView *imgView =  [[ImageView share] addToView:_mapButtonView imagePathName:@"形状-1-副本-32" rect:RectMake2x(407, 393, 734, 475)];
    imgView.userInteractionEnabled = YES;
    
    NSDictionary *dict  = [NSDictionary dictionaryWithDictionary: [self dictForDataArray:pactNumber]];
    DLog(@"%@", dict);
    currentGDDict = dict;
    
    
    int hight = 50;
    
    for (int i = 1; i < 7; i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = RectMake2x(0, (i-1) * hight, 734, 50);
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = i +10;
        [imgView addSubview:label];
    }

    
    
    
    UILabel *l = (UILabel *)[imgView viewWithTag:11];
    UILabel *l1 = (UILabel *)[imgView viewWithTag:12];
    UILabel *l2 = (UILabel *)[imgView viewWithTag:13];
    UILabel *l3 = (UILabel *)[imgView viewWithTag:14];
    UILabel *l4 = (UILabel *)[imgView viewWithTag:15];
//    UILabel *l5 = (UILabel *)[imgView viewWithTag:16];
    
    
    DLog(@"%@",  dict[@"OrderState"][@"text"]);
    l.text = [NSString stringWithFormat:@"实小创：%@", dict[@"MonitorName"][@"text"] ];
    l1.text = [NSString stringWithFormat:@"订单状态：%@", dict[@"OrderState"][@"text"] ];
    l2.text = [NSString stringWithFormat:@"客户姓名：%@ ", dict[@"CustomerName"][@"text"] ];
    
    
//    延期
    NSMutableString *string = [NSMutableString stringWithFormat:@""];
    if ([dict[@"IsDelay"][@"text"] isEqualToString:@"1"]) {

        int HideDays = [dict[@"HideDays"][@"text"] intValue];
        int MidDays = [dict[@"MidDays"][@"text"] intValue];
        int EndDays = [dict[@"EndDays"][@"text"] intValue];
        
        if (  HideDays > 0) {
            [string appendFormat:@"隐蔽延期：%@", dict[@"HideDays"][@"text"]];
        }
        
        if ( MidDays > 0) {
            [string appendFormat:@"中期延期：%@", dict[@"MidDays"][@"text"]];
        }
        
        if ( EndDays > 0) {
            [string appendFormat:@"竣工延期：%@", dict[@"EndDays"][@"text"]];
        }

    }
    l3.text = string;
    
//    欠款
    NSMutableString *payString = [NSMutableString stringWithFormat:@""];
    
    if ([dict[@"IsUnPay"][@"text"] isEqualToString:@"1"]) {
        if ([dict[@"MidPayed"][@"text"] isEqualToString:@"0"]) {
            [payString appendFormat:@"中期未交 "];
        }
        if ([dict[@"MidPayed"][@"text"] isEqualToString:@"0"] && [dict[@"OrderState"][@"text"] isEqualToString:@"确认竣工"]) {
            [payString appendFormat:@"尾款未交"];
        }
    }
    l4.text = payString;
    

    
//延期单列表
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:RectMake2x(0, 4 * 50, 734, 350)];
    sv.backgroundColor = [UIColor whiteColor];
    
    
    [imgView addSubview:sv];
    
    
    int count = 0;
    
    if ( dict[@"Delays"]  ) {
        
        NSMutableArray *a = dict[@"Delays"][@"Delay"];
        
        if ( [a isKindOfClass:[NSMutableDictionary class]] ) {
            
            a = [[NSMutableArray alloc] initWithObjects:a, nil];
            
        }
        
        
        currentDelayArray = a;
        
        int i = 4;
        int tag = 1000;
        for (NSDictionary *d in a) {
            
            
            UITextView *tv = [[UITextView alloc] initWithFrame:RectMake2x(0, i * 50, 604, 150)];
            [imgView addSubview:tv];
            tv.editable = NO;
            tv.textAlignment = NSTextAlignmentCenter;
            tv.backgroundColor = [UIColor clearColor];
            tv.text = d[@"reason"][@"text"];
            
            NSString *ImgCount = d[@"ImgCount"][@"text"];
            if ( ! [ImgCount isEqualToString:@"0"]) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                button.frame = RectMake2x(560, i * 50, 154, 60);
                button.backgroundColor = [UIColor whiteColor];
                button.tag = tag;
                [button setTitle:@"延期照片" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(openDelayZhaoPian:) forControlEvents:UIControlEventTouchUpInside];
                [imgView addSubview:button];
            }
            
            i++;
            tag ++;
            
            count ++;
        }
        
        
        
    }
    
//事务单列表

    if ( dict[@"Transactions"]  ) {
        NSMutableArray *a = dict[@"Transactions"][@"Transaction"];
        if ( [a isKindOfClass:[NSMutableDictionary class]] ) {
            
            a = [[NSMutableArray alloc] initWithObjects:a, nil];
        }
        
        
        currentTransactionsArray = a;
        
        int i = 4;
        int tag = 1000;
        for (NSDictionary *d in a) {
            
            
            UITextView *tv = [[UITextView alloc] initWithFrame:RectMake2x(0,  (i + count) * 50, 604, 150)];
            [imgView addSubview:tv];
            tv.editable = NO;
            tv.textAlignment = NSTextAlignmentCenter;
            tv.backgroundColor = [UIColor clearColor];
            tv.text = d[@"transactionContent"][@"text"];
            
            NSString *ImgCount = d[@"ImgCount"][@"text"];
            if ( ! [ImgCount isEqualToString:@"0"]) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                button.frame = RectMake2x(570, (i + count) * 50, 154, 60);
                button.backgroundColor = [UIColor whiteColor];
                button.tag = tag;
                [button setTitle:@"事务照片" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(openTransactionsZhaoPian:) forControlEvents:UIControlEventTouchUpInside];
                [imgView addSubview:button];
            }
            
            i++;
            tag ++;
            count ++;
        }
        
        
        
    }
    
    [sv setContentSize:CGSizeMake(734, count * 50)];
}



- (void)loadData:(int)type
{
    
 
    [SVProgressHUD showWithStatus:@"正在刷新数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/", KHomeUrl];
    
    
    if (type == 1) {
        [urlStr appendString:@"XingWeiDiTu"];
    }
    else {
        [urlStr appendString:@"GongDiDiTu"];
    }
    
    NSDictionary *parameters = @{ @"subCityCode":  self.city_code};
    
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        if (type == 1) {
            dict = dict[@"ArrayOfXingWeiDiTu"][@"XingWeiDiTu"];
        }
        else {
            dict = dict[@"ArrayOfGongDiDiTu"][@"GongDiDiTu"];
        }
        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            
            self.dataMArray = [[NSMutableArray alloc] init];
            
            return ;
        }
        else {
            [SVProgressHUD dismiss];
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                [self.dataMArray addObject:  dict];
            }
            else {
                self.dataMArray =  dict;
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
}



- (void)scrollV:(NSArray *)array
{
    
    for (UIView *v in imagesScrollView.subviews) {
        [v removeFromSuperview];
    }
    

    if (   ! imagesScrollView) {
        imagesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        imagesScrollView.pagingEnabled = YES;
        imagesScrollView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:imagesScrollView];
    }

    
    
    imagesScrollView.alpha = 1;
    
    int x = 0   ;
    int y = 0;
    
    for (int i = 0;  i< array.count; i++) {

        UIImageView *imgView = [[ImageView share] addToView:imagesScrollView imagePathName:@""  rect:CGRectMake(x + i*2014 , y, 1024, 768)];
        NSString *string = array[i][@"text"];
        NSURL *url = [[NSURL alloc] initWithString:string];

        [imgView setImageWithURL:url];
    }
    
    [imagesScrollView setContentSize:CGSizeMake(1024* array.count, 768)];
    
    
//    [[Button share] addToView:self.view addTarget:self rect:CGRectMake(20, 413, 20, 38) tag:1999 action:@selector(closeImagesView:) imagePath:@"箭头-左"];
    [[Button share] addToView:self.view addTarget:self rect:RectMake2x(1805, 80, 120, 120) tag:1004 action:@selector(closeImagesView:)
                    imagePath:@"按钮-返回"
     ];
}

- (void)closeImagesView:(UIButton *)button
{
    imagesScrollView.alpha = 0;
    [button removeFromSuperview];
}



- (void)getNetImages:(NSString *)orderID itemId:(NSString *)itemId t:(int)itemType
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    NSDictionary *parameters = @{
                                 @"orderId":orderID,
                                 @"itemId": itemId,
                                 @"type": [NSNumber numberWithInt:itemType]};
    
    NSString *urlString = [NSString stringWithFormat:@"%@/GetImageInfo", KSXCHomeUrl];
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        
        NSDictionary *dictionary= [XMLReader dictionaryForXMLString:s error:&parseError];
        
        NSArray *array = [NSArray array];
        if ( [dictionary[@"ArrayOfString"][@"string"] isKindOfClass:[NSMutableDictionary class]] ) {
            
            array = [[NSMutableArray alloc]     initWithObjects: dictionary[@"ArrayOfString"][@"string"], nil];
        }
        else {
            
            array = dictionary[@"ArrayOfString"][@"string"];
        }
        [self scrollV:array];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
}


//
//2	延期单
//3	事务单

- (void)openDelayZhaoPian:(UIButton *)button
{
    
    int tag = button.tag - 1000;
    
    NSDictionary *d = currentDelayArray [tag];
    [self getNetImages:currentGDDict[@"OrderId"][@"text"] itemId:d[@"id"][@"text"] t:2];
    
}


- (void)openTransactionsZhaoPian:(UIButton *)button
{
    
    int tag = button.tag - 1000;
    
    NSDictionary *d = currentTransactionsArray[tag];
    [self getNetImages:currentGDDict[@"OrderId"][@"text"] itemId:d[@"id"][@"text"] t:3];
    
}




@end
