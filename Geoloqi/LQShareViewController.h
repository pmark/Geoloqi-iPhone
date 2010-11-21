//
//  LQShareViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/19/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LQShareViewController : UIViewController
			<UIPickerViewDataSource, UIPickerViewDelegate> {
	NSMutableArray *durations;
	NSMutableArray *durationMinutes;
	NSString *selectedMinutes;
	IBOutlet UIButton *shareButton;
	UITextField *shareDescriptionField;
	NSString *sharedLinkCreated;
}

@property (nonatomic, retain) IBOutlet UITextField *shareDescriptionField;
@property (nonatomic, retain) NSMutableArray *durations;
@property (nonatomic, retain) NSMutableArray *durationMinutes;

- (IBAction)tappedShare:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes;

@end
