SDSocialNetworkManager
by Steven Degutis - http://degutis.org


Why use SDSocialNetworkManager (instead of MGTwitterEngine)
===========================================================

In its day, `MGTwitterEngine` was a prime example of a very good Cocoa interface to a RESTful API like Twitter.com maintains. Unfortunately, that day was pretty long ago (two years and 10 days, or something like that). A lot has changed with Twitter's API, and Mac OS X Leopard has added many features which MGTwitterEngine hasn't been updated to include. For anyone still supporting Tiger, MGTE is probably still a good bet. But for anyone supporting Leopard or higher, I recommend SDSocialNetwork, because it

* Uses modern, up-to-date APIs on Twitter.com, such as "statuses/mentions" versus the archaic "statuses/replies"

* Was designed from the ground up to be easily maintainable and extendable by any developer, to make use of future APIs

* Is built to support multiple services, not just Twitter

* Has huge, automatic performance boosts, due to taking advantage of the modern technologies available in Mac OS X 10.5 Leopard such as multi-threading (via NSOperation/Queue) and synthesized, atomic, thread-safe @properties
	* `SDSocialNetworkTasks` runs smoothly in background threads, and can even run simultaneously with other `SDSocialNetworkTasks`
	* Uses an optimized JSON parser to handle returned values stunningly quickly
	* User experience is greatly improved, since the user will never see a spinning wheel due to a running Task

* Requests returned values in an ubiquitous format for easy parson across multiple platforms (both Mac and iPhone)

If you are planning on developing a new Social Networking application, or are already in the process, and plan to only support Leopard or higher, I strongly urge you to take a look at the sample code below, and see how flexible and easy to use SDSocialNetworkManager is. You, the developer, decide which variables to set in your API call, without having to deal with complex and ever-changing methods like `-[MGTwitterEngine getRepliesStartingAtPage:]` (which is now deprecated by Twitter's own API).

How to use SDSocialNetworkManager
=================================

`SDSocialNetworkManager` is an Objective-C/Cocoa class which, along with its companion class `SDSocialNetworkTask`, makes it easy to add social network integration to your own Cocoa apps. It communicates with services such as Twitter via their public REST APIs. You can read about the specific supported APIs at the following links:

<http://apiwiki.twitter.com/REST+API+Documentation>

Using `SDSocialNetworkManager` is easy. The basic steps are:


1. Copy all the relevant source files into your own project. You need everything that starts with "SDSocialNetwork", and also the four `NSString+UUID` and `NSData+Base64` files. For your convenience, they are all in the `Source` folder of this project, ready for a nice Cmd-A + Cmd-C.


2. Copy `YAJL.framework` into your project, making sure to add it in a Copy Files phase which points to your Frameworks folder in your application bundle.


2. In whatever class from which you're going to use `SDSocialNetworkManager`, make sure you `#import` the `SDSocialNetworkManager.h` header file. You should also declare that your class implements the `SDSocialNetworkDelegate` protocol. The `AppDelegate.h` header file in the demo project is an example you can use.


3. Implement the `SDSocialNetworkDelegate` methods, just as the AppDelegate in the demo project does. Inside your delegate methods, you can access the Manager and Task objects to fully see the context surrounding `task.results`. These are the methods you'll need to implement:

	- (void) socialNetworkManager:(SDSocialNetworkManager*)manager resultsReadyForTask:(SDSocialNetworkTask*)task;
	- (void) socialNetworkManager:(SDSocialNetworkManager*)manager failedForTask:(SDSocialNetworkTask*)task;

4. Go ahead and use `SDSocialNetworkManager`! The Header files are very self-explanatory and well-documented. However, it is recommended that you take a look at the section below as well.



More in-depth explanation of usage
==================================

The bare basics that are required to request data from or send data to a social network, are as follows:

* Create an `SDSocialNetworkManager` (usually with `+manager`)

	* Set its `delegate`
	* Set its `username` and `password`, if your task requires authentication
	* Optionally, you can set your application's `appName`, `appVersion`, and `appWebsite` information
	* For more control, you can set the maximum tasks that can be run simultaneously, via the `maxConcurrentTasks` @property
	* All of these are @properties listed inside `SDSocialNetworkManager.h`

* Create an `SDSocialNetworkTask` (usually with `+task`)

	* Set its `service` if necessary (defaults to Twitter.com for now)
	* Set the task's `type` @property it should use (values are located in the `SDSocialNetworkTask.h` file)
	* Set any required properties for the specified task (ie. `screenName`, `text`, or `statusID`)
	* Check `SDSocialNetworkTask.h` for a list of writable properties, and types of services/tasks

* Run the task via `[manager runTask:task]`

	* Implement delegate methods to deal with any returned data
	* After every task, `SDSocialNetworkManager` object will have new rate-limiting information set on it. You can reliably et this data from the `SDSocialNetworkManager` @properties `limitMaxAmount`, `limitRemainingAmount`, and `limitResetEpochDate`, whenever necessary. They will always reflect the real-time limiting information inside the delegate methods
	* The `results` @property of the task object will contain returned information from the social networking service.
	* Once a task has completed, it will deallocate. It should not be retained, and cannot be run a second time. Read the documentation on `NSOperation` for more information.



Sample Code
===========

	- (void) awakeFromNib
	{
		// inside a header file, declare manager as an instance variable
		SDSocialNetworkManager *manager;
		
		// create out manager, retaining it as we want it to stick around
		manager = [[SDSocialNetworkManager manager] retain];
		manager.delegate = self;
		
		// change this info to match your app
		manager.appName = @"My Great App";
		manager.appVersion = @"7.0";
		manager.appWebsite = @"http://www.googlw.com/";
		
		// this is a must for certain API calls which require authentication
		// change them to real login values or the tasks will fail
		manager.username = @"USERNAME";
		manager.password = @"PASSWORD";
		
		// 3 tasks can be run simultaneously
		manager.maxConcurrentTasks = 3;
		
		// create a basic task
		SDSocialNetworkTask *mentionsTask = [SDSocialNetworkTask task];
		mentionsTask.type = SDSocialNetworkTaskGetMentions;
		mentionsTask.count = 4;
		mentionsTask.page = 2;
		[manager runTask:mentionsTask];
		
		// post a simple message on twitter
		SDSocialNetworkTask *updateTask = [SDSocialNetworkTask task];
		updateTask.type = SDSocialNetworkTaskCreateStatus;
		updateTask.text = @"Experimenting with the brand new SDSocialNetwork library for Cocoa!";
		[manager runTask:updateTask];
	}
	
	- (void) socialNetworkManager:(SDSocialNetworkManager*)manager resultsReadyForTask:(SDSocialNetworkTask*)task
	{
		NSLog(@"%@", task.results);
	}
	
	- (void) socialNetworkManager:(SDSocialNetworkManager*)manager failedForTask:(SDSocialNetworkTask*)task
	{
		NSLog(@"%@", task.error);
	}


A note on threads and performance
=================================

`SDSocialNetworkTasks` are run in separate threads in the background, to both increase performance and improve the user's experience. However, despite any worries this may invoke, the vast majority of use-cases should not worry about thread-safety, since all delegate methods are called on the main thread, and the task waits until the delegate is finished before continuing execution in the background thread. Thus, it is perfectly safe to access any @properties on the task from the main thread, after the task has completed. This allows you to implement such functionality as iterating through the returned values and storing them in a Core Data context, without worrying about data corruption at all.



A note about the format of returned values
==========================================

You may get any kind of ObjC type in the `results` property, anything from `NSArray` to `NSDictionary`, `NSString` to `NSNumber`, etc. Because of the JSON parser, these results (or the objects in a collection) may not always be of the classes you might expect. So be sure to ask for a value's `-class` when testing the services.

UUIDs: For backwards-compatibility with `MGTwitterEngine`, each Task object creates its very own a unique string identifier (or UUID) inside `-init`. These unique string identifiers are compatible with `MGTwitterEngine`'s and may be used as keys in dictionaries if you so desire. However, they are deprecated, to be removed in the (hopefully near) future. If anything, the task itself should be stored in a collection, but usually this is not necessary, as each task encapsulates sufficient information inside it for determining any contextual information needed to understand the returned data.


Other people's Source Code used in this project
===============================================

This code requires the aforementioned `NSString` and `NSData` files, which are borrowed directly from `MGTwitterEngine`. Similarly, this README file and the Source Code license borrowed heavily from their `MGTwitterEngine` counterparts.

The class `SDSocialNetworkTask` uses JSON parsing, and does not ask for, or parse, XML data at all. The JSON library `YAJL.framework` is an ObjC framework (wrapper) around a C library, both having been written by Lloyd Hilaiel.

For more information about `yajl` and `YAJL.framework`, visit <http://lloyd.github.com/yajl/>



SDSocialNetworkManager and the iPhone
=====================================

This project doesn't use any classes which (as far as I know) are unavailable on the iPhone SDK. Similarly, `YAJL.framework` should work just fine when compiled against the iPhone SDK. Thus, it should be perfectly suitable for using on the iPhone SDK.

Note: I have not tested this against the iPhone SDK as of the date of writing (5-29-09) so if anyone tests it and finds that it either works or fails, please let me know!


Standard ending of a README
===========================

That's about it. If you have trouble with the code, or want to make a feature request or report a bug (or even contribute some improvements), you can get in touch with me using the info below. I hope you enjoy using `SDSocialNetworkManager`!

`Steven Degutis`

* Web: <http://degutis.org>
* AIM: `stevendegutis`
* MSN: `steven.degutis@hotmail.com`
* Twitter: `sdegutis`

P.S. Special thanks to Matt Gemmell for providing the initial structure of this README and the Source Code License file! Thanks also to Matt for the idea of a twitter engine Cocoa class, and thanks to `@chockenberry` for finding `yajl`



Mac and iPhone Developer for Hire
=================================

If you'd like to hire me for your own Mac OS X (Cocoa) or iPhone / iPod Touch development project, take a look at my consulting site at <http://hire.degutis.org>
