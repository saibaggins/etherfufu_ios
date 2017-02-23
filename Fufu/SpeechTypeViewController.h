//
//  SpeechTypeViewController.h
//  Fufu
//
//  Created by c_jgerald on 02/02/17.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol sendDataProtocol <NSObject>

-(void)sendData:(NSString *)inputText audioFileName:(NSString*)audioFileName;

@end

@interface SpeechTypeViewController : UIViewController <AVAudioRecorderDelegate>

@property (nonatomic, strong) IBOutlet UILabel *viewHeaderLabel;
@property (nonatomic, strong) IBOutlet UILabel *inputCaptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *inputValueLabel;
@property (nonatomic, strong) IBOutlet UIButton *inputOptionButton;
@property (nonatomic, strong) IBOutlet UIButton *RecordButton;
@property (nonatomic, strong) IBOutlet UITextView *speechTextView;
@property (nonatomic, strong) NSMutableArray *inputList;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString* audioFileName;

- (IBAction)backButton_Click:(id)sender;
- (IBAction)inputOptionButton_Click:(id)sender;
- (IBAction)RecordButton_Click:(id)sender;

@end
