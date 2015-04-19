//
//  GameScene.m
//  MacArthur
//
//  Created by Justin Lennox on 4/13/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"

@implementation GameScene{
    int numberRows;
    int numberColumns;
    int portalNumber;
    int portalRow1;
    int portalColumn1;
}

static const int playerCategory =  0x1;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.coordinateRef = [self.roomRef childByAppendingPath:@"coordinateDictionary"];
    self.usersWithPropertiesRef = [self.roomRef childByAppendingPath:@"usersWithProperties"];
    self.turnRef = [self.roomRef childByAppendingPath:@"turnNumber"];
    
    self.gridArray = [[NSMutableArray alloc] init];
    self.usernameArray = [[NSMutableArray alloc] init];
    self.playerArray = [[NSMutableArray alloc] init];
    self.portalDictionary = [[NSDictionary alloc] init];
    self.usersAdded = NO;
    
    if(self.startingPlayer){
        UIButton *startGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [startGameButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame)-50, CGRectGetMidY(self.view.frame)-50, 100, 100)];
        [startGameButton setTitle:@"Start Game" forState:UIControlStateNormal];
        [startGameButton setBackgroundColor:[UIColor blueColor]];
        [startGameButton addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:startGameButton];
        
        self.roomCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) -25, CGRectGetMinY(self.view.frame), 100, 50)];
        self.roomCodeLabel.text = [NSString stringWithFormat:@"%@", self.roomCodeString];
        self.roomCodeLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:self.roomCodeLabel];
    }
    
    numberColumns = self.view.frame.size.width/100;
    numberRows = self.view.frame.size.height/100;
    float columnBuffer = (self.view.frame.size.width - 100.0f*numberColumns)/2.0000f;
    float rowBuffer = (self.view.frame.size.height - 100.0f*numberRows)/2.0000f;

    float previousX = 50 + columnBuffer;
    float previousY = 50 + rowBuffer;
    int y = 1;
    while(y <= numberRows){
        int x = 1;
        while(x <= numberColumns){
            
            Square *square = [[Square alloc] initWithImageNamed:@"Square.png"];
            square.size = CGSizeMake(100, 100);
            square.column = x;
            square.row = y;
            square.deviceNumber = self.deviceNumber;
            square.position = CGPointMake(previousX, previousY);
            previousX += 100;
            NSString *coordinateString = [NSString stringWithFormat:@"%d%d%d", self.deviceNumber, x, y];
            square.coordinateString = coordinateString;
            [self.coordinateRef updateChildValues:@{coordinateString:@"empty"}];
            [self addChild:square];
            [self.gridArray addObject:square];
            x++;
            
        }
        previousY += 100;
        previousX = 50 + columnBuffer;
        y++;
    }
    self.gameStarted = NO;
    
    
    [self.roomRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
         self.usernameArray = snapshot.value[@"usernames"];
         self.usersWithPropertiesDictionary = snapshot.value[@"usersWithProperties"];
         self.coordinateDictionary = snapshot.value[@"coordinateDictionary"];
         
         if([snapshot.value[@"gameStart"] isEqualToString:@"NO"]){
             self.gameStarted = NO;
             portalNumber = [snapshot.value[@"portalNumber"] intValue];
             if([snapshot.value[@"connecting"] isEqualToString:@"YES"]){
                 self.connecting = YES;
                 NSString *portalKey =[NSString stringWithFormat:@"portal%d", portalNumber];
                 portalRow1 = [[snapshot.value[portalKey] objectForKey:[NSString stringWithFormat:@"%@Row1",portalKey]] intValue];
                 portalColumn1 = [[snapshot.value[portalKey] objectForKey:[NSString stringWithFormat:@"%@Column1",portalKey]] intValue];

             }else{
                 self.connecting = NO;
             }

         }else{
             self.gameStarted = YES;
             self.portalDictionary = snapshot.value[@"portalDictionary"];
         }
         
         
     } ];
    
    [self.usersWithPropertiesRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {

         if(self.gameStarted)
         {
             if(!self.usersAdded)
             {
                 NSDictionary *tempUsersDict = snapshot.value;
                 for(id key in tempUsersDict){
                     NSLog(@"KEY:%@",key);
                     Player *player = [[Player alloc] initWithImageNamed:@"aragon2.png"];
                     player.size = CGSizeMake(50, 50);
                     player.position = CGPointMake(-50, -50);
                     player.name = key;
                     player.username = key;
                     for(int i = 0; i < self.usernameArray.count; i++){
                         if([[self.usernameArray objectAtIndex:i] isEqualToString:player.username]){
                             player.playerNumber = i;
                         }
                     }
                     SKLabelNode *usernameLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
                     usernameLabel.text = [NSString stringWithFormat:@"%@", player.username];
                     usernameLabel.position = CGPointMake(0, 10);
                     [self.playerArray addObject:player];
                     [player addChild:usernameLabel];
                     [self addChild:player];
                     [self.playerDictionary setObject:player forKey:player.username];

                 }
             }

             self.usersAdded = YES;
             
             for(Player *player in self.playerArray){
                 NSLog(@"player:%@", player);
                 NSLog(@"player username:%@", player.username);
                 NSDictionary *userWithProperty = snapshot.value[player.username];
                 NSString *coordinateString = [userWithProperty objectForKey:@"coordinates"];
                 for(Square *square in self.gridArray)
                  {
                       if([square.coordinateString isEqualToString:coordinateString])
                       {
                           NSLog(@"Player is on device");
                           player.position = CGPointMake(square.position.x, square.position.y);
                           player.row = square.row;
                           player.column = square.column;
                           player.deviceNumber = self.deviceNumber;
                           player.hidden = NO;
                           break;

                       }else{
                           NSLog(@"Player isn't on device");
                           player.hidden = YES;
                           player.position = CGPointMake(-100, -100);
                       }
                 }

             }
             
             NSLog(@"Dict:%@",self.playerDictionary);
//             int userNumber = 0;
//             for(NSString *username in self.usernameArray)
//             {
//                 NSDictionary *userWithProperty = snapshot.value[username];
//                 NSString *coordinateString = [userWithProperty objectForKey:@"coordinates"];
//                 for(Square *square in self.gridArray)
//                 {
//                      if([square.coordinateString isEqualToString:coordinateString])
//                      {
//                          Player *player = [[Player alloc] initWithImageNamed:@"aragon2.png"];
//                          player.size = CGSizeMake(50, 50);
//                          player.position = CGPointMake(square.position.x, square.position.y);
//                          player.row = square.row;
//                          player.column = square.column;
//                          player.deviceNumber = self.deviceNumber;
//                          player.playerNumber = userNumber;
//                          player.username = username;
//                          player.name = username;
//                          SKLabelNode *usernameLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
//                          usernameLabel.text = [NSString stringWithFormat:@"%@", username];
//                          usernameLabel.position = CGPointMake(0, 10);
//                          if(![self childNodeWithName:username]){
//                              [self addChild:player];
//                              [self.playerArray addObject:player];
//                              [player addChild:usernameLabel];
//
//                          }
//                      }
//                }
//                 userNumber++;
//             }
         }
         
         
     }];
    
    [self.turnRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
         self.turnNumber = [snapshot.value intValue];
         int userNumber = 0;
         for(NSString *username in self.usernameArray)
         {
             NSDictionary *userWithProperty = [self.usersWithPropertiesDictionary objectForKey:username];
             NSString *coordinateString = [userWithProperty objectForKey:@"coordinates"];
             for(Square *square in self.gridArray)
             {
                 if([square.coordinateString isEqualToString:coordinateString])
                 {
                     if([snapshot.value intValue] == userNumber)
                     {
                         [self prepTurn];
                     }
                 }
             }
             userNumber++;
         }

         
         
     }];
    
    
    
    [self.view bringSubviewToFront:self.roomCodeLabel];
    SKLabelNode *prepTurnLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    prepTurnLabel.position = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    prepTurnLabel.name = @"prepTurnLabel";
    prepTurnLabel.alpha = 0.0f;
    [self addChild:prepTurnLabel];
    
    SKLabelNode *goLabel = [SKLabelNode labelNodeWithText:@"GO!"];
    goLabel.position =CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    goLabel.name = @"goLabel";
    goLabel.alpha = 0.0f;
    [self addChild:goLabel];
    
    SKLabelNode *timeLabel = [SKLabelNode labelNodeWithText:@"TIME!"];
    timeLabel.position =CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    timeLabel.name = @"timeLabel";
    timeLabel.alpha = 0.0f;
    [self addChild:timeLabel];
}

-(void)prepTurn{
    NSTimer *prepTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(startTurn) userInfo:nil repeats:NO];
    
    SKLabelNode *timeLabel = (SKLabelNode *)[self childNodeWithName:@"timeLabel"];
    timeLabel.alpha = 0.0f;
    
    SKLabelNode *prepTurnLabel = (SKLabelNode *)[self childNodeWithName:@"prepTurnLabel"];
    [prepTurnLabel setText:[NSString stringWithFormat:@"%@ GET READY!", [self.usernameArray objectAtIndex:self.turnNumber]]];
    prepTurnLabel.alpha = 1.0f;
    
    self.currentPlayer = (Player *)[self childNodeWithName:[self.usernameArray objectAtIndex:self.turnNumber]];
    self.currentPlayer.color = [SKColor yellowColor];
    self.currentPlayer.blendMode = 0.7f;
    
}

-(void)startTurn{
    NSLog(@"Start Turn");
    self.canInteract = YES;
    
    NSTimer *turnCounter = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(secondTick) userInfo:nil repeats:YES];
    
    SKLabelNode *prepTurnLabel = (SKLabelNode *)[self childNodeWithName:@"prepTurnLabel"];
    prepTurnLabel.alpha = 0.0f;
    
    SKLabelNode *goLabel = (SKLabelNode *)[self childNodeWithName:@"goLabel"];
    goLabel.alpha = 1.0f;
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0f duration:0.5f];
    [goLabel runAction:fadeOut];
    
    self.turnTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(endTurn) userInfo:nil repeats:NO];
    self.turnTimerCounter = 15;
}

-(void)secondTick{
    self.turnTimerCounter--;

    
}

-(void)endTurn{
    NSLog(@"End Turn");
    
    self.canInteract = NO;
    [self.turnTimer invalidate];
    self.turnTimer = nil;
    if(self.turnNumber < self.usernameArray.count -1){
        self.turnNumber++;
    }else{
        self.turnNumber = 0;
    }
    
    [self.turnRef setValue:[NSNumber numberWithInt:self.turnNumber]];
    
    self.currentPlayer.color = [SKColor whiteColor];
    self.currentPlayer.blendMode = 0.0f;
    
    SKLabelNode *timeLabel = (SKLabelNode *)[self childNodeWithName:@"timeLabel"];
    timeLabel.alpha = 1.0f;
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0f duration:0.5f];
    [timeLabel runAction:fadeOut];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
       // NSLog(@"Node name:%@", n.name);
        if([[[n class] description] isEqualToString:@"Square"])
        {
            Square *square = (Square *)n;
            NSLog(@"Square Type:%@", square.type);
            if(self.canInteract){
                self.currentPlayer.position = square.position;
                self.currentPlayer.row = square.row;
                self.currentPlayer.column = square.column;
                if([square.type isEqualToString:@"portal"]){
                    [self activatePortal:square];
                }
            }
            if(!self.gameStarted && !self.connecting)
            {
                [self placePortalStart:square];
            }else if(!self.gameStarted && self.connecting)
            {
                [self placePortalEnd:square];
            }
        }

    }
}

-(void)placePortalStart : (Square *)square{
    
    square.type = @"portal";
    square.portalNumber = portalNumber;
    Square *portal = [Square spriteNodeWithImageNamed:@"totem2.png"];
    portal.type = @"portal";
    portal.portalNumber = portalNumber;
    NSLog(@"Portal Number:%d", portalNumber);
    portal.name = [NSString stringWithFormat:@"portal%d", portalNumber];
    [self colorSquare :square withPortal:portal];
    portal.position = square.position;
    portal.size = CGSizeMake(35, 35);
    portal.portalRow1 = square.row;
    portal.portalColumn1 = square.column;
    [self addChild:portal];
    NSString *portalString = [NSString stringWithFormat:@"portal%d", portalNumber];
    Firebase *portalRef = [self.roomRef childByAppendingPath:@"portalDictionary"];
    [portalRef updateChildValues:@{[NSString stringWithFormat:@"%@Device1",portalString]:[NSNumber numberWithInt:self.deviceNumber], [NSString stringWithFormat:@"%@Row1",portalString]:[NSNumber numberWithInt:portal.portalRow1], [NSString stringWithFormat:@"%@Column1",portalString]:[NSNumber numberWithInt:portal.portalColumn1]}];
    [self.roomRef updateChildValues:@{@"connecting":@"YES"}];

    
}

-(void)placePortalEnd : (Square *)square{
    
    square.type = @"portal";
    Square *portal = [Square spriteNodeWithImageNamed:@"totem2.png"];
    portal.type = @"portal";
    portal.portalNumber = portalNumber;
    NSLog(@"Portal Number:%d", portalNumber);
    portal.name = [NSString stringWithFormat:@"portal%d", portalNumber];
    [self colorSquare :square withPortal:portal];
    portal.position = square.position;
    portal.size = CGSizeMake(35, 35);
    portal.portalRow2 = square.row;
    portal.portalColumn2 = square.column;
    [self addChild:portal];
    NSString *portalString = [NSString stringWithFormat:@"portal%d", portalNumber];
    Firebase *portalRef = [self.roomRef childByAppendingPath:@"portalDictionary"];
    [portalRef updateChildValues:@{[NSString stringWithFormat:@"%@Device2",portalString]:[NSNumber numberWithInt:self.deviceNumber], [NSString stringWithFormat:@"%@Row2",portalString]:[NSNumber numberWithInt:portal.portalRow2], [NSString stringWithFormat:@"%@Column2",portalString]:[NSNumber numberWithInt:portal.portalColumn2]}];
    [self.roomRef updateChildValues:@{@"connecting":@"NO", @"portalNumber":[NSNumber numberWithInt:(portalNumber + 1)]}];

    
}

-(void)colorSquare : (Square *)square withPortal: (Square *)portal{
    
    switch (portal.portalNumber) {
        case 0:
            square.color = [SKColor redColor];
            break;
        case 1:
            square.color = [SKColor blueColor];
            break;
        case 2:
            square.color = [SKColor greenColor];
            break;
        case 3:
            square.color = [SKColor purpleColor];
            break;
        case 4:
            square.color = [SKColor grayColor];
            break;
        case 5:
            square.color = [SKColor blackColor];
            break;
        case 6:
            square.color = [SKColor magentaColor];
            break;
        case 7:
            square.color = [SKColor yellowColor];
            break;
        case 8:
            square.color = [SKColor orangeColor];
            break;
        case 9:
            square.color = [SKColor whiteColor];
            break;
        case 10:
            square.color = [SKColor brownColor];
            break;
        case 11:
            square.color = [SKColor darkGrayColor];
            break;
        case 12:
            square.color = [SKColor lightGrayColor];
            break;
        default:
            break;
    }

        square.colorBlendFactor = 0.5f;

}

-(void)startGame : (UIButton *)sender{
    sender.alpha = 0.0f;
    self.roomCodeLabel.alpha = 0.0f;
    [self.roomRef updateChildValues:@{@"gameStart":@"YES"}];

    
    //USED TO RANDOMIZE PLAYER LOCATIONS
    NSMutableArray *coordinateArray = [[NSMutableArray alloc] init];
    for(id key in self.coordinateDictionary){
        [coordinateArray addObject:key];
    }
    for(id key in self.usersWithPropertiesDictionary){
        NSString *coordinateString = [coordinateArray objectAtIndex:(arc4random() % coordinateArray.count)];
        Firebase *userRef = [self.usersWithPropertiesRef childByAppendingPath:key];
        [userRef updateChildValues:@{@"coordinates":coordinateString}];
    }
    
    
    [self.roomRef updateChildValues:@{@"turnNumber":@0}];

    

    
}

-(void)activatePortal : (Square *)square{
    NSLog(@"Portal Number:%d", square.portalNumber);
    Firebase *userRef = [self.usersWithPropertiesRef childByAppendingPath:self.currentPlayer.username];
    NSString *portRow1 = [NSString stringWithFormat:@"%@", [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dRow1", square.portalNumber]]];
    NSString *portColumn1 = [NSString stringWithFormat:@"%@", [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dColumn1", square.portalNumber]]];
    NSString *portRow2 = [NSString stringWithFormat:@"%@", [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dRow2", square.portalNumber]]];
    NSString *portColumn2 = [NSString stringWithFormat:@"%@", [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dColumn2", square.portalNumber]]];
    NSString *portDevice1 = [NSString stringWithFormat:@"%@", [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dDevice1", square.portalNumber]]];
    NSString *portDevice2 = [NSString stringWithFormat:@"%@", [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dDevice2", square.portalNumber]]];
    
    NSString *playerRow = [NSString stringWithFormat:@"%d", self.currentPlayer.row];
    NSString *playerColumn = [NSString stringWithFormat:@"%d", self.currentPlayer.column];
    NSString *playerDevice = [NSString stringWithFormat:@"%d", self.currentPlayer.deviceNumber];

    
    NSLog(@"Player Info: %@%@%@", playerDevice, playerColumn, playerRow);
    NSLog(@"Portal Info1: %@%@%@ \n Portal Info2:%@%@%@", portDevice1, portColumn1, portRow1, portDevice2, portColumn2, portRow2);

//    NSLog(@"Portal1Row:%@ Column:%@ // 2Row:%@ Column:%@", [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dRow1", square.portalNumber]], [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dColumn1", square.portalNumber]], [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dRow2", square.portalNumber]], [self.portalDictionary objectForKey:[NSString stringWithFormat:@"portal%dColumn2", square.portalNumber]]);
    NSLog(@"Legnth:%lu, Length:%lu", [playerDevice length], [portDevice1 length]);
    if([playerDevice isEqualToString:portDevice1]){
        NSLog(@"Device");
    }else{
        NSLog(@"Wah");
    }
    if([playerRow isEqualToString:portRow1]){
        NSLog(@"Row");
    }
    
    if([playerColumn isEqualToString:portColumn1]){
        NSLog(@"Column");
    }
    if([playerRow isEqualToString: portRow1] && [playerColumn isEqualToString:portColumn1] && [playerDevice isEqualToString:portDevice1]){
        NSLog(@"Updated1");
       [userRef updateChildValues:@{@"coordinates":[NSString stringWithFormat:@"%@%@%@", portDevice2, portColumn2, portRow2]}];
    }else if([playerRow isEqualToString: portRow2] && [playerColumn isEqualToString:portColumn2] && [playerDevice isEqualToString:portDevice2]){
        NSLog(@"Updated2");
        [userRef updateChildValues:@{@"coordinates":[NSString stringWithFormat:@"%@%@%@", portDevice1, portColumn1, portRow1]}];
    }
    
    
    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
//    [self enumerateChildNodesWithName:@"portal*" usingBlock:^(SKNode *node, BOOL *stop) {
//        if([self.currentPlayer intersectsNode:node]){
//            NSLog(@"INTERSECT");
//            Square *portal = (Square *)node;
//            Firebase *userRef = [self.usersWithPropertiesRef childByAppendingPath:self.currentPlayer.username];
//            if(self.currentPlayer.row == portal.portalRow1 && self.currentPlayer.column == portal.portalColumn1){
//                [userRef updateChildValues:@{@"coordinates":[NSString stringWithFormat:@"%d%d%d",portal.deviceNumber, portal.portalColumn2, portal.portalRow2]}];
//            }else{
//                [userRef updateChildValues:@{@"coordinates":[NSString stringWithFormat:@"%d%d%d",portal.deviceNumber, portal.portalColumn1, portal.portalRow1]}];
//            }
//        }
//    }];
    
}

@end
