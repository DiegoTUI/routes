//
//  deCartaGlobals.h
//  iPhoneApp
//
//  Created by Z.S. on 3/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#ifndef DECARTAGLOBALS_H
#define DECARTAGLOBALS_H

//Default zoom level
#define ZOOM_LEVEL 13
#define DIGITAL_ZOOMING_TIME_PER_LEVEL 0.5
#define MAP_TILT_MIN -45.0f
#define PAN_TO_POSITION_TIME_DEF 0.5

/*! @ingroup global
 * The map type for displaying the map. */
typedef enum{
	STREET_MAP_TYPE, /**< Street Map */
	SATELLITE_MAP_TYPE, /**< Satellite Map */
	HYBRID_MAP_TYPE, /**< Hybrid Street Map/Satellite Map */
	NUM_OF_MAP_TYPE /**< Max number of map types supported by the API */
}deCartaMapTypeEnum;

/*! @internal For internal API use only */
typedef enum{
	STREET, /**< Street-map map layer */
	SATELLITE, /**< Satellite map layer */
	TRANSPARENT, /**< A transparent map layer */
	NUM_OF_MAPLAYER_TYPE /**< Max number of layer types supported by the API */
}MapLayerType;

extern BOOL MapType_MapLayer_Visibility[][NUM_OF_MAPLAYER_TYPE];

/*! @internal For internal API use only */
typedef enum{
	RGBA,
	RGB_565,
}deCartaImageFormatEnum;

/*! @internal For internal API use only */
typedef struct{
	int bytesPerPixel;
	int alphaInfo;
	unsigned short texFormat;
	unsigned short texType;
}deCartaImageFormatStruct;

extern deCartaImageFormatStruct Image_Formats[];
extern float g_scale;

extern long MERC_X_MODS[21];
extern int INDEX_X_MODS[21];

extern int MapLayer_Format[NUM_OF_MAPLAYER_TYPE];

/*!
 * @internal
 * This class is used only inside API
 */
@interface deCartaGlobals : NSObject {

}

@end

#endif