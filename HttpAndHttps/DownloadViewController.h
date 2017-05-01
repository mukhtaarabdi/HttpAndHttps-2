//
//  DownloadViewController.h
//  HttpAndHttps
//
//  Created by Mukhtar on 03/04/2017.
//  Copyright © 2017 Njust. All rights reserved.
//
#ifndef DownloadViewController_h
#define DownloadViewController_h

#import <UIKit/UIKit.h>

@interface DownloadViewController : UIViewController <NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlEditField;
@property (weak, nonatomic) IBOutlet UILabel *downloadTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *downloadedImage;

@property (strong, nonatomic) NSURLConnection *connectionManager;
@property (strong, nonatomic) NSMutableData *downloadedMutableData;
@property (strong, nonatomic) NSURLResponse *urlResponse;

@property (weak, nonatomic) NSTimer *schedulerTimer;

@property (weak, nonatomic) NSMutableString* finalTime;

@end


#endif /* DownloadViewController_h */
