//
//  deCartaRotationTilt.h
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @ingroup Map
 * Defines the types of map rotation
 */
typedef enum{
	ROTATE_RELATIVE_TO_SCREEN, /**< Indicates absolute rotation, relative to the screen */
	ROTATE_RELATIVE_TO_MAP, /**< Indicates relative rotation, adding to the map's rotation */
}RotateRelativeEnum;

/*!
 * @ingroup Map
 * Defines the types of map tilt
 */
typedef enum{
	TILT_RELATIVE_TO_SCREEN, /**< Indicates absolute tilt, relative to the screen */
	TILT_RELATIVE_TO_MAP /**< Indicates relative tilt, adding to the map's tilt */
}TiltRelativeEnum;

/*!
 * @ingroup Map
 * @class deCartaRotationTilt
 * This class defines how an object (such as a deCartaPin or deCartaInfoWindow)
 * is rotated and tilted.
 * Rotation is defined as the rotation around the Z-axis
 * using the right-hand rule, meaning that positive angles rotate the object
 * a specified number of degrees clockwise. This rotation can be specified
 * as an absolute rotation, or as a rotation that is added to the map's
 * rotation (see the rotateRelativeTo property).
 * Tilt is defined as the rotation around the X-axis using the right-hand
 * rule, meaning that a negative angle tilts the top of the object away from
 * the viewer. This tilt can be specified as an absolute tilt, or as a tilt
 * that is added to the map's tilt (see the tiltRelativeTo property).
 * @brief Defines how an object is rotated and tilted when displayed.
 */
@interface deCartaRotationTilt : NSObject {
	RotateRelativeEnum _rotateRelativeTo;
	float _rotation;
	TiltRelativeEnum _tiltRelativeTo;
	float _tilt;
	
	float _cosR;
	float _sinR;
	float _cosT;
	float _sinT;
}
/*! Set to ROTATE_RELATIVE_TO_SCREEN to have the rotation of this object
 * be independent of the map's rotation, or set to ROTATE_RELATIVE_TO_MAP
 * to have the rotation of the object be relative to the map's rotation.
 */
@property(nonatomic,assign,readonly)RotateRelativeEnum rotateRelativeTo;

/*! Set to TILT_RELATIVE_TO_SCREEN to have the tilt of this object
 * be independent of the map's tilt, or set to TILT_RELATIVE_TO_MAP
 * to have the tilt of the object be relative to the map's tilt.
 */
@property(nonatomic,assign,readonly)TiltRelativeEnum tiltRelativeTo;

/*! 
 * Rotation can be any angle, and will automatically be normalized to an angle
 * from -180.0 to 180.0 degrees. Positive angles rotate the object clockwise.
 */
@property(nonatomic,assign)float rotation;

/*!
 * Tilt must be an angle from 0.0 to -45.0, with 0.0 indicating no tilt,
 * and -45.0 indicating that the top of the object tilts away from the viewer
 * at a 45-degree angle.
 */
@property(nonatomic,assign)float tilt;

/*! The cosine of the rotation */
@property(nonatomic,assign,readonly)float cosR;

/*! The sine of the rotation */
@property(nonatomic,assign,readonly)float sinR;

/*! The cosine of the tilt */
@property(nonatomic,assign,readonly)float cosT;

/*! The sine of the tilt */
@property(nonatomic,assign,readonly)float sinT;

/*!
 * Initializes the deCartaRotationTilt object with the desired rotation and
 * tilt settings.
 * @param inRotateRelativeTo Set to ROTATE_RELATIVE_TO_SCREEN to have the
 * rotation of this object be independent of the map's rotation, or set to
 * ROTATE_RELATIVE_TO_MAP to have the rotation of the object be relative to
 * the map's rotation.
 * @param inTiltRelativeTo Set to TILT_RELATIVE_TO_SCREEN to have the tilt 
 * of this object be independent of the map's tilt, or set to
 * TILT_RELATIVE_TO_MAP to have the tilt of the object be relative to the
 * map's tilt.
 * @return Objective C ID of the returned deCartaRotationTilt object
 */
-(id)initWithRotateRelative:(RotateRelativeEnum)inRotateRelativeTo tiltRelative:(TiltRelativeEnum)inTiltRelativeTo;

/*!
 * Returns the ID of this deCartaRotationTilt object.
 @return Objective C ID of this deCartaRotationTilt object
 */
+(id)rotationTilt;

/*!
 * Sets the deCartaRotationTilt object's properties with the desired rotation
 * and tilt settings.
 * @param inRotateRelativeTo Set to ROTATE_RELATIVE_TO_SCREEN to have the
 * rotation of this object be independent of the map's rotation, or set to
 * ROTATE_RELATIVE_TO_MAP to have the rotation of the object be relative to
 * the map's rotation.
 * @param inTiltRelativeTo Set to TILT_RELATIVE_TO_SCREEN to have the tilt 
 * of this object be independent of the map's tilt, or set to
 * TILT_RELATIVE_TO_MAP to have the tilt of the object be relative to the
 * map's tilt.
 * @return Objective C ID of the returned deCartaRotationTilt object
 */
+(id)rotationTiltWithRotateRelative:(RotateRelativeEnum)inRotateRelativeTo tiltRelative:(TiltRelativeEnum)inTiltRelativeTo;

@end
