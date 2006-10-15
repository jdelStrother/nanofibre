//
//  MusicLibrary.m
//  Fibre
//
//  Created by Jonathan del Strother on 08/10/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
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



-(void)loadLibrary
{
	NSDictionary* xml = [NSDictionary dictionaryWithContentsOfFile:@"/Users/jon/Music/iTunes/iTunes Music Library.xml"];
	
	NSDictionary* tracks = [xml objectForKey:@"Tracks"];
	NSEnumerator* trackEnum = [tracks objectEnumerator];
	NSDictionary* track;
	NSMutableDictionary* albumCollection = [NSMutableDictionary dictionary];
	while(track=[trackEnum nextObject])
	{
		if ([track objectForKey:@"Disabled"])
			continue;
		Album* album = [albumCollection objectForKey:[track objectForKey:@"Album"]];
		if (!album)
		{
			album = [[Album alloc] init];
			NSString* albumTitle = [track objectForKey:@"Album"];
			if (!albumTitle)
				albumTitle = @"";
			[albumCollection setObject:album forKey:albumTitle];
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
		[NSException raise:@"No Master Library" format:@"Couldn't find the itunes master library"];
	}
}

-(NSArray*)fibreSelection
{
	NSMutableArray* albumSelection = [albums mutableCopy];
	float maxSize = [[[NSUserDefaults standardUserDefaults] valueForKey:@"maxSize"] floatValue]*gigabytes();
	
	NSLog(@"Filter out big tracked albums (KCRW)/low rated ones/unchecked ones here");
	
	
	while(totalSize(albumSelection) > maxSize)
	{
		[albumSelection removeObjectAtIndex:rand()%[albumSelection count]];
	}
	
	NSLog(@"Album selection is %.3gGB", (float)(totalSize(albumSelection)/(1024.0*1024*1024)));
	
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
	
	/* We have to construct an AppleEvent descriptor to contain the arguments for our handler call.  Remember that this list is 1, rather than 0, based. */
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
	
	if (index > 1) //check that we actually have some tracks to play)
	{
		
		NSAppleEventDescriptor *arguments = [[NSAppleEventDescriptor alloc] initListDescriptor];
		[arguments insertDescriptor: list atIndex: 1];


		errorInfo = nil;

		/* Call the handler using the method in our special category */
		NSAppleEventDescriptor *result = [script callHandler:@"launch_album" withArguments: arguments errorInfo: &errorInfo];
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
