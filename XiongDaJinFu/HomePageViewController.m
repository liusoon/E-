//
//  ViewController.m
//  XiongDaJinFu
//
//  Created by 码动 on 16/10/13.
//  Copyright © 2016年 digirun. All rights reserved.
//

#import "HomePageViewController.h"
#import "AAChartView.h"
#import "MHEmotionSwing.h"
#import "TMHomeTableViewCell1.h"
#import "MHEmotion.h"
@interface HomePageViewController ()<AAChartViewDidFinishLoadDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    MHEmotion  * emotion;
}

@property(nonatomic,strong)AAChartView *chartView;
@property(nonatomic,strong)AAChartModel *chartModel;
@property (nonatomic,strong)  UIScrollView  * scrollView;
@property (nonatomic,strong)  NSMutableArray  * dataArray;
@property (nonatomic,strong)  NSMutableArray  * emotionArr;
@property (nonatomic,strong)  UILabel  * titleLabel;



@end

@implementation HomePageViewController

-(UILabel*)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 15, 300, 18)];
        
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }

    return _titleLabel;
}

-(NSMutableArray*)emotionArr{
    if (!_emotionArr) {
        _emotionArr = [NSMutableArray new];
    }
    return _emotionArr;
    
}
- (NSMutableArray*)dataArray{
    
    if (!_dataArray) {
        _dataArray = [[NSMutableArray  alloc] init];
    }
    
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
    [self setUpUI];
    [self setUpNewNai:nil Title:@"情绪周期"];
}

-(void)setUpUI{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREENWIDTH,SCREENHEIGHT+60) style:UITableViewStylePlain];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#EBEBEB"];
    _tableView.showsVerticalScrollIndicator = NO;

    [self.view addSubview:_tableView];
}

#pragma mark -tableView
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 8;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 636/2;
        
    }
    else{
        
        return UITableViewAutomaticDimension;
    }
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    self.titleLabel.text = [NSString stringWithFormat:@"距离下一次波峰%@天",emotion.ufcNextHeigHighDate];
    if (indexPath.section ==0) {
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell.contentView  addSubview:self.titleLabel ];

        [cell.contentView  addSubview:self.scrollView ];
        return cell;

    }
    else{
        static  NSString  * idStr = @"TMHomeTableViewCell1";
        TMHomeTableViewCell1 * cell = [tableView dequeueReusableCellWithIdentifier:idStr ];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TMHomeTableViewCell1" owner:self options:nil] lastObject];
            
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.descriLabel.text = [NSString stringWithFormat:@"   %@",emotion.ufcCycMsg];
        cell.dateStrLabel.text = emotion.ufcDate;
        
        if ([emotion.ufcVal integerValue]<=44) {
            cell.typeLabel.text = @"低潮期";
            cell.iconImageView.image = [UIImage imageNamed:@"Image-low"];

        }else if([emotion.ufcVal integerValue]<=55&&[emotion.ufcVal integerValue]>=45){
            cell.typeLabel.text = @"临界期";
            cell.iconImageView.image = [UIImage imageNamed:@"Image-center"];

        }else if([emotion.ufcVal integerValue]>=56){
            cell.typeLabel.text = @"高潮期";
            cell.iconImageView.image = [UIImage imageNamed:@"Image-high"];
        }
        
        switch (emotion.ufcIsLow) {
            case 1:
                cell.descriLabel.text = @"心情愉快,舒畅乐观，精力充沛，意志坚强，办事有信心，创造力、艺术感染力强。思路灵活、敏捷，是解决矛盾，处理疑难问题的好时候。对待问题的态度积极且富建设性。能与人融洽相处。做事一般不易出错，效率也高。";
                break;
            case 2:
                cell.descriLabel.text = @"情绪低落，精神不振，意志比较消沉。做事缺乏勇气，信心不足，注意力易分散，常感到烦躁不安或心绪不宁，此时也容易出工作差错和事故。";
                break;
            case 3:
                cell.descriLabel.text = @"情绪不稳定，烦躁易怒，心绪不宁，精力特别不易集中。精神恍惚，工作易出差错。自制能力差，缺乏理智、容易冲动。一点小事都可能激怒人，人一旦被激怒常做出过火行为。有无事生非心态，做不好调解工作。一些矛盾激化事件也多在此时发生。";
                break;
            default:
                break;
        }
        
        return cell;
        
 
    }
}

- (void)configTheChartView:(NSString *)chartType {
    
    
    UIScrollView  *  myScrollView  = [[UIScrollView alloc] init];
    
    myScrollView.frame  = CGRectMake(0, 46, SCREENWIDTH, SCREENHEIGHT);
    myScrollView.contentSize  = CGSizeMake(SCREENWIDTH*2, 470/2);
    myScrollView.bounces = NO;
    myScrollView.delegate  = self;
    self.scrollView = myScrollView;
    NSMutableArray * valueArr = [[NSMutableArray alloc] init];
    NSMutableArray * dateArr = [[NSMutableArray alloc] init];

    for (int i =0;i <self.dataArray.count;i ++) {
        MHEmotionSwing * model = self.dataArray[i];
    
        [valueArr addObject:[NSNumber numberWithInteger:model.ufcVal]];
        NSString *str1 = [model.ufcDate substringFromIndex:5];//截取掉下标5之前的字符串

        [dateArr addObject:str1];
    }
    
    
    
    self.chartView = [[AAChartView alloc]init];
    self.chartView.delegate = self;
    self.chartView.scrollView.scrollEnabled = NO;
    self.chartView.frame = CGRectMake(0, 0, 2*SCREENWIDTH, 470/2);
    self.chartView.contentHeight =470/2;
    [myScrollView addSubview:self.chartView];
    self.chartModel= AAObject(AAChartModel)
    .chartTypeSet(chartType)
    //.titleSet(@"编程语言热度")
    .subtitleSet(@"")
    .pointHollowSet(true)
    
    .categoriesSet(dateArr)
    .yAxisTitleSet(@"")
    .seriesSet(@[
                 //                 AAObject(AASeriesElement)
                 //                 .nameSet(@"2017")
                 //                 .dataSet(@[@45,@88,@49,@43,@65,@56,@47,@28,@49,@44,@89,@55]),
                 //
                 //                 AAObject(AASeriesElement)
                 //                 .nameSet(@"2018")
                 //                 .dataSet(@[@31,@22,@33,@54,@35,@36,@27,@38,@39,@54,@41,@29]),
                 //
                 //                 AAObject(AASeriesElement)
                 //                 .nameSet(@"2019")
                 //                 .dataSet(@[@11,@12,@13,@14,@15,@16,@17,@18,@19,@33,@56,@39]),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"情绪值")
                 .dataSet(valueArr),
                 ]
               )
    //    //标示线的设置
//        .yPlotLinesSet(@[AAObject(AAPlotLinesElement)
//                         .colorSet(@"#F05353")//颜色值(16进制)
//                         .dashStyleSet(@"Dash")//样式：Dash,Dot,Solid等,默认Solid
//                         .widthSet(@(1)) //标示线粗细
//                         .valueSet(@(20)) //所在位置
//                         .zIndexSet(@(1)) //层叠,标示线在图表中显示的层叠级别，值越大，显示越向前
//                         .labelSet(@{@"text":@"标示线1",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})//这里其实也可以像AAPlotLinesElement这样定义个对象来赋值（偷点懒直接用了字典，最会终转为js代码，可参考https://www.hcharts.cn/docs/basic-plotLines来写字典）
//                         ,AAObject(AAPlotLinesElement)
//                         .colorSet(@"#33BDFD")
//                         .dashStyleSet(@"Dash")
//                         .widthSet(@(1))
//                         .valueSet(@(40))
//                         .labelSet(@{@"text":@"标示线2",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
//                         ,AAObject(AAPlotLinesElement)
//                         .colorSet(@"#ADFF2F")
//                         .dashStyleSet(@"Dash")
//                         .widthSet(@(1))
//                         .valueSet(@(60))
//                         .labelSet(@{@"text":@"标示线3",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
//                         ]
//                       )
        //Y轴最大值
        .yMaxSet(@(100))
        //Y轴最小值
        .yMinSet(@(1))
        //是否允许Y轴坐标值小数
        .yAllowDecimalsSet(YES)
        //指定y轴坐标
        .yTickPositionsSet(@[@(0),@(20),@(40),@(60),@(80),@(100)])
    ;
   //图表的背景颜色
   // self.chartModel.backgroundColor = @"#0b95f3";
    self.chartModel.legendEnabledSet(false);

    [self.chartView aa_drawChartWithChartModel:_chartModel];
}

#pragma mark -- AAChartView delegate
-(void)AAChartViewDidFinishLoad {
    NSLog(@"图表视图已完成加载");
}
-(void)getData{
    NSDate *datenow = [NSDate date];
    NSDictionary  * dict = @{@"uiId":[[XDCommonTool readDicFromUserDefaultWithKey:USER_INFO].firstObject objectForKey:@"id"],@"ufcDate":datenow,@"loginToken":[[XDCommonTool readDicFromUserDefaultWithKey:USER_INFO].firstObject objectForKey:@"loginToken"]};
    
    
    
    [[NetworkClient sharedClient] GET:URL_Emotion_Swing dict:dict succeed:^(id data) {
       //NSLog(@"%@",data);

        NSArray  * dataArr = (NSArray*)data;
       [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           MHEmotionSwing  * model = [MHEmotionSwing mj_objectWithKeyValues:(NSDictionary*)obj];
           [self.dataArray addObject:model];
       
       }];
    
        [self configTheChartView:AAChartTypeAreaspline];
        [_tableView reloadData];
    
    } failure:^(NSError *error) {
       NSLog(@"%@",error);
   }];
   [[NetworkClient sharedClient] GET:URL_Emotion_Satus dict:dict succeed:^(id data) {
      // NSLog(@"%@",data);
       NSArray  * dataArr = (NSArray*)data;

        emotion = [MHEmotion mj_objectWithKeyValues:(NSDictionary*)dataArr.firstObject];
      
       [_tableView reloadData];
   } failure:^(NSError *error) {
       NSLog(@"%@",error);

   }];
}
@end
