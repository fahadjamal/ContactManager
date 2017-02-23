//
//  DetailTableViewCell.h
//  FirstTask
//
//

#import <UIKit/UIKit.h>

@interface DetailTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *contactDetailTextField;

@property (nonatomic, strong) id textFieldDelegate;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@protocol DetailTableViewCellDelegate <NSObject>

-(void)addDetailForNewContact:(NSString *)valueString keyString:(NSString *)key;

@end

