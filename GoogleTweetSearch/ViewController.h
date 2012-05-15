//
//  ViewController.h
//  GoogleTweetSearch
//
//  Created by 真有 津坂 on 12/05/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//以下追加
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface ViewController : UIViewController {
    //NSMutableDataは変更可能な文字列(文字列を追加していきたい場合やデータの保持など)を使う
    //以下追加
    
    NSMutableArray *userNameArray;
    NSMutableArray *tweetTextArray;
    NSMutableArray *iconDataArray;
    
    
    ACAccount *account;
    ACAccountType *accountType;
    ACAccountStore *accountStore;
    
    //タイマー。3秒ごとにつぶやきを表示させるため
    NSTimer *myTimer;
    
    //ユーザ名・テキスト・アイコンの配列を取り出すための数
    int twindex;
    
    //入力された日本語のキーワードを使えるようにエンコードする文字列
    NSString *encodStr;

}

//検索したいキーワードを入力
@property (weak, nonatomic) IBOutlet UITextField *keywordInput;
//つぶやきを検索してヒットした数を表示
@property (weak, nonatomic) IBOutlet UILabel *hitcount;
//アイコンを表示
@property (weak, nonatomic) IBOutlet UIImageView *tweetIconImg;
//ユーザ名を表示
@property (weak, nonatomic) IBOutlet UILabel *twAccount;
//テキストを表示
@property (weak, nonatomic) IBOutlet UILabel *tweetText;

@property (nonatomic,retain) NSMutableArray *userNameArray;
@property (nonatomic,retain) NSMutableArray *tweetTextArray;
@property (nonatomic,retain) NSMutableArray *iconDataArray;

@property (nonatomic,retain) NSString *encodStr; 

//つぶやき表示を止める
- (IBAction)tweetviewStop:(id)sender;
//テキストを入力すると、検索などの処理を開始する
- (IBAction)searchStart:(id)sender;

//つぶやきを検索してヒット数を出す
- (void)hitcountview;
//Twitterのタイムラインを取得、整形する
- (void)loadTimeline;
//Twitterのタイムラインを表示
-(void)loadTimelineView;


@end
