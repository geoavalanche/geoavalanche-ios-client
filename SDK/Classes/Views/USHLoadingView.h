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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface USHLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *activityIndicatorBackground;
@property (nonatomic, retain) IBOutlet UILabel *activityIndicatorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

+ (USHLoadingView*) viewWithController:(UIViewController *)controller;

- (void) show;
- (void) showAfterDelay:(NSTimeInterval)delay;
- (void) showWithMessage:(NSString *)message;
- (void) showWithMessage:(NSString *)message hide:(NSTimeInterval)delay;
- (void) showWithMessage:(NSString *)message animated:(BOOL)animated;
- (void) showWithMessage:(NSString *)message afterDelay:(NSTimeInterval)delay;
- (void) showWithMessage:(NSString *)message afterDelay:(NSTimeInterval)delay animated:(BOOL)animated;

- (void) hide;
- (void) hideAfterDelay:(NSTimeInterval)delay;
- (void) hideIfMessage:(NSString *)message;
- (void) centerView;

@end
