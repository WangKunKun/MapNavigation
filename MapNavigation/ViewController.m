//
//  ViewController.m
//  MapNavigation
//
//  Created by apple on 16/2/14.
//  Copyright © 2016年 王琨. All rights reserved.
//

#import "ViewController.h"
#import "MapNavigationManager.h"

@interface ViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *start;
@property (strong, nonatomic) IBOutlet UITextField *end;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;




@property (assign, nonatomic) CGFloat offsetY;

@property (strong, nonatomic) UITextField * presentTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startNavigation:(UIButton *)sender {
    
    if (_cityLabel.text.length == 0 || _start.text.length == 0 || _end.text.length == 0) {
         UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"重要提示" message:@"起点和终点不能为空" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
        
    }
    
    [MapNavigationManager showSheetWithCity:_cityLabel.text start:_start.text end:_end.text];
}

@end
