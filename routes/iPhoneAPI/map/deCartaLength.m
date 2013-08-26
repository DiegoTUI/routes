//
//  Length.m
//  iPhoneApp
//
//  Created by Z.S. on 2/4/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaLength.h"


@implementation deCartaLength
@synthesize distance=_distance;
@synthesize uom=_uom;

-(id)initWithDistance:(double)inDistance andUOM:(UOM)inUom{
	self=[super init];
    if(self){
		
		self.distance=inDistance;
		self.uom=inUom;
	}
	return self;
}

-(double)toMeters{
	if(_uom == M) return _distance;
	else if(_uom == KM) return _distance*1000;
	else if(_uom == MI) return _distance*1609.344;
	else return 0;
			
}

-(NSString *)description{
	NSString * uomS=@"M";
	if(_uom==KM) uomS=@"KM";
	else if(_uom==MI) uomS=@"MI";
	return [NSString stringWithFormat:@"%f %@",_distance,uomS];
}

@end
