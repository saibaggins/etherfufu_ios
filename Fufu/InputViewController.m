//
//  InputViewController.m
//  Fufu
//
//  Created by c_jgerald on 02/02/17.
//
//

#import "InputViewController.h"
#import "ActionSheetPicker.h"
#import "SpeechTypeViewController.h"

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize InputTable;
@synthesize InputTableCell;
@synthesize SubmitButton;
@synthesize inputList;
@synthesize audioFilePath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SubmitButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    SubmitButton.layer.borderWidth = 2;
    SubmitButton.layer.cornerRadius = 5.0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FufuInput" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    
    NSError *error;
    NSPropertyListFormat format;
    NSArray *inputArray = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
    
    if(!inputArray){
        NSLog(@"Error: %@",error);
    }
    
    NSArray *filteredInputArray = [inputArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(required == %d)", 1]];
    self.inputList = [[NSMutableArray alloc] initWithArray:filteredInputArray];
    
    [InputTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*NSString *requestString = @"http://etherfufu-staging.us-east-1.elasticbeanstalk.com/audiobank/v1/options";
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [self placeRequest:request withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *inputArray;
        
        if (!error) {
            inputArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        } else {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"FufuInput" ofType:@"plist"];
            NSData *plistData = [NSData dataWithContentsOfFile:path];
            
            NSError *error;
            NSPropertyListFormat format;
            inputArray = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
        }
        
        if(!inputArray){
            NSLog(@"Error: %@",error);
        }
        
        NSArray *filteredInputArray = [inputArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(required == %d)", 1]];
        self.inputList = [[NSMutableArray alloc] initWithArray:filteredInputArray];
        
        [InputTable reloadData];
    }];*/
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.inputList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InputTableCell";
    NSMutableDictionary *inputDict = [inputList objectAtIndex:indexPath.row];
    
    InputCell *cell = (InputCell*)[InputTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"InputCell" owner:self options:nil];
        cell = (InputCell*)InputTableCell;
    }
    
    cell.inputOptionButton.imageEdgeInsets = UIEdgeInsetsMake(13, (self.view.bounds.size.width - 34), 13, 10);
    cell.inputOptionButton.tag = indexPath.row;
    cell.inputCaptionLabel.text = [inputDict valueForKey:@"display_name"];
    cell.inputValueLabel.text = [inputDict valueForKey:@"default_value"];
    
    return cell;
}

- (IBAction)inputOptionButton_Click:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger index = button.tag;
    
    NSMutableDictionary *inputDict = [[NSMutableDictionary alloc] initWithDictionary:[inputList objectAtIndex:index]];
    NSString *inputName = [inputDict valueForKey:@"display_name"];
    
    if (![inputName isEqualToString:@"Speech Type"])
    {
        NSArray *optionList = [inputDict valueForKey:@"enum"];
        
        [ActionSheetStringPicker showPickerWithTitle:inputName
                                                rows:optionList
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               [inputDict setValue:selectedValue forKey:@"default_value"];
                                               [inputList replaceObjectAtIndex:index withObject:inputDict];
                                               [InputTable reloadData];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:sender];
    }
    else
    {
        SpeechTypeViewController *speechTypeView = [[SpeechTypeViewController alloc] initWithNibName:@"SpeechTypeViewController" bundle:nil];
        speechTypeView.selectedIndex = index;
        speechTypeView.inputList = self.inputList;
        speechTypeView.delegate = self;
        [self.navigationController pushViewController:speechTypeView animated:YES];
    }
}

#pragma mark Custom Events

- (IBAction)SubmitButton_Click:(id)sender
{
    if (self.audioFilePath)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:self.audioFilePath])
        {
            NSURL *url = [NSURL fileURLWithPath:self.audioFilePath];
            NSError *err = nil;
            NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
            
            if(!audioData)
            {
                NSLog(@"audio data: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Record audio before you proceed." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
                for (NSDictionary *dict in self.inputList) {
                    if ([[dict valueForKey:@"type"] isEqualToString:@"Integer"]) {
                        NSString *attributeValue = [dict valueForKey:@"default_value"];
                        NSArray *listItems = [attributeValue componentsSeparatedByString:@" "];
                        attributeValue = [listItems objectAtIndex:0];
                        
                        [metadata setObject:[NSNumber numberWithInt:[attributeValue intValue]] forKey:[NSString stringWithFormat:@"%@", [dict valueForKey:@"attribute"]]];
                    } else {
                        [metadata setObject:[NSString stringWithFormat:@"%@", [dict valueForKey:@"default_value"]] forKey:[NSString stringWithFormat:@"%@", [dict valueForKey:@"attribute"]]];
                    }
                }
                
                NSError *err = nil;
                NSData *postData = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:&err];
                NSString *requestString = @"http://etherfufu-staging.us-east-1.elasticbeanstalk.com/audiobank/v1/metadata";
                NSURL *url = [NSURL URLWithString:requestString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:postData];
                
                [self placeRequest:request withHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                {
                    if (!error)
                    {
                        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                        NSString *responseID = [responseData valueForKey:@"id"];
                        
                        NSString *requestString = [NSString stringWithFormat:@"http://etherfufu-staging.us-east-1.elasticbeanstalk.com/audiobank/v1/metadata/%@/sample", responseID];
                        NSURL *url = [NSURL URLWithString:requestString];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                        
                        //--------
                        
                        /*NSString *boundary = @"---------------------------14737809831466499882746641449";
                        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                        
                        NSMutableData *body = [NSMutableData data];
                        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\".caf\"\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[NSData dataWithData:audioData]];
                        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [request setHTTPBody:body];*/
                        
                        //--------
                        
                        [self placeRequest:request withHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                         {
                             if (error)
                             {
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Recorded audio is not uploaded successfully" preferredStyle:UIAlertControllerStyleAlert];
                                 UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 [alertController addAction:ok];
                                 [self presentViewController:alertController animated:YES completion:nil];
                             }
                             else
                             {
                                 NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                 NSLog(@"Response Data: %@", responseData);
                                 
                                 
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Recorded audio is uploaded successfully" preferredStyle:UIAlertControllerStyleAlert];
                                 UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 [alertController addAction:ok];
                                 [self presentViewController:alertController animated:YES completion:nil];
                                 
                                 // SHOW THE SEARCH RESULTS IN THE NEXT VIEW CONTROLLER
                             }
                         }];
                    }
                }];
            }
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Record audio before you proceed." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark Custom Methods

-(void)placeRequest:(NSMutableURLRequest *)request withHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))ourBlock {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:ourBlock] resume];
}

-(void)sendData:(NSString *)inputText audioFileName:(NSString*)audioFileName
{
    self.audioFilePath = audioFileName;
}

@end
