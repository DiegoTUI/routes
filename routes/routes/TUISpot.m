//
//  TUIPin.m
//  routes
//
//  Created by Diego Lafuente Garcia on 8/27/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUISpot.h"
#import "UIImage+Tui.h"

#pragma mark - Private interface
@interface TUISpot()

@property (strong, nonatomic) NSString *name;
@property (nonatomic) TUISpotType type;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

-(void)addEventListeners;

@end

#pragma mark - Implementation
@implementation TUISpot

#pragma mark - Public methods
-(TUISpot *)initSpotOfType:(TUISpotType)type
                 latitude:(double)latitude
                 longitude:(double)longitude
                      name:(NSString *)name {
    NSString* pinsPath = [[NSBundle mainBundle] pathForResource:@"pins" ofType:@"plist"];
    NSArray *pinFiles = [NSArray arrayWithContentsOfFile:pinsPath];
    UIImage *image = [UIImage imageNamedSmart:pinFiles[type]];
    deCartaRotationTilt *pinrt=[[deCartaRotationTilt alloc] initWithRotateRelative:ROTATE_RELATIVE_TO_SCREEN tiltRelative:TILT_RELATIVE_TO_SCREEN];
    pinrt.rotation = 0.0; //No rotation
    pinrt.tilt = 0.0; //No tilt
    int width = image.size.width;
    int height = image.size.height;
    deCartaXYInteger *size = [deCartaXYInteger XYWithX:width andY:height];
    deCartaXYInteger *offset = [deCartaXYInteger XYWithX:width/2 andY:height];
    deCartaIcon *pinicon = [[deCartaIcon alloc] initWithImage:image size:size offset:offset];
    self = [super initWithPosition:[[deCartaPosition alloc] initWithLat:latitude andLon:longitude] icon:pinicon message:name rotationTilt:pinrt];
    [self addEventListeners];
    _name = name;
    _type = type;
    _latitude = latitude;
    _longitude = longitude;
    return self;
}

#pragma mark - Private methods
-(void)addEventListeners {
    //TOUCH event
    deCartaEventListener * touchEventListener=[[deCartaEventListener alloc] initWithCallback:^(id sender,id param){
        NSLog(@"Executing TUIPin TOUCH event handler");
        TUISpot * spot = (TUISpot *)sender;
        [spot.delegate spotTouched:spot];
        
    }];
    [self addEventListener:touchEventListener forEventType:TOUCH];
    
}

@end
