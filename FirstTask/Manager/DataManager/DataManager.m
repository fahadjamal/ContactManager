//
//  DataManager.m
//  Second_Task
//
//

#import "DataManager.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@implementation DataManager

+(DataManager *)sharedInstance {
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataManager alloc] init];
        // Do any other initialisation stuff here
        [sharedInstance dataSetUp];
    });
    return sharedInstance;
}

-(void)dataSetUp {
    self.addContactKeysArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.addContactKeysArray addObject:@"First_Name"];
    [self.addContactKeysArray addObject:@"Last_Name"];
    [self.addContactKeysArray addObject:@"Mobile_Number"];
    [self.addContactKeysArray addObject:@"Email_Address"];
    [self.addContactKeysArray addObject:@"Birth_Day"];
    [self.addContactKeysArray addObject:@"Address"];
    [self.addContactKeysArray addObject:@"Photo_Name"];
    
    self.addNewContactDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
}

#pragma mark NSURLConnection Delegate Methods

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)saveContactData:(NSMutableDictionary *)contactDictionary withCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSString *firstName = [NSString stringWithFormat:@"%@", [contactDictionary valueForKey:@"First_Name"]];
    NSString *lastName  = [NSString stringWithFormat:@"%@", [contactDictionary valueForKey:@"Last_Name"]];
    NSString *emailAddress = [NSString stringWithFormat:@"%@", [contactDictionary valueForKey:@"Email_Address"]];
    
    NSString *mobileNumber = [NSString stringWithFormat:@"%@", [contactDictionary valueForKey:@"Mobile_Number"]];
    NSString *birthdayDate = [NSString stringWithFormat:@"%@", [contactDictionary valueForKey:@"Birth_Day"]];
    NSString *address = [NSString stringWithFormat:@"%@", [contactDictionary valueForKey:@"Address"]];
    
    NSString *photoName = [NSString stringWithFormat:@"%@", [contactDictionary valueForKey:@"Photo_Name"]];
    
    // Create a new managed object
    NSManagedObject *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"AddNewContact" inManagedObjectContext:context];
    [newContact setValue:firstName forKey:@"firstName"];
    [newContact setValue:lastName forKey:@"lastName"];
    [newContact setValue:[NSNumber numberWithInteger:[mobileNumber integerValue]] forKey:@"mobileNo"];
    
    [newContact setValue:emailAddress forKey:@"emailAddress"];
    [newContact setValue:[self dateFromString:birthdayDate] forKey:@"birthDate"];
    [newContact setValue:address forKey:@"address"];

    [newContact setValue:photoName forKey:@"photoName"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        completionBlock(false , error);
    }
    else {
         completionBlock(true , nil);
    }
}

-(void)saveUpdateContactData:(NSManagedObject *)contact withCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSString *firstName = [NSString stringWithFormat:@"%@", [self.addNewContactDictionary valueForKey:@"First_Name"]];
    NSString *lastName  = [NSString stringWithFormat:@"%@", [self.addNewContactDictionary valueForKey:@"Last_Name"]];
    NSString *emailAddress = [NSString stringWithFormat:@"%@", [self.addNewContactDictionary valueForKey:@"Email_Address"]];
    
    NSString *mobileNumber = [NSString stringWithFormat:@"%@", [self.addNewContactDictionary valueForKey:@"Mobile_Number"]];
    NSString *birthdayDate = [NSString stringWithFormat:@"%@", [self.addNewContactDictionary valueForKey:@"Birth_Day"]];
    NSString *address = [NSString stringWithFormat:@"%@", [self.addNewContactDictionary valueForKey:@"Address"]];
    
    NSString *photoName = [NSString stringWithFormat:@"%@", [self.addNewContactDictionary valueForKey:@"Photo_Name"]];
    
    // Create a new managed object
    [contact setValue:firstName forKey:@"firstName"];
    [contact setValue:lastName forKey:@"lastName"];
    [contact setValue:[NSNumber numberWithInteger:[mobileNumber integerValue]] forKey:@"mobileNo"];
    
    [contact setValue:emailAddress forKey:@"emailAddress"];
    [contact setValue:[self dateFromString:birthdayDate] forKey:@"birthDate"];
    [contact setValue:address forKey:@"address"];
    
    [contact setValue:photoName forKey:@"photoName"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        completionBlock(false , error);
    }
    else {
        completionBlock(true , nil);
    }
}

-(void)loadAllContactData:(void (^)(NSArray *allContactList, NSError *error))completionBlock {
    // load All
    NSError *error = nil;

    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"AddNewContact"];
    NSArray *fullList = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    // Save the object to persistent store
    if (error != nil) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        completionBlock(nil , error);
    }
    else {
        completionBlock(fullList , error);
    }
}

-(void)deleteSpecificContactFromList:(NSManagedObject *)contact completionHandler:(void (^)(BOOL success, NSError *error))completionBlock {
    // load All
    NSError *error = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Delete object from database
    [context deleteObject:contact];
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        completionBlock(false , error);
    }
    else {
        completionBlock(true , error);
    }
}

-(NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

-(NSString *)stringFromDate:(NSDate *)dobDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:dobDate];
    NSLog(@"%@", stringDate);
    return stringDate;
}

-(NSString *)stringFromCurrentDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HH-MM-SS"];
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@", stringDate);
    return stringDate;
}


@end
