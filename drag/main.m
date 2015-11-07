// drag
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

#import "AppDelegate.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSArray<NSString*> *const arguments = [NSProcessInfo processInfo].arguments;
        
        if (arguments.count < 2)
        {
            fprintf(stderr, "Usage: drag path/to/file...");
            return EXIT_FAILURE;
        }
        else
        {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSURL *working = [NSURL fileURLWithPath:fm.currentDirectoryPath];
            
            NSMutableArray *fileURLs = [NSMutableArray arrayWithCapacity:arguments.count - 1];
            
            for (NSUInteger i = 1; i < argc; i++)
            {
                NSString *path = arguments[i].stringByStandardizingPath;
                NSURL *URL = [[NSURL alloc] initWithString:path relativeToURL:working];
                
                if (![fm fileExistsAtPath:URL.path])
                {
                    fprintf(stderr, "File does not exist: “%s”", arguments[i].UTF8String);
                    return EXIT_FAILURE;
                }
                
                [fileURLs addObject:URL];
            }
            
            AppDelegate *appDelegate = [AppDelegate new];
            appDelegate.fileURLs = fileURLs;
            
            NSApplication *app = [NSApplication sharedApplication];
            app.delegate = appDelegate;
            
            [app run];
            
            NSLog(@"%@", appDelegate); // retain the app delegate, -run will never return
            
            return EXIT_SUCCESS;
        }
    }
}
