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
#import "CBMethod.h"
#import "CBProtocol.h"
#import "CBSelector.h"


static unsigned CBClassHash(Class class);
static NSSet *CBSelectorsFromClass(Class class);

static CBClass *CBClassHashTable[7457] = { NULL, };

static unsigned CBClassHash(Class class)
{
    // The two least significant bits are meaningless due to pointer alignment
    return ((size_t)class >> 2) % (sizeof(CBClassHashTable) / sizeof(*CBClassHashTable));
}

static NSSet *CBSelectorsFromClass(Class class)
{
    unsigned i, j, methodCount = 0;
    Method *methodList = class_copyMethodList(class, &methodCount);
    for (i = j = 0; i < methodCount; ++i) {
        CBSelector *selector = [[CBSelector alloc] initWithSelector:method_getName(methodList[i])];
        if (selector) {
            methodList[j++] = (Method)selector;
        }
    }
    NSSet *selectors = [NSSet setWithObjects:(id *)methodList count:j];
    while (j > 0) {
        [(id)methodList[--j] release];
    }
    free(methodList);
    return selectors;
}


@implementation CBClass

+ (void)initialize
{
    NSAssert(self == [CBClass class], @"You must not subclass CBClass");
    
    // Forcibly trigger initialization of CBFramework to make
    // sure that all frameworks are loaded into this process
    [CBFramework self];
}

+ (NSArray *)registeredClasses
{
    static NSArray *registeredClasses = nil;
    if (!registeredClasses) {
        unsigned i, j, classCount = 0;
        Class *const classList = objc_copyClassList(&classCount);
        for (i = j = 0; i < classCount; ++i) {
            CBClass *const class = [self classWithClass:classList[i]];
            if (class && [class framework]) {
                classList[j++] = (Class)class;
            }
        }
        registeredClasses = [[NSArray alloc] initWithObjects:(const id *)classList count:j];
        free(classList);
    }
    return registeredClasses;
}

+ (CBClass *)classWithClass:(Class)aClass
{
    CBClass *class;
    CBClass **cp = &CBClassHashTable[CBClassHash(aClass)];
    for (class = *cp; class; class = class->_next) {
        if (class->_class == aClass) {
            break;
        }
    }
    if (!class && aClass) {
        class = [[self alloc] init];
        if (class) {
            class->_class = aClass;
            class->_next = *cp;
            *cp = class;
        }
    }
    return class;
}

- (id)initWithClass:(Class)aClass
{
    if (aClass) {
        CBClass **cp = &CBClassHashTable[CBClassHash(aClass)];
        for (CBClass *class = *cp; class; class = class->_next) {
            if (class->_class == aClass) {
                [self release];
                return class;
            }
        }
        self = [self init];
        if (self) {
            self->_class = aClass;
            self->_next = *cp;
            *cp = self;
        }
    }
    else {
        [self release];
        self = nil;
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

- (BOOL)isEqual:(id)anObject
{
    return ([anObject isMemberOfClass:[CBClass class]]
            && _class == ((CBClass *)anObject)->_class);
}

- (NSUInteger)hash
{
    // The two least significant bits are
    // meaningless due to pointer alignment
    return (size_t)_class >> 2;
}

- (CBFramework *)framework
{
    if (!_framework) {
        _framework = [CBFramework frameworkWithBundle:[NSBundle bundleForClass:_class]];
    }
    return _framework;
}

- (NSString *)name
{
    if (!_name) {
        _name = [NSStringFromClass(_class) copy];
    }
    return _name;
}

- (NSUInteger)instanceSize
{
    return class_getInstanceSize(_class);
}

- (NSInteger)version
{
    return class_getVersion(_class);
}

- (BOOL)isSubClassOfClass:(CBClass *)aClass
{
    return [aClass isSuperClassOfClass:self];
}

- (NSArray *)subClasses
{
    if (!_subClasses) {
        NSMutableArray *subClasses = [[NSMutableArray alloc] init];
        for (CBClass *class in [[self class] registeredClasses]) {
            if ([self isSuperClassOfClass:class]) {
                [subClasses addObject:class];
            }
        }
        _subClasses = [subClasses copy];
        [subClasses release];
    }
    return _subClasses;
}

- (BOOL)isSuperClassOfClass:(CBClass *)aClass
{
    for (Class class = aClass ? aClass->_class : Nil; class; class = class_getSuperclass(class)) {
        if (class == _class) {
            return YES;
        }
    }
    return NO;
}

- (CBClass *)superClass
{
    return [CBClass classWithClass:class_getSuperclass(_class)];
}

- (NSSet *)classSelectors
{
    return CBSelectorsFromClass(_class->isa);
}

- (NSSet *)instanceSelectors
{
    return CBSelectorsFromClass(_class);
}

- (NSArray *)methods
{
    if (!_methods) {
        unsigned i, j, methodCount = 0;
        Method *methodsList = class_copyMethodList(_class, &methodCount);
        for (i = j = 0; i < methodCount; ++i) {
            CBMethod *method = [CBMethod methodWithMethod:methodsList[i]];
            if (method) {
                methodsList[j++] = (Method)method;
            }
        }
        _methods = [[NSArray alloc] initWithObjects:(const id *)methodsList count:j];
        free(methodsList);
    }
    return _methods;
}

- (NSSet *)protocols
{
    unsigned i, j, protocolCount = 0;
    Protocol **protocolList = class_copyProtocolList(_class, &protocolCount);
    for (i = j = 0; i < protocolCount; ++i) {
        CBProtocol *protocol = [CBProtocol protocolWithProtocol:protocolList[i]];
        if (protocol) {
            protocolList[j++] = (Protocol *)protocol;
        }
    }
    NSSet *protocols = [NSSet setWithObjects:(id *)protocolList count:j];
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

@end
