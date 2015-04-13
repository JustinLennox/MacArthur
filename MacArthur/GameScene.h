//
//  GameScene.h
//  MacArthur
//

//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Firebase/Firebase.h>
#import "Square.h"

@interface GameScene : SKScene

@property (strong, nonatomic) Firebase *myRootRef;
@property (strong, nonatomic) Firebase *roomRef;
@property (nonatomic) BOOL startingPlayer;
@property (nonatomic) BOOL gridMade;
@property (nonatomic) BOOL canInteract;

@end
