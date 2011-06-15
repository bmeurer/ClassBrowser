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

#import "CBClass.h"
#import "CBClassListViewController.h"
#import "CBFrameworkListViewController.h"
#import "CBSelector.h"
#import "CBSelectorListViewController.h"
#import "CBProtocol.h"
#import "CBProtocolListViewController.h"
#import "CBRootViewController.h"


@implementation CBRootViewController

@synthesize frameworks = _frameworks;
@synthesize classes = _classes;
@synthesize protocols = _protocols;
@synthesize selectors = _selectors;

- (void)dealloc
{
    [_frameworks release];
    [_classes release];
    [_protocols release];
    [_selectors release];
    [super dealloc];
}

#pragma mark - Properties

- (void)setFrameworks:(NSArray *)frameworks
{
    if (_frameworks != frameworks) {
        [_frameworks release], _frameworks = [frameworks copy];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setClasses:(NSArray *)classes
{
    if (_classes != classes) {
        [_classes release], _classes = [classes copy];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setProtocols:(NSArray *)protocols
{
    if (_protocols != protocols) {
        [_protocols release], _protocols = [protocols copy];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setSelectors:(NSArray *)selectors
{
    if (_selectors != selectors) {
        [_selectors release], _selectors = [selectors copy];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    }
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
                
            case 2: // Selectors and Properties
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
    switch (indexPath.section) {
        case 0:
        {
            unsigned frameworkCount = [self.frameworks count];
            cell.detailTextLabel.text = frameworkCount ? [NSString stringWithFormat:@"%d", frameworkCount] : nil;
            cell.imageView.image = [UIImage imageNamed:@"frameworks"];
            cell.textLabel.text = @"Frameworks";
            break;
        }
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    unsigned classCount = [self.classes count];
                    cell.detailTextLabel.text = classCount ? [NSString stringWithFormat:@"%d", classCount] : nil;
                    cell.imageView.image = [UIImage imageNamed:@"classes"];
                    cell.textLabel.text = @"Classes";
                    break;
                }

                case 1:
                {
                    unsigned protocolCount = [self.protocols count];
                    cell.detailTextLabel.text = protocolCount ? [NSString stringWithFormat:@"%d", protocolCount] : nil;
                    cell.imageView.image = [UIImage imageNamed:@"protocols"];
                    cell.textLabel.text = @"Protocols";
                    break;
                }
            }
            break;
        }
            
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    unsigned selectorCount = [self.selectors count];
                    cell.detailTextLabel.text = selectorCount ? [NSString stringWithFormat:@"%d", selectorCount] : nil;
                    cell.imageView.image = [UIImage imageNamed:@"selectors"];
                    cell.textLabel.text = @"Selectors";
                    break;
                }

                case 1:
                {
                    cell.detailTextLabel.text = nil;
                    cell.imageView.image = [UIImage imageNamed:@"properties"];
                    cell.textLabel.text = @"Properties";
                    break;
                }
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
                        CBFrameworkListViewController *frameworkListViewController = [[CBFrameworkListViewController alloc] initWithNibName:@"SectionedListViewController" bundle:nil];
                        frameworkListViewController.objects = self.frameworks;
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
                        CBClassListViewController *classListViewController = [[CBClassListViewController alloc] initWithNibName:@"SectionedListViewController" bundle:nil];
                        classListViewController.objects = self.classes;
                        classListViewController.title = @"Classes";
                        [self.navigationController pushViewController:classListViewController animated:YES];
                        [classListViewController release];
                        break;
                    }
                        
                    case 1: // Protocols
                    {
                        CBProtocolListViewController *protocolListViewController = [[CBProtocolListViewController alloc] initWithNibName:@"SectionedListViewController" bundle:nil];
                        protocolListViewController.objects = self.protocols;
                        protocolListViewController.title = @"Protocols";
                        [self.navigationController pushViewController:protocolListViewController animated:YES];
                        [protocolListViewController release];
                        break;
                    }
                }
                break;
            }
                
            case 2:
            {
                switch (indexPath.row) {
                    case 0: // Selectors
                    {
                        CBSelectorListViewController *selectorListViewController = [[CBSelectorListViewController alloc] initWithNibName:@"SectionedListViewController" bundle:nil];
                        selectorListViewController.objects = self.selectors;
                        selectorListViewController.title = @"Selectors";
                        [self.navigationController pushViewController:selectorListViewController animated:YES];
                        [selectorListViewController release];
                        break;
                    }
                        
                    case 1: // Properties
                        break; // TODO
                }
            }
        }
    }
}

@end
