//
//  DCGuidanceAnnouncement.h
//  NavigationLib
//
//  Created by Daniel Posluns on 6/20/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DCGuidanceUpdate;

@protocol DCGuidanceAnnouncement <NSObject>

- (id<DCGuidanceUpdate>)getUpdate;
- (BOOL)willArrive;
- (int)announcementStage;
- (int)totalAnnouncementStages;

@end
