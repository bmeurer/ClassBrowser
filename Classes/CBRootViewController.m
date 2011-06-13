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

#import "CBClassListViewController.h"
#import "CBFrameworkListViewController.h"
#import "CBProtocolListViewController.h"
#import "CBRootViewController.h"
#import "CBRuntime.h"


@implementation CBRootViewController

#pragma mark - UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    if (tableView == self.tableView) {
        numberOfSections = 3;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (tableView == self.tableView) {
        switch (section) {
            case 0: // Frameworks
                numberOfRows = 1;
                break;
                
            case 1: // Classes and Protocols
                numberOfRows = 2;
                break;
                
            case 2: // Messages and Properties
                numberOfRows = 2;
                break;
        }
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    switch (indexPath.section) {
        case 0:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[[CBRuntime sharedRuntime] allFrameworks] count]];
            cell.imageView.image = [UIImage imageNamed:@"frameworks"];
            cell.textLabel.text = @"Frameworks";
            break;
        }
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[[CBRuntime sharedRuntime] allClasses] count]];
                    cell.imageView.image = [UIImage imageNamed:@"classes"];
                    cell.textLabel.text = @"Classes";
                    break;
                    
                case 1:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[[CBRuntime sharedRuntime] allProtocols] count]];
                    cell.imageView.image = [UIImage imageNamed:@"protocols"];
                    cell.textLabel.text = @"Protocols";
                    break;
            }
            break;
        }
            
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"methods"];
                    cell.textLabel.text = @"Messages";
                    break;
                    
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"properties"];
                    cell.textLabel.text = @"Properties";
                    break;
            }
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        switch (indexPath.section) {
            case 0:
            {
                switch (indexPath.row) {
                    case 0: // Frameworks
                    {
                        CBFrameworkListViewController *frameworkListViewController = [[CBFrameworkListViewController alloc] initWithNibName:@"FrameworkListViewController" bundle:nil];
                        frameworkListViewController.objects = [[CBRuntime sharedRuntime] allFrameworks];
                        frameworkListViewController.title = @"Frameworks";
                        [self.navigationController pushViewController:frameworkListViewController animated:YES];
                        [frameworkListViewController release];
                        break;
                    }
                }
                break;
            }
                
            case 1:
            {
                switch (indexPath.row) {
                    case 0: // Classes
                    {
                        CBClassListViewController *classListViewController = [[CBClassListViewController alloc] initWithNibName:@"ClassListViewController" bundle:nil];
                        classListViewController.objects = [[CBRuntime sharedRuntime] allClasses];
                        classListViewController.title = @"Classes";
                        [self.navigationController pushViewController:classListViewController animated:YES];
                        [classListViewController release];
                        break;
                    }
                        
                    case 1: // Protocols
                    {
                        CBProtocolListViewController *protocolListViewController = [[CBProtocolListViewController alloc] initWithNibName:@"ProtocolListViewController" bundle:nil];
                        protocolListViewController.objects = [[CBRuntime sharedRuntime] allProtocols];
                        protocolListViewController.title = @"Protocols";
                        [self.navigationController pushViewController:protocolListViewController animated:YES];
                        [protocolListViewController release];
                        break;
                    }
                }
                break;
            }
        }
    }
}

@end
