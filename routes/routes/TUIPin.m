//
//  TUIPin.m
//  routes
//
//  Created by Diego Lafuente Garcia on 8/27/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIPin.h"
#import "UIImage+Tui.h"

#pragma mark - Private interface
@interface TUIPin()

-(void)addEventListeners;

@end

#pragma mark - Implementation
@implementation TUIPin

#pragma mark - Public methods
-(TUIPin *)initPinOfType:(TUIPinType)type
            withPosition:(deCartaPosition *)position
              andMessage:(NSString *)message {
    NSString* pinsPath = [[NSBundle mainBundle] pathForResource:@"pins" ofType:@"plist"];
    NSArray *pinFiles = [NSArray arrayWithContentsOfFile:pinsPath];
    UIImage *image = [UIImage imageNamedSmart:pinFiles[type]];
    //UIImage *image = [UIImage imageNamedSmart:@"home_pin"];
    //NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"attraction_pin" ofType:@"png"];
    //UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    deCartaRotationTilt *pinrt=[[deCartaRotationTilt alloc] initWithRotateRelative:ROTATE_RELATIVE_TO_SCREEN tiltRelative:TILT_RELATIVE_TO_SCREEN];
    pinrt.rotation = 0.0; //No rotation
    pinrt.tilt = 0.0; //No tilt
    int width = image.size.width;
    int height = image.size.height;
    deCartaXYInteger *size = [deCartaXYInteger XYWithX:width andY:height];
    deCartaXYInteger *offset = [deCartaXYInteger XYWithX:width/2 andY:height];
    deCartaIcon *pinicon = [[deCartaIcon alloc] initWithImage:image size:size offset:offset];
    self = [super initWithPosition:position icon:pinicon message:message rotationTilt:pinrt];
    [self addEventListeners];
    return self;
}

#pragma mark - Private methods
-(void)addEventListeners {
    //TOUCH event
    deCartaEventListener * touchEventListener=[[deCartaEventListener alloc] initWithCallback:^(id sender,id param){
        NSLog(@"Executing TUIPin TOUCH event handler");
        TUIPin * pin = (TUIPin *)sender;
        [pin.delegate pinTouched:pin];
        
    }];
    [self addEventListener:touchEventListener forEventType:TOUCH];
    //LONGTOUCH event
    deCartaEventListener * longTouchEventListener=[[deCartaEventListener alloc] initWithCallback:^(id sender,id param){
        NSLog(@"Executing TUIPin LONGTOUCH event handler");
        TUIPin * pin = (TUIPin *)sender;
        [pin.delegate pinLongTouched:pin];
        
    }];
    [self addEventListener:longTouchEventListener forEventType:DOUBLECLICK];
    
}

@end
