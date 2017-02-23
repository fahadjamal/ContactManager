//
//  DataManager.h
//  Second_Task
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSMutableArray *addContactKeysArray;
@property (nonatomic, strong) NSMutableDictionary *addNewContactDictionary;

+(DataManager *)sharedInstance;

-(void)saveContactData:(NSMutableDictionary *)contactDictionary withCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

-(void)loadAllContactData:(void (^)(NSArray *allContactList, NSError *error))completionBlock;

-(void)deleteSpecificContactFromList:(NSManagedObject *)contact completionHandler:(void (^)(BOOL success, NSError *error))completionBlock;

-(void)saveUpdateContactData:(NSManagedObject *)contact withCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

-(NSString *)stringFromCurrentDate;

-(NSString *)stringFromDate:(NSDate *)dobDate;

@end
