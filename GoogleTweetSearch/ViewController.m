//
//  ViewController.m
//  GoogleTweetSearch
//
//  Created by 真有 津坂 on 12/05/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize keywordInput;
@synthesize hitcount;
@synthesize tweetIconImg;
@synthesize twAccount;
@synthesize tweetText;

//以下追加
@synthesize userNameArray;
@synthesize tweetTextArray;
@synthesize iconDataArray;
@synthesize encodStr;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //データを受け取る準備をする。userNameArrayy・tweetTextArray・iconDataArrayはユーザ名・実際のツイート・アイコン
    accountStore = [[ACAccountStore alloc] init];
    accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    userNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    tweetTextArray = [[NSMutableArray alloc] initWithCapacity:0];
    iconDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //最初はユーザ名・テキスト・アイコンの配列の1番目を取得する
    twindex = 1;

}

//つぶやき表示を止める
- (IBAction)tweetviewStop:(id)sender {
    [myTimer invalidate];
}

//テキストを入力すると、以下の処理を開始する
- (IBAction)searchStart:(id)sender {
    //つぶやきを検索してヒット数を出す
    [self hitcountview];
    //Twitterのタイムラインを取得、整形する
    [self loadTimeline];
    
    //タイマー設定。3秒ごとに- (void)loadTimelineView の内容を繰り返す
   myTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(loadTimelineView) userInfo:nil repeats:YES];

/*
//フェードアウトのタイマー設定
alpFOTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadTimelineViewFadeOut) userInfo:nil repeats:YES];
    //フェードインのタイマー設定
    alpFITimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadTimelineViewFadeIn) userInfo:nil repeats:YES];

*/
   
}

//つぶやきをGoogle検索にかけてヒット数を出す
- (void)hitcountview {
    //ここをTextFieldで入力した言葉ではなく指定したい場合はNSString *searchString = @"ほげほげ";にする
    //検索語を指定する。日本語を検索する場合は、UTF-8でURLエンコードした文字列を渡す
    //英語で入力しても大丈夫
    NSString *searchString = keywordInput.text;
    //UTF-8でURLエンコード
    encodStr = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    /*
     普通のGoogle検索
     NSString *urlString = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%@",encodStr];
     */
    
     //GoogleでTwitter検索
    NSString *urlString = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%@+site:http://twitter.com",encodStr];
    
    //URLWithStringでNSURLのインスタンスを生成
    NSURL *url = [NSURL URLWithString:urlString];
    //NSURLRequestとurlStringで設定したアドレスにアクセスする設定をする
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"error: %@", [error localizedDescription]);
                                   return;
                               }
                               
                               //jsonで解析する
                               NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                               //「responseData」キーを取り出す
                               NSArray *ajaxdata = [dictionary objectForKey:@"responseData"];
                               //文字列に変換
                               NSString *strchange = [ajaxdata description];
                               //改行で分割する
                               NSArray *strsep = [strchange componentsSeparatedByString:@"\n"];
                               //分割して出来た配列の3番目の要素を取り出す
                               NSString *hairetu3 = [strsep objectAtIndex:3];
                               //「estimatedResultCount =」を消す
                               NSString *str1 = [hairetu3 stringByReplacingOccurrencesOfString:@"estimatedResultCount =" withString:@""];
                               //最後の;を消す
                               NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@";" withString:@""];
                               //検索結果(ヒット数)をラベルに表示
                               hitcount.text = str2;
                               //検索結果(ヒット数)を数値に変換する
                               hit = [str2 integerValue];
                               NSLog(@"%d",hit);
                               
   }]; 
    
    
}

//追加、Twitterのタイムラインを取得・整形
- (void)loadTimeline{
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
            if (account == nil) {
                NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                account = [accountArray objectAtIndex:0];
            }
            if (account != nil) {
                
             //TwitterのSearchAPIを使用する
                NSString *twurlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@",encodStr];
                
                //URLWithStringでNSURLのインスタンスを生成
                NSURL *twurl = [NSURL URLWithString:twurlString];
                
                
                
                //NSURLRequestとurlStringで設定したアドレスにアクセスする設定をする
                NSURLRequest *twrequest = [NSURLRequest requestWithURL:twurl];
                //NSURLConnectionで実際にアクセスする
                [NSURLConnection sendAsynchronousRequest:twrequest queue:[NSOperationQueue mainQueue]completionHandler:^(NSURLResponse *twresponse, NSData *twdata, NSError *twerror) {
                    if (twerror) {
                        NSLog(@"error: %@", [twerror localizedDescription]);
                        return;
                    }
                    
                    //jsonで解析する
                    NSDictionary *twdictionary =[NSJSONSerialization JSONObjectWithData:twdata options:NSJSONReadingAllowFragments error:nil];
                    //resultsにTweetが配列の形で入っている
                    NSArray *tweets = [twdictionary objectForKey:@"results"];
                                     //Tweetをひとつずつ取り出して表示する準備をする
                    for (NSDictionary *tweet in tweets) {
                        [tweetTextArray addObject:[tweet objectForKey:@"text"]];
                        [userNameArray addObject:[tweet objectForKey:@"from_user_name"]];
                        [iconDataArray addObject:[tweet objectForKey:@"profile_image_url"]];
                        
                                              
                        
                       
                    }
                    
                   
                }];
            }
        }
    }];
    
    
}

//3秒ごとにつぶやきを表示(以下の{}内の動作を3秒ごとに繰り返す)
-(void)loadTimelineView {
    twindex = twindex + 1;
    
    //13件表示したら最初から繰り返して表示(ここでAPIにアクセスしてもいいんですが、負荷を考慮して)
    //もしヒット数と要素数が同じになったら最初から繰り返して表示する(ヒット数が少ないキーワードを考慮)
   if (twindex == 13) {
       
        twindex = 1;
    } else if (twindex == hit) {
        twindex = 1;
    }
    
    //配列userNameArray(ユーザ名)のtwindex番目(3秒ごとに増えていく。最初は1で次は2)の要素を取り出す
    NSString *twAstr = [userNameArray objectAtIndex:twindex];
    //配列tweetTextArray(テキスト)のtwindex番目(3秒ごとに増えていく。最初は1で次は2)の要素を取り出す
    NSString *twTstr = [tweetTextArray objectAtIndex:twindex];
    //配列iconDataArray(アイコン)のtwindex番目(3秒ごとに増えていく。最初は1で次は2)の要素を取り出す
    NSURL *iconurl = [NSURL URLWithString:[iconDataArray objectAtIndex:twindex]];
    //iconを表示
    NSData *iconData = [NSData dataWithContentsOfURL:iconurl];
    tweetIconImg.image = [UIImage imageWithData:iconData];
    
    //アカウント名を表示
    twAccount.text = twAstr;
    //テキスト表示
    tweetText.text = twTstr;
    
}

/*
//フェードアウト
- (void)loadTimelineViewFadeOut {
    //フェードアウト開始まで2秒待つ
    [NSThread sleepForTimeInterval:2];
    //フェードアウト準備
    CATransition *transition;
    transition = [CATransition animation];
    
    //フェードアウトを2秒かけて実行
    [transition setDuration:2];
    //フェードイン/アウト設定
    [transition setType:kCATransitionFade];
   //フェードアウトの場合はYES、フェードインの場合はNOに
    [tweetText setHidden:YES];
    [twAccount  setHidden:YES];
    [tweetIconImg  setHidden:YES];
    //フェードアウト実行
    [[tweetText layer] addAnimation:transition forKey:@"transitionAnimation"];
    [[twAccount layer] addAnimation:transition forKey:@"transitionAnimation"];
    [[tweetIconImg layer] addAnimation:transition forKey:@"transitionAnimation"];

    
}

//フェードイン
- (void)loadTimelineViewFadeIn {
//フェードイン準備
    CATransition *transition2;
    transition2 = [CATransition animation];
    //フェードイントを2秒かけて実行
    [transition2 setDuration:2];
    //フェードイン/アウト設定
    [transition2 setType:kCATransitionFade];
    //フェードアウトの場合はYES、フェードインの場合はNOに
    [tweetText setHidden:NO];
    [twAccount setHidden:NO];
    [tweetIconImg setHidden:NO];
    
    //フェードイン実行
    [[tweetText layer] addAnimation:transition2 forKey:@"transitionAnimation"];
    [[twAccount layer] addAnimation:transition2 forKey:@"transitionAnimation"];
    [[tweetIconImg layer] addAnimation:transition2 forKey:@"transitionAnimation"];
}

*/


- (void)viewDidUnload
{
    [self setKeywordInput:nil];
    [self setHitcount:nil];
    [self setTwAccount:nil];
    [self setTweetText:nil];
    [self setTweetIconImg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
