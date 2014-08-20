//
//  ZHPeopleViewController.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-5.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHPeopleViewController.h"
#import "SHLineGraphView.h"
#import "SHPlot.h"
#import "JYRadarChart.h"



@interface ZHPeopleViewController ()
{
    JYRadarChart *p;
}
@end

@implementation ZHPeopleViewController


- (void)updateData {
	int n = 7;
	NSMutableArray *a = [NSMutableArray array];
	NSMutableArray *b = [NSMutableArray array];
	NSMutableArray *c = [NSMutableArray array];
    
    
	for (int i = 0; i < n - 1; i++) {
		a[i] = [NSNumber numberWithInt:arc4random() % 40 + 80];
		b[i] = [NSNumber numberWithInt:arc4random() % 50 + 70];
		c[i] = [NSNumber numberWithInt:arc4random() % 60 + 60];
	}
    
	p.dataSeries = @[a, b, c];
	p.steps = arc4random() % 6;
	p.fillArea = arc4random() % 2 ? YES : NO;
	p.drawPoints = arc4random() % 2 ? YES : NO;
	p.showStepText = arc4random() % 2 ? YES : NO;
	[p setTitles:@[@"iPhone", @"pizza", @"hard drive"]];
	[p setNeedsDisplay];
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
    
    
    [[Button share] addToView:self.view addTarget:self rect:RectMake2x(1805, 80, 120, 120) tag:1004 action:@selector(dismissViewController:)
                    imagePath:@"按钮-返回"
     ];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    
    //initate the graph view
    SHLineGraphView *_lineGraph = [[SHLineGraphView alloc] initWithFrame:CGRectMake(20, 220, 568, 320)];
    
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
    
    /**
     *  the maximum y-value possible in the graph. make sure that the y-value is not in the plotting points is not greater
     *  then this number. otherwise the graph plotting will show wrong results.
     */
    _lineGraph.yAxisRange = @(98);
    
    /**
     *  y-axis values are calculated according to the yAxisRange passed. so you do not have to pass the explicit labels for
     *  y-axis, but if you want to put any suffix to the calculated y-values, you can mention it here (e.g. K, M, Kg ...)
     */
    _lineGraph.yAxisSuffix = @"K";
    
    /**
     *  an Array of dictionaries specifying the key/value pair where key is the object which will identify a particular
     *  x point on the x-axis line. and the value is the label which you want to show on x-axis against that point on x-axis.
     *  the keys are important here as when plotting the actual points on the graph, you will have to use the same key to
     *  specify the point value for that x-axis point.
     */
    _lineGraph.xAxisValues = @[
                               @{ @1 : @"JAN" },
                               @{ @2 : @"FEB" },
                               @{ @3 : @"MAR" },
                               @{ @4 : @"APR" },
                               @{ @5 : @"MAY" },
                               @{ @6 : @"JUN" },
                               @{ @7 : @"JUL" },
                               @{ @8 : @"AUG" },
                               @{ @9 : @"SEP" },
                               @{ @10 : @"OCT" },
                               @{ @11 : @"NOV" },
                               @{ @12 : @"DEC" }
                               ];
    
    //create a new plot object that you want to draw on the `_lineGraph`
    SHPlot *_plot1 = [[SHPlot alloc] init];
    
    //set the plot attributes
    
    /**
     *  Array of dictionaries, where the key is the same as the one which you specified in the `xAxisValues` in `SHLineGraphView`,
     *  the value is the number which will determine the point location along the y-axis line. make sure the values are not
     *  greater than the `yAxisRange` specified in `SHLineGraphView`.
     */
    _plot1.plottingValues = @[
                              @{ @1 : @65.8 },
                              @{ @2 : @20 },
                              @{ @3 : @23 },
                              @{ @4 : @22 },
                              @{ @5 : @12.3 },
                              @{ @6 : @45.8 },
                              @{ @7 : @56 },
                              @{ @8 : @97 },
                              @{ @9 : @65 },
                              @{ @10 : @10 },
                              @{ @11 : @67 },
                              @{ @12 : @23 }
                              ];
    
    /**
     *  this is an optional array of `NSString` that specifies the labels to show on the particular points. when user clicks on
     *  a particular points, a popover view is shown and will show the particular label on for that point, that is specified
     *  in this array.
     */
    NSArray *arr = @[@"1", @"2", @"3", @"4", @"5", @"6" , @"7" , @"8", @"9", @"10", @"11", @"12"];
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
    
    [self.view addSubview:_lineGraph];


    
    
    p = [[JYRadarChart alloc] initWithFrame:CGRectMake(650, 220, 350, 350)];
    
	NSArray *a1 = @[@(81), @(97), @(87), @(60), @(65), @(77)];
	NSArray *a2 = @[@(91), @(87), @(33), @(77), @(78), @(96)];
	p.dataSeries = @[a1, a2];
	p.steps = 1;
	p.showStepText = YES;
	p.backgroundColor = [UIColor whiteColor];
	p.r = 60;
	p.minValue = 20;
	p.maxValue = 120;
	p.fillArea = YES;
	p.colorOpacity = 0.7;
	p.attributes = @[@"Attack", @"Defense", @"Speed", @"HP", @"MP", @"IQ"];
	p.showLegend = YES;
	[p setTitles:@[@"archer", @"footman"]];
	[p setColors:@[[UIColor yellowColor], [UIColor purpleColor]]];
	[self.view addSubview:p];
    
    
	[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(updateData) userInfo:nil repeats:YES];
    
    

}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
