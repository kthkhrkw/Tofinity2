//
//  main.m
//  Tofinity
//
//  Created by 高橋 啓治郎 on 10/06/30.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
 NSLog(@"--->main");   
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
	NSLog(@"<---main");   
    return retVal;
}
