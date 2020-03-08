//
//  GameView.h
//  hexagonest
//
//  Created by PixelOmer on 6.03.2020.
//  Copyright © 2020 PixelOmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class GameObstacle;

@interface GameView : UIView {
	NSUInteger colorSwitchFrameCounter;
	NSUInteger obstacleGenerationFrameCounter;
	NSUInteger whiteFlashFrameCounter;
	NSUInteger zoomFrameCounter;
	NSUInteger reverseRotationFrameCounter;
	NSUInteger zoomBackFrameCounter;
	CGFloat hexagonBaseRadius;
	NSMutableArray<UITouch *> *_touches;
	BOOL switchColors;
	UIColor *whiteFlashOldGameColor;
	UIColor *whiteFlashOldTargetColor;
	BOOL isNearObstacle;
	UIColor * _Nullable targetGameColor;
	void(^_Nullable gameColorAnimationCompletionHandler)(GameView * _Nonnull);
	NSMutableArray<GameObstacle *> * _Nonnull obstacles;
	AVAudioPlayer * _Nonnull _audioPlayer;
	NSAttributedString *lastScoreString;
	CGFloat triangleDegreeChange;
	NSUInteger FPSCounter;
	NSUInteger FPSCounter2;
	NSTimer *FPSTimer;
	NSTimeInterval startTime;
	UIColor *cachedLightColor;
	UIColor *cachedDarkColor;
	NSUInteger previousGenerationAlgorithm;
	NSUInteger algorithmChangeCounter;
}
@property (nonatomic, readonly, assign) BOOL hyperMode;
@property (nonatomic, readonly, assign) CGFloat degrees;
@property (nonatomic, assign) CGFloat rotationSpeed;
@property (nonatomic, assign) CGFloat obstacleSpeed;
@property (nonatomic, assign) NSUInteger framesBeforeRotation;
@property (nonatomic, assign) BOOL rotates;
@property (nonatomic, assign) BOOL obstaclesMove;
@property (nonatomic, readonly, assign) CGFloat playerTriangleDegrees;
@property (nonatomic, copy) UIColor * _Nonnull gameColor;
- (void)setGameColorAnimated:(UIColor * _Nonnull)gameColor completionHandler:(void(^ _Nullable)(GameView * _Nonnull))completionHandler;
- (void)keyDown:(UIKeyCommand * _Nonnull)keyCommand;
- (void)keyUp:(UIKeyCommand * _Nonnull)keyCommand;
@end
