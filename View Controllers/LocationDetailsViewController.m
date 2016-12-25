//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Mingyuan Wang on 5/27/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerTableViewController.h"
#import "HudView.h"
#import "Location.h"
#import "NSMutableString+AddText.h"

@interface LocationDetailsViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *photoLabel;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *categoryName;
@property (nonatomic) NSString *descriptionText;
@property (nonatomic) UIImagePickerController *imagePicker;

@end

@implementation LocationDetailsViewController

#pragma mark - View Controller Life Cycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.descriptionText = @"";
        self.categoryName = @"No Category";
        self.date = [NSDate date];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.locationToEdit != nil) {
        self.title = @"Edit Location";
        if ([self.locationToEdit hasPhoto]) {
            UIImage *existingImage = [self.locationToEdit photoImage];
            if (existingImage != nil) {
                [self showImage:existingImage];
            }
        }
    }
    
    self.descriptionTextView.text = self.descriptionText;
    self.categoryLabel.text = self.categoryName;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
    
    if (self.placemark != nil) {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    } else {
        self.addressLabel.text = @"No Address Found";
    }
    self.dateLabel.text = [self formatDate: self.date];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.descriptionTextView.backgroundColor = [UIColor blackColor];
    
    self.photoLabel.textColor = [UIColor whiteColor];
    self.photoLabel.highlightedTextColor = self.photoLabel.textColor;
    
    self.addressLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    self.addressLabel.highlightedTextColor = self.addressLabel.textColor;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground
{
    if (self.imagePicker != nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        self.imagePicker = nil;
    }
    [self.descriptionTextView resignFirstResponder];
}


- (void)showImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.photoLabel.hidden = YES;
    
}

- (void)setLocationToEdit:(Location *)newLocationToEdit
{
    if (_locationToEdit != newLocationToEdit) {
        _locationToEdit = newLocationToEdit;
        
        self.descriptionText = _locationToEdit.locationDescription;
        self.categoryName = _locationToEdit.category;
        self.date = _locationToEdit.date;
        
        self.coordinate = CLLocationCoordinate2DMake([_locationToEdit.latitude doubleValue], [_locationToEdit.longitude doubleValue]);
        
        self.placemark = _locationToEdit.placemark;
    }
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath != nil && indexPath.section == 0 &&indexPath.row == 0) {
        return;
    }
    [self.descriptionTextView resignFirstResponder];
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark
{
    NSMutableString *line = [NSMutableString stringWithCapacity:100];
    [line addText:placemark.subThoroughfare withSeparator:@" "];
    [line addText:placemark.thoroughfare withSeparator:@" "];
    [line addText:placemark.locality withSeparator:@", "];
    [line addText:placemark.administrativeArea withSeparator:@", "];
    
    [line addText:placemark.postalCode withSeparator:@""];
    [line addText:placemark.country withSeparator:@", "];
    
    return line;
}

- (NSString *) formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return [formatter stringFromDate:theDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    
    Location *location = nil;
    if (self.locationToEdit != nil) {
        hudView.text = @"Updated";
        location = self.locationToEdit;
    }else{
    hudView.text = @"Tagged";
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        location.photoId = @ -1;
    }
    
    location.locationDescription = self.descriptionText;
    location.category = self.categoryName;
    location.latitude = @(self.coordinate.latitude);
    location.longitude = @(self.coordinate.longitude);
    location.date = self.date;
    location.placemark = self.placemark;
    
    if (self.image != nil) {
        //NSLog(@"yo yo yo");
        if (![location hasPhoto]) {
            location.photoId = @([Location nextPhotoId]);
        }
        
        //NSLog(@"okie...");
        NSData *data  = UIImageJPEGRepresentation(self.image, 0.5);
        NSError *error;
        if (![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error writing file: %@", error);
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"*** Fatal error in %s: %d\n%@\n%@", __FILE__, __LINE__, error, [error userInfo]);
        [[NSNotificationCenter defaultCenter]postNotificationName:ManagedObjectContextSaveDidFailNotification object:error];
    }
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
}

- (IBAction)cancel:(id)sender
{
    [self closeScreen];
}

- (void)closeScreen
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue
{
    CategoryPickerTableViewController *viewController = segue.sourceViewController;
    self.categoryName = viewController.selectedCategoryName;
    self.categoryLabel.text = self.categoryName;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCategory"]) {
        CategoryPickerTableViewController *controller = segue.destinationViewController;
        controller.selectedCategoryName = self.categoryName;
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
    } else if (indexPath.section == 1) {
        if (self.imageView.hidden) {
            return 44;
        } else {
            return 280;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 2){
        CGRect rect = CGRectMake(200, 11, 205, 10000);
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return self.addressLabel.frame.size.height + 20;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    cell.selectedBackgroundView = selectionView;
    
    if (indexPath.row == 2) {
        UILabel *addressLabel = (UILabel *)[cell viewWithTag:100];
        addressLabel.textColor = [UIColor whiteColor];
        addressLabel.highlightedTextColor = addressLabel.textColor;
    }
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    }else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showPhotoMenu];
    }
}


#pragma mark - Photo Handling

- (void)takePhoto
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.view.tintColor = self.view.tintColor;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    self.imagePicker= [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)showPhotoMenu
{
    if ([UIImagePickerController  isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Select image or take photo" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:^{ }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:^{ }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:^{ }];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self choosePhotoFromLibrary];
    }
}

#pragma  mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.descriptionText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView*)textView
{
    self.descriptionText = textView.text;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerOriginalImage];
    [self showImage:self.image];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}




@end
