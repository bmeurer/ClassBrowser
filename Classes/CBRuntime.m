/*-
 * Copyright (c) 2011, Benedikt Meurer <benedikt.meurer@googlemail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <objc/runtime.h>

#import "CBClass.h"
#import "CBFramework.h"
#import "CBRuntime.h"


@implementation CBRuntime

@synthesize allClasses = _allClasses;
@synthesize allFrameworks = _allFrameworks;
@synthesize allProtocols = _allProtocols;

static CBRuntime *sharedRuntime = nil;

+ (CBRuntime *)sharedRuntime
{
    @synchronized(self) {
        if (!sharedRuntime) {
            sharedRuntime = [[self alloc] init];
        }
    }
    return sharedRuntime;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (!sharedRuntime) {
            sharedRuntime = [super allocWithZone:zone];
            return sharedRuntime;
        }
    }
    return nil;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (void)release
{
    
}

- (id)autorelease
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
#if !TARGET_IPHONE_SIMULATOR
        // Forcibly load all frameworks in the Library/Frameworks/ directories of the system domain
        for (NSString *libraryDirectoryPath in NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSSystemDomainMask, NO)) {
            NSString *frameworksDirectoryPath = [libraryDirectoryPath stringByAppendingPathComponent:@"Frameworks"];
            for (NSString *fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:frameworksDirectoryPath error:NULL]) {
                NSAutoreleasePool *pool = [NSAutoreleasePool new];
                [[NSBundle bundleWithPath:[frameworksDirectoryPath stringByAppendingPathComponent:fileName]] load];
                [pool release];
            }
        }
#endif

        // Determine all classes within all (loaded) frameworks
        unsigned klassCount = 0, klassIndex;
        Class *klassList = objc_copyClassList(&klassCount);
        _frameworks = [[NSMutableDictionary alloc] init];
        _classes = [[NSMutableDictionary alloc] initWithCapacity:klassCount];
        for (klassIndex = 0; klassIndex < klassCount; ++klassIndex) {
            CBClass *class = [[CBClass alloc] initWithClass:klassList[klassIndex]];
            if (class) {
                NSBundle *bundle = class.bundle;
                NSString *bundleIdentifier = [bundle bundleIdentifier];
                if (bundleIdentifier && bundle != [NSBundle mainBundle]) {
                    CBFramework *framework = [_frameworks objectForKey:bundleIdentifier];
                    if (!framework) {
                        framework = [[CBFramework alloc] initWithBundle:bundle];
                        if (framework) {
                            [_frameworks setObject:framework forKey:bundleIdentifier];
                            [framework release];
                        }
                    }
                    if (framework) {
                        [_classes setObject:class forKey:class.name];
                    }
                }
                [class release];
            }
        }
        free(klassList);
        
        // Add all frameworks without classes
        for (NSBundle *bundle in [NSBundle allFrameworks]) {
            NSString *bundleIdentifier = [bundle bundleIdentifier];
            if (bundleIdentifier && bundle != [NSBundle mainBundle]) {
                CBFramework *framework = [_frameworks objectForKey:bundleIdentifier];
                if (!framework) {
                    framework = [[CBFramework alloc] initWithBundle:bundle];
                    if (framework) {
                        [_frameworks setObject:framework forKey:bundleIdentifier];
                        [framework release];
                    }
                }
            }
        }
        
        // Determine all protocols
        unsigned protocolCount = 0, protocolIndex;
        Protocol **protocolList = objc_copyProtocolList(&protocolCount);
        _protocols = [[NSMutableDictionary alloc] initWithCapacity:protocolCount];
        for (protocolIndex = 0; protocolIndex < protocolCount; ++protocolIndex) {
            CBProtocol *protocol = [[CBProtocol alloc] initWithProtocol:protocolList[protocolIndex]];
            if (protocol) {
                [_protocols setObject:protocol forKey:protocol.name];
                [protocol release];
            }
        }
        free(protocolList);
        
        // Collect the classes, frameworks and protocols
        _allClasses = [[_classes allValues] retain];
        _allFrameworks = [[_frameworks allValues] retain];
        _allProtocols = [[_protocols allValues] retain];
    }
    return self;
}

@end
