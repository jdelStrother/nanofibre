//
//  MusicLibrary.m
//  NanoFibre
//  Created by Jonathan del Strother on 08/10/2006.
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

#import "MusicLibrary.h"
#import "Album.h"
#import "NSAppleEventDescriptor+NDAppleScriptObject.h"
#import "NSAppleScript+HandlerCalls.h"
#import "NSString+NDCarbonUtilities.h"

UInt64 gigabytes()
{
	return 1024*1024*1024;
}

UInt64 totalSize(NSArray* albums)
{
	UInt64 totalSize=0;
	NSEnumerator* albumEnum = [albums objectEnumerator];
	Album* album;
	while (album = [albumEnum nextObject])
	{
		totalSize += [album byteSize];
	}
	return totalSize;
};


void handleScriptError(NSDictionary* errorInfo)
{
    NSString *errorMessage = [errorInfo objectForKey: NSAppleScriptErrorBriefMessage];
    NSNumber *errorNumber = [errorInfo objectForKey: NSAppleScriptErrorNumber];

    NSLog(@"The script produced an error %@: %@", errorNumber, errorMessage);
}



NSAppleScript* loadScript(NSString* scriptName)
{
	NSDictionary *errorInfo = nil;

	NSString *scriptPath = [[NSBundle mainBundle] pathForResource:scriptName ofType: @"scpt"];
	if (!scriptPath)
	{
		NSLog(@"Script %@ not found", scriptName);
		return nil;
	}
	NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];
	NSAppleScript* script = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:&errorInfo];
	
	if (![script isCompiled])
		NSLog(@"%@ is not compiled", scriptName);

	/* See if there were any errors loading the script */
	if (!script || errorInfo) {
		handleScriptError(errorInfo);
	}
	
	return [script autorelease];
}


@interface MusicLibrary (private)
-(void)loadLibrary;
-(NSArray*)fibreSelection;
@end


@implementation MusicLibrary

static MusicLibrary* sharedLibrary = nil;

+(id)sharedLibrary
{
	@synchronized(self) {
        if (sharedLibrary == nil) {
            sharedLibrary = [[self alloc] init];
        }
    }
	NSLog(@"Shared library is %@", sharedLibrary);
    return sharedLibrary;
}

-(id)init
{
	@synchronized(self)
	{
		if (sharedLibrary == nil)
		{
			self = [super init];
			if (self)
			{
				sharedLibrary = self;
				[self loadLibrary];
			}
		}
	}
	
	return sharedLibrary;
}

-(void)dealloc
{
	[albums release];
	[libraryName release];
	[super dealloc];
}

-(void)loadLibrary
{
	// This isn't particularly robust : It doesn't handle music libraries in odd locations, or ones that are linked to the usual location with aliases.
	NSString* libraryPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesXMLPath"];

	NSDictionary* xml = [NSDictionary dictionaryWithContentsOfFile:libraryPath];
	
	if (!xml)
	{
		NSString* error = [NSString stringWithFormat:@"NanoFibre couldn't load your music library from %@. Sorry.", libraryPath];
		NSRunAlertPanel(@"Couldn't load library", error, @"Quit",nil,nil);
		[[NSApplication sharedApplication] terminate:self];
	}	
	
	NSDictionary* tracks = [xml objectForKey:@"Tracks"];
	NSMutableDictionary* albumCollection = [NSMutableDictionary dictionary];
	nsenumerat(tracks, track)
	{
		if ([track objectForKey:@"Disabled"])
			continue;
		Album* album = [albumCollection objectForKey:[Album albumKeyForTrack:track]];
		if (!album)
		{
			album = [[Album alloc] init];

			[albumCollection setObject:album forKey:[Album albumKeyForTrack:track]];
			[album release];
		}
		
		[album addTrack:track];
	}
	
	albums = [[albumCollection allValues] retain];
		
	
	
	//Need to find the name of the Library playlist - varies for different countries.
	NSArray* playlists = [xml objectForKey:@"Playlists"];
	nsenumerat (playlists, playlist)
	{
		if ([playlist objectForKey:@"Master"])
		{
			libraryName = [[playlist objectForKey:@"Name"] copy];
			break;
		}
	}
	
	if (!libraryName)
	{
		[NSException raise:@"No Master Library" format:@"Couldn't find the iTunes master library"];
	}
}


// This is where we actually select some albums to play.
// Could definitely be cleverer - it just deletes albums from the complete list until size<desiredSize.
//  ie it doesn't try to match desiredSize as closely as possible, it doesn't bias towards highly rated albums etc etc.
-(NSArray*)fibreSelection
{
	NSMutableArray* albumSelection = [albums mutableCopy];
	float maxSize = [[[NSUserDefaults standardUserDefaults] valueForKey:@"maxSize"] floatValue]*gigabytes();
		
	while(totalSize(albumSelection) > maxSize)
	{
		[albumSelection removeObjectAtIndex:rand()%[albumSelection count]];
	}
	
	NSLog(@"Album selection is %.3gGB", totalSize(albumSelection)/(float)gigabytes());
	
	return [[albumSelection copy] autorelease];
}


-(void)createFibrePlaylist
{
	// Construct and execute applescript to play the album
	NSString* scriptName = @"ConstructPlaylist";
	NSMutableArray* tracks = [NSMutableArray array];
	NSArray* selection = [self fibreSelection];
	nsenumerat(selection, album)
	{
		[tracks addObjectsFromArray:[album tracks]];
	}
	
	NSAppleScript *script = loadScript(scriptName);

	NSDictionary *errorInfo = nil;
	
	// We have to construct an AppleEvent descriptor to contain the arguments for our handler call.  Remember that this list is 1, rather than 0, based
	NSAppleEventDescriptor *list = [[NSAppleEventDescriptor alloc] initListDescriptor];
	int index = 0;
	[list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:libraryName] atIndex:++index];

	//Add each track path to the argument list
	nsenumerat(tracks, path)
	{
		NSAppleEventDescriptor* pathDescriptor = [NSAppleEventDescriptor aliasDescriptorWithString:path];
		if (pathDescriptor)
			[list insertDescriptor:pathDescriptor atIndex:++index];
	}
	
	if (index > 1) //check that we actually have some tracks to play
	{
		
		NSAppleEventDescriptor *arguments = [[NSAppleEventDescriptor alloc] initListDescriptor];
		[arguments insertDescriptor: list atIndex: 1];


		errorInfo = nil;

		NSAppleEventDescriptor *result = [script callHandler:@"construct_playlist" withArguments: arguments errorInfo: &errorInfo];
		#pragma unused(result)
		
		/* Check for errors in running the handler */
		if (errorInfo) {
			handleScriptError(errorInfo);
		}
		
		[arguments release];
	}
	[list release];
		
}

@end
