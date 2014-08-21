//
//  ZHMapViewController.h
//  SC_Analysis
//
//  Created by bejoy on 14-6-6.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "BaseViewController.h"
#import "BMapKit.h"
#import "ZHAnnotationView.h"
#import "DateTimePopoverController.h"
#import "PdfPopoverController.h"


enum {
    MapTagTypeRed = 0,
    MapTagTypeBlue ,
    MapTagTypeGreen ,
    MapTagTypeYello,
    MapTagTypePurple
};
typedef  NSInteger MapTagType;



@interface ZHMapViewController : BaseViewController<BMKMapViewDelegate, DateTimePopoverDelegate,PdfPopoverDelegate>
{
    BMKPointAnnotation *pointAnnotation;
    ZHAnnotationView* newAnnotation;
    MapTagType currentMapTagType;
    
    UIButton *currentButton;
    int currentMapType;
    
    NSArray *currentDelayArray;
    NSArray *currentTransactionsArray;
    
    NSMutableArray *userArray;
    
}

@property (nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet BMKMapView *baidu_MapView;
@property (weak, nonatomic) IBOutlet UIView *mView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) NSString *city_code;
@property (weak, nonatomic) IBOutlet UIButton *closeView;

@property (strong, nonatomic) IBOutlet UIView *xingweiView;
@property (strong, nonatomic) IBOutlet UIView *gongdiView;
@property (weak, nonatomic) IBOutlet UIButton *gongdiDate;
@property (weak, nonatomic) IBOutlet UIButton *gongdiDateButton;
@property (weak, nonatomic) IBOutlet UIButton *xingweiDateButton;
@property (weak, nonatomic) IBOutlet UIButton *xingweiNameButton;


@property (weak, nonatomic) IBOutlet UIButton *shixiaochuangButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButtonView;


- (IBAction)addAnnotationForType:(id)sender;
- (IBAction)addAnnotationGongdi:(id)sender;
- (IBAction)closeView:(id)sender;
- (IBAction)switchMap:(id)sender;
- (IBAction)openData:(id)sender;
- (IBAction)openDate:(id)sender;


- (IBAction)openMapDatePiker:(id)sender;


@end
