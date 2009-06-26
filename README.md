CocoaREST - Cocoa Library
=========================

* Created by [Steven Degutis](http://degutis.org)



What is CocoaREST?
==================

CocoaREST is a family of classes for the Cocoa and Cocoa Touch platforms, which allows developers to interact with RESTful APIs on the internet.

The basic workflow is something like this:

* Instantiate a long-living object of a SDNetTaskManager subclass representing the service you want to use (ie SDTwitterTaskManager)
* Set its delegate, success and fail selectors, and any other properties the subclass may specify
* Instantiate a short-lived object of its counterpart SDNetTask subclass (ie SDTwitterTask)
* Set properties on this task object (which correspond to query arguments in the chosen RESTful service)
* Run the task and catch its results (or errors) in the 2 delegate methods

It's really that simple. The key thing to remember are that @properties in both subclasses are usually representative of query arguments.

Some features:

* Lightweight and easy to get started with
* Tasks are run asynchronously in background threads
* Easily extensible to support more services in the future (many are planned)
* Easily maintainable to support changes in currently supported services' APIs



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
		
		// create and run a basic task
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


Integrating CocoaREST into your app
===================================

1. Copy all the files from the Source directory, into your own project. For now, developers will need to link against the dynamic library libcrypto.dylib (which comes standard on all modern versions of Mac OS X and is available on the iPhone SDK as well).


2. Just follow the above example, peeking at the header files when necessary. Make sure to include the header for the specific Manager subclass you're using.



CocoaREST and the iPhone
========================

This project doesn't use any classes which are unavailable on the iPhone SDK, excepting NSColor (a UIColor counterpart coming soon!). The `YAJL` C library's source code (under the Source dir) works just fine when compiled against the iPhone SDK. Thus, `CocoaREST` is perfectly suitable for use on the iPhone SDK.



A note on threads and performance
=================================

`SDNetTask` objects are run in separate threads in the background, to both increase performance and improve the user's experience. However, despite any worries this may invoke, the vast majority of use-cases should not worry about thread-safety, since the delegate methods are always called on the main thread, and the task waits until the delegate is finished before continuing execution in the background thread. Thus, it is perfectly safe to access any @properties on the task from the main thread, after the task has completed. This allows developers to implement such functionality as iterating through the returned values and storing them in a Core Data context, without worrying about data corruption at all.



Compatibility with MGTwitterEngine
==================================

Most (if not all) MGTwitterEngine code should work just fine with CocoaREST.

**UUIDs:** For compatibility with MGTwitterEngine, each Task object creates its very own a unique string identifier (or UUID) inside `-init`. These unique string identifiers are compatible with MGTwitterEngine's and may be used as keys in dictionaries if you so desire. However, they are deprecated, to be removed in the (hopefully near) future. If anything, the task itself should be stored in a collection, but usually this is not necessary, as each task encapsulates sufficient information inside it for determining any contextual information needed to understand the returned data.



Other people's Source Code used in this project
===============================================

This code requires the aforementioned `NSString` and `NSData` files, which are borrowed directly from MGTwitterEngine. Similarly, this README file and the Source Code license borrowed heavily from their MGTwitterEngine counterparts.

The class `SDNetTask` uses JSON parsing (and will support XML in the near future). The JSON library used is [`yajl`](http://lloyd.github.com/yajl/) (written in C), and was written by Lloyd Hilaiel.



Heartfelt Goodbyes
==================

That's about it. If you have trouble with the code, or want to make a feature request or report a bug (or even contribute some improvements), you can get in touch with me using the info below. I hope you enjoy using CocoaREST!

Sincerely, `Steven Degutis`

* Web: <http://degutis.org>
* AIM: `stevendegutis`
* MSN: `steven.degutis@hotmail.com`
* Twitter: `sdegutis`

P.S. Special thanks to Matt Gemmell for providing the initial structure of this README and the Source Code License file! Thanks also to Matt for the idea of a twitter engine Cocoa class, and thanks to `@chockenberry` for finding `yajl`

P.P.S. Since this README file was first written, the API has undergone tremendous changes in the past 24 hours. So, if you find any inconsistencies I may have missed, let me know so I can fix them!


Mac and iPhone Developer for Hire
=================================

If you'd like to hire me for your own Mac OS X (Cocoa) or iPhone / iPod Touch development project, take a look at my consulting site at <http://hire.degutis.org>
