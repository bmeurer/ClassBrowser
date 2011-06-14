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

#import "CBClassDetailsViewController.h"
#import "CBClassListViewController.h"
#import "CBMethodListViewController.h"


@implementation CBClassListViewController

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    CBClass *class = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d methods", [class.methods count]];
    cell.imageView.image = [UIImage imageNamed:@"class"];
    cell.textLabel.text = class.name;
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    CBClass *class = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    CBClassDetailsViewController *classDetailsViewController = [[CBClassDetailsViewController alloc] initWithNibName:@"ClassDetailsViewController" bundle:nil];
    classDetailsViewController.clazz = class;
    classDetailsViewController.title = @"Info";
    [self.navigationController pushViewController:classDetailsViewController animated:YES];
    [classDetailsViewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBClass *class = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    CBMethodListViewController *methodListViewController = [[CBMethodListViewController alloc] initWithNibName:@"SectionedListViewController" bundle:nil];
    methodListViewController.infoBlock = ^(CBSectionedListViewController *sectionedListViewController){
        CBClassDetailsViewController *classDetailsViewController = [[CBClassDetailsViewController alloc] initWithNibName:@"ClassDetailsViewController" bundle:nil];
        classDetailsViewController.clazz = class;
        classDetailsViewController.title = @"Info";
        [sectionedListViewController.navigationController pushViewController:classDetailsViewController animated:YES];
        [classDetailsViewController release];
    };
    methodListViewController.objects = class.methods;
    methodListViewController.title = class.name;
    [self.navigationController pushViewController:methodListViewController animated:YES];
    [methodListViewController release];
}

@end
