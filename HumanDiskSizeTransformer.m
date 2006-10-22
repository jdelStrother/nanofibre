//
//  HumanDiskSizeTransformer.m
// NanoFibre
//
//  Created by Jonathan del Strother on 08/10/2006.
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