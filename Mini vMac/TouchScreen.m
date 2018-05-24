//
//  TouchScreen.m
//  Mini vMac for iOS
//
//  Created by Jesús A. Álvarez on 18/04/2016.
//  Copyright © 2016-2018 namedfork. All rights reserved.
//

#import "TouchScreen.h"
#import "AppDelegate.h"
#import "ScreenView.h"
#import "PencilDetector.h"

@implementation TouchScreen
{
    // when using absolute mouse mode, button events are processed before the position is updated
    NSTimeInterval mouseButtonDelay;
    CGPoint previousTouchLoc;
    NSTimeInterval previousTouchTime;
    NSTimeInterval touchTimeThreshold;
    CGFloat touchDistanceThreshold;
    NSMutableSet *currentTouches;
    Boolean havePencil;
    Boolean pencilExclusive;
}

- (Boolean) detectPencil
{
	CBCentralManager* m_centralManager = [[CBCentralManager alloc] initWithDelegate:nil
								queue:nil
							      options:nil];
	
	// Device information UUID
	NSArray* myArray = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"180A"]];
	
	NSArray* peripherals =
	[m_centralManager retrieveConnectedPeripheralsWithServices:myArray];
	for (CBPeripheral* peripheral in peripherals)
	{
		if ([[peripheral name] isEqualToString:@"Apple Pencil"])
		{
			// The Apple pencil is connected
			return YES;
		}
	}
	return NO;
	
}

- (instancetype)initWithFrame:(CGRect)frame {
	
	
if ((self = [super initWithFrame:frame])) {
    mouseButtonDelay = 0.05;
    touchTimeThreshold = 0.25;
    touchDistanceThreshold = 16;
    currentTouches = [NSMutableSet setWithCapacity:4];
    
    if ([self detectPencil] )
	{
        havePencil = true;
        NSLog(@"We have a pencil!");
        touchTimeThreshold = 0.05;
        touchDistanceThreshold = 2;
        
        //  currently this just blindly sets pencil to exclusive if we have one,
        //  which subsequently ignores TouchScreen touches that are not the pencil.
        //  what would be much better would be a settings toggle that appeared
        //  if the pencil is detected, but I have very little skill hacking up
        //  storyboards and was unable to correctly add this.
        pencilExclusive = true;
	}else{
        havePencil = false;
        NSLog(@"No pencil!");
	}

    }
    return self;
}

- (Point)mouseLocForCGPoint:(CGPoint)point {
    Point mouseLoc;
    CGRect screenBounds = [ScreenView sharedScreenView].screenBounds;
    CGSize screenSize = [ScreenView sharedScreenView].screenSize;
    mouseLoc.h = (point.x - screenBounds.origin.x) * (screenSize.width/screenBounds.size.width);
    mouseLoc.v = (point.y - screenBounds.origin.y) * (screenSize.height/screenBounds.size.height);
    return mouseLoc;
}

- (void)mouseDown {
    [[AppDelegate sharedEmulator] setMouseButton:YES];
}

- (void)mouseUp {
    [[AppDelegate sharedEmulator] setMouseButton:NO];
}

- (CGPoint)effectiveTouchPointForEvent:(UIEvent *)event {
    CGPoint touchLoc = [[event touchesForView:self].anyObject locationInView:self];
    if (event.timestamp - previousTouchTime < touchTimeThreshold &&
        fabs(previousTouchLoc.x - touchLoc.x) < touchDistanceThreshold &&
        fabs(previousTouchLoc.y - touchLoc.y) < touchDistanceThreshold)
        return previousTouchLoc;
    previousTouchLoc = touchLoc;
    previousTouchTime = event.timestamp;
    return touchLoc;
}


- (Boolean)checkPencilExclusitivity:(NSSet *)touches withEvent:(UIEvent*) event
{
    if ( !pencilExclusive )
    {
        return YES;
    }
    
    for (UITouch* touch in touches) {
        if (touch.type == UITouchTypeStylus ){
            return YES;
        }
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [currentTouches unionSet:touches];
    if (![AppDelegate sharedEmulator].running) return;
    
    if (![self checkPencilExclusitivity:touches withEvent:event])
        return;
    
    CGPoint touchLoc = [self effectiveTouchPointForEvent:event];
    Point mouseLoc = [self mouseLocForCGPoint:touchLoc];
    
    [[AppDelegate sharedEmulator] setMouseX:mouseLoc.h Y:mouseLoc.v];
    [self performSelector:@selector(mouseDown) withObject:nil afterDelay:mouseButtonDelay];
    previousTouchLoc = touchLoc;
    previousTouchTime = event.timestamp;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![AppDelegate sharedEmulator].running) return;
   
    if (![self checkPencilExclusitivity:touches withEvent:event])
        return;
    
    CGPoint touchLoc = [self effectiveTouchPointForEvent:event];
    Point mouseLoc = [self mouseLocForCGPoint:touchLoc];
    [[AppDelegate sharedEmulator] setMouseX:mouseLoc.h Y:mouseLoc.v];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [currentTouches minusSet:touches];
    if (![AppDelegate sharedEmulator].running) return;
    if (currentTouches.count > 0) return;

    if (![self checkPencilExclusitivity:touches withEvent:event])
        return;
    
    CGPoint touchLoc = [self effectiveTouchPointForEvent:event];
    Point mouseLoc = [self mouseLocForCGPoint:touchLoc];
    [[AppDelegate sharedEmulator] setMouseX:mouseLoc.h Y:mouseLoc.v];
    [self performSelector:@selector(mouseUp) withObject:nil afterDelay:mouseButtonDelay];
    previousTouchLoc = touchLoc;
    previousTouchTime = event.timestamp;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

@end
