//
//  SetupViewController.h
//  MacArthur
//
//  Created by Justin Lennox on 4/13/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface SetupViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *roomCodeTextField;

@property (strong, nonatomic) UILabel *roomCodeLabel;

@property (strong, nonatomic) NSString *roomCodeString;
@property (strong, nonatomic) NSString *username;

@property (strong, nonatomic) Firebase *usernameRef;
@property (strong, nonatomic) Firebase *myRootRef;
@property (strong, nonatomic) Firebase *roomRef;

@property (nonatomic) NSInteger usersInRoom;

@property (nonatomic) BOOL newRoom;
@property (nonatomic) BOOL joinRoom;

@property (strong, nonatomic) UIButton *joinRoomButton;
@property (strong, nonatomic) UIButton *startRoomButton;
@property (strong, nonatomic) UIButton *startGameButton;
@property (strong, nonatomic) UIButton *backButton;

- (void)startRoomButtonPressed:(id)sender;
- (void)joinRoomButtonPressed:(id)sender;
- (void)startGameButtonPressed;



@end
