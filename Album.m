//
//  Album.m
//  NanoFibre
//
//  Created by Jonathan del Strother on 01/10/2006.
//
//  Copyright (c) 2006 Jonathan del Strother
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//  Copyright 2006. All rights reserved.
//

#import "Album.h"


@implementation Album

+(NSString*)albumKeyForTrack:(NSDictionary*)track
{
	NSString* albumTitle = [track objectForKey:@"Album"];
	
	NSString* artist = [track objectForKey:@"Album Artist"];
	if (!artist)
		artist = [track objectForKey:@"Artist"];

	if (!artist) artist=@"";
	if (!albumTitle) albumTitle=@"";
	

	return [NSString stringWithFormat:@"%@__%@", artist, albumTitle];
}
			
			
-(id)init
{
	self = [super init];
	if (self)
	{
		tracks = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[tracks release];
	[super dealloc];
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
	nsenumerat(tracks, track) {
		NSString* path = [Album pathOfTrack:track];
		if (path)
			[trackPaths addObject:path];
	}
		
	return [[trackPaths copy] autorelease];
}

@end
