//
//  GameViewController.h
//  MacArthur
//

//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Firebase/Firebase.h>

@interface GameViewController : UIViewController

@property (strong, nonatomic) Firebase *myRootRef;
@property (strong, nonatomic) Firebase *roomRef;
@property (nonatomic) BOOL startingPlayer;

@end
