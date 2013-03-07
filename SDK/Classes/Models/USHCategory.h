//
//  USHCategory.h
//  SDK
//
//  Created by Cristiano Carducci on 26/02/13.
//  Copyright (c) 2013 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class USHMap, USHReport;

@interface USHCategory : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * parent_id;
@property (nonatomic, retain) USHMap *map;
@property (nonatomic, retain) NSSet *reports;
@end

@interface USHCategory (CoreDataGeneratedAccessors)

- (void)addReportsObject:(USHReport *)value;
- (void)removeReportsObject:(USHReport *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;

@end
