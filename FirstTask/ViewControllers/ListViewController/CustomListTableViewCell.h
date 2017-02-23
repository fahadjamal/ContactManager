//
//  CustomListTableViewCell.h
//  FirstTask
//
//

#import <UIKit/UIKit.h>

@interface CustomListTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *mobilePhoneLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailAddressLabel;

@property (nonatomic, strong) IBOutlet UIImageView *contactImageView;

@end
