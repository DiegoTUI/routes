//
//  TUIPin.h
//  routes
//
//  Created by Diego Lafuente Garcia on 8/27/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "deCartaPin.h"

@protocol TUIPinDelegate;

@interface TUIPin : deCartaPin
//The delegate
@property (weak, nonatomic) id<TUIPinDelegate> delegate;

/**
 * Inits the pin.
 * @return a singleton.
 */
-(TUIPin *)initWithPosition:(deCartaPosition *)position
                      image:(UIImage *)image
                    message:(NSString *)message
            andRotationTilt:(deCartaRotationTilt *)pinrt;

@end

@protocol TUIPinDelegate <NSObject>

-(void)pinTouched:(TUIPin *)sender;
-(void)pinLongTouched:(TUIPin *)sender;

@end
