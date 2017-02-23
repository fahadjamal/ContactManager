//
//  ListViewController.m
//  FirstTask
//
//

#import "ListViewController.h"
#import "CustomListTableViewCell.h"

#import "DetailViewController.h"
#import "DataManager.h"

#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>


@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *listTableView;

@property (nonatomic, strong) NSMutableArray *contactsArray;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) BOOL isEditing;

@end

@implementation ListViewController

#pragma mark - Default Init Method -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationItem setTitle:@"Contact Manager"];
    
    UIBarButtonItem *addNewContact = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact)];
    
    self.navigationItem.rightBarButtonItem = addNewContact;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] loadAllContactData:^(NSArray *allContactList, NSError *error) {
        if (error == nil) {
            [self.contactsArray removeAllObjects];
            self.contactsArray = [[NSMutableArray alloc] initWithArray:allContactList];
            
            [self.listTableView reloadData];
        }
        else {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to fetch"
                                                                    delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
        }
    }];
}

#pragma mark - UITableViewDataSource Method -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contactsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomListTableViewCell";
    
    CustomListTableViewCell *cell = (CustomListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSManagedObject *contact = [self.contactsArray objectAtIndex:indexPath.row];
    [cell.nameLabel setText:[NSString stringWithFormat:@"%@", [contact valueForKey:@"firstName"]]];
    [cell.mobilePhoneLabel setText:[NSString stringWithFormat:@"%ld", [[contact valueForKey:@"mobileNo"] integerValue]]];
    [cell.emailAddressLabel setText:[NSString stringWithFormat:@"%@", [contact valueForKey:@"emailAddress"]]];
    
    NSString *imageFilePath1 = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), [contact valueForKey:@"photoName"]];
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath1]];
    UIImage *thumbNail = [[UIImage alloc] initWithData:imgData];
    [cell.contactImageView setImage:thumbNail];
    
    [cell.contactImageView setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contactImageView.layer setCornerRadius:cell.contactImageView.frame.size.width/2];
    [cell.contactImageView.layer setMasksToBounds:YES];
    
    return cell;
}

#pragma mark - UITableViewDelegate Method -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!tableView.isEditing) {
        self.selectedIndexPath = indexPath;
        
        UIActionSheet *menuActionSheet = [[UIActionSheet alloc] initWithTitle:@"Contact Menu" delegate:self
                                                            cancelButtonTitle:@"Close"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Show Details", @"Call", @"Send an Email",  nil];
        [menuActionSheet setTag:123];
        [menuActionSheet showInView:self.view];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObject *contact = [self.contactsArray objectAtIndex:indexPath.row];

        [[DataManager sharedInstance] deleteSpecificContactFromList:contact completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                // Remove device from table view
                [self.contactsArray removeObjectAtIndex:indexPath.row];
                [self.listTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [[[UIAlertView alloc] initWithTitle:@"Success" message:@"User deleted" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving user data, please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
        }];
    }
}

#pragma mark - UIActionSheetDelegate Method -

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 123) {
        switch (buttonIndex) {
            case 0: {
                NSLog(@"buttonIndex is %ld", (long)buttonIndex);
                [self showDetailsOfSpecificContact];
                break;
            }
            case 1: {
                NSLog(@"buttonIndex is %ld", (long)buttonIndex);
                [self makeCallToSpecificContact];
                break;
            }
            case 2: {
                NSLog(@"buttonIndex is %ld", (long)buttonIndex);
                [self sendEmailToSpecificContact];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Class Instance Method -

-(void)showDetailsOfSpecificContact {
    self.isEditing = TRUE;
    [[DataManager sharedInstance].addNewContactDictionary removeAllObjects];
    [self performSegueWithIdentifier:@"DetailViewController" sender:[NSNumber numberWithBool:self.isEditing]];
}

-(void)makeCallToSpecificContact {
    NSManagedObject *contact = [self.contactsArray objectAtIndex:self.selectedIndexPath.row];
    NSString *mobileNumber = [NSString stringWithFormat:@"%ld", [[contact valueForKey:@"mobileNo"] integerValue]];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",mobileNumber]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
    else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

-(void)sendEmailToSpecificContact {
    NSManagedObject *contact = [self.contactsArray objectAtIndex:self.selectedIndexPath.row];
    NSString *emailAddress = [NSString stringWithFormat:@"%@", [contact valueForKey:@"emailAddress"]];
    NSLog(@"emailAddress is %@", emailAddress);
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
         mail.mailComposeDelegate = self;
        [mail setSubject:@"Sample Subject"];
        [mail setMessageBody:@"Here is some main text in the email!" isHTML:NO];
        [mail setToRecipients:@[@"testingEmail@example.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Button Action Method -

- (void)addContact {
    [[DataManager sharedInstance].addNewContactDictionary removeAllObjects];
    self.isEditing = FALSE;
    [self performSegueWithIdentifier:@"DetailViewController" sender:[NSNumber numberWithBool:self.isEditing]];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([[segue identifier] isEqualToString:@"DetailViewController"]) {
         NSNumber *isEditingFlag = (NSNumber *)sender;
         
         if ([isEditingFlag boolValue]) {
             DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
             detailViewController.isEditing = [isEditingFlag boolValue];
             detailViewController.contact = [self.contactsArray objectAtIndex:self.selectedIndexPath.row];
         }
         else {
             DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
             detailViewController.isEditing = [isEditingFlag boolValue];
         }
     }
 }

#pragma mark - Default De-Init Method -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    self.listTableView = nil;
    
    self.contactsArray = nil;
    self.selectedIndexPath = nil;
}

@end
