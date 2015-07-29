//
//  LoginViewController.m
//  Tap'n'Share
//
//  Created by Nikhil Wali on 27/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "User.h"

static float offset = 40.0f;

NSString * const INVALID_USER_TEXT = @"Invalid User";

NSString * const HOME_VIEW_ID = @"HomeViewID";

@interface LoginViewController () <UITextFieldDelegate> {
    
    UITextField *_activeTextField;
    
    UITapGestureRecognizer *_tapGesture;
    
    User *_user;
    
}

@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) HomeViewController *homeViewController;

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation LoginViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    [self addTapGesture];   //To dismiss keyboard.
    
    self.appDelegate = [UIApplication sharedApplication].delegate;

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [self.view removeGestureRecognizer:_tapGesture];
    _tapGesture = nil;
    
    [super viewWillDisappear:animated];
    
}

#pragma mark - Gesture Method

- (void)addTapGesture {
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    _tapGesture.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer:_tapGesture];
    
}

- (void)dismissKeyboard {
    
    [self.view endEditing:YES];
    
}

- (void)resetLoginForm {
    
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    
    self.loginButton.enabled = NO;
    
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if (textField == self.usernameTextField) {

        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
        
    }
    else if (textField == self.passwordTextField) {
        
        [self login:nil];
        
    }
    
    return YES;

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _activeTextField = textField;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    _activeTextField = nil;
    
    if (self.passwordTextField.text.length == 0 || self.usernameTextField.text.length == 0) {
        
        self.loginButton.enabled = NO;
        
    }
    else {
        
        self.loginButton.enabled = YES;
        
    }
    
}

#pragma mark - Keyboard notification

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + offset, 0.0);
    
    [self.scrollView setContentInset:contentInsets];
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, _activeTextField.frame.origin)){
        
        [self.scrollView scrollRectToVisible:_activeTextField.frame animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}

#pragma mark - Home view controller

- (void)showHomeView {
    
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    self.homeViewController = [myStoryboard instantiateViewControllerWithIdentifier:HOME_VIEW_ID];
    self.homeViewController.user = _user;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}


#pragma mark - IBAction Method

- (IBAction)login:(id)sender {
    
    [self dismissKeyboard];
    
    if (![self isUserValid]) {
        
        //Invalid user alert
        [Utility showAlertWithTitle:APP_TITLE message:INVALID_USER_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    [self resetLoginForm];
    
    [self showHomeView];
    
}

- (BOOL)isUserValid {
    
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username = %@ && password = %@)", self.usernameTextField.text, self.passwordTextField.text];
    request.predicate = predicate;
    request.fetchLimit = 1;
    
    NSError *error;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users.count) {
        
        return NO;
        
    }
    
    _user = users.firstObject;
    
    return YES;
    
}

@end
