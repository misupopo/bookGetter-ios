//
//  FirstViewController.swift
//  bookGetter
//
//  Created by 土居豊明 on 2016/12/07.
//  Copyright © 2016年 土居豊明. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, URLSessionDownloadDelegate {
    
    var myCollectionView : UICollectionView!
    var getData : Array<Dictionary <String,AnyObject>> = []
    
    var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        HTTPGet(url: "http://160.16.201.215:9001/jsonData") {
            (data: String, error: String?) -> Void in
            
            if error != nil {
                print(error!)
            } else {
                let jsonData: Data = data.data(using: String.Encoding.utf8)!
                
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    self.getData = json as! Array<Dictionary <String,AnyObject>>

                    self.localDataSet(jsonData: json as! Array<Any>)
                    
                    // collectionViewRenderが引き金になってtable listを描画する
                    // collection系の操作はバックグランドで実行できないっぽい
                    DispatchQueue.main.async(){
                        self.collectionViewRender()
                    }
                } catch {
                    print(error) // パースに失敗したときにエラーを表示
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func HTTPsendRequest(request: NSMutableURLRequest,callback: @escaping (String, String?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request as URLRequest,completionHandler :
            {
                data, response, error in
                if error != nil {
                    callback("", (error!.localizedDescription) as String)
                } else {
                    callback(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String,nil)
                }
        })
        
        //Tasks are called with .resume()
        task.resume()
    }
    
    func HTTPGet(url: String, callback: @escaping (String, String?) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL) //To get the URL of the receiver , var URL: NSURL? is used
        HTTPsendRequest(request: request, callback: callback)
    }
    
    /* UITableViewDataSourceプロトコル */
    // セクションごとの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 5
        }
    }
    
    // 各行に表示するセルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セル番号でセルを取り出す
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // セルに表示するテキストを設定する
        cell.textLabel?.text = "セル" + (indexPath.row).description
        //cell.textLabel.text = "セル" + (indexPath.row).description //Xcode6.1.0のみ
        cell.detailTextLabel?.text = "サブタイトル"
        return cell
    }
    
    func collectionViewRender() {
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()
        
        // Cell一つ一つの大きさ.
        layout.itemSize = CGSize(width:100, height:100)
        
        // Cellのマージン.
        // top,left,bottom,rightの余白
        // layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // セクション毎のヘッダーサイズ.
        layout.headerReferenceSize = CGSize(width:0, height:0)
        
        layout.minimumInteritemSpacing = 0
        
        // 折り返した地点でのスペースサイズ
        layout.minimumLineSpacing = 20
        
        // CollectionViewを生成.
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        // Cellに使われるクラスを登録.
        myCollectionView.register(CustomUICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        self.view.addSubview(myCollectionView)
    }
    
    /*
     Cellの総数を返す
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.getData.count
    }
    
    /*
     Cellに値を設定する
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CustomUICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CustomUICollectionViewCell
        
        // indexの番号をここで記述できる
//        cell.textLabel?.text = indexPath.row.description
//        cell.textLabel?.text = "superTest"
        
        let headImage : UIImageView = imageFromUrl(urlString: self.getData[indexPath[1]]["url"] as! String)
        let getMark : UIImageView = imageFromUrl(urlString: "http://160.16.201.215:9001/test/getMark.png")
        
//        image2.alpha = 0.4

//        cell.contentView.insertSubview(getMark, belowSubview: image2)
//        cell.contentView.addSubview(getMark)
        
//        headImage.isUserInteractionEnabled = true
        
//        let tapTrigger: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FirstViewController.setTestSuper(sender:)))
        
//        headImage.addGestureRecognizer(tapTrigger)
        
        var button = UIButton(type: .system)
        button.addTarget(self, action: #selector(self.showDownloadBar(data:)), for: .touchUpInside)
//        button.setTitle("ダウンロード開始", for: .normal)
        button.titleLabel?.font = UIFont(name: "Arial", size: 24)
//        button.sizeToFit()
        
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        button.backgroundColor = UIColor.darkGray
        
//        button.alpha = 0.4
        
        let downloadBar = self.setDownloadButton(parentCell: cell, index: indexPath[1])
        
        // ダウンロード進捗バーを挿入
        button.addSubview(downloadBar)
        cell.contentView.addSubview(button)
        cell.contentView.addSubview(getMark)
        
        // getMarkの下に新しいSubviewが追加される
//        cell.contentView.insertSubview(headImage, belowSubview: getMark)
//        cell.contentView.insertSubview(getMark, belowSubview: button)
        return cell
    }
    
    func showDownloadBar(data: UIButton) {
        for subview in data.subviews {
            if(subview.isHidden) {
                subview.isHidden = false
            } else {
                subview.isHidden = true
            }
        }
    }
    
    func setDownloadButton(parentCell: CustomUICollectionViewCell?, index: Int?) -> UIProgressView {
        // ダウンロード開始ボタン
//        let button = UIButton(type: .system)
//        button.setTitle("ダウンロード開始", for: .normal)
//        button.titleLabel?.font = UIFont(name: "Arial", size: 24)
//        button.addTarget(self, action: #selector(self.startDownloadTask), for: .touchUpInside)
//        button.sizeToFit()
//        button.center = self.view.center
//        self.view.addSubview(button)
        
        // プログレスバーの設定
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.layer.position = CGPoint(x: 50, y: 50)
//        progressBar.transform = progressBar.transform.scaledBy(x: 50, y: 50)
        progressBar.transform = CGAffineTransform(scaleX: 0.5, y: 2)
//        progressBar.widthAnchor.constraint(equalTo: progressBar.widthAnchor, multiplier: 1).isActive = true

        return progressBar
    }
    
    // バックグラウンドで動作する非同期通信
    func startDownloadTask() {
        
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: "myapp-background")
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        let url = URL(string: "http://160.16.201.215:9001/test/testImg1.png")!
        
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
    
    // ディレクトリを作成
    func createDir(path: String) {
        do {
            let fileManager = Foundation.FileManager.default
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("createDir: \(error)")
        }
    }
    
    // 保存するディレクトリのパス
    func getSaveDirectory() -> String {
        
        let fileManager = Foundation.FileManager.default
        
        // ライブラリディレクトリのルートパスを取得して、それにフォルダ名を追加
        let path = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.libraryDirectory, Foundation.FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/DownloadFiles/"
        
        // ディレクトリがない場合は作る
        if !fileManager.fileExists(atPath: path) {
            createDir(path: path)
        }
        
        return path
    }
    
    // 現在時刻からユニークな文字列を得る
    func getIdFromDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return dateFormatter.string(from: Date())
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // ダウンロード完了時の処理
        
        print("didFinishDownloading")
        
        do {
            if let data = NSData(contentsOf: location) {
                
                let fileExtension = location.pathExtension
                let filePath = getSaveDirectory() + getIdFromDateTime() + "." + fileExtension
                
                print(filePath)
                
                try data.write(toFile: filePath, options: .atomic)
            }
        } catch let error as NSError {
            print("download error: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // ダウンロード進行中の処理
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        // ダウンロードの進捗をログに表示
        print(String(format: "%.2f", progress * 100) + "%")
        
        // メインスレッドでプログレスバーの更新処理
        DispatchQueue.main.async(execute: {
            self.progressBar.setProgress(progress, animated: true)
        })
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // ダウンロードエラー発生時の処理
        if error != nil {
            print("download error: \(error)")
        }
    }
    
    func imageFromUrl(urlString: String) -> UIImageView {
        let url = NSURL(string: urlString)
        _ = NSURLRequest(url: url! as URL)
        
        let imageData :NSData = NSData(contentsOf: url! as URL)!;
        let img = UIImage(data:imageData as Data);
        
        return UIImageView(image:img);
    }
    
    func localDataSet(jsonData: Array<Any>) {
        let defaults = UserDefaults.standard
        
//        let testData : [String : AnyObject] = (self.getData[1] as! NSDictionary) as! [String : AnyObject]
//        
//        print(testData["name"])
        
        for (index, _) in jsonData.enumerated()
        {
            let insertData : [String: AnyObject] = (jsonData[index] as! NSDictionary) as! [String : AnyObject]

            defaults.set(insertData, forKey: (insertData["name"] as AnyObject) as! String)
        }

        self.localDataRead()
    }
    
    func localDataRead() {
        let defaults = UserDefaults.standard

        // データを呼び出し
        let bookData = defaults.dictionary(forKey: "test2")
        
//        for (key, value) in bookData! {
//            print("key:\(key) value:\(value)")
//        }
    }
    
}

