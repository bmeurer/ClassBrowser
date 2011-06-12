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


@implementation CBFramework

@synthesize bundle = _bundle;
@synthesize classes = _classes;
@synthesize name = _name;

- (id)init
{
    return [self initWithBundle:nil];
}

- (id)initWithBundle:(NSBundle *)bundle
{
    self = [super init];
    if (self) {
        _bundle = [bundle retain];
    }
    return self;
}

- (void)dealloc
{
    [_bundle release];
    [_classes release];
    [_name release];
    [super dealloc];
}

- (NSArray *)classes
{
    if (!_classes) {
        NSString *bundleIdentifier = [self.bundle bundleIdentifier];
        NSMutableArray *classes = [[NSMutableArray alloc] init];
        for (CBClass *class in [[CBRuntime sharedRuntime] allClasses]) {
            if ([bundleIdentifier isEqualToString:[class.bundle bundleIdentifier]]) {
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
        _name = [([self.bundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] ?: [[[self.bundle bundlePath] lastPathComponent] stringByDeletingPathExtension]) copy];
    }
    return _name;
}

@end
