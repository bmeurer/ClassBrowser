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

#import "CBClass.h"
#import "CBFramework.h"


static CBFramework *CBFrameworkHashTable[227] = { NULL, };

static unsigned CBFrameworkHash(NSBundle *bundle)
{
    // The two least significant bits are meaningless due to pointer alignment
    return ((size_t)bundle >> 2) % (sizeof(CBFrameworkHashTable) / sizeof(*CBFrameworkHashTable));
}


@implementation CBFramework

+ (void)initialize
{
    NSAssert(self == [CBFramework class], @"You must not subclass CBFramework!");
    
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
}

+ (NSArray *)registeredFrameworks
{
    static NSArray *allFrameworks = nil;
    if (!allFrameworks) {
        NSArray *const bundles = [NSBundle allFrameworks];
        NSBundle *const mainBundle = [NSBundle mainBundle];
        NSMutableArray *frameworks = [[NSMutableArray alloc] initWithCapacity:[bundles count]];
        for (NSBundle *bundle in bundles) {
            if (bundle != mainBundle) {
                [frameworks addObject:[self frameworkWithBundle:bundle]];
            }
        }
        allFrameworks = [frameworks copy];
        [frameworks release];
    }
    return allFrameworks;
}

+ (CBFramework *)frameworkWithBundle:(NSBundle *)aBundle
{
    CBFramework *framework;
    CBFramework **fp = &CBFrameworkHashTable[CBFrameworkHash(aBundle)];
    for (framework = *fp; framework; framework = framework->_next) {
        if (framework->_bundle == aBundle) {
            break;
        }
    }
    if (!framework && aBundle && aBundle != [NSBundle mainBundle]) {
        framework = [[self alloc] init];
        if (framework) {
            framework->_bundle = [aBundle retain];
            framework->_next = *fp;
            *fp = framework;
        }
    }
    return framework;
}

- (id)initWithBundle:(NSBundle *)aBundle
{
    if (aBundle && aBundle != [NSBundle mainBundle]) {
        CBFramework **fp = &CBFrameworkHashTable[CBFrameworkHash(aBundle)];
        for (CBFramework *framework = *fp; framework; framework = framework->_next) {
            if (framework->_bundle == aBundle) {
                [self release];
                return framework;
            }
        }
        self = [self init];
        if (self) {
            self->_bundle = [aBundle retain];
            self->_next = *fp;
            *fp = self;
        }
    }
    else {
        [self release];
        self = nil;
    }
    return self;
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

- (BOOL)isEqual:(id)anObject
{
    return ([anObject isMemberOfClass:[CBFramework class]]
            && _bundle == ((CBFramework *)anObject)->_bundle);
}

- (NSUInteger)hash
{
    // The two least significant bits are
    // meaningless due to pointer alignment
    return (size_t)_bundle >> 2;
}

- (NSBundle *)bundle
{
    return _bundle;
}

- (NSArray *)classes
{
    if (!_classes) {
        NSMutableArray *classes = [[NSMutableArray alloc] init];
        for (CBClass *class in [CBClass registeredClasses]) {
            if ([class framework] == self) {
                [classes addObject:class];
            }
        }
        _classes = [classes copy];
        [classes release];
    }
    return _classes;
}

- (NSString *)name
{
    if (!_name) {
        _name = [([_bundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] ?: [[[_bundle bundlePath] lastPathComponent] stringByDeletingPathExtension]) copy];
    }
    return _name;
}

@end
