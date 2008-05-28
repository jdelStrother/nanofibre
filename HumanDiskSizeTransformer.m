//
//  HumanDiskSizeTransformer.m
//  NanoFibre
//
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

#import "HumanDiskSizeTransformer.h"


@implementation HumanDiskSizeTransformer

+(Class)transformedValueClass;
{
	return [NSNumber class];
}

+(BOOL)allowsReverseTransformation;
{
	return YES;   
}


-(id)reverseTransformedValue:(id)value;	// NSString -> NSNumber
{
	float size;

	if (value == nil) return nil;
	
	// Attempt to get a reasonable value from the 
	// value object. 
    if ([value isKindOfClass:[NSString class]])
	{
		NSString* strSize = [[[value lowercaseString]
									 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
									 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"s"]];
		
		if ([strSize hasSuffix:@"megabyte"]||[strSize hasSuffix:@"mb"])
			size = [value floatValue]/1024;
		else	//Assume we want gigabytes
			size = [value floatValue];
    }
	else
	{
        [NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) needs to be a string", value];
    }
	
	id returnValue = [NSNumber numberWithFloat:size];
 
    return returnValue;
}


-(id)transformedValue:(id)value		// NSNumber -> NSString
{
	float size;
    
    if (value == nil) return nil;
    
    // Attempt to get a reasonable value from the 
    // value object. 
	if ([value respondsToSelector: @selector(floatValue)]) {
		size = [value floatValue];
	} else {
		[NSException raise: NSInternalInconsistencyException
					format: @"Value (%@) does not respond to -floatValue.",
		[value class]];
	}
	
	id returnValue;
	if (size < 0.5)
		returnValue = [NSString stringWithFormat:@"%.0fMB", size*1024];
	else
		returnValue = [NSString stringWithFormat:@"%0.3gGB", size];

    return returnValue;
}

@end