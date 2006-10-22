//
//  Album.h
//  NanoFibre
//
//  Created by Jonathan del Strother on 01/10/2006.
//  Copyright 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Album : NSObject {
	NSMutableArray* tracks;
	
	UInt64 size;
	BOOL sizeCached;
}

+(NSString*)albumKeyForTrack:(NSDictionary*)track;
-(void)addTrack:(NSDictionary*)track;
-(NSString*)title;
-(NSString*)artist;
-(NSString*)sizeDescription;
-(UInt64)byteSize;
-(NSArray*)tracks;
@end
