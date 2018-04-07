#import "EAGLView.h"
#import "Wrangler.h"
#import "debug_macro.h"



@implementation EAGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder {
	NSLog(@"--->initWithCoder");
    if (self = [super initWithCoder:coder]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*)self.layer;
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary
            dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],
            kEAGLDrawablePropertyRetainedBacking,
            kEAGLColorFormatRGBA8,
            kEAGLDrawablePropertyColorFormat, nil];

        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }

        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                     GL_COLOR_ATTACHMENT0_OES,
                                     GL_RENDERBUFFER_OES,
                                     colorRenderbuffer);

        animating = FALSE;
        displayLink = nil;
        wrangler = nil;
        frameStartTime = CFAbsoluteTimeGetCurrent();
        accelX = accelY = 0;
		
		srand(time(nil));		//rand()の種を初期化します
		
    }
	NSLog(@"<---initWithCoder");
    return self;
}

- (void)drawView:(id)sender {
	NSLog(@"--->drawView");   
    glViewport(0, 0, backingWidth, backingHeight);
    if (wrangler) [wrangler render];
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];

    CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval interval = MIN(currentTime - frameStartTime, 3.0 / 60);
#ifdef FREE_GRAVITY 	//==={=========
    if (wrangler) [wrangler stepTime:interval gravity:b2Vec2(accelX, accelY)];
#else 	//=============
    if (wrangler) [wrangler stepTime:interval gravity:b2Vec2(0, 0.5)];
#endif 	//===}=========
    frameStartTime = currentTime;
    //NSLog(@"accelX %f, accelY %f",accelX, accelY);
	NSLog(@"<---drawView");
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	int color = rand();	
	color=color % 7;
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        float scale = 10.0f / backingWidth;
        [wrangler touchAt:CGPointMake(point.x * scale, point.y * scale):color];
    }
}

- (void)accelerometer:(UIAccelerometer*)accelerometer
        didAccelerate:(UIAcceleration*)acceleration {
	LOG_METHOD; 	//....
    accelX = acceleration.x;
    accelY = -acceleration.y;
	LOG_METHOD_R;	//....
}

- (void)layoutSubviews {
	NSLog(@"--->layoutSubviews");
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES
                    fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                    GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                    GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"Failed to make complete framebuffer object %x",
              glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    } else {
        if (!wrangler) {
            float aspect = (float)backingWidth / backingHeight;
            wrangler = [[Wrangler alloc] initWithSize:CGSizeMake(10, 10.0f / aspect)];
        }
		
		
		int xn,yn,xd,yd,xs,ys;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// iPad
			xn=5, yn=7;
			xd=150,yd=90;
			xs=50,ys=50;
		}
		else {
			// iPhone
			xn=5, yn=8;
			xd=60,yd=50;
			xs=30,ys=20;
		}
		
		
		CGPoint point;
		point.x=xs;
		point.y=ys;
        float scale = 10.0f / backingWidth;
		for (int y=0; y<yn; y++) {
			for (int i=0; i<xn; i++) {
				int color = rand();	
				color=color % 7;
				[wrangler touchAt:CGPointMake(point.x * scale, point.y * scale):color];
				point.x+=xd;
			}
			point.x=xs;
			point.y+=yd;
		}
        [self drawView:nil];
    }
	NSLog(@"<---layoutSubviews");
}

- (void)startAnimation {
	NSLog(@"--->startAnimation");   
    if (!animating) {
		NSLog(@"....if (!animating)");
        displayLink = [NSClassFromString(@"CADisplayLink")
                       displayLinkWithTarget:self selector:@selector(drawView:)];
        [displayLink setFrameInterval:1];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
        
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 15)];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
        
        frameStartTime = CFAbsoluteTimeGetCurrent();
        animating = TRUE;
    }
	NSLog(@"<---startAnimation");   
}

- (void)stopAnimation {
    if (animating) {
        [displayLink invalidate];
        displayLink = nil;
        animating = FALSE;
    }
}

- (void)dealloc {
    if (defaultFramebuffer) {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }

    if (colorRenderbuffer) {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }

    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }

    [context release];
    context = nil;

    [wrangler release];
    wrangler = nil;
    
    [super dealloc];
}

@end
