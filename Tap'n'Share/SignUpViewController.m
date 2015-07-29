//
//  SignUpViewController.m
//  Tap'n'Share
//
//  Created by Nikhil Wali on 27/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "User.h"

static float offset = 40.0f;

NSString * const NAME_KEY = @"name";
NSString * const GENDER_KEY = @"gender";
NSString * const USERNAME_KEY = @"username";
NSString * const PASSWORD_KEY = @"password";
NSString * const EMAIL_KEY = @"email";

NSString * const SUCCESSFULLY_REGISTERED_USER_TEXT = @"Your successfully registered";
NSString * const ALREADY_REGISTERED_USERNAME_TEXT = @"Username already registered";
NSString * const ALREADY_REGISTERED_USER_TEXT = @"Already registered user";
NSString * const INVALID_EMAIL_ID_TEXT = @"Provide a valid email ID.";

NSString * const EMAIL_REGEX = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

NSString * const ALPHABETS_CHARACTERS = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

NSString * const MALE = @"MALE";
NSString * const FEMALE = @"FEMALE";

@interface SignUpViewController () <UITextFieldDelegate> {
    
    UITextField *_activeTextField;
    
    UITapGestureRecognizer *_tapGesture;
    
    BOOL _isEmailValid;
    
}

@property (nonatomic, weak) IBOutlet UIButton *registerButton;

@property (nonatomic, weak) IBOutlet UISegmentedControl *genderSegmentController;

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation SignUpViewController

#pragma mark - Lifecycle 

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self addTapGesture];   //To dismiss keyboard.
    
    [self resetSignupForm];  //Reset forme to default values
    
    self.appDelegate = [Utility appDelegateInstance];
    
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

- (void)resetSignupForm {
    
    self.nameTextField.text = @"";
    self.emailTextField.text = @"";
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    
    self.registerButton.enabled = NO;
    
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

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.nameTextField) {
        
        [self.nameTextField resignFirstResponder];
        [self.usernameTextField becomeFirstResponder];
        
    }
    else if (textField == self.usernameTextField) {
        
        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];

    }
    if (textField == self.passwordTextField) {
        
        [self.passwordTextField resignFirstResponder];
        [self.emailTextField becomeFirstResponder];
        
    }
    else if (textField == self.emailTextField) {
        
        [self.emailTextField resignFirstResponder];
        
    }
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _activeTextField = textField;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    _activeTextField = nil;
    
    if (self.nameTextField.text.length == 0 || self.usernameTextField.text.length == 0 || self.passwordTextField.text.length == 0 || self.emailTextField.text.length == 0) {
        
        self.registerButton.enabled = NO;
        
    }
    else {
        
        self.registerButton.enabled = YES;
        
    }
    
    if (textField == self.emailTextField) {
        
        /*
         If invalid email id then text will be RED else BLACK (default)
         */
        if (![self validateEmail:textField.text]) {
            
            textField.textColor = [UIColor redColor];
            _isEmailValid = NO;
            
        }
        else {
            
            textField.textColor = [UIColor blackColor];
            _isEmailValid = YES;
            
        }
        
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    /*
     Name textifeld to allow only alphabets.
     */
    if (textField == self.nameTextField) {
        
        NSCharacterSet *invalidCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:ALPHABETS_CHARACTERS] invertedSet];
        
        NSString *filteredString = [[string componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
        
        return [string isEqualToString:filteredString];
        
    }
    else {
        
        return YES;
        
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

#pragma mark - Validation check methods

- (BOOL)validateEmail:(NSString *)emailString {
    
    NSString *emailRegexString = EMAIL_REGEX;
    NSPredicate *emailTestPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegexString];
    
    return [emailTestPredicate evaluateWithObject:emailString];
    
}

#pragma mark - IBAction Method

- (IBAction)registerNewUSer:(id)sender {
    
    if (!_isEmailValid) {
        
        [Utility showAlertWithTitle:APP_TITLE message:INVALID_EMAIL_ID_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    if (![self isUserNameAvailable]) {
        
        [Utility showAlertWithTitle:APP_TITLE message:ALREADY_REGISTERED_USERNAME_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    if ([self isUserRegistered]) {
        
        [Utility showAlertWithTitle:APP_TITLE message:ALREADY_REGISTERED_USER_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    NSError *error = nil;
    
    NSString *genderString = (self.genderSegmentController.selectedSegmentIndex == 0) ? MALE : FEMALE;
    
    NSDictionary *userDetails = @{NAME_KEY : self.nameTextField.text, EMAIL_KEY : self.emailTextField.text, USERNAME_KEY : self.usernameTextField.text, PASSWORD_KEY : self.passwordTextField.text, GENDER_KEY : genderString};
    
    if (![self saveUserCredentialWithDetails:userDetails error:error]) {
        
        //error alert
        [Utility showAlertWithTitle:APP_TITLE message:error.localizedDescription controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    NSString *welcomeString = [NSString stringWithFormat:@"Welcome %@\n%@", self.nameTextField.text, SUCCESSFULLY_REGISTERED_USER_TEXT];
    
    //success alert
    [Utility showAlertWithTitle:APP_TITLE message:welcomeString controller:self completionBlock:^(UIAlertAction *action) {
        
        NSLog(@"Welcome");
        
        self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
}

#pragma mark - Database method

- (BOOL)isUserRegistered {
    
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:USER_ENTTY inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(email = %@)", self.emailTextField.text];
    request.predicate = predicate;
    request.fetchLimit = 1;
    
    NSError *error;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users.count) {
        
        return NO;
        
    }
    
    return YES;
    
}

- (BOOL)isUserNameAvailable {
    
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:USER_ENTTY inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username = %@)", self.usernameTextField.text];
    request.predicate = predicate;
    request.fetchLimit = 1;
    
    NSError *error;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users.count) {
        
        return YES;
        
    }
    
    return NO;
    
}

- (BOOL)saveUserCredentialWithDetails:(NSDictionary *)userDetails error:(NSError *)error {
    
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    
    User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:USER_ENTTY inManagedObjectContext:context];
    
    user.name = userDetails[NAME_KEY];
    user.gender = userDetails[GENDER_KEY];
    user.password = userDetails[PASSWORD_KEY];
    user.email = userDetails[EMAIL_KEY];
    user.username = userDetails[USERNAME_KEY];

    if (![context save:&error]) {
        
        return NO;
        
    }

    return YES;
    
}

@end
