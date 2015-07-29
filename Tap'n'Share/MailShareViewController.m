//
//  MailShareViewController.m
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreLocation/CoreLocation.h>

#import "MailShareViewController.h"
#import "Location.h"

static NSString * const NAVIGATION_TITLE = @"Via Mail";

NSString * const AUDIO_RECORD_TEXT = @"Record";
NSString * const AUDIO_STOP_TEXT = @"Stop";

NSString * const MAIL_SENT_ALERT_TEXT = @"Mail sent";
NSString * const MAIL_FAILED_ALERT_TEXT = @"Mail failed";
NSString * const MAIL_CANCEL_ALERT_TEXT = @"Mail cancelled";
NSString * const MAIL_SAVED_ALERT_TEXT = @"Mail saved";

NSString * const MAIL_SUBJECT_TEXT = @"Spot me here!";

NSString * const AUDIO_FINISHED_PLAYING_ALERT_TEXT = @"Finish playing the recording!";

NSString * const AUDIO_FILE_WITH_EXTENSION_NAME = @"hearMeOut.m4a";

NSString * const AUDIO_FILE_EXTENSION = @"m4a";
NSString * const AUDIO_FILE_NAME = @"Hear Me Out";

NSString * const DEVICE_NOT_CONFIGURED = @"Device not configured for Mail";

float const AV_SAMPLE_RATE_VALUE = 44100.0;
int const AV_CHANNELS_VALUE = 2;

@interface MailShareViewController () <AVAudioPlayerDelegate, AVAudioRecorderDelegate, MFMailComposeViewControllerDelegate> {
    
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    
    BOOL _isMailSent;
    BOOL _isVoiceRecorded;
    
}

@property (nonatomic, weak) IBOutlet UIButton *recordStopButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (nonatomic, weak) IBOutlet UIButton *mailButton;

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation MailShareViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = NAVIGATION_TITLE;
    
    self.appDelegate = [Utility appDelegateInstance];
    
    /*
     Enable record button and disable play/clear button
     */
    [self enableDisableButtons];
    
    /*
     Initiatisle the recorder/player objects
     */
    [self setupAudioRecorder];
    
}

#pragma mark - Business logic

- (void)enableDisableButtons {
    
    _isVoiceRecorded = NO;
    
    self.recordStopButton.enabled = YES;
    
    self.playButton.enabled = NO;
    self.clearButton.enabled = NO;
    
}

- (void)setupAudioRecorder {
    
    _playButton.enabled = NO;
    
    //set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects :[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,NSUserDomainMask, YES) lastObject], AUDIO_FILE_WITH_EXTENSION_NAME, nil ];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents :pathComponents];
    
    //set audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //set recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:AV_SAMPLE_RATE_VALUE] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:AV_CHANNELS_VALUE] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    
}

#pragma mark - IBAction methods

- (IBAction)recordStopAudio:(id)sender {
    
    //Stop the audio player before recording
    if (_player.playing ) {
        
        [_player stop];
        
    }
    
    if (!_recorder.recording) {
        
        self.mailButton.enabled = NO;
        
        //Start recording
        [_recorder record];
        
        [self.recordStopButton setTitle:AUDIO_STOP_TEXT forState:UIControlStateNormal];
        
    }
    else {
        
        self.clearButton.enabled = YES;
        
        _isVoiceRecorded = YES;
        
        //Stop recording
        [_recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        [self.recordStopButton setTitle:AUDIO_RECORD_TEXT forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)playTapped:(id)sender {
    
    if (!_recorder.recording) {
        
        self.mailButton.enabled = NO;
        self.clearButton.enabled = NO;
        self.recordStopButton.enabled = NO;
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recorder.url error:nil];
        _player.delegate = self;
        
        [_player play];
        
    }
    
}

- (IBAction)clearAudio:(id)sender {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    if (![fileManager removeItemAtPath:[_recorder.url path]  error:&error]) {
        
        [Utility showAlertWithTitle:APP_TITLE message:error.localizedDescription controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    [self enableDisableButtons];
    
}

- (IBAction)sendMail:(id)sender {
    
    if (![Utility isInternetConnectivity]) {
        
        [Utility showAlertWithTitle:APP_TITLE message:NO_INTERNET_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    if (![MFMailComposeViewController canSendMail]) {
        
        [Utility showAlertWithTitle:APP_TITLE message:DEVICE_NOT_CONFIGURED controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:MAIL_SUBJECT_TEXT];
    
    NSString *bodyString = [NSString stringWithFormat:@"%@ %@", SHARE_LOCATION_TEXT, self.locationDetail[LOCATION_NAME_KEY]];
    
    [mailComposeViewController setMessageBody:bodyString isHTML:NO];
    
    if (_isVoiceRecorded) {
        
        NSData *audioData = [NSData dataWithContentsOfURL:_recorder.url];
        
        [mailComposeViewController addAttachmentData:audioData mimeType:AUDIO_FILE_EXTENSION fileName:AUDIO_FILE_NAME];
        
    }
    
    if (mailComposeViewController) {
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
        
    }
    
}

#pragma mark - AVAudioRecorder and AVAudioPlayer delegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
    
    [self.recordStopButton setTitle:AUDIO_RECORD_TEXT forState:UIControlStateNormal];
    
    self.mailButton.enabled = YES;
    self.playButton.enabled = YES;
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [Utility showAlertWithTitle:APP_TITLE message:AUDIO_FINISHED_PLAYING_ALERT_TEXT controller:self completionBlock:^(UIAlertAction *action) {
        
        self.mailButton.enabled = YES;
        self.clearButton.enabled = YES;
        self.recordStopButton.enabled = YES;
        
        NSLog(@"Finished playing.");
        
    }];
    
}

#pragma mark - MFMailCompose Delegate method

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    __weak typeof(self) weakSelf = self;
    
    if (error) {
        
        [Utility showAlertWithTitle:APP_TITLE message:error.localizedDescription controller:controller completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"ok tapped");
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        return;
        
    }
    
    NSString *alertMessageString = [self retrieveMailAlertMessageForResult:result];
    
    [Utility showAlertWithTitle:APP_TITLE message:alertMessageString controller:controller completionBlock:^(UIAlertAction *action) {
        
        NSLog(@"ok tapped");
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
        if (!_isMailSent) {
            
            return;
            
        }
        
        [Utility changeLastLocationFlagForUser:weakSelf.user];
        
        NSError *error = nil;
        
        if (![weakSelf saveSharedLocationWithError:error]) {
            
            [Utility showAlertWithTitle:APP_TITLE message:error.localizedDescription controller:weakSelf completionBlock:^(UIAlertAction *action) {
                
                NSLog(@"Ok action");
                
            }];
            
        }
        
        [weakSelf clearAudio:nil];
        
    }];
    
}

- (NSString *)retrieveMailAlertMessageForResult:(MFMailComposeResult)result {
    
    NSString *alertMessageString;
    
    switch (result) {
            
        case MFMailComposeResultSent:
            
            _isMailSent = YES;
            alertMessageString = MAIL_SENT_ALERT_TEXT;
            
            break;
            
        case MFMailComposeResultFailed:
            
            _isMailSent = NO;
            alertMessageString = MAIL_FAILED_ALERT_TEXT;
            
            break;
            
        case MFMailComposeResultCancelled:
            
            _isMailSent = NO;
            alertMessageString = MAIL_CANCEL_ALERT_TEXT;
            
            break;
            
        case MFMailComposeResultSaved:
            
            _isMailSent = NO;
            alertMessageString = MAIL_SAVED_ALERT_TEXT;
            
            break;
            
        default:
            _isMailSent = NO;
            
            break;
    }
    
    return alertMessageString;
    
}

#pragma mark - Database method

- (BOOL)saveSharedLocationWithError:(NSError *)error {
    
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    
    Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:LOCATION_ENTTY inManagedObjectContext:context];
    
    CLLocation *userLocation = self.locationDetail[LOCATION_KEY];
    
    location.latitude = @(userLocation.coordinate.latitude);
    location.longitude = @(userLocation.coordinate.longitude);
    location.isLastShareLocation = @(1);
    location.locationName = self.locationDetail[LOCATION_NAME_KEY];
    
    location.user = self.user;
    
    if (![context save:&error]) {
        
        return NO;
        
    }
    
    return YES;
    
}

@end
