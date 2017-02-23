//
//  DetailViewController.h
//  FirstTask
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DetailViewController : UIViewController

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) NSManagedObject *contact;

@end
