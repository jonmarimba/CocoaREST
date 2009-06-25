CocoaREST - Cocoa Library
=========================

* Created by [Steven Degutis](http://degutis.org)
* Recently renamed yet again (this time for the final time, thank goodness!) to CocoaREST


What is CocoaREST?
==================

CocoaREST is a family of classes for the Cocoa (and Cocoa Touch) platforms, which allows developers to interact with RESTful APIs on the internet. There are two abstract superclasses:

* SDNetTaskManager

	* Handles user-specified information (username, password, rate-limiting information, etc.) about the social network, and is necessary for running tasks
	* The lifespan of this object is generally as long as your controller object

* SDNetTask

	* Handles task-specific arguments and data (such as `statusID`, `page`, `text`, `count`, etc.)
	* returns information from the service in the form of Cocoa classes (`NSDictionary`, `NSArray`, `NSNumber`, `NSString`, etc.)
	* The lifespan of this object is generally very short, and it should rarely, if ever, be retained
	* Runs in a separate thread when `-run` is called, and calls its delegate methods on the main thread when completed

There are several concrete subclasses of these two, which allow developers to interact with specific web APIs:

	* `SDTwitterManager`/`SDTwitterTask`, interacts with Twitter.com (view [<http://apiwiki.twitter.com/REST+API+Documentation>](API))
	* `SDIdenticaManager`/`SDIdenticaTask`, interacts with identi.ca (in progress!)
	* `SDFriendfeedManager`/`SDFriendfeedTask`, interacts with Friendfeed.com (in progress!)

These classes have been designed specifically for developers to *easily* be able to extend the functionality of existing services by making minor adjustments inside these APi-specific class files, which is becoming a necessity these days with the way these APIs are rapidly changing.


Why use it?
===========

The CocoaREST family of Cocoa Classes are designed to be flexible, powerful, and incredibly simple and transparent to use. Here are just some advantages:

* Uses modern, up-to-date APIs. For example, SDTwitterTask uses "statuses/mentions" versus the archaic "statuses/replies"

* Designed from the ground up to be easily maintainable and extendable by any developer, for extending current and implementing future RESTful APIs

* Is built to support multiple services, including (but not limited to) Twitter, Identi.ca, and Friendfeed

* Has large, automatic performance boosts, due to taking advantage of the modern technologies available in Mac OS X 10.5 Leopard, such as multi-threading (via NSOperation/Queue) and synthesized, atomic, thread-safe @properties
	* `SDNetTasks` runs smoothly in background threads, and can even run simultaneously with other `SDNetTasks`
	* Uses an optimized JSON parser to handle returned values stunningly quickly
	* User experience is greatly improved, since the user will never see a spinning wheel due to a running Task

* Requested returned values are returned in the format available for that specific API (either XML or JSON), and parsed with either `LibXML` or `YAJL`, which maximizes the number of supported services and API calls


Sample Code
===========

	- (void) awakeFromNib {
		// inside a header file, declare manager as an instance variable
		SDTwitterManager *manager;
		
		// create out manager, retaining it as we want it to stick around
		manager = [[SDTwitterManager manager] retain];
		manager.successSelector = @selector(twitterManager:resultsReadyForTask:);
		manager.failSelector = @selector(twitterManager:failedForTask:);
		manager.delegate = self;
		
		// this is a must for certain API calls which require authentication
		// change them to real login values or the tasks will fail
		manager.username = @"USERNAME";
		manager.password = @"PASSWORD";
		
		// 3 tasks can be run simultaneously
		manager.maxConcurrentTasks = 3;
		
		// create a basic task
		SDTwitterTask *mentionsTask = [SDTwitterTask taskWithManager:manager];
		mentionsTask.type = SDTwitterTaskGetPersonalTimeline;
		mentionsTask.count = 3;
		mentionsTask.page = 10;
		[mentionsTask run];
	}

	- (void) twitterManager:(SDTwitterManager*)manager resultsReadyForTask:(SDTwitterTask*)task {
		NSLog(@"%@", task.results);
	}

	- (void) twitterManager:(SDTwitterManager*)manager failedForTask:(SDTwitterTask*)task {
		NSLog(@"%@", task.error);
	}


How to use CocoaREST
====================

Using `CocoaREST` is easy. The basic steps are:


1. Copy all the files from the Source directory, into your own project. For now, developers will need to link against the dynamic library libcrypto.dylib (which comes standard on all modern versions of Mac OS X and is available on the iPhone SDK as well).


2. Pick your a service-specific pair of subclasses, such as SDTwitterManager and SDTwitterTask, and #import their header files into whatever class you plan to use them in. The `AppDelegate.h` header file in the demo project is an example you can use.


3. Implement the delegate methods you have chosen, just as the AppDelegate in the demo project does. Inside your delegate methods, you can access the Manager and Task objects to fully see the context surrounding `task.results`. For example, if you were implementing `SDTwitterTaskDelegate`, these are the methods you'd need to implement:

	- (void) twitterManager:(SDTwitterManager*)manager resultsReadyForTask:(SDTwitterTask*)task;
	- (void) twitterManager:(SDTwitterManager*)manager failedForTask:(SDTwitterTask*)task;

4. Create and `-run` some tasks! The Header files are very self-explanatory and well-documented. However, it is recommended that you take a look at the section below as well.



More in-depth explanation of usage
==================================

The bare basics that are required to request data from or send data to a social network, are as follows:

* Instantiate an object of a concrete `SDNetTaskManager` subclass (usually using `+manager`)

	* Set its `delegate`, along with the `successSelector` and `failSelector`
		* Read SDNetManager.h for information on what the signature of these selectors should look like
	* Set its `username` and `password`, if any of your tasks will require authentication
	* Optionally, you can set the specific Manager's settings. For instance, SDTwitterManager declares `appName`, `appVersion`, and `appWebsite`
	* For more control, you can set the maximum tasks that can be run simultaneously, via the `maxConcurrentTasks` @property
	* Be sure to look inside `SDNetTaskManager.h` as well as the header for your specific Manager subclass

* Instantiate an object of a concrete `SDNetTask` subclass (usually using `+taskWithManager:`)

	* Set the task's `type` @property it should use (values are located in the Task subclass's header files)
	* Set any required properties for the specified task (ie. `screenName`, `text`, or `statusID`)
	* Check the Task subclass's header file for a list of writable properties, and types of services/tasks

* Run the task via `[task run]`, which runs asynchronously

	* Implement the Task's specific delegate methods to handle any returned data
	* After every SDTwitterTasks, its `SDTwitterManager` object will have new rate-limiting information set on it. You can reliably et this data from the `SDTwitterManager` @properties `limitMaxAmount`, `limitRemainingAmount`, and `limitResetEpochDate`, whenever necessary. They will always reflect the real-time limiting information inside the delegate methods
	* The `results` @property of the task object will contain returned information from the social networking service.
	* Once a task has completed, it will deallocate on its own. It should not be retained, and cannot be run a second time (as it is an NSOperation subclass).



A note on threads and performance
=================================

`SDNetTask` objects are run in separate threads in the background, to both increase performance and improve the user's experience. However, despite any worries this may invoke, the vast majority of use-cases should not worry about thread-safety, since all delegate methods are called on the main thread, and the task waits until the delegate is finished before continuing execution in the background thread. Thus, it is perfectly safe to access any @properties on the task from the main thread, after the task has completed. This allows you to implement such functionality as iterating through the returned values and storing them in a Core Data context, without worrying about data corruption at all.



A note about the format of returned values
==========================================

You may get any kind of ObjC type in the `results` property, anything from `NSArray` to `NSDictionary`, `NSString` to `NSNumber`, etc. Because of the JSON parser, these results (or the objects in a collection) may not always be of the classes you might expect. So be sure to ask for a value's `-class` when testing the services.

UUIDs: For backwards-compatibility with `MGTwitterEngine`, each Task object creates its very own a unique string identifier (or UUID) inside `-init`. These unique string identifiers are compatible with `MGTwitterEngine`'s and may be used as keys in dictionaries if you so desire. However, they are deprecated, to be removed in the (hopefully near) future. If anything, the task itself should be stored in a collection, but usually this is not necessary, as each task encapsulates sufficient information inside it for determining any contextual information needed to understand the returned data.



Creating a subclass-pair of SDNetTaskManager/Task
=======================================================

Coming soon!



Other people's Source Code used in this project
===============================================

This code requires the aforementioned `NSString` and `NSData` files, which are borrowed directly from `MGTwitterEngine`. Similarly, this README file and the Source Code license borrowed heavily from their `MGTwitterEngine` counterparts.

The class `SDNetTask` uses JSON parsing (and will support XML in the near future). The JSON library used is `yajl` (written in C), and was written by Lloyd Hilaiel. For more information about `yajl`, visit <http://lloyd.github.com/yajl/>



CocoaREST and the iPhone
===========================

This project doesn't use any classes which (as far as I know) are unavailable on the iPhone SDK, excepting NSColor (a UIColor counterpart coming soon!). Similarly, the `YAJL` C static library works just fine when compiled against the iPhone SDK. Thus, `CocoaREST` is perfectly suitable for use on the iPhone SDK.


Standard ending of a README
===========================

That's about it. If you have trouble with the code, or want to make a feature request or report a bug (or even contribute some improvements), you can get in touch with me using the info below. I hope you enjoy using CocoaREST!

`Steven Degutis`

* Web: <http://degutis.org>
* AIM: `stevendegutis`
* MSN: `steven.degutis@hotmail.com`
* Twitter: `sdegutis`

P.S. Special thanks to Matt Gemmell for providing the initial structure of this README and the Source Code License file! Thanks also to Matt for the idea of a twitter engine Cocoa class, and thanks to `@chockenberry` for finding `yajl`

P.P.S. Since this README file was first written, the API has undergone tremendous changes in the past 24 hours. So, if you find any inconsistencies I may have missed, let me know so I can fix them!


Mac and iPhone Developer for Hire
=================================

If you'd like to hire me for your own Mac OS X (Cocoa) or iPhone / iPod Touch development project, take a look at my consulting site at <http://hire.degutis.org>
