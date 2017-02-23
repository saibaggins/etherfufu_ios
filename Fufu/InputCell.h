//
//  InputCell.h
//  Fufu
//
//  Created by c_jgerald on 02/02/17.
//
//

#import <UIKit/UIKit.h>

@interface InputCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIButton *inputOptionButton;
@property (nonatomic,strong) IBOutlet UILabel *inputCaptionLabel;
@property (nonatomic,strong) IBOutlet UILabel *inputValueLabel;

@end
