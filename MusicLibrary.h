//
//  MusicLibrary.h
//  Fibre
//
//  Created by Jonathan del Strother on 08/10/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MusicLibrary : NSObject {
	NSArray* albums;
	NSString* libraryName;
}
+(id)sharedLibrary;
-(void)createFibrePlaylist;

@end
