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

#import "CBClassDetailsViewController.h"
#import "CBProtocolListViewController.h"


@implementation CBClassDetailsViewController

@synthesize clazz = _clazz;

- (void)dealloc
{
    [_clazz release];
    [super dealloc];
}

#pragma mark - UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    numberOfSections = 2;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 2;
            break;
            
        case 1:
            numberOfRows = 3;
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            static NSString *const CellIdentifier = @"Cell0";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            }
            switch (indexPath.row) {
                case 0:
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d B", self.clazz.instanceSize];
                    cell.textLabel.text = @"Instance size";
                    break;
                }
                    
                case 1:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.clazz.version];
                    cell.textLabel.text = @"Version";
                    break;
            }
            break;
        }
            
        case 1:
        {
            static NSString *const CellIdentifier = @"Cell1";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:(CGFloat)14.0f];
                cell.detailTextLabel.showsRoundedRect = YES;
                cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
            else {
                cell.detailTextLabel.text = nil;
            }
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Members";
                    break;
                    
                case 1:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[self.clazz allProtocols] count]];
                    cell.textLabel.text = @"Protocols";
                    break;
                    
                case 2:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.clazz.subClasses count]];
                    cell.textLabel.text = @"Subclasses";
                    break;
            }
            break;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            title = self.clazz.name;
            break;
    }
    return title;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            indexPath = nil;
            break;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
        {
            switch (indexPath.row) {
                case 1: // Protocols
                {
                    CBProtocolListViewController *protocolListViewController = [[CBProtocolListViewController alloc] initWithNibName:@"SectionedListViewController" bundle:nil];
                    protocolListViewController.objects = [[self.clazz allProtocols] allObjects];
                    protocolListViewController.title = @"Protocols";
                    [self.navigationController pushViewController:protocolListViewController animated:YES];
                    [protocolListViewController release];
                    break;
                }
                    
                case 2: // Subclasses
                {
                    // TODO
                    break;
                }
            }
            break;
        }
    }
}

@end
