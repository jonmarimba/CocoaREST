SDSocialNetworkManager
by Steven Degutis - http://degutis.org



How to use SDSocialNetworkManager
==========================

SDSocialNetworkManager is an Objective-C/Cocoa class which, along with its companion class SDSocialNetworkTask, makes it easy to add social network integration to your own Cocoa apps. It communicates with services such as Twitter via their public REST APIs. You can read about the specific supported APIs at the following links:

http://apiwiki.twitter.com/REST+API+Documentation

Using SDSocialNetworkManager is easy. The basic steps are:


1. Copy all the relevant source files into your own project. You need everything that starts with "SDSocialNetwork", and also the NSString+UUID and NSData+Base64 category files. For your convenience, they are all in the Source folder of this project, ready for a nice Cmd-A + Cmd-C.


2. Copy YAJL.framework into your project, making sure to add it in a Copy Files phase which points to your Frameworks folder in your application bundle.


2. In whatever class you're going to use SDSocialNetworkManager from, obviously make sure you #import the SDSocialNetworkManager.h header file. You should also declare that your class implements the SDSocialNetworkDelegate protocol. The AppDelegate.h header file in the demo project is an example you can use.


3. Implement the SDSocialNetworkDelegate methods, just as the AppDelegate in the demo project does. These are the methods you'll need to implement:

- (void) socialNetworkManager:(SDSocialNetworkManager*)manager resultsReadyForTask:(SDSocialNetworkTask*)task;


4. Go ahead and use SDSocialNetworkManager! The Header files are very self-explanatory and well-documented. However, it is recommended that you take a look at the section below as well.



More in-depth explanation of usage
==================================

The bare basics that are required to request data from or send data to a social network, are as follows:

(1) Create an SDSocialNetworkManager (usually with +manager)

	(a) Set its delegate
	(b) Set its username and password, if your task requires authentication
	(c) Optionally, you can set your application's information
	(d) For more control, you can set the maximum tasks that can be run simultaneously
	(e) All of these are @properties listed inside SDSocialNetworkManager.h

(2) Create an SDSocialNetworkTask (usually with +task)

	(a) Set its service if necessary (defaults to Twitter.com for now)
	(b) Set the task type it should use
	(c) Set any required properties for the specified task (ie. screenName, text, or statusID)
	(d) Check SDSocialNetworkTask.h for a list of writable properties, and service/task types

(3) Run the task via [manager runTask:task]

	(a) Implement delegate methods to deal with any returned data
	(b) After every task, SDSocialNetworkManager object will have new rate-limiting information set on it. You can reliably et this data from the SDSocialNetworkManager @properties limitMaxAmount, limitRemainingAmount, and limitResetEpochDate, whenever necessary. They will always reflect the real-time limiting information
	(c) The `results` @property of the Task object will contain returned information from the social networking service.
	(d) Once a task has completed, it will deallocate. It should not be retained, and cannot be run a second time. Read the documentation on NSOperation for more information on this.


A note on threads and performance
=================================

SDSocialNetworkTasks are run in separate threads in the background, to increase performance and user experience. However, the vast majority of use-cases should not worry about thread-safety, as all delegate methods are called on the main thread, and the task waits until the delegate is finished before continuing execution in the background thread. Thus, it is perfectly safe to access any @properties on the task from the main thread, after the task has completed.



A note about the format of returned values
==========================================

You may get any kind of ObjC type in the `results` property, anything from NSArray to NSDictionary, NSString to NSNumber, etc. Because of the JSON parser, these results (or the objects in a collection) may not always be of the classes you might expect. So be sure to ask for a value's -class when testing the services.

UUIDs: For backwards-compatibility with MGTwitterEngine, each Task object contains a unique string identifier (or UUID), created inside -init. These unique string identifiers are compatible with MGTwitterEngine's and may be used as keys in dictionaries if you so desire. However, they are deprecated, to be removed in the (hopefully near) future. If anything, the task itself should be stored in a collection, but usually this is not necessary, as each task encapsulates sufficient information inside it for determining any contextual information needed to understand the returned data.


Other people's Source Code used in this project
===============================================

This code requires the aforementioned NSString and NSData files, which are borrowed directly from MGTwitterEngine. Similarly, this README file and the Source Code license borrowed heavily from their MGTwitterEngine counterparts.

The class SDSocialNetworkTask uses JSON parsing, and does not ask for, or parse, XML data at all. The JSON library YAJL.framework is an ObjC framework (wrapper) around a C library, both having been written by Lloyd Hilaiel.

For more information about `yajl` and YAJL.framework, visit the following website:

http://lloyd.github.com/yajl/



SDSocialNetworkManager and the iPhone
=====================================

Most of the classes used in this project should be available on the iPhone SDK as well as Leopard. Similarly, YAJL.framework should work just fine when compiled against the iPhone SDK. Thus, it should be perfectly suitable for using on the iPhone SDK.

Note: I have not tested this against the iPhone SDK as of the date of writing (5-29-09) so if anyone tests it and finds that it either works or fails, please let me know!


Standard ending of a README
===========================

That's about it. If you have trouble with the code, or want to make a feature request or report a bug (or even contribute some improvements), you can get in touch with me using the info below. I hope you enjoy using SDSocialNetworkManager!

-Steven Degutis


Web:      http://degutis.org
AIM:      stevendegutis
MSN:      steven.degutis@hotmail.com
Twitter:  sdegutis

P.S. Special Thanks to Matt Gemmell for providing the initial structure of this README and the Source Code License file! Thanks also to Matt for the idea of a twitter engine Cocoa class, and thanks to @chockenberry for finding `yajl`



Mac and iPhone Developer for Hire
=================================

If you'd like to hire me for your own Mac OS X (Cocoa) or iPhone / iPod Touch development project, take a look at my consulting site at http://hire.degutis.org
