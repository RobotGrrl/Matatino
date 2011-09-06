//
//  MatatinoTesterAppDelegate.h
//  MatatinoTester
//
//  Created by Erin Kennedy on 11-09-03.
//  Copyright 2011 robotgrrl.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Matatino/Matatino.h>

@interface MatatinoTesterAppDelegate : NSObject <NSApplicationDelegate, MatatinoDelegate> {
    
    // Display
    NSWindow *_window;
    IBOutlet NSPopUpButton *serialSelectMenu;
    IBOutlet NSButton *connectButton;
    IBOutlet NSTextField *receivedText;
    IBOutlet NSTextField *sendText;
    
    // Other
    Matatino *arduino;
    
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
//@property (strong) IBOutlet NSPopUpButton *serialSelectMenu;

// Display
- (IBAction) connectPressed:(id)sender;
- (IBAction) sendPressed:(id)sender;
- (IBAction) showPrefs:(id)sender;

- (void) setButtonsEnabled;
- (void) setButtonsDisabled;

@end
