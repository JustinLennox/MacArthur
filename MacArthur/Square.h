//
//  Square.h
//  MacArthur
//
//  Created by Justin Lennox on 4/13/15.
//  Copyright (c) 2015 Justin Lennox. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Square : SKSpriteNode

@property (nonatomic) int column;
@property (nonatomic) int row;
@property (nonatomic) int deviceNumber;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *coordinateString;
@property (nonatomic) int portalNumber;
@property (nonatomic) int portalRow1;
@property (nonatomic) int portalRow2;
@property (nonatomic) int portalColumn1;
@property (nonatomic) int portalColumn2;

@end
