聊天 Api

https://www.stage.daf-shoes.com:8081/api/chat/askToken
[POST]
索取授權用 需要登入才能用
輸入:無須輸入
回覆:
{
s:1表示成功 其餘失敗
m:簡易說明
access_token: s=1時返回 索取Listen時使用 有效期間約30分鐘
}

https://www.stage.daf-shoes.com:8081/api/chat/send
[POST]
給用戶發訊息用 需要登入才能用
輸入:
{
txt:用戶發出的訊息
}
回覆:
{
s:1表示成功 其餘失敗
m:簡易說明
}

https://www.stage.daf-shoes.com:9090/Listen
[POST]
監聽有沒有新訊息用(long pulling)需要先從askToken拿到授權 因為主機不同無法檢查登入
輸入
{
token: access_token直接拿來用就可,
Ts:基準時間戳記(初次可以輸入0,之後可以拿回覆收到的nextTs來填這格)
}
回覆
{
s:1表示有新訊息 0 表示無 其餘表示有錯誤
m:(不一定有這個變數 通常有錯誤時才給簡易說明用)
Data:[](裝新訊息用的陣列)
nextTs:到ms的時間戳記(拿到後可以記錄下 下次呼叫輸入改這個戳記時間 這樣就只會收到這個時間戳之後才有的新訊息)
}