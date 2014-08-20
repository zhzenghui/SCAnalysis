//
//  ZHBehaviorViewController.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-5.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHBehaviorViewController.h"
#import "ZHCityPeopleViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "XMLReader.h"

#import "SHLineGraphView.h"
#import "SHPlot.h"



@interface ZHBehaviorViewController ()
{
    UITableView *tb;
    UIView *v;
    SHLineGraphView *_lineGraph;
}
@end

@implementation ZHBehaviorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)loadConstructionsData
{
    
    
    [self.dataMArray removeAllObjects];
    
    
    
    
    [SVProgressHUD showWithStatus:@"正在刷新数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/XingWei", KHomeUrl];
    
    if ( ! SharedAppUser.SubCityCode) {
        [SVProgressHUD dismiss];

        return;
    }
    
    NSDictionary *parameters = @{ @"subCityCode":  SharedAppUser.SubCityCode };

    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        
        
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        dict = dict[@"ArrayOfBehavior"][@"Behavior"];
        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            
            self.dataMArray = [[NSMutableArray alloc] init];
            [tb reloadData];
            
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
            
            [tb reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
}


- (void)removeChart
{
    for (UIView *vall in v.subviews) {
        [vall removeFromSuperview];
    }
    chartView.alpha = 0;
}


- (void)loadChart:(int)type plottingValues:(NSArray *)plottingValues plottingPointsLabels:(NSArray *)plottingPointsLabels
{

    chartView.alpha = 1;
    
    [[Button share] addToView:chartView addTarget:self rect:RectMake2x(0, 0, 1888, 1260) tag:100 action:@selector(removeChart)];
    
    
    //initate the graph view
    _lineGraph = [[SHLineGraphView alloc] initWithFrame:CGRectMake(200, 150, 568, 320)];
    _lineGraph.backgroundColor = [UIColor whiteColor];
    //set the main graph area theme attributes
    
    /**
     *  theme attributes dictionary. you can specify graph theme releated attributes in this dictionary. if this property is
     *  nil, then a default theme setting is applied to the graph.
     */
    NSDictionary *_themeAttributes = @{
                                       kXAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                                       kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       kYAxisLabelColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                                       kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       kYAxisLabelSideMarginsKey : @20,
                                       kPlotBackgroundLineColorKey : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4],
                                       kDotSizeKey : @10
                                       };
    _lineGraph.themeAttributes = _themeAttributes;
    
    //set the line graph attributes
    _lineGraph.yAxisRange = @(100);
    _lineGraph.yAxisSuffix = @"%";
    
    switch (type) {
        case 1: //合格率
        {
            _lineGraph.yAxisRange = @(100);
            _lineGraph.yAxisSuffix = @"%";
            break;
        }
        case 2: //时长
        {
            _lineGraph.yAxisRange = @(120);
            _lineGraph.yAxisSuffix = @"分钟";
            break;
        }
        case 3: //接单量
        {
            _lineGraph.yAxisRange = @(10);
            _lineGraph.yAxisSuffix = @"单";
            break;
        }
        default:
            break;
    }
    
    
    
    /**
     *  an Array of dictionaries specifying the key/value pair where key is the object which will identify a particular
     *  x point on the x-axis line. and the value is the label which you want to show on x-axis against that point on x-axis.
     *  the keys are important here as when plotting the actual points on the graph, you will have to use the same key to
     *  specify the point value for that x-axis point.
     */
    _lineGraph.xAxisValues = @[
                               @{ @1 : @"一月" },
                               @{ @2 : @"二月" },
                               @{ @3 : @"三月" },
                               @{ @4 : @"四月" },
                               @{ @5 : @"五月" },
                               @{ @6 : @"六月" },
                               @{ @7 : @"七月" },
                               @{ @8 : @"八月" },
                               @{ @9 : @"九月" },
                               @{ @10 : @"十月" },
                               @{ @11 : @"十一月" },
                               @{ @12 : @"十二月" }
                               ];
    
    //create a new plot object that you want to draw on the `_lineGraph`
    SHPlot *_plot1 = [[SHPlot alloc] init];
    
    //set the plot attributes
    
    /**
     *  Array of dictionaries, where the key is the same as the one which you specified in the `xAxisValues` in `SHLineGraphView`,
     *  the value is the number which will determine the point location along the y-axis line. make sure the values are not
     *  greater than the `yAxisRange` specified in `SHLineGraphView`.
     */
    _plot1.plottingValues = plottingValues;

    
    /**
     *  this is an optional array of `NSString` that specifies the labels to show on the particular points. when user clicks on
     *  a particular points, a popover view is shown and will show the particular label on for that point, that is specified
     *  in this array.
     */
    NSArray *arr = plottingPointsLabels;  //@[@"1", @"2", @"3", @"4", @"5", @"6.2" , @"7" , @"8", @"9", @"10", @"11", @"12"];
    _plot1.plottingPointsLabels = arr;
    
    //set plot theme attributes
    
    /**
     *  the dictionary which you can use to assing the theme attributes of the plot. if this property is nil, a default theme
     *  is applied selected and the graph is plotted with those default settings.
     */
    
    NSDictionary *_plotThemeAttributes = @{
                                           kPlotFillColorKey : [UIColor colorWithRed:0.47 green:0.75 blue:0.78 alpha:0.5],
                                           kPlotStrokeWidthKey : @2,
                                           kPlotStrokeColorKey : [UIColor colorWithRed:0.18 green:0.36 blue:0.41 alpha:1],
                                           kPlotPointFillColorKey : [UIColor colorWithRed:0.18 green:0.36 blue:0.41 alpha:1],
                                           kPlotPointValueFontKey : [UIFont fontWithName:@"TrebuchetMS" size:18]
                                           };
    
    _plot1.plotThemeAttributes = _plotThemeAttributes;
    [_lineGraph addPlot:_plot1];
    
    //You can as much `SHPlots` as you can in a `SHLineGraphView`
    
    [_lineGraph setupTheView];
    
    [chartView addSubview:_lineGraph];

}

- (void)addLine:(int )type
{
    
    [SVProgressHUD showWithStatus:@"正在获取数据..." maskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/", KHomeUrl];
    switch (type) {
        case 1:
            [urlStr appendString:@"QianDaoHeGeLv"];
            break;
        case 2:
            [urlStr appendString:@"PingJunShiChang"];
            break;
        case 3:
            [urlStr appendString:@"JieDanShu"];
            break;
        default:
            break;
    }
    
    NSDictionary *parameters = @{ @"subCityCode":  SharedAppUser.SubCityCode };
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSError *parseError = nil;
        
        NSDictionary *xmlDictionary= [XMLReader dictionaryForParse:responseObject error:&parseError];
        
        
        NSString *s = [xmlDictionary[@"string"] objectForKey:@"text"];
        
        NSDictionary *dict = [XMLReader dictionaryForXMLString:s error:&parseError];
        
        
        
        

            dict = dict[@"ArrayOfReportMonthResult"][@"ReportMonthResult"];


        
        
        
        
        
        if (dict == nil) {
            [SVProgressHUD dismiss];
            
            return ;
        }
        else {
            [SVProgressHUD dismiss];
            
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                [array addObject:  dict];
            }
            else {
                array =  dict;
            }

            
            NSMutableArray *chartArray = @[
                                    @{ @3 : @0 },
                                    @{ @2 : @0 },
                                    @{ @1 : @3 },
                                    @{ @4 : @0 },
                                    @{ @5 : @0 },
                                    @{ @6 : @0 },
                                    @{ @7 : @0 },
                                    @{ @8 : @0 },
                                    @{ @9 : @0 },
                                    @{ @10 : @0 },
                                    @{ @11 : @0 },
                                    @{ @12 : @0 }
                                    ];
            
            chartArray =  [[NSMutableArray alloc] init];
            NSMutableArray *chartTipArray =  [[NSMutableArray alloc] init];

            for (int i = 1; i <13; i++) {
                NSDictionary *dict = nil;
                
                for (NSDictionary *d in array) {
                    if ([d[@"Month"][@"text"] isEqualToString:[NSString stringWithFormat:@"%d", i]]) {
                        dict = d;
                    }
                }
                
                if (dict) {
                    NSString *string = [dict[@"HeGeLv"][@"text"] stringByReplacingOccurrencesOfString:@"%" withString:@""];
                    switch (type) {
                        case 1:
                        {
                            break;
                        }
                        case 2:
                        {
                            string = dict[@"ZhuChangShiJian"][@"text"] ;
                            break;
                        }
                        case 3:
                        {
                            string = dict[@"JieDanShu"][@"text"] ;
                            break;
                        }
                        default:
                            break;
                    }
                    float f = [string floatValue];
                    
                    [chartArray addObject:@{[NSNumber numberWithInt:i] : [NSNumber numberWithFloat:f]}];
                    [chartTipArray addObject:string];
                    
                }
                else {
                    [chartArray addObject:@{[NSNumber numberWithInt:i] :@0}];
                    [chartTipArray addObject:@0];
                }
            }
            
            
            
            
            [self loadChart:type plottingValues: chartArray plottingPointsLabels:chartTipArray];
          
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[Message share] messageAlert:KString_Server_Error];
        DLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
}

- (void)loadView
{
    [super loadView];

    
    
    
    
    tb = [[UITableView alloc] initWithFrame:RectMake2x(0 , 0, 1888, 1260) style:UITableViewStylePlain];
    tb.backgroundColor = [UIColor clearColor];
    tb.dataSource = self;
    tb.delegate = self;
    [self.view addSubview:tb];

    
    
    
    
    chartView = [[UIView alloc] initWithFrame:RectMake2x(0 , 0, 1888, 1260)];
    chartView.alpha = 0;
    
    v = [[UIView alloc] initWithFrame:RectMake2x(0 , 0, 1888, 1260)];
    v.backgroundColor = [ UIColor blackColor];
    v.alpha = .8;
    [chartView addSubview:v];
    
    [self.view addSubview:chartView];
    
    
    
    
    self.dataMArray = [[NSMutableArray alloc] init];

    
    [self loadConstructionsData];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadConstructionsData) name:@"loadNetData" object:nil];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    

    return self.dataMArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    return 56;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 60;
    
}


- (void)orderByFiled:(UIButton *)button
{
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 1888/2, 60);
    headerView.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"行为统计-表格title-00"]];
    
//    for (int i = 1; i < 7 ; i++) {
//        
//        UIButton  *l = [UIButton buttonWithType:UIButtonTypeCustom];
//        [l addTarget:self action:@selector(orderByFiled:) forControlEvents:UIControlEventTouchUpInside];
//        [l setImage:[UIImage imageNamed:@"符号-排位-向上"] forState:UIControlStateNormal ];
//        
//        l.tag = i +100;
////        
////        if ( i  ==1) {
////            l.frame = RectMake2x( 0, 0, 314, 120);
////        }
//        if (i == 2) {
//            l.frame = RectMake2x( 415, 0, 214, 120);
//        }
//        
//        if (i == 3) {
//            l.frame = RectMake2x( 730, 0, 214, 120);
//        }
//        
//        if (i == 4) {
//            l.frame = RectMake2x( 845, 0, 214, 120);
//        }
//        if (i == 5) {
//            l.frame = RectMake2x( 1359, 0, 214, 120);
//            
//        }
//        
//        if (i == 6) {
//            l.frame = RectMake2x( 1674, 0, 214, 120);
//            
//        }
//        
//        
//        
//        
//        
//        [headerView addSubview:l];
//    }
//    
    
    
    
    return headerView;
    
}



- (UITableViewCell *)cell3Height
{
    
    static NSString *CellIdentifier = @"Cell3h";
    
    UITableViewCell *cell = [tb dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    }

    
    for (int i = 1; i < 7 ; i++) {
        
        UILabel *l = [[UILabel alloc] init];
        l.textAlignment = NSTextAlignmentCenter;
        l.tag = i +100;
        
        if ( i  ==1) {
            l.frame = RectMake2x( 0, 0, 314, 120);
            l.numberOfLines = 0;
        }
        if (i == 2) {
            l.frame = RectMake2x( 315, 0, 314, 120);
        }
        
        if (i == 3) {
            l.frame = RectMake2x( 630, 0, 314, 120);
        }
        
        if (i == 4) {
            l.frame = RectMake2x( 945, 0, 314, 120);
            l.textAlignment = NSTextAlignmentRight;
            [[Button share] addToView:cell.contentView addTarget:self rect:RectMake2x( 945, 0, 88, 120) tag:1000 action:@selector(openChart:) imagePath:@"符号-点击-图标"];
        }
        if (i == 5) {
            l.frame = RectMake2x( 1259, 0, 314, 120);
            l.textAlignment = NSTextAlignmentRight;
            [[Button share] addToView:cell.contentView addTarget:self rect:RectMake2x( 1359, 0, 88, 120) tag:1001 action:@selector(openChart:) imagePath:@"符号-点击-图标"];

        }

        if (i == 6) {
            l.frame = RectMake2x( 1574, 0, 314, 120);
            l.textAlignment = NSTextAlignmentRight;
            [[Button share] addToView:cell.contentView addTarget:self rect:RectMake2x( 1574, 0, 88, 120) tag:1002 action:@selector(openChart:) imagePath:@"符号-点击-图标"];

        }

        
        
        
        
        [cell.contentView addSubview:l];
    }
    

    
    
    return cell;
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    
    static NSString *CellIdentifier = @"Cell3h";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [self cell3Height];
    }
    

    
    
    
    NSDictionary *dict = [self.dataMArray objectAtIndex:indexPath.row];

    
    
    
    UILabel *l1 = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *l2 = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *l3 = (UILabel *)[cell.contentView viewWithTag:103];
    UILabel *l4 = (UILabel *)[cell.contentView viewWithTag:104];
    UILabel *l5 = (UILabel *)[cell.contentView viewWithTag:105];
    UILabel *l6 = (UILabel *)[cell.contentView viewWithTag:106];
    
    
    
    l1.text = @"";
    l2.text = @"";
    l3.text = @"";
    l4.text = @"";
    l5.text = @"";
    l6.text = @"";
    
    
    l1.text = dict [@"SubCityName"][@"text"];
    l2.text = dict [@"PersonNum"][@"text"];
    l3.text = dict [@"Attendance"][@"text"];
    l4.text = dict [@"AttendanceQualified"][@"text"];
    l5.text = dict [@"FiledLength"][@"text"];
    float f = [ dict [@"AvgOrders"][@"text"] floatValue];
    l6.text = [NSString stringWithFormat:@"%.2f", f];
    
    
    return cell;
    
    
}


- (void)openChart:(UIButton *)button
{
    

    UITableViewCell *cell = (UITableViewCell *)[[[button superview]  superview] superview];
    NSIndexPath *indexPath = [tb indexPathForCell:cell];
    
    
    NSDictionary *dict = self.dataMArray[indexPath.row];

    
    switch (button.tag) {
        case 1000:
            //    1000   合格率
            [self addLine:1];

            break;
        case 1001:
            //    1001   驻场时长
            [self addLine:2];

            break;
        case 1002:
            //    1002   接单
            [self addLine:3];

            break;
            
        default:
            break;
    }
    
    
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    
    ZHCityPeopleViewController *cp = [[ZHCityPeopleViewController alloc]  init];
    cp.dataMDict = self.dataMArray[indexPath.row];
    [self presentViewController:cp animated:YES completion:^{
        
    }];
    
    
    
}




@end
