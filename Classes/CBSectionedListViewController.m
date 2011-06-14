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

#import "CBSectionedListViewController.h"


@implementation CBSectionedListViewController

@synthesize objects = _objects;
@synthesize infoBlock = _infoBlock;
@synthesize infoButtonItem = _infoButtonItem;

- (void)dealloc
{
    [_objects release];
    [_searchResults release];
    [_sections release];
    [_infoBlock release];
    [_infoButtonItem release];
    [super dealloc];
}

- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = nil;
    if (tableView == self.tableView) {
        object = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        object = [_searchResults objectAtIndex:indexPath.row];
    }
    return object;
}

- (IBAction)infoButtonItemDidActivate:(UIBarButtonItem *)infoButtonItem
{
    void (^infoBlock)(CBSectionedListViewController *) = self.infoBlock;
    if (infoBlock) {
        infoBlock(self);
    }
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Sort the objects into sections
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSUInteger sectionCount = [[collation sectionTitles] count], sectionIndex;
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:sectionCount];
    for (sectionIndex = 0; sectionIndex < sectionCount; ++sectionIndex) {
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        [sections addObject:rows];
        [rows release];
    }
    for (id object in self.objects) {
        sectionIndex = [collation sectionForObject:object collationStringSelector:@selector(name)];
        [[sections objectAtIndex:sectionIndex] addObject:object];
    }
    for (sectionIndex = 0; sectionIndex < sectionCount; ++sectionIndex) {
        NSArray *rows = [sections objectAtIndex:sectionIndex];
        rows = [collation sortedArrayFromArray:rows collationStringSelector:@selector(name)];
        [sections replaceObjectAtIndex:sectionIndex withObject:rows];
    }
    [_sections release], _sections = sections;
    
    // Show the "Info" button if an infoBlock is set
    if (self.infoBlock) {
        self.navigationItem.rightBarButtonItem = self.infoButtonItem;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release the search results and sections
    [_searchResults release], _searchResults = nil;
    [_sections release], _sections = nil;
    
    // Release any references to IB outlets
    self.infoButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    if (tableView == self.tableView) {
        numberOfSections = [_sections count];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        numberOfSections = 1;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (tableView == self.tableView) {
        numberOfRows = [[_sections objectAtIndex:section] count];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        numberOfRows = [_searchResults count];
    }
    return numberOfRows;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *sectionIndexTitles = nil;
    if (tableView == self.tableView) {
        sectionIndexTitles = [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
    return sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger section = NSNotFound;
    if (tableView == self.tableView) {
        if (title == UITableViewIndexSearch) {
            [tableView setContentOffset:CGPointZero];
        }
        else {
            section = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:(index - 1)];
        }
    }
    return section;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (tableView == self.tableView) {
        if ([[_sections objectAtIndex:section] count]) {
            title = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        }
    }
    return title;
}

#pragma mark - UISearchDisplayDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (!_searchResults) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    else {
        [_searchResults removeAllObjects];
    }
    for (NSArray *section in _sections) {
        for (id object in section) {
            NSRange range = [[object name] rangeOfString:searchString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)];
            if (range.location != NSNotFound) {
                [_searchResults addObject:object];
            }
        }
    }
    return YES;
}

@end
