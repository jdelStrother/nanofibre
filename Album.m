//
//  Album.m
//  Fibre
//
//  Created by Jonathan del Strother on 01/10/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "Album.h"


@implementation Album

-(id)init
{
	self = [super init];
	if (self)
	{
		tracks = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)addTrack:(NSDictionary*)track
{
	[tracks addObject:track];
}
-(NSString*)title
{
	return [[tracks objectAtIndex:0] objectForKey:@"Album"];
}
-(NSString*)artist
{
	NSString* artist = [[tracks objectAtIndex:0] objectForKey:@"Album Artist"];
	if (!artist || [artist isEqualToString:@""])
		artist = [[tracks objectAtIndex:0] objectForKey:@"Artist"];
	return artist;
}
-(UInt64)byteSize
{
	if (!sizeCached)
	{
		size = 0;
		NSEnumerator* trackEnum = [tracks objectEnumerator];
		NSDictionary* track;
		while(track = [trackEnum nextObject])
		{
			size += [[track objectForKey:@"Size"] intValue];
		}
		sizeCached = YES;
	}
	return size;
}
-(NSString*)sizeDescription
{
	return [NSString stringWithFormat:@"%.2fMB", [self byteSize]/(float)(1024*1024)];
}


+(NSString*)pathOfTrack:(NSDictionary*)track
{
	//Get the path, and replace percentage escapes (eg %20 -> ' ')
	NSString* location = [track objectForKey:@"Location"];
	if (!location) return nil;
	
	NSString* encodedLocation = [location stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if (!encodedLocation) return nil;
	NSMutableString* path = [[encodedLocation mutableCopy] autorelease];
	
	if ([path hasPrefix:@"http:"])
		return nil;
	
	//Strip the protocol from the start of the string (eg 'file://')
	NSRange range = [path rangeOfString:@"//"];
	if (range.location == NSNotFound) return nil;
	[path deleteCharactersInRange:NSMakeRange(0,range.location+range.length)];
	
	//Strip the host from the start of the string (eg 'localhost')
	range = [path rangeOfString:@"/"];
	if (range.location == NSNotFound) return nil;
	[path deleteCharactersInRange:NSMakeRange(0,range.location+range.length-1)];
	
	return [[path copy] autorelease];
}

-(NSArray*)tracks
{
	NSMutableArray* trackPaths = [NSMutableArray array];
	nsenumerat(tracks, track)
		[trackPaths addObject:[Album pathOfTrack:track]];
		
	return [[trackPaths copy] autorelease];
}

@end
