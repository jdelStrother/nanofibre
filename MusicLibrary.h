//
//  MusicLibrary.h
// NanoFibre
//
//  Created by Jonathan del Strother on 08/10/2006.
//  Copyright 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MusicLibrary : NSObject {
	NSArray* albums;
	NSString* libraryName;
}
+(id)sharedLibrary;
-(void)createFibrePlaylist;

@end