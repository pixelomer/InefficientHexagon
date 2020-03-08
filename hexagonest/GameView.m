//
//  GameView.m
//  hexagonest
//
//  Created by PixelOmer on 6.03.2020.
//  Copyright © 2020 PixelOmer. All rights reserved.
//

/*-------------[WARNING]--------------*
 | This code relies on UIBezierPaths  |
 | to render the entire game. Proceed |
 | with caution.                      |
 *------------------------------------*/


#import "GameView.h"
#import "GameObstacle.h"
#import "FakeTouch.h"

#ifndef DEG_TO_RAD
#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)
#endif
#define FPS 60

@implementation GameView

const CGFloat initialHexagonBaseRadius = 32.5;

- (void)setGameColor:(UIColor *)gameColor {
	_gameColor = gameColor;
	cachedDarkColor = cachedLightColor = nil;
}

- (void)rotatePath:(UIBezierPath *)path withCenter:(CGPoint)center degrees:(CGFloat)degrees {
	CGFloat radians = DEG_TO_RAD(degrees);
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformTranslate(transform, center.x, center.y);
	transform = CGAffineTransformRotate(transform, radians);
	transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
	[path applyTransform:transform];
}

- (void)fillPath:(UIBezierPath *)originalPath withCenter:(CGPoint)center {
	UIBezierPath *path = originalPath.copy;
	CGFloat radians = DEG_TO_RAD(_degrees);
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformTranslate(transform, center.x, center.y);
	transform = CGAffineTransformRotate(transform, radians);
	transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
	[path applyTransform:transform];
	[path fill];
}

- (void)setTriangleChangeValue {
	triangleDegreeChange = 11.5;
	if ([_touches.lastObject locationInView:self].x <= self.center.x) triangleDegreeChange *= -1.0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[_touches addObjectsFromArray:touches.allObjects];
	[self setTriangleChangeValue];
}

- (void)keyDown:(UIKeyCommand *)keyCommand {
	FakeTouch *object = [keyCommand.input isEqualToString:UIKeyInputLeftArrow] ? [FakeTouch leftTouch] : [FakeTouch rightTouch];
	if (![_touches containsObject:(id)object]) [_touches addObject:(id)object];
	[self setTriangleChangeValue];
}

- (void)keyUp:(UIKeyCommand *)keyCommand {
	FakeTouch *object = [keyCommand.input isEqualToString:UIKeyInputLeftArrow] ? [FakeTouch leftTouch] : [FakeTouch rightTouch];
	[_touches removeObject:(id)object];
	[self setTriangleChangeValue];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	[self setTriangleChangeValue];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	[_touches removeObjectsInArray:touches.allObjects];
	[self setTriangleChangeValue];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	[_touches removeObjectsInArray:touches.allObjects];
	[self setTriangleChangeValue];
}

- (void)setGameColorAnimated:(UIColor *)gameColor completionHandler:(void(^)(GameView *))completionHandler {
	targetGameColor = gameColor;
	if (gameColorAnimationCompletionHandler) gameColorAnimationCompletionHandler(self);
	gameColorAnimationCompletionHandler = completionHandler;
}

- (instancetype)init {
	return [self initWithFrame:CGRectZero];
}

- (void)refreshFPS:(id)sender {
	NSLog(@"%lu FPS", (unsigned long)FPSCounter);
	FPSCounter = 0;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		hexagonBaseRadius = initialHexagonBaseRadius;
		_rotationSpeed = 0.9;
		FPSTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshFPS:) userInfo:nil repeats:YES];
		_touches = [NSMutableArray new];
		self.multipleTouchEnabled = YES;
		_framesBeforeRotation = 300;
		NSError *error = nil;
		_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"music" withExtension:@"mp3"] error:&error];
		_audioPlayer.meteringEnabled = YES;
		_audioPlayer.numberOfLoops = -1;
		_rotates = YES;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	if (!obstacles) {
		// Reset
		FPSCounter2 = 0;
		_rotationSpeed = 0.81;
		_obstacleSpeed = 0.81;
		_obstaclesMove = YES;
		_hyperMode = NO;
		obstacleGenerationFrameCounter = 1;
		reverseRotationFrameCounter = _framesBeforeRotation;
		_audioPlayer.volume = 1.0;
		[_audioPlayer play];
		startTime = [NSDate date].timeIntervalSince1970;
		obstacles = [NSMutableArray new];
	}
	
	colorSwitchFrameCounter++;
	if (_obstaclesMove) obstacleGenerationFrameCounter--;
	if (colorSwitchFrameCounter >= 75) {
		switchColors = !switchColors;
		colorSwitchFrameCounter = 0;
	}
	if ((_framesBeforeRotation > 0) && (reverseRotationFrameCounter >= 1)) {
		reverseRotationFrameCounter--;
		if (reverseRotationFrameCounter == 0) {
			reverseRotationFrameCounter = _framesBeforeRotation;
			_rotationSpeed *= -1;
			if (_hyperMode && (fabs(_rotationSpeed) <= 0.85)) {
				_rotationSpeed = 1.0;
				_obstacleSpeed = 1.0;
			}
		}
	}
	if (obstacleGenerationFrameCounter == 0) {
		NSUInteger algorithm;
		if (algorithmChangeCounter) {
			algorithmChangeCounter--;
			algorithm = previousGenerationAlgorithm;
		}
		else {
			algorithm = arc4random_uniform(10);
		}
		if (algorithm == 6) {
			if (previousGenerationAlgorithm != 6) algorithmChangeCounter = 5;
			for (uint8_t i=0; i<6; i++) {
				if ((i%2) ^ (algorithmChangeCounter%2)) {
					GameObstacle *obstacle = [GameObstacle new];
					obstacle.radius = 700.0;
					obstacle.index = i;
					[obstacles addObject:obstacle];
				}
			}
			obstacleGenerationFrameCounter = 15 + 15*!algorithmChangeCounter;
		}
		else {
			NSUInteger index = arc4random_uniform(6);
			for (uint8_t i=0; i<5; i++) {
				GameObstacle *obstacle = [GameObstacle new];
				obstacle.index = index+i;
				obstacle.radius = 700.0;
				[obstacles addObject:obstacle];
			}
			obstacleGenerationFrameCounter = 35 - (_obstacleSpeed / 0.1);
		}
		previousGenerationAlgorithm = algorithm;
	}
	if (whiteFlashFrameCounter >= 1) {
		whiteFlashFrameCounter--;
		if (whiteFlashFrameCounter == 1) {
			self.gameColor = whiteFlashOldGameColor;
			reverseRotationFrameCounter = 0;
			targetGameColor = whiteFlashOldTargetColor;
			zoomFrameCounter = 90;
		}
	}
	if (zoomFrameCounter >= 1) {
		zoomFrameCounter--;
		if (zoomFrameCounter == 0) {
			self.userInteractionEnabled = YES;
			zoomBackFrameCounter = 60;
		}
		else if (zoomFrameCounter <= 60) {
			for (GameObstacle *obstacle in obstacles) {
				obstacle.radius += sqrt(zoomFrameCounter) * 2;
			}
			hexagonBaseRadius += sqrt(zoomFrameCounter/2.0) * 0.7;
		}
	}
	if (zoomBackFrameCounter >= 1) {
		zoomBackFrameCounter--;
		if (zoomBackFrameCounter == 0) {
			[_audioPlayer prepareToPlay];
			switch (arc4random_uniform(3)) {
				case 0: _audioPlayer.currentTime = 30.35; break;
				case 1: _audioPlayer.currentTime = 0; break;
				case 2: _audioPlayer.currentTime = 44.3; break;
			}
			obstacles = nil;
			hexagonBaseRadius = initialHexagonBaseRadius;
		}
		hexagonBaseRadius -= sqrt((60-zoomBackFrameCounter)/2.0) * 0.7;
	}
	
	if (_touches.count && self.userInteractionEnabled) {
		int8_t playerIndex = ((int8_t)((_playerTriangleDegrees+30.0)/60.0) + 4) % 6;
		_playerTriangleDegrees += triangleDegreeChange;
		int8_t newPlayerIndex = ((int8_t)((_playerTriangleDegrees+30.0)/60.0) + 4) % 6;
		if ((newPlayerIndex != playerIndex) && isNearObstacle) _playerTriangleDegrees -= triangleDegreeChange;
		else if (_playerTriangleDegrees >= 360.0) while (_playerTriangleDegrees >= 360.0) _playerTriangleDegrees -= 360.0;
		else while (_playerTriangleDegrees <= 0) _playerTriangleDegrees += 360.0;
	}
	
	if (targetGameColor) {
		CGFloat old[4];
		CGFloat new[4];
		[targetGameColor getHue:&old[0] saturation:&old[1] brightness:&old[2] alpha:&old[3]];
		[self.gameColor getHue:&new[0] saturation:&new[1] brightness:&new[2] alpha:&new[3]];
		BOOL didChange = NO;
		for (uint8_t i=0; i<4; i++) {
			new[i] *= 255.0;
			old[i] *= 255.0;
			if (fabs(old[i] - new[i]) > 3) {
				didChange = YES;
				if (new[i] > old[i]) new[i] -= 2;
				else new[i] += 2;
			}
			new[i] /= 255.0;
		}
		self.gameColor = [UIColor colorWithHue:new[0] saturation:new[1] brightness:new[2] alpha:new[3]];
		if (!didChange) {
			targetGameColor = nil;
			if (gameColorAnimationCompletionHandler) gameColorAnimationCompletionHandler(self);
			gameColorAnimationCompletionHandler = nil;
		}
	}
	
	_degrees += _rotationSpeed * 3.0;
	
	CGPoint center = self.center;
	
	UIColor *veryLightColor = self.gameColor;
	UIColor *lightColor = cachedLightColor;
	UIColor *darkColor = cachedDarkColor;
	if (!lightColor || !darkColor) {
		CGFloat h,s,b,a;
		[self.gameColor getHue:&h saturation:&s brightness:&b alpha:&a];
		cachedLightColor = lightColor = [UIColor colorWithHue:h saturation:s brightness:b-0.5 alpha:a];
		veryLightColor = self.gameColor;
		cachedDarkColor = darkColor = [UIColor colorWithHue:h saturation:s brightness:b-0.6 alpha:a];
	}
	
	#define fill(path) [self fillPath:path withCenter:center]
	
	// Background
	@autoreleasepool {
		const CGFloat radius = 750.0;
		UIColor * const colorA = switchColors ? lightColor : darkColor;
		UIColor * const colorB = !switchColors ? lightColor : darkColor;
		for (int degreeMultiplier=0; degreeMultiplier<6; degreeMultiplier++) {
			UIBezierPath *triangle = [UIBezierPath bezierPath];
			[triangle moveToPoint:center];
			[triangle addLineToPoint:CGPointMake(
				center.x + cos(DEG_TO_RAD(degreeMultiplier * 60.0)) * radius,
				center.y + sin(DEG_TO_RAD(degreeMultiplier * 60.0)) * radius
			)];
			[triangle addLineToPoint:CGPointMake(
				center.x + cos(DEG_TO_RAD((degreeMultiplier+1) * 60.0)) * radius,
				center.y + sin(DEG_TO_RAD((degreeMultiplier+1) * 60.0)) * radius
			)];
			[triangle addLineToPoint:center];
			[triangle closePath];
			if (degreeMultiplier % 2) [colorA setFill];
			else [colorB setFill];
			fill(triangle);
		}
	}
	
	// Hexagon
	[_audioPlayer updateMeters];
	UIBezierPath *innerHexagon;
	UIColor *innerHexagonColor;
	@autoreleasepool {
		// Outer hexagon configuration
		CGFloat radius = hexagonBaseRadius;
		UIColor *color = veryLightColor;
		
		int j;
		CGFloat change = 0.0;
		for (j=0; j<_audioPlayer.numberOfChannels; j++) {
			change += fabs([_audioPlayer averagePowerForChannel:j]);
		}
		change /= _audioPlayer.numberOfChannels;
		change *= 1.3;
		if (change >= 15.0) change = 15.0;
		radius += change;
		
		for (j=0; j<2; j++) {
			UIBezierPath *hexagon = [UIBezierPath bezierPath];
			for (int i=0; i<6; i++) {
				CGPoint point = CGPointMake(
					center.x + cos(DEG_TO_RAD(i * 60.0)) * radius,
					center.y + sin(DEG_TO_RAD(i * 60.0)) * radius
				);
				if (i) [hexagon addLineToPoint:point];
				else [hexagon moveToPoint:point];
			}
			[hexagon closePath];
			[color setFill];
			fill(hexagon);
			
			// Inner hexagon configuration
			radius -= 6.0;
			innerHexagonColor = color = darkColor;
			
			// Store the inner hexagon for later
			innerHexagon = hexagon;
		}
	}
	
	// Triangle
	UIBezierPath *triangle;
	@autoreleasepool {
		triangle = [UIBezierPath bezierPath];
		const CGFloat radius = 60.0;
		[triangle moveToPoint:CGPointMake(center.x, center.y-radius-4.0)];
		[triangle addLineToPoint:CGPointMake(center.x+7.5, center.y-radius+7.5)];
		[triangle addLineToPoint:CGPointMake(center.x-7.5, center.y-radius+7.5)];
		[triangle addLineToPoint:CGPointMake(center.x, center.y-radius-4.0)];
		[triangle closePath];
		[self rotatePath:triangle withCenter:center degrees:_playerTriangleDegrees];
		[veryLightColor setFill];
		fill(triangle);
	}
	
	// Obstacles
	BOOL obstaclesMove = _obstaclesMove;
	isNearObstacle = NO;
	for (NSInteger i=obstacles.count-1; i>=0; i--) {
		@autoreleasepool {
			GameObstacle *obstacle = obstacles[i];
			UIBezierPath *path = [UIBezierPath bezierPath];
			double r1 = DEG_TO_RAD(obstacle.index * 60.0);
			double r2 = DEG_TO_RAD((obstacle.index + 1) * 60.0);
			double cosines[2] = { cos(r1), cos(r2) };
			double sines[2] = { sin(r1), sin(r2) };
			if (obstaclesMove) obstacle.radius -= _obstacleSpeed * 7.5;
			[path moveToPoint:CGPointMake(
				center.x + cosines[0] * obstacle.radius,
				center.y + sines[0] * obstacle.radius
			)];
			[path addLineToPoint:CGPointMake(
				center.x + cosines[1] * obstacle.radius,
				center.y + sines[1] * obstacle.radius
			)];
			[path addLineToPoint:CGPointMake(
				center.x + cosines[1] * (obstacle.radius-22.5),
				center.y + sines[1] * (obstacle.radius-22.5)
			)];
			[path addLineToPoint:CGPointMake(
				center.x + cosines[0] * (obstacle.radius-22.5),
				center.y + sines[0] * (obstacle.radius-22.5)
			)];
			[path addLineToPoint:CGPointMake(
				center.x + cosines[0] * obstacle.radius,
				center.y + sines[0] * obstacle.radius
			)];
			[path addLineToPoint:center];
			[path closePath];
			[veryLightColor setFill];
			
			// Detect collision
			int8_t playerIndex = ((int8_t)((_playerTriangleDegrees+30.0)/60.0) + 4) % 6;
			if (fabs(obstacle.radius - 80.0) < 12.0) {
				// Player is near obstacle
				isNearObstacle = YES;
				if ((obstacle.index == playerIndex) && _obstaclesMove) {
					// Obstacle is in front of player
					if (@available(iOS 10.0, *)) {
						[_audioPlayer setVolume:0.0 fadeDuration:1.0];
					} else {
						[_audioPlayer setVolume:0.0];
					}
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC), dispatch_get_main_queue(), ^{
						[self->_audioPlayer stop];
					});
					_obstaclesMove = NO;
					self.backgroundColor = [UIColor whiteColor];
					whiteFlashOldTargetColor = targetGameColor;
					targetGameColor = nil;
					whiteFlashOldGameColor = self.gameColor;
					self.gameColor = [UIColor clearColor];
					whiteFlashFrameCounter = 5;
					self->_rotationSpeed = 0.5;
					self.userInteractionEnabled = NO;
				}
			}
			
			fill(path);
			if (obstacle.radius <= 10.0) [obstacles removeObjectAtIndex:i];
		}
	}
	
	// Redraw the inner hexagon
	[innerHexagonColor setFill];
	fill(innerHexagon);
	
	// Draw score
	@autoreleasepool {
		NSString * const fontName = @"Bump it up fixed 0";
		NSAttributedString *text;
		NSTimeInterval currentTime = startTime + ((NSTimeInterval)FPSCounter2 * 0.0166);
		NSTimeInterval subsecond = (currentTime - startTime);
		while (subsecond >= 1.0) subsecond -= 1.0;
		subsecond /= 0.0166;
		int seconds = ((int)currentTime - (int)startTime);
		if (_obstaclesMove && (FPSCounter2 % 2)) {
			NSMutableAttributedString *newString = [NSMutableAttributedString new];
			[newString appendAttributedString:[[NSAttributedString alloc]
				initWithString:[NSString stringWithFormat:@"%d", seconds]
				attributes:@{
					NSFontAttributeName : [UIFont fontWithName:fontName size:30.0],
					NSForegroundColorAttributeName : [UIColor whiteColor]
				}
			]];
			[newString appendAttributedString:[[NSAttributedString alloc]
				initWithString:[NSString stringWithFormat:@":%02d", (int)subsecond]
				attributes:@{
					NSFontAttributeName : [UIFont fontWithName:fontName size:17.5],
					NSForegroundColorAttributeName : [UIColor whiteColor]
				}
			]];
			if (!_hyperMode && (seconds >= 60)) {
				// Time to get serious
				_hyperMode = YES;
				[self setGameColorAnimated:[UIColor whiteColor] completionHandler:nil];
			}
			lastScoreString = text = [newString copy];
		}
		else {
			text = lastScoreString;
		}
		CGSize size = [text size];
		CGRect rect = CGRectMake(self.frame.size.width-size.width-20, 0, size.width+20, size.height+20);
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
		[UIColor.blackColor setFill];
		[path fill];
		rect.origin.x += 10.0;
		rect.origin.y += 10.0;
		[text drawInRect:rect];
		[UIColor.blackColor setFill];
		path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(rect.origin.x - 30.0, 0)];
		[path addLineToPoint:CGPointMake(rect.origin.x - 9.9, 0)];
		[path addLineToPoint:CGPointMake(rect.origin.x - 9.9, rect.size.height)];
		[path addLineToPoint:CGPointMake(rect.origin.x - 30.0, 0)];
		[path closePath];
		[path fill];
	}
	
	if (_degrees >= 360.0) while (_degrees >= 360.0) _degrees -= 360.0;
	else while (_degrees <= 0) _degrees += 360.0;
	
	FPSCounter++;
	FPSCounter2++;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1.0/(double)FPS) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self setNeedsDisplay];
	});
}

@end
