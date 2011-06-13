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

#import "UILabel+BMRoundedRectAdditions.h"


static CGSize BMRoundedRectAdditions_UILabel_sizeThatFits(id self, SEL _cmd, CGSize size)
{
    // Locate the method that would be invoked by [super sizeThatFits:...]
    Method method = NULL;
    for (Class class = object_getClass(self); method == NULL; ) {
        class = class_getSuperclass(class);
        method = class_getInstanceMethod(class, _cmd);
    }
    
    // Invoke
    //
    //   size = [super sizeThatFits:size];
    //
    // using the method determined above. We explicitly avoid objc_msgSendSuper and
    // objc_msgSendSuper_stret here, because of their unclear semantics with respect
    // to the CGSize structure return type.
    //
    CGSize (*super_sizeThatFits)(id, SEL, CGSize) = (CGSize(*)(id, SEL, CGSize))method_getImplementation(method);
    size = (*super_sizeThatFits)(self, _cmd, size);
    size.width += (CGFloat)14.0f;
    return size;
}

static void BMRoundedRectAdditions_UILabel_drawRect(id self, SEL _cmd, CGRect rect)
{
    if (![self isHighlighted]) {
        CGRect bounds = [self bounds];
        UIColor *color = [UIColor colorWithRed:0.530f green:0.600f blue:0.738f alpha:1.000f];
        CGFloat radius = bounds.size.height / (CGFloat)2.0f;
        
        // Setup the path
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + radius);
        
        // First corner
        CGContextAddArcToPoint(context, bounds.origin.x, bounds.origin.y, bounds.origin.x + radius, bounds.origin.y, radius);
        CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y);
        
        // Second corner
        CGContextAddArcToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, bounds.origin.y + radius, radius);
        CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height - radius);
        
        // Third corner
        CGContextAddArcToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, bounds.origin.x + bounds.size.width - radius, bounds.origin.y + bounds.size.height, radius);
        CGContextAddLineToPoint(context, bounds.origin.x + radius, bounds.origin.y + bounds.size.height);
        
        // Fourth corner
        CGContextAddArcToPoint(context, bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, bounds.origin.y + bounds.size.height - radius, radius);
        CGContextAddLineToPoint(context, bounds.origin.x, bounds.origin.y + radius);
        
        // Finalize the path
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillPath(context);
    }
    
    // [super drawRect:rect];
    struct objc_super super = { self, class_getSuperclass(object_getClass(self)) };
    void (*super_drawRect)(struct objc_super *, SEL, CGRect) = (void(*)(struct objc_super *, SEL, CGRect))&objc_msgSendSuper;
    (*super_drawRect)(&super, _cmd, rect);
}


static NSString *const BMRoundedRectAdditionsPrefix = @"__BMRoundedRectAdditions__class_";

@implementation UILabel (BMRoundedRectAdditions)

@dynamic showsRoundedRect;

- (BOOL)showsRoundedRect
{
    return [NSStringFromClass(object_getClass(self)) hasPrefix:BMRoundedRectAdditionsPrefix];
}

- (void)setShowsRoundedRect:(BOOL)showsRoundedRect
{
    Class class = object_getClass(self);
    NSString *className = NSStringFromClass(class);
    if (showsRoundedRect) {
        if (![className hasPrefix:BMRoundedRectAdditionsPrefix]) {
            // Check if we already constructed an appropriate subclass
            NSString *newClassName = [BMRoundedRectAdditionsPrefix stringByAppendingString:className];
            Class newClass = NSClassFromString(newClassName);
            if (!newClass) {
                // Construct a new subclass named BMRoundedRectAdditionsPrefix+className
                newClass = objc_allocateClassPair(class, [newClassName cStringUsingEncoding:NSNEXTSTEPStringEncoding], 0);
                char types[128];
                
                // - (void)drawRect:(CGRect)rect
                snprintf(types, sizeof(types), "%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(CGRect));
                class_addMethod(newClass, @selector(drawRect:), (IMP)BMRoundedRectAdditions_UILabel_drawRect, types);
                
                // - (CGSize)sizeThatFits:(CGSize)size
                snprintf(types, sizeof(types), "%s%s%s%s", @encode(CGSize), @encode(id), @encode(SEL), @encode(CGSize));
                class_addMethod(newClass, @selector(sizeThatFits:), (IMP)BMRoundedRectAdditions_UILabel_sizeThatFits, types);
                
                objc_registerClassPair(newClass);
            }
            
            // Perform the "isa wizzling"
            object_setClass(self, newClass);
            [self setNeedsLayout];
        }
    }
    else if ([className hasPrefix:BMRoundedRectAdditionsPrefix]) {
        // Perform the "isa wizzling"
        class = class_getSuperclass(class);
        object_setClass(self, class);
        [self setNeedsLayout];
    }
}

@end
