//
//  InputViewController.h
//  Fufu
//
//  Created by c_jgerald on 02/02/17.
//
//

#import <UIKit/UIKit.h>
#import "InputCell.h"

@interface InputViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *InputTable;
@property (nonatomic, strong) IBOutlet InputCell *InputTableCell;
@property (nonatomic, strong) IBOutlet UIButton *SubmitButton;
@property (nonatomic, strong) NSMutableArray *inputList;
@property (nonatomic, strong) NSString* audioFilePath;

- (IBAction)SubmitButton_Click:(id)sender;
- (IBAction)inputOptionButton_Click:(id)sender;

-(void)placeRequest:(NSMutableURLRequest *)request withHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))ourBlock;

@end
