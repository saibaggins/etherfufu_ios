//
//  InputCell.m
//  Fufu
//
//  Created by c_jgerald on 02/02/17.
//
//

#import "InputCell.h"

@implementation InputCell

@synthesize inputOptionButton;
@synthesize inputCaptionLabel;
@synthesize inputValueLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
