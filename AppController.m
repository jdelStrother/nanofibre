#import <Security/Security.h>

#import "AppController.h"
#import "MusicLibrary.h"
#import "HumanDiskSizeTransformer.h";

@interface AppController(private)
-(void)findITunesXML;
@end

@implementation AppController

+(void)initialize
{
	NSDictionary* defaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:3.5] forKey:@"maxSize"];	//3.5GB is about right for my 4GB nano...
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

	HumanDiskSizeTransformer* humanDiskSizeTransformer = [[HumanDiskSizeTransformer alloc] init];
	[NSValueTransformer setValueTransformer:humanDiskSizeTransformer
                                forName:@"HumanDiskSizeTransformer"];
	[humanDiskSizeTransformer release];
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// If we're running in daemon mode, just make the changes and leave.
	if ([[[NSProcessInfo processInfo] environment] objectForKey:@"fibreDaemon"])
	{
		[[MusicLibrary sharedLibrary] createFibrePlaylist];
		[[NSApplication sharedApplication] terminate:self];
	}
	else
	{
		[self findITunesXML];
		[window makeKeyAndOrderFront:self];
	}
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	//It's a bit silly setting up cocoa bindings for the size controls, only to manually set it here...
	//However, I can't figure out a way of persuading it to update the label on every keystroke otherwise.
	NSString* sizeString = [[[[aNotification userInfo] objectForKey:@"NSFieldEditor"] textStorage] string];
	NSNumber* size = [[NSValueTransformer valueTransformerForName:@"HumanDiskSizeTransformer"]  reverseTransformedValue:sizeString];
	NSString* readableSize = [[NSValueTransformer valueTransformerForName:@"HumanDiskSizeTransformer"]  transformedValue:size];
	if (readableSize)
		[sizeLabel setStringValue:readableSize];
}

-(IBAction)makePlaylist:(id)sender
{
	//Persuade the text field to end editing, so the size value is committed:
	[sizeField selectText:self];
	
	[[MusicLibrary sharedLibrary] createFibrePlaylist];
	
	NSRunAlertPanel(@"Playlist Generated", @"Take a look in iTunes, you should have a NanoFibre playlist ready and waiting for your iPod syncing needs.", @"OK", nil, nil);
}


-(IBAction)installDaemon:(id)sender
{
	//Persuade the text field to end editing, so the size value is committed:
	[sizeField selectText:self];

	if (NSRunAlertPanel(@"Install Daemon?",
						@"This will install a daemon to /usr/local/bin, and a launch agent to ~/Library/LaunchAgents", 
						@"Install",@"Cancel",nil) == NSAlertDefaultReturn)
	{
		AuthorizationRef auth;
		if(AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth) == errAuthorizationSuccess)
		{
			BOOL daemonFailed = NO;
			BOOL agentFailed = NO;
		
			NSString* sourceExecutable = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"fibred"];
			
			char * args[3];
			args[0] = "-p";
			args[1] = "/usr/local/bin";
			args[2] = NULL;
			AuthorizationExecuteWithPrivileges(auth,"/bin/mkdir",
											   kAuthorizationFlagDefaults,
											   args, NULL);
			
			args[0] = (char*)[sourceExecutable fileSystemRepresentation];
			args[1] = "/usr/local/bin/";
			args[2] = NULL;
			AuthorizationExecuteWithPrivileges(auth,"/bin/cp",
											   kAuthorizationFlagDefaults,
											   args,NULL);	// Some error handling here would be handy, but we don't get anything useful in communicationsPipe because it doesn't catch STDERR
			
			//The above call doesn't block, so we need to wait for a bit before the file actually gets copied.
			// Let's go for 5 attempts, 0.5seconds apart.
			int attempts = 5;
			while (attempts-->0 && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/bin/fibred"])
			{
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
			}
			//Still not copied?  Well, crap.
			if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/bin/fibred"])
			{
				daemonFailed = YES;
				NSRunAlertPanel(@"Couldn't install daemon", @"Failed to copy daemon to /usr/local/bin/fibred",@"OK",nil,nil);
			}
			
			AuthorizationFree(auth,kAuthorizationFlagDefaults);
			
			if (!daemonFailed)
			{
				NSString* srcAgent = [[NSBundle mainBundle] pathForResource:@"Nanofibre" ofType:@"plist"];
				NSString* dstAgentDir = [@"~/Library/LaunchAgents" stringByExpandingTildeInPath];
				NSString* dstAgent = [dstAgentDir stringByAppendingPathComponent:@"Nanofibre.plist"];
				[[NSFileManager defaultManager] createDirectoryAtPath:dstAgentDir attributes:nil];
				[[NSFileManager defaultManager] copyPath:srcAgent toPath:dstAgent handler:nil];
				
				[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:[NSArray arrayWithObjects:@"load", @"-w", dstAgent, nil]];
				
				if (![[NSFileManager defaultManager] fileExistsAtPath:dstAgent])
				{
					agentFailed = YES;
					NSString* msg = [NSString stringWithFormat:@"Failed to copy launch agent to %@.\nThe fibred agent has been left in /usr/local/bin", dstAgent];
					NSRunAlertPanel(@"Couldn't install launch agent",msg,@"OK",nil,nil);
				}
			}
			
			if (!daemonFailed && !agentFailed)
				NSRunAlertPanel(@"Installation Succeeded", @"Successfully installed launch agent and the fibred daemon\nNanoFibre will generate a new playlist for you every night.", @"OK", nil, nil);
		}
	}
}


-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}



// This could use some love - it won't handle aliases etc.
-(void)findITunesXML
{
	//Need to find the iTunes XML.  Start by checking previous results:	
	BOOL libraryFound = NO;
	NSString* pathToLibrary = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesXMLPath"];
	if (pathToLibrary && [[NSFileManager defaultManager] fileExistsAtPath:pathToLibrary])
		return;	//We're good to go
	
	
	//OK, we don't know where it is.  Check the obvious location:
	pathToLibrary = [@"~/Music/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:pathToLibrary])
		libraryFound = YES;
		
	//Still not found it?  Ask the user to locate it:
	if (!libraryFound)
	{
		NSOpenPanel* openPanel = [NSOpenPanel openPanel];
		[openPanel setTitle:@"Open iTunes Library"];
		[openPanel setMessage:@"Where is your iTunes Music Library XML?"];
		int panelResult = [openPanel runModalForTypes:[NSArray arrayWithObject:@"xml"]];
		if (panelResult == NSOKButton)
		{
			pathToLibrary = [openPanel filename];
			if ([[NSFileManager defaultManager] fileExistsAtPath:pathToLibrary])
				libraryFound = YES;
		}
	}
	
	if (libraryFound)
		[[NSUserDefaults standardUserDefaults] setObject:pathToLibrary forKey:@"iTunesXMLPath"];
	else
	{
		NSRunAlertPanel(@"Oh dear", @"We couldn't find your iTunes XML.  Bad luck." ,@":(",nil,nil);
		[[NSApplication sharedApplication] terminate:self];
	}
}

@end