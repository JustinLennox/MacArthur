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
@property (strong, nonatomic) Firebase *coordinateRef;
@property (strong, nonatomic) Firebase *usersWithPropertiesRef;
@property (strong, nonatomic) Firebase *turnRef;
@property (nonatomic) BOOL startingPlayer;
@property (nonatomic) BOOL gameStarted;
@property (nonatomic) BOOL connecting;
@property (nonatomic) BOOL canInteract;
@property (nonatomic) BOOL deviceTurn;
@property (nonatomic) int deviceNumber;
@property (nonatomic) int turnNumber;
@property (nonatomic) int turnTimerCounter;
@property (strong, nonatomic) NSString *roomCodeString;
@property (strong, nonatomic) NSMutableArray *gridArray;
@property (strong, nonatomic) NSMutableArray *usernameArray;
@property (strong, nonatomic) NSMutableArray *playerArray;
@property (strong, nonatomic) NSMutableDictionary *usersWithPropertiesDictionary;
@property (strong, nonatomic) NSMutableDictionary *portalDictionary;
@property (strong, nonatomic) NSMutableDictionary *coordinateDictionary;
@property (strong, nonatomic) UILabel *roomCodeLabel;
@property (strong, nonatomic) NSTimer *turnTimer;

@end
