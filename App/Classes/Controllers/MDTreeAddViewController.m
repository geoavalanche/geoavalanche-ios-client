//
//  TreeViewController.m
//  TreeDemo
//
//  Created by Max Desyatov on 08/11/2012.
//  Copyright (c) 2012 Max Desyatov. All rights reserved.
//

#import "MDTreeAddViewController.h"
#import <Ushahidi/MDTreeAddNodestore.h>
#import <Ushahidi/MDTreeNode.h>
#import "MDTreeAddViewCell.h"
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/CategoryTreeManager.h>
#import <Ushahidi/CategoryTree.h>
#import "USHSettings.h"

@implementation MDTreeAddViewController

@synthesize mapControllerTree;
@synthesize map;
@synthesize report;


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [[USHSettings sharedInstance] tableRowColor];
}


- (UIColor *)toUIColor :(NSString *)colorHex{
    
    unsigned int c;

    if ([colorHex characterAtIndex:0] == '#') {
        
        [[NSScanner scannerWithString:[colorHex substringFromIndex:1]] scanHexInt:&c];
        
    } else {
        
        [[NSScanner scannerWithString:colorHex] scanHexInt:&c];
        
    }
    
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:1.0];
    
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        UINavigationItem *n = [self navigationItem];

        [n setTitle:NSLocalizedString(@"cat_new", nil)];
        
        UIBarButtonItem *bbi =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonItemStylePlain
         target:self
         action:@selector(done:)];

        [[self navigationItem] setRightBarButtonItem:bbi];

    }

    // CRI
    [[MDTreeAddNodeStore sharedStore]   removeAll];
    NSMutableArray *flatCategory = [[Ushahidi sharedInstance] flatCategory];
    NSLog(@"Count in MDTreeAddViewController: %i",flatCategory.count);
    CategoryTreeManager *operazione = [[CategoryTreeManager alloc] init];
    [operazione createTreeAdd:flatCategory];
    [operazione dealloc];
    // CRI

    return self;
}

/** I don't think that using UITableViewStyleGrouped would look good for a tree
 *  would look good, so using UITableViewStylePlain for both simple and 
 *  designated init
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"MDTreeAddViewCell" bundle:nil];

    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MDTreeAddViewCell"];
    
    self.tableView.backgroundColor = [[USHSettings sharedInstance] tableBackColor];
    
    self.navigationController.navigationBar.tintColor = [[USHSettings sharedInstance] navBarColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[MDTreeAddNodeStore sharedStore] allNodes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MDTreeAddViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"MDTreeAddViewCell"];

    if (!cell)
    {
        cell =
            [[MDTreeAddViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"MDTreeAddViewCell"];
    }

    MDTreeNode *n =
        [[[MDTreeAddNodeStore sharedStore] allNodes]
            objectAtIndex:[indexPath row]];
    
    
    cell.buttonCheck.tag =(NSInteger) n.id;
    NSLog(@"-------------------------------"  );
    NSLog(@"TAG FOR  - %@" ,(NSString *)cell.buttonCheck.tag );
    NSLog(@" n.id  - %@" , n.id );
    [cell.buttonCheck addTarget:self action:@selector(cellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if ( cell.treeImage== nil)    NSLog(@"cell.treeImage - null" );else NSLog(@"cell.treeImage - notnull" );
    cell.buttonRowIndex.tag = [indexPath row];
    NSLog(@" index cell  - %d" , cell.buttonRowIndex.tag );
    [[cell nodeTitleField] setText:[n description]];
    [cell setIndentationWidth:8];
    [cell setIsExpanded:[n isExpanded]];
    [cell setHasChildren:([[n children] count] > 0)];
    [cell prepareForReuse];
    NSLog(@"-------------------------------"  );

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
    indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[MDTreeAddNodeStore sharedStore] allNodes];
    MDTreeNode *n = [items objectAtIndex:[indexPath row]];

    NSInteger result = -1;

    while (n && n.parent)
    {
        ++result;
        n = n.parent;
    }

    return result;
}

#pragma mark - Table view delegate



- (IBAction)done:(id)sender
{
    // CRI
    [self dismissModalViewControllerAnimated:YES];   
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        MDTreeAddNodeStore *store = [MDTreeAddNodeStore sharedStore];
        NSArray *items = [store allNodes];
        MDTreeNode *n = [items objectAtIndex:[indexPath row]];
        NSLog(@"deleting row %d", [indexPath row]);
        MDTreeAddViewCell *cell =
            (MDTreeAddViewCell *)[tableView cellForRowAtIndexPath:indexPath];

        NSArray *childrenToReload;
        // no need to reload children if they're removed with the parent
        // but if they're not removed with the parent, we need to get those
        // before changes to the store were applied
        if ([cell isExpanded])
        {
            childrenToReload = [n flatten];
            [store removeNode:n];
        } else
            [store removeNodeWithChildren:n];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];

        // no need to reload children if they're removed with the parent
        if (![cell isExpanded])
            return;

        NSMutableArray *indexPathsToReload = [NSMutableArray array];
        // reloading all items to get refreshed indexes
        items = [store allNodes];
        for (MDTreeNode *nodeToReload in childrenToReload)
        {
            NSUInteger index = [items indexOfObjectIdenticalTo:nodeToReload];

            [indexPathsToReload addObject:[NSIndexPath indexPathForRow:index
                                                             inSection:0]];
        }

        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:indexPathsToReload
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView
    moveRowAtIndexPath:(NSIndexPath *)oldPath
           toIndexPath:(NSIndexPath *)newPath
{
    MDTreeAddNodeStore *store = [MDTreeAddNodeStore sharedStore];
    NSArray *items = [store allNodes];
    MDTreeNode *n = [items objectAtIndex:[oldPath row]];
    MDTreeAddViewCell *cell =
        (MDTreeAddViewCell *)[tableView cellForRowAtIndexPath:oldPath];

    NSArray *childrenToReload;

    // no need to reload children if they're moved with the parent
    // but if they're not moved with the parent, we need to get those
    // before changes to the store were applied
    if ([cell isExpanded])
        childrenToReload = [n flatten];

    NSInteger oldRow = [oldPath row];
    NSInteger newRow = [newPath row];

    if (![cell isExpanded])
        [store moveNodeAtRowWithChildren:oldRow toRow:newRow];
    else
        [store moveNodeAtRow:oldRow toRow:newRow];

    [cell setIndentationLevel:[self tableView:[self tableView]
            indentationLevelForRowAtIndexPath:newPath]];
    [cell setNeedsLayout];

    // no need to reload children if they're moved with the parent
    if (![cell isExpanded])
        return;

    // reloading all items to get refreshed indexes
    items = [store allNodes];
    for (MDTreeNode *nodeToReload in childrenToReload)
    {
        NSUInteger row = [items indexOfObjectIdenticalTo:nodeToReload];
        NSIndexPath *indexPathToUpdate =
            [NSIndexPath indexPathForRow:row inSection:0];

        UITableViewCell *cell =
            [[self tableView] cellForRowAtIndexPath:indexPathToUpdate];
        [cell setIndentationLevel:[self tableView:[self tableView]
                indentationLevelForRowAtIndexPath:indexPathToUpdate]];
        [cell setNeedsLayout];
    }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSLog(@"click %d",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *nodes = [[MDTreeAddNodeStore sharedStore] allNodes];
    MDTreeNode *selectedNode = [nodes objectAtIndex:[indexPath row]];
    if ([[selectedNode children] count] < 1)
        return;

    MDTreeAddViewCell *cell =
        (MDTreeAddViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    [cell spinNodeStateIndicatorWithDuration:0.25];


    BOOL oldIsExpanded = [selectedNode isExpanded];

    if (oldIsExpanded)
    {
        NSArray *flattenedChildren = [selectedNode flatten];
        NSMutableArray *rowsToDelete = [NSMutableArray array];

        NSLog(@"-------------------------");
        NSLog(@"DeExpand node %d",cell.tag);
        for (MDTreeNode *child in flattenedChildren)
        {
            NSUInteger row = [nodes indexOfObjectIdenticalTo:child];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
            [rowsToDelete addObject:ip];
        }
        NSLog(@"-------------------------");
        [selectedNode setIsExpanded:!oldIsExpanded];
        [cell setIsExpanded:!oldIsExpanded];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:rowsToDelete
                         withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
        
        // SET IMAGE EXPAND PLUS
        [cell.buttonExpand setImage:[UIImage imageNamed:@"button_plus_blue.png"] forState:UIControlStateNormal];
        
    } else
    {
        [selectedNode setIsExpanded:!oldIsExpanded];
        [cell setIsExpanded:!oldIsExpanded];
        
        NSArray *flattenedChildren = [selectedNode flatten];
        NSMutableArray *rowsToInsert = [NSMutableArray array];
        // refreshing list of all nodes after expand
        nodes = [[MDTreeAddNodeStore sharedStore] allNodes];
        
        NSLog(@"-------------------------");
        NSLog(@"Expand node %d",cell.tag);
        for (MDTreeNode *child in flattenedChildren)
        {
            NSUInteger row = [nodes indexOfObjectIdenticalTo:child];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
            [rowsToInsert addObject:ip];
        }
        NSLog(@"-------------------------");
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:rowsToInsert
                         withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
        
        // SET IMAGE EXPAND MINUS
        [cell.buttonExpand setImage:[UIImage imageNamed:@"button_minus_blue.png"] forState:UIControlStateNormal];
    }
    
}

- (void)tableView:(UITableView *)tableView
    accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [self dismissModalViewControllerAnimated:YES];
    /*
    [super setEditing:editing animated:animate];
    // forcing reload of data source to avoid any bugs connected with reordering
    // in view and data source not synchronized.  as a side effect, it ends
    // editing without cute animation
    if (!editing)
        [[self tableView] reloadData];
     */
}


-(void) cellButtonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *tableViewCell = (UITableViewCell *)button.superview.superview;
    UITableView* tableView = (UITableView *)tableViewCell.superview;
    NSIndexPath* pathOfTheCell = [tableView indexPathForCell:tableViewCell];
    NSInteger rowOfTheCell = pathOfTheCell.row;
    NSLog(@"rowofthecell %d", rowOfTheCell);
    
    NSArray *nodes = [[MDTreeAddNodeStore sharedStore] allNodes];
    MDTreeNode *selectedNode = [nodes objectAtIndex:pathOfTheCell.row];

    NSInteger myInteger = [button.tag integerValue];
    NSString *key =[NSString stringWithFormat:@"%i", myInteger];

    
    NSMutableDictionary *flatCategoryToAdd = [[Ushahidi sharedInstance] flatCategoryToAdd];
    NSMutableDictionary *flatCategoryToAddSelected = [[Ushahidi sharedInstance] flatCategoryToAddSelected];
    USHCategory *category = [flatCategoryToAddSelected objectForKey:key];
    USHCategory *categoryDic = [flatCategoryToAdd objectForKey:key];

    if( [[button imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"checkbox_checked.png"]])
    {
        [button setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        if (category!=nil)
        {
            [report removeCategoriesObject:category];
            [flatCategoryToAddSelected removeObjectForKey:key];
        }
    }
    else
    {
        
        category = categoryDic;
        if (category!=NULL)
        {
            [button setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
            [report addCategoriesObject:category];
            [flatCategoryToAddSelected setObject:category forKey:key];
        }
    }

}



- (void)setCildren:(NSString *)value node:(MDTreeNode *)selectedNode withCell:(NSString *)refreshImageCheck {
    NSMutableDictionary *dictionary = [[Ushahidi sharedInstance] flatCategorySelected];
    
    NSMutableArray *children = selectedNode.children;
    for (MDTreeNode *child in children) {
        [dictionary setValue:value forKey:(NSString *)child.id];
        [self setCildren:value node:child withCell:refreshImageCheck];
        if ([refreshImageCheck isEqual:@"YES"] ) [self setCell:child.id numberRows: [[[MDTreeAddNodeStore sharedStore] allNodes] count] value:value];
    }
}

- (void)setCell:(NSNumber *)index numberRows:(NSInteger) rows value:(NSString *)check{

    for ( NSInteger i = 0; i < rows;i++){
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        MDTreeAddViewCell *pp = (MDTreeAddViewCell *) [[self tableView] cellForRowAtIndexPath:path];
        if (pp.buttonCheck.tag == index ){
            if ( [check isEqualToString:@"YES"]){
                [pp.buttonCheck setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
            }else{
                [pp.buttonCheck setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
            }
        }
    }
}


@end
