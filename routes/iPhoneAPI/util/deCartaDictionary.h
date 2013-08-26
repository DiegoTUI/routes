//
//  deCartaDictionary.h
//  iPhoneApp
//
//  Created by Z.S. on 2/10/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @internal This class is only used for the deCartaDictionary class
 */
@interface LinkedListNode : NSObject
{
	id key; /**< Key for this node */
	id value; /**< Value corresponding to the key for this node */
	LinkedListNode * after; /**< Next linked list node */
	LinkedListNode * before; /**< Previous linked list node */
}
@property(nonatomic,retain) id key;
@property(nonatomic,retain) id value;
@property(nonatomic,assign) LinkedListNode * after;
@property(nonatomic,assign) LinkedListNode * before;

-(id)initWithValue:(id)inValue andKey:(id)inKey;

@end

/*!
 * @internal A dictionary of key-value pairs, used for managing tiles within the API.
 */
@interface deCartaDictionary : NSObject {
	NSMutableDictionary * dic;
	int size;
	LinkedListNode * header;
	void (*delFunc)(id);
}

-(id)initWithSize:(int)inSize andDelFunc:(void(*)(id))inDelFunc;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (id)removeObjectForKey:(id)aKey andExecDelFunc:(BOOL)execDelFunc;
- (void)removeAllObjects;

@end
