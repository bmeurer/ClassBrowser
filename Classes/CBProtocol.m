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

#import "CBRuntime.h"


@implementation CBProtocol

@synthesize name = _name;

- (id)init
{
    return [self initWithProtocol:nil];
}

- (id)initWithProtocol:(Protocol *)aProtocol
{
    self = [super init];
    if (self) {
        _name = [NSStringFromProtocol(aProtocol) retain];
        if (!_name) {
            [self release];
            return nil;
        }
        _protocol = aProtocol;
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
    return ([anObject isMemberOfClass:[CBProtocol class]]
            && [[self name] isEqualToString:[anObject name]]);
}

- (NSUInteger)hash
{
    return [[self name] hash];
}

- (NSSet *)protocols
{
    unsigned i, j, protocolCount = 0;
    Protocol **protocolList = protocol_copyProtocolList(_protocol, &protocolCount);
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

@end
