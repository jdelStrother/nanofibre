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
	
	LSApplicationParameters appParams;
	appParams.version = 0;
	appParams.flags = kLSLaunchAsync | kLSLaunchDontSwitch | kLSLaunchDontAddToRecents | kLSLaunchAndHide;
	appParams.application = &appRef;
	appParams.asyncLaunchRefCon = NULL;
	//Tell the app that we want to run in daemon mode.  We're using the environment vars to do this, because...
	appParams.environment = (CFDictionaryRef)[NSDictionary dictionaryWithObject:@"yes" forKey:@"fibreDaemon"];
	// ..."This field is ignored in Mac OS X v10.4".  Cheers guys.
	appParams.argv = NULL;
	appParams.initialEvent = NULL;
	
	LSOpenApplication(&appParams, NULL);
	
	[pool release];
	
	return 0;
}
