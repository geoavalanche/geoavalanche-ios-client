/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
 ** All rights reserved
 ** Contact: team@ushahidi.com
 ** Website: http://www.ushahidi.com
 **
 ** GNU Lesser General Public License Usage
 ** This file may be used under the terms of the GNU Lesser
 ** General Public License version 3 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file. Please review the following information to
 ** ensure the GNU Lesser General Public License version 3 requirements
 ** will be met: http://www.gnu.org/licenses/lgpl.html.
 **
 **
 ** If you have questions regarding the use of this file, please contact
 ** Ushahidi developers at team@ushahidi.com.
 **
 *****************************************************************************/

#import "USHDownloadCategory.h"
#import "NSDictionary+USH.h"
#import "NSObject+USH.h"
#import "Ushahidi.h"
#import "USHDatabase.h"
#import "USHMap.h"
#import "USHCategory.h"
#import "CategoryTreeManager.h"
#import "CategoryTree.h"

@interface USHDownloadCategory ()

@property (nonatomic, strong, readwrite) USHCategory *category;

@end

@implementation USHDownloadCategory

@synthesize category = _category;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map {
    return [super initWithDelegate:delegate
                          callback:callback
                               map:map 
                               api:@"api?task=categories&resp=json"];
}

- (void) downloadedJSON:(NSDictionary*)json {
    NSDictionary *payload = [json objectForKey:@"payload"];
    NSArray *categories = [payload objectForKey:@"categories"];
    
    /* CRI  AGGIUNTO PER CARICARE  LE CATEGORIE */
    NSMutableArray *flatCategory = [[Ushahidi sharedInstance] flatCategory] ;
    NSMutableDictionary *flatCategorySelected = [[Ushahidi sharedInstance] flatCategorySelected] ;
    NSMutableDictionary *flatOnlyCategoryYES = [[Ushahidi sharedInstance] flatOnlyCategoryYES];
    [flatCategory removeAllObjects];
    [flatCategorySelected removeAllObjects];
    [flatOnlyCategoryYES removeAllObjects];
    /* CRI  AGGIUNTO PER CARICARE  LE CATEGORIE */
    
    for (NSDictionary *item in categories) {
        NSDictionary *category = [item objectForKey:@"category"];
        if (category != nil) {
            self.category = (USHCategory*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Category"
                                                                                           query:@"map.url = %@ && identifier = %@"
                                                                                          params:self.map.url, [category stringForKey:@"id"], nil];
            self.category.identifier = [category stringForKey:@"id"];
            self.category.title = [category stringForKey:@"title"];
            self.category.desc = [category stringForKey:@"description"];
            self.category.color = [category stringForKey:@"color"];
            self.category.position = [NSNumber numberWithInt:[category intForKey:@"position"]];
            NSInteger tipoCategoria = [category intForKey:@"parent_id"];
            self.category.parent_id = [NSString stringWithFormat:@"%i", tipoCategoria];
            
            /* CRI  AGGIUNTO PER CARICARE  LE CATEGORIE */
            
            CategoryTree *elementFlat = [[CategoryTree alloc] init];
            elementFlat.open = @"NO";
            elementFlat.selected = @"YES";
            elementFlat.title =  self.category.title;
            elementFlat.parent_id = self.category.parent_id;
            elementFlat.id = self.category.identifier;
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * myNumber = [f numberFromString:self.category.identifier];
            elementFlat.indetifier = myNumber ;
            [flatCategory addObject:elementFlat];
            NSLog(@"------------------ RICARICO INIT ----------------------");
            NSLog(@"elementFlat.Title --> %@",elementFlat.title);
            NSLog(@"elementFlat.parent_id --> %@",elementFlat.parent_id);
            NSLog(@"elementFlat.id --> %@",elementFlat.indetifier);
            NSLog(@"elementFlat.selected --> %@",elementFlat.selected);
            [flatCategorySelected setValue:elementFlat.selected forKey:elementFlat.indetifier];
            NSString *value = [flatCategorySelected objectForKey:elementFlat.indetifier];
            NSLog(@"flatCategorySelected --> %@",value);
            [flatOnlyCategoryYES setValue:@"YES" forKey:elementFlat.id];
            NSLog(@"flatOnlyCategoryYES %@ --> %@",elementFlat.selected,elementFlat.id);
            NSLog(@"------------------ RICARICO END ----------------------");     
            
            /* CRI  AGGIUNTO PER CARICARE  LE CATEGORIE */
            
            self.category.map = self.map;
            DLog(@"Map:%@ Category:%@", self.map.name, self.category.title);
            [[USHDatabase sharedInstance] saveChanges];
            [self.delegate performSelector:@selector(download:downloaded:)
                               withObjects:self, self.map, nil];
        }
    }
    //NSString *value = [flatOnlyCategoryYES valueForKey:@"4"];
    //NSLog(@"valueee 4 --> %@",value);
    NSLog(@"Count  --> %i",flatCategory.count);


}

- (void)dealloc {
    [_category release];
    [super dealloc];
}

@end
