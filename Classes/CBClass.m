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

#import "CBRuntime.h"


@implementation CBClass

@synthesize bundle = _bundle;
@synthesize methods = _methods;
@synthesize name = _name;

@dynamic framework;
@dynamic instanceSize;
@dynamic subClasses;
@dynamic superClass;
@dynamic version;

- (id)init
{
    return [self initWithClass:Nil];
}

- (id)initWithClass:(Class)aClass
{
    self = [super init];
    if (self) {
        _name = [NSStringFromClass(aClass) retain];
        if (!_name) {
            [self release];
            return nil;
        }
        _klass = aClass;
    }
    return self;
}

- (void)dealloc
{
    [_bundle release];
    [_methods release];
    [_name release];
    [super dealloc];
}

- (NSBundle *)bundle
{
    if (!_bundle) {
        _bundle = [NSBundle bundleForClass:_klass];
    }
    return _bundle;
}

- (NSArray *)methods
{
    if (!_methods) {
        unsigned i, j, methodCount = 0;
        Method *methods = class_copyMethodList(_klass, &methodCount);
        if (methods) {
            for (i = j = 0; i < methodCount; ++i) {
                id method = [[CBMethod alloc] initWithMethod:methods[i]];
                if (method) {
                    methods[j++] = (Method)method;
                }
            }
            _methods = [[NSArray alloc] initWithObjects:(const id *)methods count:j];
            while (j != 0) {
                [(id)methods[--j] release];
            }
            free(methods);
        }
    }
    return _methods;
}

- (CBFramework *)framework
{
    return [CBFramework frameworkWithBundleIdentifier:[self.bundle bundleIdentifier]];
}

- (size_t)instanceSize
{
    return class_getInstanceSize(_klass);
}

- (NSArray *)subClasses
{
    NSMutableArray *subClasses = [NSMutableArray array];
    for (CBClass *class in [[CBRuntime sharedRuntime] allClasses]) {
        if (class_getSuperclass(class->_klass) == _klass) {
            [subClasses addObject:class];
        }
    }
    return subClasses;
}

- (CBClass *)superClass
{
    return [[self class] classWithName:NSStringFromClass(class_getSuperclass(_klass))];
}

- (int)version
{
    return class_getVersion(_klass);
}

#pragma mark - Access to protocols

- (NSSet *)protocols
{
    unsigned i, j, protocolCount = 0;
    Protocol **protocolList = class_copyProtocolList(_klass, &protocolCount);
    for (i = j = 0; i < protocolCount; ++i) {
        CBProtocol *protocol = [[CBProtocol alloc] initWithProtocol:protocolList[i]];
        if (protocol) {
            protocolList[j++] = (Protocol *)protocol;
        }
    }
    NSSet *protocols = [NSSet setWithObjects:(id *)protocolList count:j];
    while (j > 0) {
        [(id)protocolList[--j] release];
    }
    free(protocolList);
    return protocols;
}

- (NSSet *)allProtocols
{
    NSSet *allProtocols = [self protocols];
    for (CBClass *class = self;; ) {
        class = [class superClass];
        if (!class) {
            break;
        }
        allProtocols = [allProtocols setByAddingObjectsFromSet:[class protocols]];
    }
    for (NSSet *protocols;; ) {
        protocols = allProtocols;
        for (CBProtocol *protocol in protocols) {
            allProtocols = [allProtocols setByAddingObjectsFromSet:[protocol protocols]];
        }
        if ([allProtocols isEqualToSet:protocols]) {
            break;
        }
    }
    return allProtocols;
}

#pragma mark - Class methods

+ (CBClass *)classWithName:(NSString *)aName
{
    return aName ? [[CBRuntime sharedRuntime]->_classes objectForKey:aName] : nil;
}

@end
