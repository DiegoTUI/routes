//
//  DCMapViewController.h
//  Sunder
//
//  Created by Daniel Posluns on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DCMapDelegate.h"

@class DCMapView;

@interface DCMapViewController : UIViewController <DCMapDelegate>
{
	// Primary
    DCMapView					*mapView;
	int							headerUIHeight;
}

@property (nonatomic, retain) IBOutlet DCMapView *mapView;

- (void)doneLoading:(DCMapView *)mapView;

@end
