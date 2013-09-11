//
//  TUIPin.h
//  routes
//
//  Created by Diego Lafuente Garcia on 8/27/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "deCartaPin.h"

typedef enum {
    TUIHomeSpot = 0,
    TUIAttractionSpot = 1,
    TUICustomSpot = 2
} TUISpotType;

@protocol TUISpotDelegate;

@interface TUISpot : deCartaPin
//The delegate
@property (weak, nonatomic) id<TUISpotDelegate> delegate;

/**
 * Inits the pin.
 * @return a singleton.
 */
-(TUISpot *)initSpotOfType:(TUISpotType)type
            withPosition:(deCartaPosition *)position
              andName:(NSString *)name;

/**
 * Gets the name
 * @return the name.
 */
-(NSString *)name;

/**
 * Gets the type
 * @return the type.
 */
-(TUISpotType)type;

@end

@protocol TUISpotDelegate <NSObject>

-(void)spotTouched:(TUISpot *)sender;

@end
