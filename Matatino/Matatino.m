//
//  Matatino.m
//  Matatino
//
/*
Matatino is licensed under the BSD 3-Clause License
http://www.opensource.org/licenses/BSD-3-Clause

Matatino Copyright (c) 2011, RobotGrrl.com. All rights reserved.
*/

#import "Matatino.h"
#import "AMSerialPort.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"

@interface Matatino ()
- (void) initEverything;
@end

@implementation Matatino

@synthesize delegate, debug;

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        [self initEverything];
        delegate = nil;
    }
    return self;
}

- (id)initWithDelegate:(id <MatatinoDelegate>)aDelegate {
    self = [super init];
    if (self)  {
        [self initEverything];
        delegate = aDelegate;        
    }
    return self;
}

- (void) initEverything {
    debug = NO;
    
    /// Add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovePorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];
    
    /// Initialize port list
    [AMSerialPortList sharedPortList];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


#pragma mark - Connect/disconnect

- (BOOL) connect:(NSString *)deviceName withBaud:(long)baud {
    
    if(debug) NSLog(@"Attempting to connect");
    
    if (![deviceName isEqualToString:[port bsdPath]]) {
        [port close];
        
        if(debug) NSLog(@"Initing with device name: %@", deviceName);
        
        [self setPort:[[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
        [port setDelegate:self];
        
        if ([port open]) {
            
            // Connection success!
            if(debug) NSLog(@"Connection success!");
            
            // Default baud rate for this will be 115200
            [port setSpeed:baud];
            
            if(debug) NSLog(@"Port speed: %lu", [port speed]);
            
            // Listen for the data in a sepperate thread
            [port readDataInBackground];
            
            return YES;
            
        } else { // An error occured while creating port
            
            if(debug) NSLog(@"Connection error");
            [self setPort:nil];
            
        }
    } else {
        if(debug) NSLog(@"Now what? Bizarre error.");
    }
    
    return NO;
}

- (void) disconnect {
    [port close];
    port = nil;
}

- (BOOL) isConnected {
    return [port isOpen];
}


#pragma mark - Send data

- (BOOL) send:(NSString *)tx {
    
    NSString *sendString = tx;
    NSError *error = nil;
    
    if([port isOpen]) {
        [port writeString:sendString usingEncoding:NSUTF8StringEncoding error:&error];
    } else {
        if(debug) NSLog(@"Port was not open");
        return NO;
    }
    
    if(error != nil) {
        if(debug) NSLog(@"There was an error sending the data: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


#pragma mark - Serial related

- (NSArray *) deviceNames {
    
    NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
    NSMutableArray *allDevices = [[[NSMutableArray alloc] initWithCapacity:6] autorelease]; // just some random number
    AMSerialPort *aPort;
    
    while (aPort = [enumerator nextObject]) {
        [allDevices addObject:[aPort bsdPath]];
    }
    
    if(debug) NSLog(@"All devices: %@", allDevices);
    return [NSArray arrayWithArray:allDevices];
}


- (void)setPort:(AMSerialPort *)newPort {
    id old = nil;
    
    if (newPort != port) {
        old = port;
        port = [newPort retain];
        [old release];
    }
}

- (AMSerialPort *)port {
    return port;
}


#pragma mark - AMSerialPort Delegate Methods

- (void) serialPortReadData:(NSDictionary *)dataDictionary {
        
    // Get the data
    AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
    NSData *data = [dataDictionary objectForKey:@"data"];
    
    if ([data length] > 0) {
        
        // Extract the data
        NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //NSLog(@"Serial Port Data Received: %@", receivedText);
        
        // Send it to our delegate
        [delegate receivedString:receivedText];
        
        // Keep on listening!
        [sendPort readDataInBackground];
        
        // Release, geez!
        [receivedText release];
        
    } else { 
        // Port closed
        if(debug) NSLog(@"Port was closed on a readData operation ... not good!");
        [self disconnect];
        [delegate portClosed];
    }
    
}


#pragma mark - AMSerialPort Notifications

- (void)didAddPorts:(NSNotification *)theNotification {
    if(debug) NSLog(@"A port was added");
    NSArray *ports = [[theNotification userInfo] objectForKey:AMSerialPortListAddedPorts];
    
    NSMutableArray *portNames = [[[NSMutableArray alloc] initWithCapacity:1] autorelease]; // Even though it can be > 1, it's really rare :P, so we can let the NSMutableArray deal with it if it is >1
    
    for(AMSerialPort *aPort in ports) {
        [portNames addObject:[aPort bsdPath]];
    }
    
    [delegate portAdded:portNames];
}

- (void)didRemovePorts:(NSNotification *)theNotification {
    if(debug) NSLog(@"A port was removed");
    NSArray *ports = [[theNotification userInfo] objectForKey:AMSerialPortListRemovedPorts];
    
    NSMutableArray *portNames = [[[NSMutableArray alloc] initWithCapacity:1] autorelease]; // Even though it can be > 1, it's really rare :P, so we can let the NSMutableArray deal with it if it is >1
    
    for(AMSerialPort *aPort in ports) {
        [portNames addObject:[aPort bsdPath]];
    }
    
    [delegate portRemoved:portNames];
}

@end
