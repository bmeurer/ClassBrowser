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

#import "CBFramework.h"
#import "CBProtocol.h"
#import "CBSelector.h"


static unsigned CBProtocolHash(Protocol *protocol);
static NSSet *CBSelectorsFromProtocol(Protocol *protocol, BOOL isRequiredMethod, BOOL isInstanceMethod);

static CBProtocol *CBProtocolHashTable[727] = { NULL, };

static unsigned CBProtocolHash(Protocol *protocol)
{
    // The two least significant bits are meaningless due to pointer alignment
    return ((size_t)protocol >> 2) % (sizeof(CBProtocolHashTable) / sizeof(*CBProtocolHashTable));
}

static NSSet *CBSelectorsFromProtocol(Protocol *protocol, BOOL isRequiredMethod, BOOL isInstanceMethod)
{
    unsigned i, j, methodCount = 0;
    struct objc_method_description *methodList = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &methodCount);
    for (i = j = 0; i < methodCount; ++i) {
        CBSelector *selector = [[CBSelector alloc] initWithSelector:methodList[i].name];
        if (selector) {
            ((CBSelector **)methodList)[j++] = selector;
        }
    }
    NSSet *selectors = [NSSet setWithObjects:(id *)methodList count:j];
    while (j > 0) {
        [((id *)methodList)[--j] release];
    }
    free(methodList);
    return selectors;
}


@implementation CBProtocol

+ (void)initialize
{
    NSAssert(self == [CBProtocol class], @"You must not subclass CBProtocol");
    
    // Forcibly trigger initialization of CBFramework to make
    // sure that all frameworks are loaded into this process
    [CBFramework self];
}

+ (NSArray *)registeredProtocols
{
    static NSArray *registeredProtocols = nil;
    if (!registeredProtocols) {
        unsigned i, j, protocolCount = 0;
        Protocol **protocolList = objc_copyProtocolList(&protocolCount);
        for (i = j = 0; i < protocolCount; ++i) {
            CBProtocol *protocol = [self protocolWithProtocol:protocolList[i]];
            if (protocol) {
                protocolList[j++] = (Protocol *)protocol;
            }
        }
        registeredProtocols = [[NSArray alloc] initWithObjects:(const id *)protocolList count:j];
        free(protocolList);
    }
    return registeredProtocols;
}

+ (CBProtocol *)protocolWithProtocol:(Protocol *)aProtocol
{
    CBProtocol *protocol;
    CBProtocol **pp = &CBProtocolHashTable[CBProtocolHash(aProtocol)];
    for (protocol = *pp; protocol; protocol = protocol->_next) {
        if (protocol->_protocol == aProtocol) {
            break;
        }
    }
    if (!protocol && aProtocol) {
        protocol = [[self alloc] init];
        if (protocol) {
            protocol->_protocol = aProtocol;
            protocol->_next = *pp;
            *pp = protocol;
        }
    }
    return protocol;
}

- (id)initWithProtocol:(Protocol *)aProtocol
{
    if (aProtocol) {
        CBProtocol **pp = &CBProtocolHashTable[CBProtocolHash(aProtocol)];
        for (CBProtocol *protocol = *pp; protocol; protocol = protocol->_next) {
            if (protocol->_protocol == aProtocol) {
                [self release];
                return protocol;
            }
        }
        self = [self init];
        if (self) {
            self->_protocol = aProtocol;
            self->_next = *pp;
            *pp = self;
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
    return ([anObject isMemberOfClass:[CBProtocol class]]
            && _protocol == ((CBProtocol *)anObject)->_protocol);
}

- (NSUInteger)hash
{
    // The two least significant bits are
    // meaningless due to pointer alignment
    return (size_t)_protocol >> 2;
}

- (NSString *)name
{
    if (!_name) {
        _name = [NSStringFromProtocol(_protocol) copy];
    }
    return _name;
}

- (NSSet *)classSelectors
{
    return [CBSelectorsFromProtocol(_protocol, NO, NO) setByAddingObjectsFromSet:CBSelectorsFromProtocol(_protocol, YES, NO)];
}

- (NSSet *)instanceSelectors
{
    return [CBSelectorsFromProtocol(_protocol, NO, YES) setByAddingObjectsFromSet:CBSelectorsFromProtocol(_protocol, YES, YES)];
}

- (NSSet *)protocols
{
    unsigned i, j, protocolCount = 0;
    Protocol **protocolList = protocol_copyProtocolList(_protocol, &protocolCount);
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
