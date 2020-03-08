//
//  ViewController.h
//  hexagonest
//
//  Created by PixelOmer on 4.03.2020.
//  Copyright © 2020 PixelOmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameView;

@interface ViewController : UIViewController {
	UIKeyCommand *_leftArrow;
	UIKeyCommand *_rightArrow;
}
@property (nonatomic, readonly, strong) GameView *gameView;
@end

