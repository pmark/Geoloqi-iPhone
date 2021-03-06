//
//  GLWelcomeViewController.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLWelcomeViewController : UIViewController {
	
}
@property (nonatomic, retain) IBOutlet UIViewController *signUpViewController;
@property (nonatomic, retain) IBOutlet UIViewController *logInViewController;

@property (nonatomic, retain) IBOutlet UIButton *signUpButton;
@property (nonatomic, retain) IBOutlet UIButton *signInButton;
@property (nonatomic, retain) IBOutlet UIButton *useAnonymouslyButton;


- (IBAction)signUp;
- (IBAction)useAnonymously;
- (IBAction)logIn;

@end
