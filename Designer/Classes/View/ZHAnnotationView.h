//
//  ZHPointAnnotation.h
//  SC_Analysis
//
//  Created by bejoy on 14-6-6.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "BMKAnnotationView.h"
enum {
    ZHPointAnnotationColorRed = 0,
    ZHPointAnnotationColorGreen ,
    ZHPointAnnotationColorPurple ,
    ZHPointAnnotationColorBlue ,
    ZHPointAnnotationColorYello ,
};
typedef NSUInteger ZHPointAnnotationColor;



@interface ZHAnnotationView : BMKAnnotationView <BMKAnnotation>{
    
    @package
    CLLocationCoordinate2D _coordinate;
}


///该点的坐标
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@property (nonatomic) ZHPointAnnotationColor pinColor;


@end
