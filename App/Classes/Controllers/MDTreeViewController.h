//
//  TreeViewController.h
//  TreeDemo
//
//  Created by Max Desyatov on 08/11/2012.
//  Copyright (c) 2012 Max Desyatov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USHReportMapViewController.h"

@interface MDTreeViewController : UITableViewController{
    USHReportMapViewController *mapControllerTree;
}

@property (strong, nonatomic) USHReportMapViewController *mapControllerTree;
- (IBAction)done:(id)sender;
- (UIColor *)toUIColor :(NSString *)colorHex;
//- (void) buttonPushed:(id)sender;
//- (IBAction)expand:(id)sender;
@end
