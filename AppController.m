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


-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}


@end