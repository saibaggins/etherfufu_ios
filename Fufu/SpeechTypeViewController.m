//
//  SpeechTypeViewController.m
//  Fufu
//
//  Created by c_jgerald on 02/02/17.
//
//

#import "SpeechTypeViewController.h"
#import "ActionSheetPicker.h"

@interface SpeechTypeViewController ()

@end

@implementation SpeechTypeViewController

@synthesize viewHeaderLabel;
@synthesize inputCaptionLabel;
@synthesize inputValueLabel;
@synthesize inputOptionButton;
@synthesize speechTextView;
@synthesize RecordButton;
@synthesize inputList;
@synthesize selectedIndex;
@synthesize delegate;
@synthesize audioFileName;

AVAudioRecorder *recorder;
NSString *recorderFilePath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RecordButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    RecordButton.layer.borderWidth = 2;
    RecordButton.layer.cornerRadius = 5.0;
    
    speechTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    speechTextView.layer.borderWidth = 1;
    speechTextView.layer.cornerRadius = 5.0;
    
    inputOptionButton.imageEdgeInsets = UIEdgeInsetsMake(13, (self.view.bounds.size.width - 34), 13, 10);
    
    NSMutableDictionary *inputDict = [[NSMutableDictionary alloc] initWithDictionary:[inputList objectAtIndex:self.selectedIndex]];
    viewHeaderLabel.text = [inputDict valueForKey:@"display_name"];
    inputCaptionLabel.text = [inputDict valueForKey:@"display_name"];
    inputValueLabel.text = [inputDict valueForKey:@"default_value"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [delegate sendData:speechTextView.text audioFileName:self.audioFileName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [speechTextView endEditing:YES];
}

- (IBAction)backButton_Click:(id)sender
{
    if ([RecordButton.titleLabel.text isEqualToString:@"Stop"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Stop the recording audio before you proceed." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)inputOptionButton_Click:(id)sender
{
    NSMutableDictionary *inputDict = [[NSMutableDictionary alloc] initWithDictionary:[inputList objectAtIndex:self.selectedIndex]];
    NSString *inputName = [inputDict valueForKey:@"display_name"];
    
    if ([inputName isEqualToString:@"Speech Type"])
    {
        NSArray *optionList = [inputDict valueForKey:@"enum"];
        
        [ActionSheetStringPicker showPickerWithTitle:inputName
                                                rows:optionList
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               [inputDict setValue:selectedValue forKey:@"default_value"];
                                               [inputList replaceObjectAtIndex:self.selectedIndex withObject:inputDict];
                                               
                                               inputValueLabel.text = selectedValue;
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:sender];
    }
}

- (IBAction)RecordButton_Click:(id)sender
{
    if ([RecordButton.titleLabel.text isEqualToString:@"Record"]) {
        [self startRecording];
    } else {
        [self stopRecording];
    }
}

//--------------

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

- (void) startRecording {
    
    [RecordButton setAttributedTitle:nil forState:UIControlStateNormal];
    [RecordButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    [audioSession setActive:YES error:&err];
    err = nil;
    
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, caldate];
    self.audioFileName = recorderFilePath;
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    
    if(!recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:[err localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    NSArray *availableInputs = [audioSession availableInputs];
    BOOL audioHWAvailable = false;
    for (AVAudioSessionPortDescription *port in availableInputs)
    {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic] ||
            [port.portType isEqualToString:AVAudioSessionPortHeadsetMic])
        {
            audioHWAvailable = true;
        }
    }
    
    if (! audioHWAvailable) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Audio input hardware not available" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    // start recording
    [recorder recordForDuration:(NSTimeInterval) 1];
}

- (void) stopRecording
{
    [recorder stop];
    
    [RecordButton setAttributedTitle:nil forState:UIControlStateNormal];
    [RecordButton setTitle:@"Record" forState:UIControlStateNormal];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    
    [RecordButton setAttributedTitle:nil forState:UIControlStateNormal];
    [RecordButton setTitle:@"Record" forState:UIControlStateNormal];
}

//--------------

@end
