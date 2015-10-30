//
//  ViewController.m
//  电话归属地查询
//
//  Created by RenSihao on 15/10/30.
//  Copyright © 2015年 RenSihao. All rights reserved.
//

#import "ViewController.h"
#import "List.h"
#import "MBProgressHUD+MJ.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_height [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITextFieldDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) UINavigationBar *headerBar;
@property (nonatomic, strong) UITextField *inputTF;
@property (nonatomic, strong) UIButton *askBtn;
@property (nonatomic, strong) UILabel *idLab;
@property (nonatomic, strong) UILabel *numLab;
@property (nonatomic, strong) UILabel *codeLab;
@property (nonatomic, strong) UILabel *cityLab;
@property (nonatomic, strong) UILabel *cardtypeLab;

@property (nonatomic, copy) NSString *input; //实时记录当前输入
@property (nonatomic, strong) List *list; //当前电话号码的完整信息
@property (nonatomic, copy) NSString *content; //XML元素 内容哨兵
@property (nonatomic, assign) Boolean isFind; //是否查找到输入到电话号码
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    //设置状态栏为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //加载所有子控件
    [self addSubviews];
}

/**
 加载子控件
 */
- (void)addSubviews
{
    
    //添加navigationBar
    [self.navigationController.navigationBar removeFromSuperview];
    [self.view addSubview:self.headerBar];
    NSLog(@"%lf", self.headerBar.frame.origin.x);
    //添加输入框，查询按钮，显示信息标签
    [self.view addSubview:self.inputTF];
    [self.view addSubview:self.askBtn];
    [self.view addSubview:self.idLab];
    [self.view addSubview:self.numLab];
    [self.view addSubview:self.codeLab];
    [self.view addSubview:self.cityLab];
    [self.view addSubview:self.cardtypeLab];
    
    
    
}

#pragma mark - lazyload
- (UINavigationBar *)headerBar
{
    if(!_headerBar)
    {
        _headerBar = [[UINavigationBar alloc] init];
        _headerBar.frame = CGRectMake(0, 0, Screen_Width, 64);
        _headerBar.barTintColor = [UIColor blackColor];
        [_headerBar setBarStyle:UIBarStyleBlackTranslucent];
//        UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"归属地查询" style:UIBarButtonItemStyleDone target:nil action:nil];
//        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        _headerBar.items = @[flex, title];
    }
    return _headerBar;
}
- (UITextField *)inputTF
{
    if(!_inputTF)
    {
        _inputTF = [[UITextField alloc] init];
        _inputTF.frame = CGRectMake(20, 64+20, Screen_Width-40, 40);
        _inputTF.placeholder        = @"请输入电话号码不得少于前7位";
        _inputTF.keyboardType       = UIKeyboardTypeNumberPad;
        _inputTF.backgroundColor    = [UIColor whiteColor];
        _inputTF.textAlignment      = NSTextAlignmentCenter;
        _inputTF.clearButtonMode    = UITextFieldViewModeWhileEditing;
        _inputTF.autocorrectionType = NO;
        _inputTF.delegate = self;
    }
    return _inputTF;
}
- (UIButton *)askBtn
{
    if(!_askBtn)
    {
        _askBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _askBtn.bounds = CGRectMake(0, 0, self.inputTF.frame.size.width/5, self.inputTF.frame.size.height);
        _askBtn.center = CGPointMake(Screen_Width/2, CGRectGetMaxY(self.inputTF.frame)+10+_askBtn.bounds.size.height/2);
        _askBtn.enabled = NO;
        [_askBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
        [_askBtn setTitle:@"查询" forState:UIControlStateNormal];
        [_askBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_askBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_askBtn setBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1.0]];
        //添加点击事件
        [_askBtn addTarget:self action:@selector(askButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _askBtn;
}
- (UILabel *)idLab
{
    if(!_idLab)
    {
        _idLab = [[UILabel alloc] init];
        _idLab.frame = CGRectMake(40, CGRectGetMaxY(self.askBtn.frame)+50, self.inputTF.bounds.size.width-40, 30);
        [_idLab setBackgroundColor:[UIColor lightGrayColor]];
        [_idLab setFont:[UIFont systemFontOfSize:13.0f]];
        [_idLab setTextColor:[UIColor redColor]];
        [_idLab setTextAlignment:NSTextAlignmentLeft];
        [_idLab setText:@"ID:"];
    }
    return _idLab;
}
- (UILabel *)numLab
{
    if(!_numLab)
    {
        _numLab = [[UILabel alloc] init];
        _numLab.frame = CGRectMake(40, CGRectGetMaxY(_idLab.frame)+10, _idLab.bounds.size.width, _idLab.bounds.size.height);
        [_numLab setBackgroundColor:[UIColor lightGrayColor]];
        [_numLab setFont:[UIFont systemFontOfSize:13.0f]];
        [_numLab setTextColor:[UIColor redColor]];
        [_numLab setTextAlignment:NSTextAlignmentLeft];
        [_numLab setText:@"Num:"];
    }
    return _numLab;
}
- (UILabel *)codeLab
{
    if(!_codeLab)
    {
        _codeLab = [[UILabel alloc] init];
        _codeLab.frame = CGRectMake(40, CGRectGetMaxY(_numLab.frame)+10, _idLab.bounds.size.width, _idLab.bounds.size.height);
        [_codeLab setBackgroundColor:[UIColor lightGrayColor]];
        [_codeLab setFont:[UIFont systemFontOfSize:13.0f]];
        [_codeLab setTextColor:[UIColor redColor]];
        [_codeLab setTextAlignment:NSTextAlignmentLeft];
        [_codeLab setText:@"Code:"];
    }
    return _codeLab;
}
- (UILabel *)cityLab
{
    if(!_cityLab)
    {
        _cityLab = [[UILabel alloc] init];
        _cityLab.frame = CGRectMake(40, CGRectGetMaxY(_codeLab.frame)+10, _idLab.bounds.size.width, _idLab.bounds.size.height);
        [_cityLab setBackgroundColor:[UIColor lightGrayColor]];
        [_cityLab setFont:[UIFont systemFontOfSize:13.0f]];
        [_cityLab setTextColor:[UIColor redColor]];
        [_cityLab setTextAlignment:NSTextAlignmentLeft];
        [_cityLab setText:@"City:"];
    }
    return _cityLab;
}
- (UILabel *)cardtypeLab
{
    if(!_cardtypeLab)
    {
        _cardtypeLab = [[UILabel alloc] init];
        _cardtypeLab.frame = CGRectMake(40, CGRectGetMaxY(_cityLab.frame)+10, _idLab.bounds.size.width, _idLab.bounds.size.height);
        [_cardtypeLab setBackgroundColor:[UIColor lightGrayColor]];
        [_cardtypeLab setFont:[UIFont systemFontOfSize:13.0f]];
        [_cardtypeLab setTextColor:[UIColor redColor]];
        [_cardtypeLab setTextAlignment:NSTextAlignmentLeft];
        [_cardtypeLab setText:@"CardType:"];
    }
    return _cardtypeLab;
}
- (NSString *)input
{
    if(!_input)
    {
        _input = [NSString string];
    }
    return _input;
}

#pragma mark - UITextFieldDelegate
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if([self.inputTF.text length] == 7)
//    {
//        self.askBtn.enabled = YES;
//    }
//    else
//    {
//        NSLog(@"不足7位");
//    }
//}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(self.inputTF.text.length < 6)
    {
        self.askBtn.enabled = NO;
        return YES;
    }
    else if(self.inputTF.text.length >= 6 && self.inputTF.text.length <=10)
    {
        self.askBtn.enabled = YES;
        return YES;
    }
    else
    {
        self.askBtn.enabled = YES;
        return NO;
    }
 
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSLog(@"点击clear");
    self.askBtn.enabled = NO;
    self.isFind = NO;
    return YES;
}


#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"扫描到文档开头，准备解析");

    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:@"正在解析中..."];
    });
    
}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"扫描到文档结尾，解析完毕");
    if(self.isFind == YES)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        //置空
        self.isFind = NO;
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showError:@"解析该号码失败!"];
        });
        self.isFind = NO;
    }
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    //NSLog(@"扫描到元素%@开头", elementName);
    if([elementName isEqualToString:@"dataroot"])
    {
        NSLog(@"dataroot开始读取节点");
    }
    else if ([elementName isEqualToString:@"list"])
    {
        self.list = [[List alloc] init];
    }
    //除了上边这两个元素，其他的则是真正要获取到的，有用信息元素

}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName
{
    //NSLog(@"扫描到元素%@结尾", elementName);
    if([elementName isEqualToString:@"dataroot"])
    {
        NSLog(@"dataroot所有节点读取完毕");
    }
    else if([elementName isEqualToString:@"list"])
    {
        //NSLog(@" 一个list节点读取完毕");
        if([self.list.num isEqualToString: self.inputTF.text ])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.idLab.text       = [NSString stringWithFormat:@"ID:%@", self.list.idid];
                self.numLab.text      = [NSString stringWithFormat:@"Num:%@", self.list.num];
                self.codeLab.text     = [NSString stringWithFormat:@"Code:%@", self.list.code];
                self.cityLab.text     = [NSString stringWithFormat:@"City:%@", self.list.city];
                self.cardtypeLab.text = [NSString stringWithFormat:@"CardType:%@", self.list.cardtype];
                NSLog(@"查找到！");
                self.isFind = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //
                    [MBProgressHUD showSuccess:@"成功解析出该号码!"];
                });
            });
            
        }
    }
    else if([elementName isEqualToString:@"id"])
    {
        self.list.idid = self.content;
    }
    else if([elementName isEqualToString:@"num"])
    {
        self.list.num = self.content;
    }
    else if([elementName isEqualToString:@"code"])
    {
        self.list.code = self.content;
    }
    else if([elementName isEqualToString:@"city"])
    {
        self.list.city = self.content;
    }
    else if([elementName isEqualToString:@"cardtype"])
    {
        self.list.cardtype = self.content;
    }
    else
    {
        NSLog(@"扫描到元素结尾，发现异常");
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"扫描到元素内容");
    self.content = string;
}

#pragma mark - 监听事件
- (void)askButtonDidClick
{
    NSLog(@"点击了查询按钮");
    
//    //串行队列
//    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
//    
//    //并行队列
//    dispatch_queue_t concQueue = dispatch_queue_create("conc", DISPATCH_QUEUE_CONCURRENT);
    
    //[MBProgressHUD showMessage:@"正在解析文件..."];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //加载耗时操作
//        //读取文件，进行解析，耗时操作
//        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mobilelist" ofType:@"xml"]];
//        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
//        parser.delegate = self;
//        [parser parse];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //返回UI主线程
//            
//        });
//        
//    });
    
//    //获取主线程(自带特殊串行队列)
//    dispatch_queue_t main = dispatch_get_main_queue();
//    
//    //获取全局(并行队列)
//    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    
//    dispatch_async(main, ^{
//        //加载耗时操作
//        //读取文件，进行解析，耗时操作
//        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mobilelist" ofType:@"xml"]];
//        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
//        parser.delegate = self;
//        [parser parse];
//    });
    
    
    //在全局里(并行队列)
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        //加载耗时操作
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mobilelist" ofType:@"xml"]];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        parser.delegate = self;
        [parser parse];
        
        //回调，即通知主线程刷新
//        if(self.isFind == YES)
//        {
           dispatch_async(dispatch_get_main_queue(), ^{
        
                [MBProgressHUD hideHUD];
            });
//        }
        
        
    });
    
    
    

    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.inputTF resignFirstResponder];
}








@end
