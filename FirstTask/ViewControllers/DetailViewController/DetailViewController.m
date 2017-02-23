//
//  DetailViewController.m
//  FirstTask
//
//

#import "DetailViewController.h"
#import "DetailTableViewCell.h"

#import "DataManager.h"

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *detailTableView;

@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UIButton *profileButton;

@property (nonatomic, strong) NSArray *placeHolderArray;

@property (nonatomic, strong) UIImage *selectedProfileImage;

-(IBAction)profileButtonTapped:(id)sender;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.placeHolderArray = [NSArray arrayWithObjects:@"First Name *", @"Last Name *", @"Mobile Number *", @"Email Address *", @"Birth Date", @"Address", nil];
    
    if (self.isEditing) {
        UIBarButtonItem *editContactBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                                 target:self action:@selector(editContactBarButtonTapped:)];
        self.navigationItem.rightBarButtonItem = editContactBarButton;
    }
    else {
        UIBarButtonItem *saveNewContactBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                 target:self action:@selector(saveNewContactBarButtonTapped:)];
        self.navigationItem.rightBarButtonItem = saveNewContactBarButton;
    }
    
    if (self.contact) {
        NSString *firstName = [NSString stringWithFormat:@"%@", [self.contact valueForKey:@"firstName"]];
        NSString *lastName  = [NSString stringWithFormat:@"%@", [self.contact valueForKey:@"lastName"]];
        NSString *emailAddress = [NSString stringWithFormat:@"%@", [self.contact valueForKey:@"emailAddress"]];
        
        NSString *mobileNumber = [NSString stringWithFormat:@"%@", [self.contact valueForKey:@"mobileNo"]];
        
        NSDate *dob = [self.contact valueForKey:@"birthDate"];
        NSString *birthdayDate = [NSString stringWithFormat:@"%@", [[DataManager sharedInstance] stringFromDate:dob]];
        NSString *address = [NSString stringWithFormat:@"%@", [self.contact valueForKey:@"address"]];
        
        NSString *photoName = [NSString stringWithFormat:@"%@", [self.contact valueForKey:@"photoName"]];
        
        [[DataManager sharedInstance].addNewContactDictionary removeAllObjects];
        
        [[DataManager sharedInstance].addNewContactDictionary setObject:firstName forKey:@"First_Name"];
        [[DataManager sharedInstance].addNewContactDictionary setObject:lastName forKey:@"Last_Name"];
        [[DataManager sharedInstance].addNewContactDictionary setObject:emailAddress forKey:@"Email_Address"];
        
        [[DataManager sharedInstance].addNewContactDictionary setObject:mobileNumber forKey:@"Mobile_Number"];
        [[DataManager sharedInstance].addNewContactDictionary setObject:birthdayDate forKey:@"Birth_Day"];
        [[DataManager sharedInstance].addNewContactDictionary setObject:address forKey:@"Address"];
        
        NSString *imageFilePath1 = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), photoName];
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath1]];
        UIImage *thumbNail = [[UIImage alloc] initWithData:imgData];
        
        [self.profileButton setBackgroundImage:thumbNail forState:UIControlStateNormal];
        
        [self.navigationItem setTitle:firstName];
    }
    else {
         [self.navigationItem setTitle:@"Add New Contact"];
    }
    
    [self.profileButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.profileButton.layer setCornerRadius:self.profileButton.frame.size.width/2];
    [self.profileButton.layer setMasksToBounds:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDataSource Method -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.placeHolderArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DetailTableViewCell";
    
    DetailTableViewCell *cell = (DetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell.contactDetailTextField setPlaceholder:[NSString stringWithFormat:@"%@", [self.placeHolderArray objectAtIndex:indexPath.row]]];
    [cell setTextFieldDelegate:self];
    [cell setSelectedIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *keyString = [[DataManager sharedInstance].addContactKeysArray objectAtIndex:indexPath.row];
    NSString *valueString = [[DataManager sharedInstance].addNewContactDictionary valueForKey:keyString];
    
    switch (indexPath.row) {
        case 0:
        case 1:
        case 5:
            cell.contactDetailTextField.keyboardType = UIKeyboardTypeDefault;
            break;

        case 2:
            cell.contactDetailTextField.keyboardType = UIKeyboardTypePhonePad;
            break;
            
        case 3:
            cell.contactDetailTextField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
            
        case 4: {
            UIDatePicker *datePicker = [[UIDatePicker alloc]init];
            [datePicker setDate:[NSDate date]];
            datePicker.datePickerMode = UIDatePickerModeDate;
            [datePicker addTarget:self action:@selector(dateTextField:) forControlEvents:UIControlEventValueChanged];
            [cell.contactDetailTextField setInputView:datePicker];
        }
            
            break;
            
        default:
            break;
    }
    
    if (valueString != nil || valueString.length > 0) {
        cell.contactDetailTextField.text = valueString;
    }
    else {
        cell.contactDetailTextField.text = @"";
    }
    
    if (self.contact) {
        cell.contactDetailTextField.userInteractionEnabled = false;
    }
    else {
        cell.contactDetailTextField.userInteractionEnabled = true;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Method -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Button Action Method -

-(IBAction)profileButtonTapped:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //You can retrieve the actual UIImage
    if (self.contact) {
        self.selectedProfileImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self.profileButton setBackgroundImage:self.selectedProfileImage forState:UIControlStateNormal];
    }
    else {
        UIImage *contactImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData1 = UIImagePNGRepresentation(contactImage);
        
        NSString *fileName = [NSString stringWithFormat:@"%@.png", [[DataManager sharedInstance] stringFromCurrentDate]];
        NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath: imageFilePath error:nil];
        }
        
        [[NSFileManager defaultManager] createFileAtPath: imageFilePath contents: imageData1 attributes:nil];
        [[DataManager sharedInstance].addNewContactDictionary setObject:fileName forKey:@"Photo_Name"];
        [self.profileButton setBackgroundImage:contactImage forState:UIControlStateNormal];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)editContactBarButtonTapped:(id)sender {
    self.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *updateContactBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                             target:self action:@selector(updateContactBarButtonTapped:)];
    self.navigationItem.rightBarButtonItem = updateContactBarButton;

    self.navigationItem.hidesBackButton = true;
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self action:@selector(cancelBarButtonTapped:)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    for (NSInteger i = 0; i < [self.detailTableView numberOfRowsInSection:0]; i++)
    {
        DetailTableViewCell *cell = [self.detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.contactDetailTextField.userInteractionEnabled = true;
    }
}

-(IBAction)cancelBarButtonTapped:(id)sender {
    self.navigationItem.hidesBackButton = false;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *editContactBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                          target:self action:@selector(editContactBarButtonTapped:)];
    self.navigationItem.rightBarButtonItem = editContactBarButton;
}

-(IBAction)updateContactBarButtonTapped:(id)sender {
    if ([self validateUserContact]) {
        NSData *imageData1 = UIImagePNGRepresentation(self.selectedProfileImage);
        
        NSString *previousFileName = [NSString stringWithFormat:@"%@.png", [self.contact valueForKey:@"photoName"]];
        NSString *peviousImageFilePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), previousFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:peviousImageFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath: peviousImageFilePath error:nil];
        }
        
        NSString *newFileName = [NSString stringWithFormat:@"%@.png", [[DataManager sharedInstance] stringFromCurrentDate]];
        NSString *newImageFilePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), newFileName];
        [[NSFileManager defaultManager] createFileAtPath: newImageFilePath contents: imageData1 attributes:nil];
        [[DataManager sharedInstance].addNewContactDictionary setObject:newFileName forKey:@"Photo_Name"];
        [self.profileButton setBackgroundImage:self.selectedProfileImage forState:UIControlStateNormal];
        
        [[DataManager sharedInstance] saveUpdateContactData:self.contact withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Contact" message:@"Successfully Updated"
                                                                          delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [successAlertView setTag:2000];
                [successAlertView show];
            }
            else {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Contact Error" message:@"Unable to Update"
                                                                        delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [errorAlertView show];
            }
        }];
    }
}

-(IBAction)saveNewContactBarButtonTapped:(id)sender {
    if ([self validateUserContact]) {
        NSLog(@"validateUserContact");
        
        [[DataManager sharedInstance] saveContactData:[DataManager sharedInstance].addNewContactDictionary withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Contact" message:@"Successfully Added"
                                                                          delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [successAlertView setTag:1000];
                [successAlertView show];
            }
            else {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Contact Error" message:@"Unable to Added"
                                                                        delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [errorAlertView show];
            }
        }];
    }
}

#pragma mark - Class Instance Method -

-(void) dateTextField:(id)sender {
    DetailTableViewCell *cell = [self.detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    UIDatePicker *picker = (UIDatePicker *)cell.contactDetailTextField.inputView;
    [picker setMaximumDate:[NSDate date]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:eventDate];
    cell.contactDetailTextField.text = [NSString stringWithFormat:@"%@",dateString];
    [[DataManager sharedInstance].addNewContactDictionary setValue:dateString forKey:@"Birth_Day"];
}

-(BOOL) validateUserContact {
    BOOL WhatToReturn = TRUE;
    NSString *error;
    
    for (NSInteger row = 0; row < 4; row++) {
        NSString *keyString = [[DataManager sharedInstance].addContactKeysArray objectAtIndex:row];
        NSString *valueString = [[DataManager sharedInstance].addNewContactDictionary valueForKey:keyString];
        
        DetailTableViewCell *cell = [self.detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        if (row == 3) {
            if (valueString == nil || valueString.length == 0 || ![self isValidEmail:valueString]) {
                error = [NSString stringWithFormat:@"Please Enter Valid %@", keyString];
                WhatToReturn = NO;
                [self AnimationAsIfErrorfor:cell.contactDetailTextField];
                break;
            }
        }
        else {
            if (valueString == nil || valueString.length == 0) {
                error = [NSString stringWithFormat:@"Please Enter Valid %@", keyString];
                WhatToReturn = NO;
                [self AnimationAsIfErrorfor:cell.contactDetailTextField];
                break;
            }
        }
    }
    
    if (error != nil) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Contact" message:error delegate:self
                                                            cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorAlert show];
    }
    return WhatToReturn;
}

- (BOOL)isValidEmail:(NSString *)emailString {
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:emailString];
}

-(void) AnimationAsIfErrorfor:(UITextField *)selectedTextField {
    CGPoint position = selectedTextField.center;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(position.x, position.y)];
    [path addLineToPoint:CGPointMake(position.x-20, position.y)];
    [path addLineToPoint:CGPointMake(position.x+20, position.y)];
    [path addLineToPoint:CGPointMake(position.x-20, position.y)];
    [path addLineToPoint:CGPointMake(position.x+20, position.y)];
    [path addLineToPoint:CGPointMake(position.x, position.y)];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = path.CGPath;
    positionAnimation.duration = .5f;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [CATransaction begin];
    [selectedTextField.layer addAnimation:positionAnimation forKey:nil];
    [CATransaction commit];
}

-(void)addDetailForNewContact:(NSString *)valueString keyString:(NSString *)key {
    [[DataManager sharedInstance].addNewContactDictionary setValue:valueString forKey:key];
    NSLog(@"[DataManager sharedInstance].addNewContactDictionary is %@", [DataManager sharedInstance].addNewContactDictionary);
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 2000) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    self.detailTableView = nil;
    
    self.tableHeaderView = nil;
    self.profileButton = nil;
    
    self.placeHolderArray = nil;
    self.selectedProfileImage = nil;
    
    self.contact = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
