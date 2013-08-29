//
//  TUIPin.h
//  routes
//
//  Created by Diego Lafuente Garcia on 8/27/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "deCartaPin.h"

typedef enum {
    TUIHomePin = 0,
    TUIAttractionPin = 1,
    TUICustomPin = 2
} TUIPinType;

@protocol TUIPinDelegate;

@interface TUIPin : deCartaPin
//The delegate
@property (weak, nonatomic) id<TUIPinDelegate> delegate;

/**
 * Inits the pin.
 * @return a singleton.
 */
-(TUIPin *)initPinOfType:(TUIPinType)type
            withPosition:(deCartaPosition *)position
              andMessage:(NSString *)message;

@end

@protocol TUIPinDelegate <NSObject>

-(void)pinTouched:(TUIPin *)sender;
-(void)pinLongTouched:(TUIPin *)sender;

@end
