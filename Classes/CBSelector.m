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
#import "CBProtocol.h"
#import "CBSelector.h"


@implementation CBSelector

+ (NSArray *)registeredSelectors
{
    static NSArray *registeredSelectors = nil;
    if (!registeredSelectors) {
        NSMutableSet *selectors = [NSMutableSet new];
        for (CBClass *class in [CBClass registeredClasses]) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            [selectors unionSet:[class classSelectors]];
            [selectors unionSet:[class instanceSelectors]];
            [pool release];
        }
        for (CBProtocol *protocol in [CBProtocol registeredProtocols]) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            [selectors unionSet:[protocol classSelectors]];
            [selectors unionSet:[protocol instanceSelectors]];
            [pool release];
        }
        registeredSelectors = [[selectors allObjects] copy];
        [selectors release];
    }
    return registeredSelectors;
}

+ (CBSelector *)selectorWithSelector:(SEL)aSelector
{
    return [[[self alloc] initWithSelector:aSelector] autorelease];
}

- (id)init
{
    return [self initWithSelector:NULL];
}

- (id)initWithSelector:(SEL)aSelector
{
    self = [super init];
    if (self) {
        if (!aSelector) {
            [self release];
            return nil;
        }
        _selector = aSelector;
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [super dealloc];
}

- (BOOL)isEqual:(id)anObject
{
    return ([anObject isMemberOfClass:[CBSelector class]]
            && _selector == ((CBSelector *)anObject)->_selector);
}

- (NSUInteger)hash
{
    // The two least significant bits are
    // meaningless due to pointer alignment
    return (size_t)_selector >> 2;
}

- (NSString *)name
{
    if (!_name) {
        _name = [NSStringFromSelector(_selector) copy];
    }
    return _name;
}

@end
