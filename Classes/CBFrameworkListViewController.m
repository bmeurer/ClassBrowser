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

#import "CBClassListViewController.h"
#import "CBFrameworkDetailsViewController.h"
#import "CBFrameworkListViewController.h"


@implementation CBFrameworkListViewController

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - Properties

- (NSArray *)objects
{
    return [[CBRuntime sharedRuntime] allFrameworks];
}

- (void)setObjects:(NSArray *)objects
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You may not set objects for CBFrameworkListViewController instances."];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    // Configure the cell...
    CBFramework *framework = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d classes", [framework.classes count]];
    cell.imageView.image = [UIImage imageNamed:@"framework"];
    cell.textLabel.text = framework.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    CBFramework *framework = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    CBFrameworkDetailsViewController *frameworkDetailsViewController = [[CBFrameworkDetailsViewController alloc] initWithNibName:@"FrameworkDetailsViewController" bundle:nil];
    frameworkDetailsViewController.framework = framework;
    [self.navigationController pushViewController:frameworkDetailsViewController animated:YES];
    [frameworkDetailsViewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBFramework *framework = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    CBClassListViewController *classListViewController = [[CBClassListViewController alloc] initWithNibName:@"ClassListViewController" bundle:nil];
    classListViewController.classes = framework.classes;
    classListViewController.title = framework.name;
    [self.navigationController pushViewController:classListViewController animated:YES];
    [classListViewController release];
}

@end
