[Matatino](http://robotgrrl.com/apps4arduino/matatino.php)
==================

Matatino is a Cocoa framework for Mac that provides a straight-forward way to communicate with your Arduino through its serial connection.

Matatino was developed by RobotGrrl. Matatino uses AMSerialPort (with modifications from xcode-arduino-serial-communication). Matatino was based off of xcode-arduino-serial-communication.


##Usage

###Variables
	id<MatatinoDelegate> delegate
Delegate for receiving the callbacks. See below for the callback methods.

	BOOL debug
Triggers NSLog() statements inside the code. Set to NO by default. 


###Init
	- (id)initWithDelegate:(id <MatatinoDelegate>)aDelegate
Initializes the Matatino object with a specific delegate. We recommend using this instead of -init and manually setting the delegate. 


###Connect/disconnect
	- (BOOL) connect:(NSString *)deviceName withBaud:(long)baud
Connects the Arduino with a certain baud rate.

The deviceName is the AMSerialPort bsdPath. You can access an array of all the bsdPath's by using -deviceNames (below). 

The baud rate long that is passed must be one of the standard speeds as defined in termios.h. You can see them listed out on the [website](http://robotgrrl.com/apps4arduino/matatino.php).

	- (void) disconnect
Safely disconnects the connected device.

	- (BOOL) isConnected
Checks if the Arduino is connected. If the Arduino is connected, returns YES. Otherwise, NO. 


###Send data
	- (BOOL) send:(NSString *)tx
Sends a NSString to the connected device. A \r is appended the end of the NSString.

The NSString is written using NSUTF8StringEncoding encoding.

Returns NO if the port was not open, or if there was an error sending the data. Otherwise, returns YES. 


###Serial related
	- (NSArray *) deviceNames
Returns a NSArray of NSStrings. The strings are all the AMSerialPort's bsdPath.

	- (AMSerialPort *) port
Returns the current AMSerialPort. You will probably never need to use this.

	- (void) setPort:(AMSerialPort *)newPort
Sets current AMSerialPort to a new AMSerialPort. You probably never need to use this. 


###MatatinoDelegate Callbacks

	- (void) receivedString:(NSString *)rx
Called when the Arduino sends data to the Mac. The NSString uses NSASCIIStringEncoding encoding.

	- (void) portClosed
Called whenever a port is closed. When you stop the communication to the Arduino, this is called.

	- (void) portAdded:(NSArray *)ports
Called when a port is added. This is useful to update a pulldown menu of all the ports, for example.
Has a NSArray of NSString- they are AMSerialPort bsdPath's.

	- (void) portRemoved:(NSArray *)ports
Called when a port is removed. This is useful to update a pulldown menu of all the ports, for example. 
Has a NSArray of NSString- they are AMSerialPort bsdPath's. 



##Contribute

Matatino is released under the [BSD 3-Clause license](http://www.opensource.org/licenses/BSD-3-Clause). This means that you can contribute fixes, improvements, and changes. All contributions that will be included in the main branch will receive credit in the Matatino and Meters for Arduino credits.rtf.

You can also make your own applications with Matatino! Although the BSD 3-Clause license is not a "copyleft" license that requires you to redistribute the source code, we highly encourage that you do so. The Arduino community is what it celebrates, an open sharing of all knowledge used to make a project!

Making Matatino more friendly for other devices would be cool. In AMSerialPort, there are ways to change the flow control and other details. Maybe making easier accessors for those in Matatino.h would be good.


##License

Matatino is released under the [BSD 3-Clause license](http://www.opensource.org/licenses/BSD-3-Clause). You can view our other legal information in legal.markdown or on the [website](http://robotgrrl.com/apps4arduino/matatino.php).