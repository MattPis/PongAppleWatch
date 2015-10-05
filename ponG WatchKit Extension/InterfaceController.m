//
//  InterfaceController.m
//  POnG WatchKit Extension
//
//  Created by Matt on 9/21/15.
//  Copyright © 2015 Matt. All rights reserved.
//

#import "InterfaceController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
@interface InterfaceController(){
    NSTimer *timer;
    float xDirection;
    float yDirection;
    
    double xRandomizer;
    double yRandomizer;
}
@property (strong, nonatomic) IBOutlet WKInterfacePicker *picker;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *board;
@property int  player1Position;
@property int player2Position;

@property int ballXPosition;
@property int ballYPosition;

@property (strong,nonatomic) UIImage *gameBoard;
@property CGContextRef context;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:40];
    for(int ctr = 0; ctr <= 40; ctr++) {
        NSString *imgName = [NSString stringWithFormat:@"round%d",ctr];
        WKPickerItem *item = [[WKPickerItem alloc] init];
        item.caption = imgName;
        [items addObject:item];
    }
    [self.picker setItems:items];

   }
- (IBAction)pickerChanged:(NSInteger)value {
    self.player1Position = 100-(value*2); //invert position from picker (twice less sensitive than board has pixels)
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(updateObjects) userInfo:nil repeats:YES];
    }
}
#pragma mark phisics

-(void)updateObjects{
    
    self.ballXPosition += xDirection;
    self.ballYPosition += yDirection;
    
    self.ballXPosition +=xRandomizer;
    self.ballXPosition +=yRandomizer;
    
    [self checkForCollision];
}

-(void)randomizeX{
    xRandomizer = arc4random_uniform(10);
    xRandomizer -= 5;
    xRandomizer /= 10;
    NSLog(@"%f", xRandomizer);
}

#pragma mark collision check
-(void)checkForCollision{
    
    if (self.ballXPosition==95) { //bounces player2 side
        xDirection = -1;
        [self randomizeX];
    }
    else if ((self.ballXPosition == 5)&&([self checkPlayer1Bounce])){   //bounces player1
        xDirection = 1;
        [self randomizeX];
    }
    else if ((self.ballXPosition ==5) &&(![self checkPlayer1Bounce])){ //player1 missed
        xDirection = 1;
        [self randomizeX];
        NSLog(@"Lost Point");
    }
    else if (self.ballYPosition == 5){ //bounces Top
        yDirection = 1;
    }
    else if (self.ballYPosition == 95){ //bounces bottom
        yDirection = -1;
    }
    [self draw];
}
-(BOOL)checkPlayer1Bounce{
    
    if ((self.ballYPosition > self.player1Position-20) && (self.ballYPosition < self.player1Position)) {
        return YES;
    }
    else{
        return NO;
    }
    
}
#pragma mark draw board

-(void)draw{
    
    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
    self.context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(self.context, [[UIColor whiteColor] CGColor]);
    
    //drawPlayer1
    CGContextSetLineWidth(self.context, 3.0);
    CGContextMoveToPoint(self.context, 2.0, self.player1Position-20);
    CGContextAddLineToPoint(self.context, 2.0, self.player1Position);
    CGContextDrawPath(self.context, kCGPathStroke);
    
    //drawPlayer2
    CGContextSetLineWidth(self.context, 3.0);
    CGContextMoveToPoint(self.context, 98, self.ballYPosition - 9);
    CGContextAddLineToPoint(self.context, 98, self.ballYPosition + 11);
    CGContextDrawPath(self.context, kCGPathStroke);
    
    //drawBall
    
    CGContextSetLineWidth(self.context, 4.0);
    CGContextMoveToPoint(self.context, self.ballXPosition, self.ballYPosition);
    CGContextAddLineToPoint(self.context, self.ballXPosition, self.ballYPosition+4);
    CGContextDrawPath(self.context, kCGPathStroke);
    
    self.gameBoard = UIGraphicsGetImageFromCurrentImageContext();
    [self.board setImage:self.gameBoard];
    
    UIGraphicsEndImageContext();
}
-(void)resetPlayer{
    self.player1Position = 100;
    self.player2Position = 40;
    
    self.ballXPosition = 10;
    self.ballYPosition = 85;
    
    xDirection = 1;
    yDirection = -1;
    
    [self draw];

}
- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    
    
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



