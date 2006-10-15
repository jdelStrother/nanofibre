/*
 *  main_daemon.c
 *  Fibre
 *
 *  Created by Jonathan del Strother on 13/10/2006.
 *  Copyright 2006 Best Before Media Ltd. All rights reserved.
 *
 */

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// Look for the app bundle using its identifier
	
	FSRef appRef;
	if (LSFindApplicationForInfo(kLSUnknownCreator, CFSTR("com.steelskies.nanofibre"), NULL, &appRef, NULL ) == kLSApplicationNotFoundErr)
	{
		NSLog(@"Couldn't find Fibre app");
		return 1;
	}
	
	NSLog(@"launching %@", CFURLCreateFromFSRef( kCFAllocatorDefault, &appRef ));
	
	LSApplicationParameters appParams;
	appParams.version = 0;
	appParams.flags = kLSLaunchAsync | kLSLaunchDontSwitch | kLSLaunchDontAddToRecents | kLSLaunchAndHide;
	appParams.application = &appRef;
	appParams.asyncLaunchRefCon = NULL;
	appParams.environment = (CFDictionaryRef)[NSDictionary dictionaryWithObject:@"yes" forKey:@"fibreDaemon"];
	appParams.argv = NULL;
	appParams.initialEvent = NULL;
	
	LSOpenApplication(&appParams, NULL);

//	LSLaunchRefSpec
	
	[pool release];
	
	return 0;
}
