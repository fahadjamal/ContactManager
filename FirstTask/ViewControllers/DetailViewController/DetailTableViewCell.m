//
//  DetailTableViewCell.m
//  FirstTask
//
//

#import "DetailTableViewCell.h"
#import "DataManager.h"

@implementation DetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *selectedTextFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *keyStrng = [NSString stringWithFormat:@"%@", [[DataManager sharedInstance].addContactKeysArray objectAtIndex:self.selectedIndexPath.row]];
    [self.textFieldDelegate addDetailForNewContact:selectedTextFieldString keyString:keyStrng];
    return YES;
}

@end
