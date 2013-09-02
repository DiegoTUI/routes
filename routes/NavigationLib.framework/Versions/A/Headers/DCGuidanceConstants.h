#ifndef _DCGUIDANCE_CONSTANTS_H_
#define _DCGUIDANCE_CONSTANTS_H_

typedef enum DCGuidanceUnits
{
	DCGuidanceUnitsImperial = 0,
	DCGuidanceUnitsMetric
}
DCGuidanceUnits;

typedef enum DCGuidanceRouteMode
{
	DCGuidanceRouteModeCar = 0,
	DCGuidanceRouteModePedestrian,
	DCGuidanceRouteModeCommercial,
	DCGuidanceRouteModeCarpool
}
DCGuidanceRouteMode;

typedef enum DCGuidanceRouteOption
{
	DCGuidanceRouteOptionAvoidFerry = 0,
	DCGuidanceRouteOptionAvoidTunnel,
	DCGuidanceRouteOptionAvoidBridge,
	DCGuidanceRouteOptionAvoidFreeway,
	DCGuidanceRouteOptionAvoidToll,
	DCGuidanceRouteOptionEnableTraffic,
	DCGuidanceRouteOptionFastest,
	DCGuidanceRouteOptionShortest,
	DCGuidanceRouteOptionEasiest
}
DCGuidanceRouteOption;

typedef enum DCGuidanceHybridMode
{
	DCGuidanceHybridModeOnboard = 0,
	DCGuidanceHybridModeOffboard,
	DCGuidanceHybridModeHybrid
}
DCGuidanceHybridMode;

typedef enum DCGuidanceIconType
{
	DCGuidanceIconTypeIntersection = 0,
	DCGuidanceIconTypeRoundaboutRight,
	DCGuidanceIconTypeRoundaboutLeft,
	DCGuidanceIconTypeKeepStraight,
	DCGuidanceIconTypeHighwayManeuverRight,
	DCGuidanceIconTypeHighwayManeuverLeft,
	DCGuidanceIconTypeUTurnRight,
	DCGuidanceIconTypeUTurnLeft
}
DCGuidanceIconType;

typedef enum DCGuidanceSimpleIconDirection
{
	DCGuidanceSimpleIconDirectionReverse = 0,
	DCGuidanceSimpleIconDirectionSharpLeft,
	DCGuidanceSimpleIconDirectionLeft,
	DCGuidanceSimpleIconDirectionKeepLeft,
	DCGuidanceSimpleIconDirectionStraightAhead,
	DCGuidanceSimpleIconDirectionKeepRight,
	DCGuidanceSimpleIconDirectionRight,
	DCGuidanceSimpleIconDirectionSharpRight
}
DCGuidanceSimpleIconDirection; 

#endif	// _DCGUIDANCE_CONSTANTS_H_
