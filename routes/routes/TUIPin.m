//
//  TUIPin.m
//  routes
//
//  Created by Diego Lafuente Garcia on 8/27/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIPin.h"

#pragma mark - Private interface
@interface TUIPin()

-(void)addEventListeners;

@end

#pragma mark - Implementation
@implementation TUIPin

#pragma mark - Public methods
-(TUIPin *)initWithPosition:(deCartaPosition *)position
                      image:(UIImage *)image
                    message:(NSString *)message
            andRotationTilt:(deCartaRotationTilt *)pinrt {
    int width = image.size.width;
    int height = image.size.height;
    deCartaXYInteger *size = [deCartaXYInteger XYWithX:width andY:height];
    deCartaXYInteger *offset = [deCartaXYInteger XYWithX:width/2 andY:height];
    deCartaIcon *pinicon = [[deCartaIcon alloc] initWithImage:image size:size offset:offset];
    self = [super initWithPosition:position icon:pinicon message:message rotationTilt:pinrt];
    return self;
}

#pragma mark - Private methods
-(void)addEventListeners {
    deCartaEventListener * touchEventListener=[[deCartaEventListener alloc] initWithCallback:^(id sender,id param){
        NSLog(@"Executing deCartaPin TOUCH event handler");
        deCartaPin * pn=(deCartaPin *)sender;
        
        //Get a pointer to the deCartaMapView's info window
        /*deCartaInfoWindow * infoWindow=_mapView.infoWindow;
        
        //Associate the info window with the pin
        infoWindow.associatedPin=pn;
        
        //Set the location of the info window to the pin's position
        infoWindow.position=pn.position;
        
        //Set the text for the info window
        infoWindow.message=pn.message;
        
        //Set the offset of the info window. In this case, we set the Y
        //offset so that the bottom of the info window will appear above
        //the pin icon.
        [infoWindow setOffset:[deCartaXYFloat XYWithX:0 andY:pn.icon.offset.y] andRotationTilt:pn.rotationTilt];
        
        //Make the info window visible
        infoWindow.visible=TRUE;
        
        //Call our new function, using the position of
        //the pin, to update the infoWindow with the
        //address where the pin is located.
        [self doReverseGeocoding:pn.position];
        
        
        NSLog(@"Executing deCartaPin TOUCH event handler");*/
        
    }];
}

@end
