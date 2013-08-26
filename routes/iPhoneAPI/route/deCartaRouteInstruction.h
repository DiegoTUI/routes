//
//  deCartaRouteInstruction.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaLength.h"
#import "deCartaPosition.h"

/*!
 * @ingroup Route
 * @class deCartaRouteInstruction
 * For turn-by-turn navigation, each maneuver along a route is described by a
 * deCartaRouteInstruction, which contains an instruction understandable by human beings,
 * as well as information about that instruction for the application to use when presenting
 * the instruction to the user.
 * @brief A user instruction for turn-by-turn navigation.
 */
@interface deCartaRouteInstruction : NSObject {
	NSString * _instruction;
	deCartaLength * _distance;
	NSString * _duration;
	deCartaPosition * _position;
	NSString * _tour;
	
}
/*!
 * The time estimated to cover this route maneuver, written as a fully 
 * described string. Example, "2 minutes 31 seconds"
 */
@property(nonatomic,retain) NSString * duration;

/*! 
 * The surface distance covered in this route maneuver. The distance is a 
 * string representing a floating point number. Example, "3.3".
 * (Units of measure are defined within the deCartaLength class)
 */
@property(nonatomic,retain) deCartaLength * distance;

/*! 
 * A human readable description of this route maneuver.
 * Example: "Turn right on Main Street."
 * The instructions will almost always contain a relative directional action 
 * (like "Turn right...") followed by the information defining the destination 
 * (like "...on Main Street").
 */
@property(nonatomic,retain) NSString * instruction;

/*! 
 * The latitude and longitude coordinate at which the maneuver happens.
 */
@property(nonatomic,retain) deCartaPosition * position;

/*!
 * A string indicating the waypoint number that this instruction is associated with
 * in an optimized route, if any.
 * When a multipoint route is optimized, the order of the waypoints can be 
 * different than the way you entered them. The waypoints are referred in 
 * zero-based array order (e.g. '0' is actually the first waypoint). 
 * Example, "1" means that this maneuver is associated with the second 
 * waypoint. Note: the origin and destination are not considered waypoints, 
 * and are not referred to by this field. Only the waypoints between the 
 * origin and destination count as waypoints.
 */
@property(nonatomic,retain) NSString * tour;



@end
