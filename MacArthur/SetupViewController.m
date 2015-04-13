//
//  SetupViewController.m
//  MacArthur
//
//  Created by Justin Lennox on 4/13/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import "SetupViewController.h"
#import "GameViewController.h"

@interface SetupViewController ()

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myRootRef = [[Firebase alloc] initWithUrl:@"https://macarthur.firebaseio.com"];
    
    self.startRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startRoomButton setTitle:@"Start Room" forState:UIControlStateNormal];
    [self.startRoomButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 50, 100, 100, 50)];
    [self.startRoomButton setBackgroundColor:[UIColor blueColor]];
    [self.startRoomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startRoomButton addTarget:self action:@selector(startRoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.joinRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.joinRoomButton setTitle:@"Join Room" forState:UIControlStateNormal];
    [self.joinRoomButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 50, CGRectGetMaxY(self.startRoomButton.frame) + 20, 100, 50)];
    [self.joinRoomButton setBackgroundColor:[UIColor blueColor]];
    [self.joinRoomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.joinRoomButton addTarget:self action:@selector(joinRoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.startGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startGameButton setTitle:@"Start Game" forState:UIControlStateNormal];
    [self.startGameButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 50, CGRectGetMaxY(self.joinRoomButton.frame) + 20, 100, 50)];
    [self.startGameButton setBackgroundColor:[UIColor blueColor]];
    [self.startGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startGameButton addTarget:self action:@selector(startGameButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.roomCodeTextField = [[UITextField alloc] initWithFrame:self.startRoomButton.frame];
    self.roomCodeTextField.placeholder = @"Room Code";
    self.roomCodeLabel = [[UILabel alloc] initWithFrame:self.roomCodeTextField.frame];
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.roomCodeTextField.frame.origin.x, CGRectGetMaxY(self.roomCodeTextField.frame) + 20, self.roomCodeTextField.frame.size.width, self.roomCodeTextField.frame.size.height)];
    self.usernameTextField.placeholder = @"Username";

    
    [self.view addSubview:self.startRoomButton];
    [self.view addSubview:self.joinRoomButton];
    [self.view addSubview:self.startGameButton];
    [self.view addSubview:self.roomCodeTextField];
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.roomCodeLabel];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{

    self.startGameButton.alpha = 0.0f;
    self.roomCodeTextField.alpha = 0.0f;
    self.usernameTextField.alpha = 0.0f;
    self.roomCodeLabel.alpha = 0.0f;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startRoomButtonPressed:(id)sender{
    
    self.roomCodeString = [self randomStringWithLength:4];
    self.roomCodeLabel.text = self.roomCodeString;
    self.roomCodeTextField.alpha = 0.0f;
    self.roomCodeLabel.alpha = 1.0f;
    self.startRoomButton.alpha = 0.0f;
    self.joinRoomButton.alpha = 0.0f;
    self.usernameTextField.alpha = 1.0f;
    self.newRoom = YES;
    self.joinRoom = NO;
    
}

-(void)joinRoomButtonPressed:(id)sender{
    
    self.roomCodeLabel.alpha = 0.0f;
    self.startRoomButton.alpha = 0.0f;
    self.joinRoomButton.alpha = 0.0f;
    self.usernameTextField.alpha = 1.0f;
    self.roomCodeTextField.alpha = 1.0f;
    self.joinRoom = YES;
    self.newRoom = NO;
    
}

-(void) startGameButtonPressed{
    self.username = self.usernameTextField.text;
    
    if(self.joinRoom){
        self.roomCodeString = self.roomCodeTextField.text;
    }
    
    NSDictionary *roomDictionary = @{self.roomCodeString:@{}};
    if(self.newRoom)
    {
        NSDictionary *usernameDict = @{@"0":self.username};
        NSDictionary *usernameDictionary = @{@"usernames":usernameDict};
        [self.myRootRef updateChildValues:roomDictionary];
        Firebase *currentRoomRef = [self.myRootRef childByAppendingPath:self.roomCodeString];
        [currentRoomRef updateChildValues:@{@"gameStart":@"NO"}];
        [currentRoomRef updateChildValues:@{@"turnNumber":@0}];
        
        //Add Values to the Player
//        [currentRoomRef updateChildValues:
//         @{self.username:
//               @{@"Health": @8,
//                 @"Gems": @15,
//                 },
//           }
//         ];
        
        //Add the username to the room's username array
        [currentRoomRef updateChildValues:usernameDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            [self performSegueWithIdentifier:@"newGameSegue" sender:self];
        }];
        Firebase *addUsersWithPropertiesDictRef= [currentRoomRef childByAppendingPath:@"usersWithProperties"];
        [addUsersWithPropertiesDictRef updateChildValues:
         @{self.username: @{@"Health": @8, @"Gems": @15}}];
        
    }else if(self.joinRoom){
        Firebase *currentRoomRef = [self.myRootRef childByAppendingPath:self.roomCodeTextField.text];
        self.usernameRef = [currentRoomRef childByAppendingPath:@"usernames"];
        [self.usernameRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            self.usersInRoom = snapshot.childrenCount;
            NSLog(@"users in room %lu",self.usersInRoom);
            
            //Add values to each user
//            [currentRoomRef updateChildValues:
//             @{self.username:
//                   @{@"Health": @8,
//                     @"Gems": @15,
//                     }
//               }
//             ];
            NSString *userNumberString = [NSString stringWithFormat:@"%lu", self.usersInRoom];
            NSDictionary *usernameDict = @{userNumberString:self.username};
            
            //Add the user to the room's username array
            [self.usernameRef updateChildValues:usernameDict withCompletionBlock:^(NSError *error, Firebase *ref) {
                [self performSegueWithIdentifier:@"newGameSegue" sender:self];
            }];
            
            Firebase *addUsersWithPropertiesDictRef= [currentRoomRef childByAppendingPath:@"usersWithProperties"];
            [addUsersWithPropertiesDictRef updateChildValues:
             @{self.username: @{@"Health": @8, @"Gems": @15}}];
            
            
        } withCancelBlock:^(NSError *error) {
            NSLog(@"%@", error.description);
            
        }];

    }
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void)checkComplete{
    if(self.joinRoom && ![self.usernameTextField.text isEqualToString:@""] && ![self.roomCodeTextField.text isEqualToString:@""]){
        self.startGameButton.alpha = 1.0f;
    }else if(self.newRoom && ![self.usernameTextField.text isEqualToString:@""]){
        self.startGameButton.alpha = 1.0f;
    }
}

#pragma mark- Keyboard Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.usernameTextField resignFirstResponder];
    [self.roomCodeTextField resignFirstResponder];
    [self checkComplete];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self checkComplete];
        return YES;
    
}

-(BOOL)textViewShouldEndEditing:(UITextField *)textField
{
    [self checkComplete];
    [textField resignFirstResponder];
    return YES;
}





#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"newGameSegue"]){
        GameViewController *vc = segue.destinationViewController;
        vc.myRootRef = self.myRootRef;
        vc.roomRef = [self.myRootRef childByAppendingPath:self.roomCodeString];
        if(self.newRoom){
            vc.startingPlayer = YES;
        }else{
            vc.startingPlayer = NO;
        }
        
    }
}


@end
