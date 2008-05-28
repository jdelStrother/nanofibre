/*
 *  main_daemon.c
 *  NanoFibre
 *
 *  Created by Jonathan del Strother on 13/10/2006.
 *  Copyright 2006. All rights reserved.
 *
 */

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>
#import "MusicLibrary.h"
#import <unistd.h>

int main(int argc, char *argv[])
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// Look for the app bundle using its identifier
	
	FSRef appRef;
	if (LSFindApplicationForInfo(kLSUnknownCreator, CFSTR("com.steelskies.nanofibre"), NULL, &appRef, NULL ) == kLSApplicationNotFoundErr)
	{
		NSLog(@"Couldn't find NanoFibre app");
		return 1;
	}
	
	CFURLRef url = CFURLCreateFromFSRef(kCFAllocatorDefault, &appRef);
	if (!url)
	{
		NSLog(@"Couldn't convert fsref to pathname");
		return 1;
	}
	
	NSString* pathName = (NSString *)CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
	CFRelease(url);
	
	NSString* executable = [pathName stringByAppendingString:@"/Contents/MacOS/NanoFibre"];
	system([[NSString stringWithFormat:@"fibreDaemon=yes \"%@\"", executable] cStringUsingEncoding:NSUTF8StringEncoding]);
	
	[pool release];
	
	sleep(60);		//LaunchD is dumb and kills our daemon if it doesn't stay running for 60 seconds (TODO: Even in Leopard?)
	
	return 0;
}
