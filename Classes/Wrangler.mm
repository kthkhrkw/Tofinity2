#include "b2MouseJoint.h"
#include "Box2D.h"
#import "Wrangler.h"
#import "Tofu.h"
#import <OpenGLES/ES1/gl.h>

@implementation Wrangler

- (id)initWithSize:(CGSize)aSize {
	NSLog(@"--->initWithSize:Wrangler");  
	LOG_METHOD
    if (self = [super init]) {
        size = aSize;
        world = new b2World(b2Vec2(0, 0), false);

        b2BodyDef bodyDef;
        bodyDef.type = b2_staticBody;
        bodyDef.position.Set(0, 0);
        b2Body* body = world->CreateBody(&bodyDef);

        float wext = size.width / 2;
        float hext = size.height / 2;
        b2PolygonShape shapes[4];
        shapes[0].SetAsBox(wext, 1, b2Vec2(wext, -1), 0);
        shapes[1].SetAsBox(wext, 1, b2Vec2(wext, size.height + 1), 0);
        shapes[2].SetAsBox(1, hext, b2Vec2(-1, hext), 0);
        shapes[3].SetAsBox(1, hext, b2Vec2(size.width + 1, hext), 0);
        
        for (int i = 0; i < 4; ++i) {
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &shapes[i];
            body->CreateFixture(&fixtureDef);
        }
    }
	NSLog(@"<---initWithSize:Wrangler");
    return self;
}

class TouchQueryCallback : public b2QueryCallback {
public:
    b2Body* detectedBody;
    TouchQueryCallback() {
        detectedBody = NULL;
    }
    bool ReportFixture(b2Fixture* fixture) {
        detectedBody = fixture->GetBody();
        return false;
    }
};

- (void)touchAt:(CGPoint)point:(int)aColor {
    b2AABB aabb;
    const float extent = 0.02f;
    aabb.lowerBound.Set(point.x - extent, point.y - extent);
    aabb.upperBound.Set(point.x + extent, point.y + extent);

    TouchQueryCallback callback;
    world->QueryAABB(&callback, aabb);
#if 01 //==={=====================
    if (callback.detectedBody) {
        id userData = (id)callback.detectedBody->GetUserData();
        if (userData && [userData isMemberOfClass:[Tofu class]]) {
            [userData release];
            world->DestroyBody(callback.detectedBody);
            return;
        }
    }
	
    [[Tofu alloc] initWithWorld:world
                           size:CGSizeMake(0.8f, 0.5f)
                       position:b2Vec2(point.x, point.y)
							int:(int)aColor];
#else //=====================
    if (callback.detectedBody) {
        id userData = (id)callback.detectedBody->GetUserData();
        if (userData && [userData isMemberOfClass:[Tofu class]]) {
            //[userData release];
			// world->DestroyBody(callback.detectedBody);
           	b2Body* body = callback.detectedBody;
			
			if (body)
			{
				b2MouseJointDef md;
				md.body1 = world->GetGroundBody();
				md.body2 = body;
				md.target = p;
#ifdef TARGET_FLOAT32_IS_FIXED
				md.maxForce = (body->GetMass() < 16.0)?
				(1000.0f * body->GetMass()) : float32(16000.0);
#else
				md.maxForce = 1000.0f * body->GetMass();
#endif
				m_mouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
				body->WakeUp();
			}
			
            return;
        }
    }
	
#endif //===}====================
	
}

- (void)stepTime:(float)time gravity:(b2Vec2)accelVector {
	NSLog(@"--->stepTime");   
    accelVector *= 40.0f;
    world->SetGravity(accelVector);
    world->Step(time, 6, 2);
    world->ClearForces();
	NSLog(@"<---stepTime");
}

- (void)render {
	NSLog(@"--->render");   
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0, size.width, size.height, 0, 0, 1);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glClearColor(0.95f, 0.95f, 0.95f, 1);
    glClear(GL_COLOR_BUFFER_BIT);

    glLineWidth(3.0f);
    
    b2Body *body = world->GetBodyList();
    while (body != nil) {
        id userData = (id)body->GetUserData();
        if (userData && [userData isMemberOfClass:[Tofu class]]) {
            [(Tofu*)userData draw];
        }
        body = body->GetNext();
    }
	NSLog(@"<---render");
}

- (void)dealloc {
    b2Body *body = world->GetBodyList();
    while (body != nil) {
        id userData = (id)body->GetUserData();
        if (userData && [userData isMemberOfClass:[Tofu class]]) {
            [userData release];
        }
        body = body->GetNext();
    }
    
    delete world;
    [super dealloc];
}

@end
