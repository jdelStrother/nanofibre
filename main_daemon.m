//
//  main_daemon.c
//  NanoFibre
//
//  Created by Jonathan del Strother on 13/10/2006.
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
