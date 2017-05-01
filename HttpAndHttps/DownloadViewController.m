//
//  DownloadViewController.m
//  HttpAndHttps
//
//  Created by Mukhtar on 03/04/2017.
//  Copyright © 2017 Njust. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController


float timerValue;
NSString *separatorString = @".";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.downloadTimeLabel.text = @"Time elapsed: N/A";
}

- (IBAction)downloadImage:(id)sender {
    
    NSURL* url = [NSURL URLWithString:self.urlEditField.text];
    if (url == nil) {
        self.downloadTimeLabel.text = @"Incorrect URL.";
    }
    else if ([url.absoluteString rangeOfString:@"http:"].location == NSNotFound && [url.absoluteString rangeOfString:@"https:"].location == NSNotFound) {
        self.downloadTimeLabel.text = @"Add http(s) in URL.";
    }
    else {
        self.downloadedMutableData = [[NSMutableData alloc] init];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url.absoluteString]
                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                timeoutInterval:60.0];
        self.connectionManager = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        timerValue = 0;
        
        self.schedulerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    }
    
}

- (IBAction)enteredURLTextField:(id)sender {
    [sender resignFirstResponder];
}

-(void)onTick:(NSTimer *)timer {
    timerValue += 0.1f;
    self.finalTime = [NSMutableString stringWithFormat:@"%f", timerValue * 1000];
//    self.downloadTimeLabel.text = self.finalTime;
    self.downloadTimeLabel.text = [[self.finalTime componentsSeparatedByString:separatorString].firstObject stringByAppendingString:@"ms"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate Methods
-(void)connection:(NSURLSession *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%lld", response.expectedContentLength);
    self.urlResponse = response;
}

-(void)connection:(NSURLSession *)connection didReceiveData:(NSData *)data {
    [self.downloadedMutableData appendData:data];
    self.downloadedImage.image = [UIImage imageWithData:self.downloadedMutableData];
}

-(void)connectionDidFinishLoading:(NSURLSession *)connection {
    [self.schedulerTimer invalidate];
    self.schedulerTimer = nil;
    self.finalTime = [NSMutableString stringWithFormat:@"Total time: %f", timerValue * 1000];
//    self.downloadTimeLabel.text = self.finalTime;
    self.downloadTimeLabel.text = [[self.finalTime componentsSeparatedByString:separatorString].firstObject stringByAppendingString:@"ms"];
}

@end
