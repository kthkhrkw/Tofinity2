// cmnt test 3
// cmnt test 2
// cmnt test 1

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


#define FREE_GRAVITY ;



@class Wrangler;

@interface EAGLView : UIView <UIAccelerometerDelegate> {
@private
    GLint backingWidth, backingHeight;
    BOOL animating;
    id displayLink;
    EAGLContext *context;
    GLuint defaultFramebuffer, colorRenderbuffer;
    Wrangler *wrangler;
    CFTimeInterval frameStartTime;
    UIAccelerationValue accelX, accelY;
}

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

@end
