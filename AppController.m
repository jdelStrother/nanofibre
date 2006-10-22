#import <Security/Security.h>

#import "AppController.h"
#import "MusicLibrary.h"
#import "HumanDiskSizeTransformer.h";

@implementation AppController

+(void)initialize
{
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
		[self makePlaylist:self];
		[[NSApplication sharedApplication] terminate:self];
	}
	else
	{
		[window makeKeyAndOrderFront:self];
	}
}


-(IBAction)makePlaylist:(id)sender
{
	[[MusicLibrary sharedLibrary] createFibrePlaylist];
}


-(IBAction)installDaemon:(id)sender
{
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


@end