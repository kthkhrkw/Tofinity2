//
//  TofinityAppDelegate.m
//  Tofinity
//
//  Created by 高橋 啓治郎 on 10/06/30.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TofinityAppDelegate.h"
#import "EAGLView.h"

@implementation TofinityAppDelegate

@synthesize window;
@synthesize glView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSLog(@"--->application");
    
    
    
    UIViewController* vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
    self.window.rootViewController = vc;
    
    [window addSubview:glView];
    
    
	
    [glView startAnimation];
	NSLog(@"<---application");   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"--->applicationDidBecomeActive");   
    [glView startAnimation];
	NSLog(@"<---applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
