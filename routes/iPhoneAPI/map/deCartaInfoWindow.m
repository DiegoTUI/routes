//
//  InfoWindow.m
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


#import "deCartaInfoWindow.h"
#import "deCartaGlobals.h"
#import "deCartaEventSource.h"
#import "deCartaEventListener.h"
#import "deCartaUtil.h"
#import "deCartaLogger.h"
#import "deCartaGlobals.h"

#define INFO_WINDOW_TRIANGLE_HEIGHT 15
#define INFO_WINDOW_TRIANGLE_WIDTH 16
#define INFO_WINDOW_TEXTOFFSET_VERTICAL 5
#define INFO_WINDOW_TEXTOFFSET_HORIZONTAL 5
#define INFO_WINDOW_FONT_FAMILY @"Helvetica"
#define INFO_WINDOW_FONT_SIZE 15
#define INFO_WINDOW_TEXT_COLOR 0xff000000
#define INFO_WINDOW_BORDER_COLOR 0xff444444
#define INFO_WINDOW_BORDER_WIDTH 1
#define INFO_WINDOW_CORNER_RADIUS 5

static deCartaInfoWindow * instance=nil;

@interface deCartaInfoWindow(Private)
-(id)initInfoWindow;
@end
@implementation deCartaInfoWindow(Private)
-(id)initInfoWindow{
	self = [super init];
    if(self){
		_associatedPin=nil;
		_visible=FALSE;
		_mercXY=nil;
		_position=nil;
		_message=nil;
		_offset=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
		_offsetRotationTilt=[[deCartaRotationTilt alloc] init];
		_backgroundColor=INFO_WINDOW_BACKGROUND_COLOR_UNCLICKED;
		_eventListeners=[[NSMutableDictionary alloc] init];
		_textureRef=0;
		_texImageChanged=FALSE;
        
        _textAlign=INFO_WINDOW_TEXT_ALIGN_LEFT;
	}
	
	return self;
}

@end


@implementation deCartaInfoWindow
@synthesize offset=_offset;
@synthesize message=_message;
@synthesize position=_position;
@synthesize visible=_visible;
@synthesize backgroundColor=_backgroundColor;
@synthesize associatedPin=_associatedPin;
@synthesize offsetRotationTilt=_offsetRotationTilt;
@synthesize mercXY=_mercXY;
@synthesize textureRef=_textureRef;
@synthesize texImageChanged=_texImageChanged;
@synthesize rect=_rect;
@synthesize textAlign=_textAlign;

+(deCartaInfoWindow *)getInfoWindowInstance{
	if(instance==nil){
		instance=[[deCartaInfoWindow alloc] initInfoWindow];
	}
	return instance;
}

-(void)setOffset:(deCartaXYFloat *)offset andRotationTilt:(deCartaRotationTilt *)offsetRotationTilt{
	[_offset release];
	_offset=[offset retain];
	[_offsetRotationTilt release];
	_offsetRotationTilt=[offsetRotationTilt retain];
}

-(void)setPosition:(deCartaPosition *)position{
	[_mercXY release];
	_mercXY=nil;
	[_position release];
	_position=nil;
	_mercXY=[[deCartaUtil posToMercPix:position atZoom:ZOOM_LEVEL] retain];
	_position=[position retain];
}

-(void)setMessage:(NSString *)message{
	[_message release];
	_message=[message retain];
	_texImageChanged=TRUE;
}

-(void)setBackgroundColor:(int)backgroundColor{
	_backgroundColor=backgroundColor;
	_texImageChanged=TRUE;
}



-(void)dealloc{
	[_offset release];
	[_message release];
	[_position release];
	[_associatedPin release];
	[_offsetRotationTilt release];
	[_mercXY release];
	[_eventListeners release];
	[super dealloc];
}

#pragma mark -
#pragma mark @implementation EventSouce protocol

-(BOOL)addEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	if([_eventListeners objectForKey:[NSNumber numberWithInt:eventType]]==nil){
		[_eventListeners setObject:[NSMutableArray arrayWithCapacity:1] forKey:[NSNumber numberWithInt:eventType]];
	}
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	[array addObject:listener];
	
	return TRUE;
}
-(void)removeEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	[array removeObject:listener];
}
-(void)removeEventListeners:(int)eventType{
	[_eventListeners removeObjectForKey:[NSNumber numberWithInt:eventType]];
	
}

-(void)executeEventListeners:(int)eventType withParam:(id)param{
	NSArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	for(deCartaEventListener * listener in array){
		(listener.callback)(self,param);
	}
}

#pragma mark -
#pragma mark @implementation methods used only in API
-(CGRect)getInfoWindowRect{
	float textOffsetX=INFO_WINDOW_TEXTOFFSET_HORIZONTAL*g_scale;
	float textOffsetY=INFO_WINDOW_TEXTOFFSET_VERTICAL*g_scale;
	NSArray * msgs=[_message componentsSeparatedByString:@"\n"];
	float maxLength=0;
	float height=0;
	UIFont * font=[UIFont fontWithName:INFO_WINDOW_FONT_FAMILY size:INFO_WINDOW_FONT_SIZE*g_scale];
	for(NSString * msg_line in msgs){
		if([msg_line length]>INFO_WINDOW_MAX_CHARS_PER_LINE){
			msg_line=[[msg_line substringWithRange:NSMakeRange(0,INFO_WINDOW_MAX_CHARS_PER_LINE-3)] stringByAppendingFormat:@"..."];
		}
		CGSize size=[msg_line sizeWithFont:font];
		if(size.width>maxLength)maxLength=size.width;
		height+=size.height;
		
	}
	float infoWindowWidth=maxLength+2*textOffsetX;
	float infoWindowHeight=height+2*textOffsetY;
	CGRect rect;
	rect.origin.x=-infoWindowWidth/2;
	rect.origin.y=-infoWindowHeight-INFO_WINDOW_TRIANGLE_HEIGHT;
	rect.size.width=infoWindowWidth;
	rect.size.height=infoWindowHeight;
	
	return rect;
}

-(void)drawInfoWindow{
	static const GLbyte TEXTURE_COORDS[]={
		0,0,
		0,1,
		1,0,
		1,1
	};
	static GLfloat mVertexBuffer[8];
	glVertexPointer(2, GL_FLOAT, 0, mVertexBuffer);
	glTexCoordPointer(2, GL_BYTE, 0, TEXTURE_COORDS);
    static float TEXT_BASE_OFF=0.0f;
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	if(self.textureRef==0){
		glGenTextures(1, &_textureRef);
		//[deCartaLogger debug:[NSString stringWithFormat:@"InfoWindow drawInfoWindow texRef:%d",_textureRef]];
	}
	glBindTexture(GL_TEXTURE_2D, _textureRef);
	
	if(_texImageChanged){
		_rect=[self getInfoWindowRect];
		//[deCartaLogger debug:[NSString stringWithFormat:@"InfoWindow drawInfoWindow _rect width:%f,height:%f",_rect.size.width,_rect.size.height]];
	}
	int sizePower2X=[deCartaUtil getPower2:(int)_rect.size.width];
	int sizePower2Y=[deCartaUtil getPower2:(int)_rect.size.height+INFO_WINDOW_TRIANGLE_HEIGHT];
	
	if(_texImageChanged){
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);// GL_NEAREST);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);// GL_NEAREST);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		unsigned char * imgBuf=0;
		@try{
			deCartaImageFormatStruct * formatStruct=(deCartaImageFormatStruct *)&Image_Formats[RGBA];
			imgBuf=malloc(sizePower2X*sizePower2Y*4);
			CGColorSpaceRef	colorSpace = CGColorSpaceCreateDeviceRGB();
			CGContextRef context = CGBitmapContextCreate(imgBuf, sizePower2X, sizePower2Y, 8, sizePower2X * 4, colorSpace, formatStruct->alphaInfo);
			CGContextTranslateCTM(context, 0, sizePower2Y);
			CGContextScaleCTM(context, 1, -1);
			
			float startX= _rect.origin.x+sizePower2X/2;
			float startY=_rect.origin.y+sizePower2Y;
			
			CGRect rc;
			rc.origin.x=0;
			rc.origin.y=0;
			rc.size.width=sizePower2X;
			rc.size.height=sizePower2Y;
			CGContextClearRect(context, rc);
			
			float backgroudnColorComps[4];
			backgroudnColorComps[0]=((_backgroundColor & 0x00ff0000)>>16)/255.0f;
			backgroudnColorComps[1]=((_backgroundColor & 0x0000ff00)>>8)/255.0f;
			backgroudnColorComps[2]=(_backgroundColor & 0x000000ff)/255.0f;
			backgroudnColorComps[3]=1;
			CGContextSetRGBFillColor(context, backgroudnColorComps[0], backgroudnColorComps[1], backgroudnColorComps[2], backgroudnColorComps[3]);
			float borderColorComps[4];
			borderColorComps[0]=((INFO_WINDOW_BORDER_COLOR & 0x00ff0000)>>16)/255.0f;
			borderColorComps[1]=((INFO_WINDOW_BORDER_COLOR & 0x0000ff00)>>8)/255.0f;
			borderColorComps[2]=(INFO_WINDOW_BORDER_COLOR & 0x000000ff)/255.0f;
			borderColorComps[3]=1;
			CGContextSetRGBStrokeColor(context, borderColorComps[0], borderColorComps[1], borderColorComps[2], borderColorComps[3]);
			CGContextSetLineWidth(context, INFO_WINDOW_BORDER_WIDTH*g_scale);
			
			//draw whole path
			CGContextMoveToPoint(context, startX+_rect.size.width/2-INFO_WINDOW_TRIANGLE_WIDTH/2, startY+_rect.size.height);
			CGContextAddLineToPoint(context, startX+_rect.size.width/2, startY+_rect.size.height+INFO_WINDOW_TRIANGLE_HEIGHT);
			CGContextAddLineToPoint(context, startX+_rect.size.width/2+INFO_WINDOW_TRIANGLE_WIDTH/2, startY+_rect.size.height);
			CGContextAddLineToPoint(context, startX+_rect.size.width, startY+_rect.size.height);
			CGContextAddLineToPoint(context, startX+_rect.size.width, startY);
			CGContextAddLineToPoint(context, startX, startY);
			CGContextAddLineToPoint(context, startX, startY+_rect.size.height);
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathFillStroke );
			
			//draw text
			CGContextSelectFont(context, [INFO_WINDOW_FONT_FAMILY UTF8String], INFO_WINDOW_FONT_SIZE*g_scale, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextFill);
			CGContextSetTextMatrix(context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
			
			float textColorComps[4];
			textColorComps[0]=((INFO_WINDOW_TEXT_COLOR & 0x00ff0000)>>16)/255.0f;
			textColorComps[1]=((INFO_WINDOW_TEXT_COLOR & 0x0000ff00)>>8)/255.0f;
			textColorComps[2]=(INFO_WINDOW_TEXT_COLOR & 0x000000ff)/255.0f;
			textColorComps[3]=1;
			CGContextSetRGBFillColor(context, textColorComps[0], textColorComps[1], textColorComps[2], textColorComps[3]);
			
			float textOffsetX=INFO_WINDOW_TEXTOFFSET_HORIZONTAL*g_scale;
			float textOffsetY=INFO_WINDOW_TEXTOFFSET_VERTICAL*g_scale;
			NSArray * msgs=[_message componentsSeparatedByString:@"\n"];
			float height=startY+textOffsetY;
			UIFont * font=[UIFont fontWithName:INFO_WINDOW_FONT_FAMILY size:INFO_WINDOW_FONT_SIZE*g_scale];
			for(NSString * msg_line in msgs){
				if([msg_line length]>INFO_WINDOW_MAX_CHARS_PER_LINE){
					msg_line=[[msg_line substringWithRange:NSMakeRange(0,INFO_WINDOW_MAX_CHARS_PER_LINE-3)] stringByAppendingFormat:@"..."];
				}
				CGSize size=[msg_line sizeWithFont:font];
				height+=size.height*TEXT_BASE_OFF;
				//CGContextShowTextAtPoint(context, startX+textOffsetX, height, [msg_line UTF8String], strlen([msg_line UTF8String])); 
                UIGraphicsPushContext(context);
                [msg_line drawAtPoint:CGPointMake(startX+textOffsetX, height) withFont:font];
                UIGraphicsPopContext();
				
				height+=size.height*(1-TEXT_BASE_OFF);
				
			}
			
			CGContextRelease(context);
			CGColorSpaceRelease(colorSpace);
			
			glTexImage2D(GL_TEXTURE_2D, 0, formatStruct->texFormat, sizePower2X, sizePower2Y, 0, formatStruct->texFormat, formatStruct->texType, imgBuf);
			
			free(imgBuf);
			_texImageChanged=FALSE;
		}
		@catch (NSException * e) {
			[deCartaLogger warn:[NSString stringWithFormat:@"MapView image2texture exception:%@",[e name]]];
			if(imgBuf) free(imgBuf);
			
		}
		
		
		
	}
	
	float x=-sizePower2X/2;
	float y=-sizePower2Y;	
	mVertexBuffer[0]=x;
	mVertexBuffer[1]=y;
	mVertexBuffer[2]=x;
	mVertexBuffer[3]=y+sizePower2Y;
	mVertexBuffer[4]=x+sizePower2X;
	mVertexBuffer[5]=y;
	mVertexBuffer[6]=x+sizePower2X;
	mVertexBuffer[7]=y+sizePower2Y;
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisable(GL_BLEND);
}
@end
