//
//  ViewController.m
//  hexagonest
//
//  Created by PixelOmer on 4.03.2020.
//  Copyright © 2020 PixelOmer. All rights reserved.
//

#import "ViewController.h"
#import "GameView.h"
#import <objc/runtime.h>

@interface UIKeyCommand(Private)
+ (id)keyCommandWithInput:(id)arg1 modifierFlags:(long long)arg2 action:(SEL)arg3 upAction:(SEL)arg4;
@end

@implementation ViewController

static NSArray *level1Colors;

+ (void)initialize {
	if (self == [ViewController class]) {
		level1Colors = @[
			[UIColor greenColor],
			[UIColor yellowColor],
			[UIColor redColor],
			[UIColor yellowColor],
			[UIColor greenColor],
			[UIColor cyanColor],
			[UIColor blueColor]
		];
	}
}

- (void)handleKeyUp:(UIKeyCommand *)sender {
	[_gameView keyUp:sender];
}

- (void)handleKeyDown:(UIKeyCommand *)sender {
	[_gameView keyDown:sender];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.edgesForExtendedLayout = UIRectEdgeNone;
	_leftArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags:0 action:@selector(handleKeyDown:) upAction:@selector(handleKeyUp:)];
	[self addKeyCommand:_leftArrow];
	_rightArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags:0 action:@selector(handleKeyDown:) upAction:@selector(handleKeyUp:)];
	[self addKeyCommand:_rightArrow];
	_gameView = [GameView new];
	_gameView.gameColor = level1Colors[0];
	__block uint8_t i = 255;
	void(^__block block)(void) = ^{
		if ((i != 255) && !self->_gameView.hyperMode) {
			[self->_gameView setGameColorAnimated:level1Colors[i] completionHandler:nil];
			i++;
			if (i == level1Colors.count) i = 0;
		}
		else i = 1;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
	};
	block();
	[self.view addSubview:_gameView];
	if (@available(iOS 6.0, *)) {
		_gameView.translatesAutoresizingMaskIntoConstraints = NO;
		UIView *base;
		if (@available(iOS 11.0, *)) base = (id)self.view.safeAreaLayoutGuide;
		else base = self.view;
		[_gameView.topAnchor constraintEqualToAnchor:base.topAnchor].active =
		[_gameView.bottomAnchor constraintEqualToAnchor:base.bottomAnchor].active =
		[_gameView.leftAnchor constraintEqualToAnchor:base.leftAnchor].active =
		[_gameView.rightAnchor constraintEqualToAnchor:base.rightAnchor].active = YES;
	}
	else {
		_gameView.frame = [UIScreen.mainScreen bounds];
	}
	// Do any additional setup after loading the view.
}


@end
