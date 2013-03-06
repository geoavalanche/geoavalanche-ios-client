//
//  TreeViewController.m
//  TreeDemo
//
//  Created by Max Desyatov on 08/11/2012.
//  Copyright (c) 2012 Max Desyatov. All rights reserved.
//

#import "MDTreeViewController.h"
#import <Ushahidi/MDTreeNodestore.h>
#import <Ushahidi/MDTreeNode.h>
#import "MDTreeViewCell.h"
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/CategoryTreeManager.h>
#import <Ushahidi/CategoryTree.h>
#import "USHSettings.h"

@implementation MDTreeViewController

@synthesize mapControllerTree;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell.backgroundColor = [self toUIColor:@"#EEF7FC"];
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
       
        //[n setTitle:@"Categorie"];
        [n setTitle:NSLocalizedString(@"cat_new", nil)];
        
        UIBarButtonItem *bbi =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonItemStylePlain
         target:self
         action:@selector(done:)];

        //[[self navigationItem] setLeftBarButtonItem:bbi];
        [[self navigationItem] setRightBarButtonItem:bbi];
        /*
        bbi.tintColor = [self toUIColor:@"#afd775"];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        */
    }

    // CRI
    [[MDTreeNodeStore sharedStore]   removeAll] ;
    NSMutableArray *flatCategory = [[Ushahidi sharedInstance] flatCategory];
    NSLog(@"Count in MDTreeViewController: %i",flatCategory.count);
    CategoryTreeManager *operazione = [[CategoryTreeManager alloc] init];
    [operazione createTree:flatCategory];
    NSMutableDictionary *flatOnlyCategoryYES = [[Ushahidi sharedInstance] flatOnlyCategoryYES];
    [flatOnlyCategoryYES removeAllObjects];
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

    UINib *nib = [UINib nibWithNibName:@"MDTreeViewCell" bundle:nil];

    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MDTreeViewCell"];
    
    //self.tableView.backgroundView =[self toUIColor:@"#c8e2eb"];
    //self.tableView.backgroundColor =[self toUIColor:@"#c8e2eb"];
    self.tableView.backgroundColor = [[USHSettings sharedInstance] tableBackColor];
    
    //[self toUIColor:@"#c8e2eb"];
    //self.navigationController.navigationBar.tintColor =  [self toUIColor:@"#024769"];
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
    return [[[MDTreeNodeStore sharedStore] allNodes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MDTreeViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"MDTreeViewCell"];

    if (!cell)
    {
        cell =
            [[MDTreeViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"MDTreeViewCell"];
    }

    MDTreeNode *n =
        [[[MDTreeNodeStore sharedStore] allNodes]
            objectAtIndex:[indexPath row]];
    
    
    cell.buttonCheck.tag =(NSInteger) n.id;
    NSLog(@"-------------------------------"  );
    NSLog(@"TAG FOR  - %@" ,(NSString *)cell.buttonCheck.tag );
    NSLog(@" n.id  - %@" , n.id );
    [cell.buttonCheck addTarget:self action:@selector(cellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if ( cell.treeImage== nil)    NSLog(@"cell.treeImage - null" );else NSLog(@"cell.treeImage - notnull" );
    cell.buttonRowIndex.tag = [indexPath row];
    NSLog(@" index cell  - %d" , cell.buttonRowIndex.tag );
    //[cell.treeImage   addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchUpInside];

    [[cell nodeTitleField] setText:[n description]];
    //[cell setIndentationWidth:32]; // INDENTAZIONE
    [cell setIndentationWidth:8]; // INDENTAZIONE
    [cell setIsExpanded:[n isExpanded]];
    //NSLog(@" [n isExpanded]  - %@" , [n isExpanded] );
    [cell setHasChildren:([[n children] count] > 0)];
    [cell prepareForReuse];
    NSLog(@"-------------------------------"  );
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
    indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[MDTreeNodeStore sharedStore] allNodes];
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
    NSMutableDictionary *dictionary = [[Ushahidi sharedInstance] flatCategorySelected];
    NSMutableArray *flatCategory = [[Ushahidi sharedInstance] flatCategory] ;
    NSMutableDictionary *flatOnlyCategoryYES = [[Ushahidi sharedInstance] flatOnlyCategoryYES];
    
    for (CategoryTree* pp in flatCategory) {
        NSString *selected = [dictionary objectForKey:pp.indetifier];
        pp.selected = selected;
        
        //NSLog(@"%@ - selected %@",pp.id,selected);
        if ([selected isEqual:@"YES"]){
            [flatOnlyCategoryYES setValue:@"YES" forKey:pp.id];
        }
    }
    //NSLog(@"SPERIMANO: %@",[flatOnlyCategoryYES objectForKey:@"4"]);
    //NSLog(@"-------------------------------------");
    //NSLog(@"CRI - DONE CATEGORIES BEGIN");
    
    /*
    NSMutableDictionary *flatOnlyCategoryYES = [[Ushahidi sharedInstance] flatOnlyCategoryYES];
    NSMutableDictionary *pp = [[NSMutableDictionary alloc]init];
    [pp setValue:@"YES" forKey:@"6"];
    for (NSString* key in dictionary) {
        id value = [dictionary objectForKey:key];
        if ( [value isEqualToString:@"YES"])
        {
  
            [flatOnlyCategoryYES setValue:@"YES" forKey:key];
            NSString *value = [flatOnlyCategoryYES objectForKey:key];
            NSLog(@"ADD id %@ to flatOnlyCategoryYES value: %@",key,value);

        }
        NSLog(@"key: %@ - value: %@",key,value);
    }
   
    
    NSLog(@"CRI - DONE flatOnlyCategoryYES BEGIN");
    for (NSString* key in flatOnlyCategoryYES)
    {
        NSString *value = [flatOnlyCategoryYES objectForKey:key];
        NSLog(@"++flatOnlyCategoryYES id %@  value:  --> %@",key,value);
    }
    NSLog(@"CRI - DONE flatOnlyCategoryYES END");
    
    */
    //NSString *valueAPPO2 = @"6";
    //NSLog(@"CAZZOOOOOOOOOOOO  %@ ",[flatOnlyCategoryYES objectForKey:valueAPPO2]);
    NSLog(@"-------------------------------------");
    [mapControllerTree refreshMap];
    // CRI
    [self dismissModalViewControllerAnimated:YES];   
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        MDTreeNodeStore *store = [MDTreeNodeStore sharedStore];
        NSArray *items = [store allNodes];
        MDTreeNode *n = [items objectAtIndex:[indexPath row]];
        NSLog(@"deleting row %d", [indexPath row]);
        MDTreeViewCell *cell =
            (MDTreeViewCell *)[tableView cellForRowAtIndexPath:indexPath];

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
    MDTreeNodeStore *store = [MDTreeNodeStore sharedStore];
    NSArray *items = [store allNodes];
    MDTreeNode *n = [items objectAtIndex:[oldPath row]];
    MDTreeViewCell *cell =
        (MDTreeViewCell *)[tableView cellForRowAtIndexPath:oldPath];

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

    NSArray *nodes = [[MDTreeNodeStore sharedStore] allNodes];
    MDTreeNode *selectedNode = [nodes objectAtIndex:[indexPath row]];
    if ([[selectedNode children] count] < 1)
        return;

    MDTreeViewCell *cell =
        (MDTreeViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
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
        nodes = [[MDTreeNodeStore sharedStore] allNodes];
        
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
    /*
    MDDetailsViewController *details = [MDDetailsViewController new];

    NSArray *nodes = [[MDTreeNodeStore sharedStore] allNodes];
    MDTreeNode *selectedNode = [nodes objectAtIndex:[indexPath row]];
    [details setNode:selectedNode];

    [[self navigationController] pushViewController:details animated:YES];
     */
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
    NSLog(@"Button tag pressed: %@",(NSString *)button.tag);
    BOOL check = false;
    NSMutableDictionary *dictionary = [[Ushahidi sharedInstance] flatCategorySelected];
    if( [[button imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"checkbox_checked.png"]])
    {
        [button setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        [dictionary setValue:@"NO" forKey:(NSString *)button.tag];
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        [dictionary setValue:@"YES" forKey:(NSString *)button.tag];
        check = true;
    }

    UITableViewCell *tableViewCell = (UITableViewCell *)button.superview.superview;
    UITableView* tableView = (UITableView *)tableViewCell.superview;
    NSIndexPath* pathOfTheCell = [tableView indexPathForCell:tableViewCell];
    NSInteger rowOfTheCell = pathOfTheCell.row;
    NSLog(@"rowofthecell %d", rowOfTheCell);

    NSArray *nodes = [[MDTreeNodeStore sharedStore] allNodes];
    MDTreeNode *selectedNode = [nodes objectAtIndex:pathOfTheCell.row];

    if ( selectedNode.isExpanded == true)
    {
        NSLog(@"is Expanded");
        if (check == true ) [self setCildren:@"YES" node:selectedNode withCell:@"YES"];
        if (check == false )[self setCildren:@"NO" node:selectedNode withCell:@"YES"];
    }else{
        NSLog(@"is not  Expanded");
        if (check == true )[self setCildren:@"YES" node:selectedNode withCell:@"NO"];
        if (check == false )[self setCildren:@"NO" node:selectedNode withCell:@"NO"];
    }
}



- (void)setCildren:(NSString *)value node:(MDTreeNode *)selectedNode withCell:(NSString *)refreshImageCheck {
    NSMutableDictionary *dictionary = [[Ushahidi sharedInstance] flatCategorySelected];
    
    NSMutableArray *children = selectedNode.children;
    for (MDTreeNode *child in children) {
        [dictionary setValue:value forKey:(NSString *)child.id];
        [self setCildren:value node:child withCell:refreshImageCheck];
        if ([refreshImageCheck isEqual:@"YES"] ) [self setCell:child.id numberRows: [[[MDTreeNodeStore sharedStore] allNodes] count] value:value];
    }
}

- (void)setCell:(NSNumber *)index numberRows:(NSInteger) rows value:(NSString *)check{

    for ( NSInteger i = 0; i < rows;i++){
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        MDTreeViewCell *pp = (MDTreeViewCell *) [[self tableView] cellForRowAtIndexPath:path];
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
