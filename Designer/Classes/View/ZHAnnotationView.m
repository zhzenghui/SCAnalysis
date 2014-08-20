//
//  ZHPointAnnotation.m
//  SC_Analysis
//
//  Created by bejoy on 14-6-6.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHAnnotationView.h"

@implementation ZHAnnotationView

-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setPinColor:(ZHPointAnnotationColor)pinColor
{
    NSString *pathStr = nil;
    switch (pinColor) {
        case ZHPointAnnotationColorGreen:
            pathStr  = @"pin_green";
            break;
        case ZHPointAnnotationColorRed:
            pathStr  = @"pin_red";
            break;
        case ZHPointAnnotationColorPurple:
            pathStr  = @"pin_purple";
            break;
        case ZHPointAnnotationColorYello:
            pathStr  = @"pin_yello";
            break;
        case ZHPointAnnotationColorBlue:
            pathStr  = @"pin_blue";
            break;
        default:
            break;
    }
    
    self.image = [UIImage imageNamed:pathStr];
}

@end
