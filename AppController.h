/* AppController */

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
	IBOutlet NSArrayController *arrayController;
	IBOutlet NSTextField *sizeLabel;
	IBOutlet NSWindow *window;
}
-(IBAction)makePlaylist:(id)sender;
-(IBAction)installDaemon:(id)sender;
@end
