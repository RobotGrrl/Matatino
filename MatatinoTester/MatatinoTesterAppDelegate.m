//
//  MatatinoTesterAppDelegate.m
//  MatatinoTester
//
//  Created by Erin Kennedy on 11-09-03.
//  Copyright 2011 robotgrrl.com. All rights reserved.
//

#import "MatatinoTesterAppDelegate.h"

@implementation MatatinoTesterAppDelegate

@synthesize window = _window;
//@synthesize serialSelectMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    arduino = [[Matatino alloc] initWithDelegate:self];
    [serialSelectMenu addItemsWithTitles:[arduino deviceNames]];
}

- (void) awakeFromNib {
    
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender {
    NSLog(@"Disconnecting...");
    // Safely disconnect
    [arduino disconnect];
    return NSTerminateNow;
}


#pragma mark - Buttons for connection

- (IBAction) connectPressed:(id)sender {
    
    if(![arduino isConnected]) { // Pressing GO!
                
        if([arduino connect:[serialSelectMenu titleOfSelectedItem] withBaud:B115200]) {
            
            [self setButtonsDisabled];
            
        } else {
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText:@"Connection Error"];
            [alert setInformativeText:@"Connection failed to start"];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        }
        
    } else { // Pressing Stop
        
        NSLog(@"stop");
        
        [arduino disconnect];
        [self setButtonsEnabled];
        
    }
    
}

- (IBAction) sendPressed:(id)sender {
    [arduino send:[sendText stringValue]];
    [sendText setStringValue:@""];
}

- (IBAction) showPrefs:(id)sender {
    
    if([arduino isConnected]) { // Show the buttons as disabled
        [self setButtonsDisabled];
    } else { // Show the buttons as enabled
        [self setButtonsEnabled];
    }
    
    [self.window makeKeyAndOrderFront:self];
    
}

- (void) setButtonsEnabled {
    [serialSelectMenu setEnabled:YES];
    [connectButton setTitle:@"GO!"];
}

- (void) setButtonsDisabled {
    [serialSelectMenu setEnabled:NO];
    [connectButton setTitle:@"Stop"];
}


#pragma mark - Arduino Delegate Methods

- (void) receivedString:(NSString *)rx {
    [receivedText setStringValue:rx];
}

- (void) portAdded:(NSArray *)ports {
    
    NSLog(@"Added: %@", ports);
    
    for(NSString *portName in ports) {
        [serialSelectMenu addItemWithTitle:portName];
    }
}

- (void) portRemoved:(NSArray *)ports {
    
    NSLog(@"Removed: %@", ports);
    
    for(NSString *portName in ports) {
        [serialSelectMenu removeItemWithTitle:portName];
    }
}

- (void) portClosed {
    [self setButtonsEnabled];
    [self.window makeKeyAndOrderFront:self];
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Disconnected"];
    [alert setInformativeText:@"Apparently the Arduino was disconnected!"];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
