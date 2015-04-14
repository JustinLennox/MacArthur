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

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.coordinateRef = [self.roomRef childByAppendingPath:@"coordinateDictionary"];
    self.usersWithPropertiesRef = [self.roomRef childByAppendingPath:@"usersWithProperties"];
    self.turnRef = [self.roomRef childByAppendingPath:@"turnNumber"];
    
    self.gridArray = [[NSMutableArray alloc] init];
    self.usernameArray = [[NSMutableArray alloc] init];
    self.playerArray = [[NSMutableArray alloc] init];
    self.portalDictionary = [[NSMutableDictionary alloc] init];
    
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
         }
         
         
     } ];
    
    [self.usersWithPropertiesRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {

         if(self.gameStarted)
         {
             int userNumber = 0;
             for(NSString *username in self.usernameArray)
             {
                 NSDictionary *userWithProperty = snapshot.value[username];
                 NSString *coordinateString = [userWithProperty objectForKey:@"coordinates"];
                 for(Square *square in self.gridArray)
                 {
                      if([square.coordinateString isEqualToString:coordinateString])
                      {
                          Player *player = [[Player alloc] initWithImageNamed:@"aragon2.png"];
                          player.size = CGSizeMake(50, 50);
                          player.position = CGPointMake(square.position.x, square.position.y);
                          player.row = square.row;
                          player.column = square.column;
                          player.deviceNumber = self.deviceNumber;
                          player.playerNumber = userNumber;
                          player.username = username;
                          [self addChild:player];
                          SKLabelNode *usernameLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
                          usernameLabel.text = [NSString stringWithFormat:@"%@", username];
                          [player addChild:usernameLabel];
                          usernameLabel.position = CGPointMake(0, 10);
                          [self.playerArray addObject:player];

                      }
                }
                 userNumber++;
             }
         }
         
         
     }];
    
    [self.turnRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
//         for(Player *player in self.playerArray){
//             NSLog(@"Player Number:%d Turn Number:%d", player.playerNumber, [snapshot.value intValue]);
//             if(player.playerNumber == [snapshot.value intValue]){
//                 NSLog(@"Turn start go!!!");
//             }
//         }
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
                         [self startTurn];
                     }
                 }
             }
             userNumber++;
         }

         
         
     }];
    
    
    
    [self.view bringSubviewToFront:self.roomCodeLabel];

    
}

-(void)startTurn{
    NSLog(@"Start Turn");
    self.turnTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(endTurn) userInfo:nil repeats:NO];
    
}

-(void)endTurn{
    NSLog(@"End Turn");
    [self.turnTimer invalidate];
    self.turnTimer = nil;
    if(self.turnNumber < self.usernameArray.count -1){
        self.turnNumber++;
    }else{
        self.turnNumber = 0;
    }
    [self.turnRef setValue:[NSNumber numberWithInt:self.turnNumber]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if([[[n class] description] isEqualToString:@"Square"])
        {
            Square *square = (Square *)n;
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
    
    Square *portal = [Square spriteNodeWithImageNamed:@"totem2.png"];
    portal.type = @"portal";
    portal.portalNumber = portalNumber;
    portal.name = [NSString stringWithFormat:@"portal%d", portalNumber];
    [self colorSquare :square withPortal:portal];
    portal.position = square.position;
    portal.size = CGSizeMake(35, 35);
    portal.portalRow1 = square.row;
    portal.portalColumn1 = square.column;
    [self addChild:portal];
    NSString *portalString = [NSString stringWithFormat:@"portal%d", portalNumber];
    [self.roomRef updateChildValues:@{portalString:@{[NSString stringWithFormat:@"%@Row1",portalString]:[NSNumber numberWithInt:portal.portalRow1], [NSString stringWithFormat:@"%@Column1",portalString]:[NSNumber numberWithInt:portal.portalColumn1]}}];
    [self.roomRef updateChildValues:@{@"connecting":@"YES"}];

    
}

-(void)placePortalEnd : (Square *)square{
    
    Square *portal = [Square spriteNodeWithImageNamed:@"totem2.png"];
    portal.type = @"portal";
    portal.portalNumber = portalNumber;
    portal.name = [NSString stringWithFormat:@"portal%d", portalNumber];
    [self colorSquare :square withPortal:portal];
    portal.position = square.position;
    portal.size = CGSizeMake(35, 35);
    portal.portalRow2 = square.row;
    portal.portalColumn2 = square.column;
    [self addChild:portal];
    NSString *portalString = [NSString stringWithFormat:@"portal%d", portalNumber];
    [self.roomRef updateChildValues:@{portalString:@{[NSString stringWithFormat:@"%@Row1",portalString]:[NSNumber numberWithInt:portalRow1], [NSString stringWithFormat:@"%@Column1",portalString]:[NSNumber numberWithInt:portalColumn1],[NSString stringWithFormat:@"%@Row2",portalString]:[NSNumber numberWithInt:portal.portalRow2], [NSString stringWithFormat:@"%@Column2",portalString]:[NSNumber numberWithInt:portal.portalColumn2]}, @"portalNumber":[NSNumber numberWithInt:(portalNumber + 1)]}];
    [self.roomRef updateChildValues:@{@"connecting":@"NO"}];

    
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

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
