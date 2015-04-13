//
//  GameScene.m
//  MacArthur
//
//  Created by Justin Lennox on 4/13/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    NSLog(@"Did move to view");

    UIButton *upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [upButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 50, 0, 100, 100)];
    upButton.tag = 0;
    [upButton setTitle:@"Up" forState:UIControlStateNormal];
    [upButton setBackgroundColor:[UIColor blueColor]];
    [upButton addTarget:self action:@selector(connectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - 100, CGRectGetMidY(self.view.frame)-50, 100, 100)];
    rightButton.tag = 1;
    [rightButton setTitle:@"Right" forState:UIControlStateNormal];
    [rightButton setBackgroundColor:[UIColor blueColor]];
    [rightButton addTarget:self action:@selector(connectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame)-50, CGRectGetMaxY(self.view.frame)-100, 100, 100)];
    downButton.tag = 2;
    [downButton setTitle:@"Down" forState:UIControlStateNormal];
    [downButton setBackgroundColor:[UIColor blueColor]];
    [downButton addTarget:self action:@selector(connectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, CGRectGetMidY(self.view.frame)-50, 100, 100)];
    leftButton.tag = 3;
    [leftButton setTitle:@"Left" forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor blueColor]];
    [leftButton addTarget:self action:@selector(connectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
     UIButton *startGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [startGameButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame)-50, CGRectGetMidY(self.view.frame)-50, 100, 100)];
     [startGameButton setTitle:@"Start Game" forState:UIControlStateNormal];
     [startGameButton setBackgroundColor:[UIColor blueColor]];
     [startGameButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:startGameButton];
    
    [self.view addSubview:upButton];
    [self.view addSubview:rightButton];
    [self.view addSubview:downButton];
    [self.view addSubview:leftButton];
    [self.view addSubview:startGameButton];
    
    startGameButton.alpha = 0.0f;
    
    [self.roomRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
         if([snapshot.value[@"gameStart"] isEqualToString:@"NO"] && self.startingPlayer == YES){

             startGameButton.alpha = 1.0f;
             
             int numberColumns = self.view.frame.size.width/100;
             int numberRows = self.view.frame.size.height/100;
             float columnBuffer = (self.view.frame.size.width - 100.0f*numberColumns)/2.0000f;
             float rowBuffer = (self.view.frame.size.height - 100.0f*numberRows)/2.0000f;
             NSLog(@"columns:%d, Rows:%d", numberColumns, numberRows);
             NSLog(@"column buffer:%f", columnBuffer);
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
                     square.position = CGPointMake(previousX, previousY);
                     previousX += 100;
                     NSLog(@"Square Position x:%f y:%f", square.position.x, square.position.y);
                     [self addChild:square];
                     x++;
                     
                 }
                 previousY += 100;
                 previousX = 50 + columnBuffer;
                 y++;
                 NSLog(@"Previous Y:%f, Height:%f", previousY, self.view.frame.size.height);
             }


         }
         
         
         if([snapshot.value[@"gameStart"] isEqualToString:@"NO"]){
             
         }
     }
     ];
    
    
    NSLog(@"Finished moving");

    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
//        Square *square = (Square *)n;
//        NSLog(@"Row:%d, column:%d",square.row, square.column);
        

    }
}

-(void)connectButtonPressed : (UIButton *)sender{
    if(sender.tag == 0){
        NSLog(@"UP");
    }else if(sender.tag == 1){
        NSLog(@"RIGHT");
    }
}

-(void)startGame{
    NSLog(@"Start Game");
}

-(void)generateStartingGrid{
    self.gridMade = YES;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
