//
//  FirstViewController.swift
//  bookGetter
//
//  Created by 土居豊明 on 2016/12/07.
//  Copyright © 2016年 土居豊明. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var myCollectionView : UICollectionView!
    var getData : Array<Dictionary <String,AnyObject>> = []
    
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
        cell.contentView.addSubview(getMark)
        // getMarkの下に新しいSubviewが追加される
        cell.contentView.insertSubview(headImage, belowSubview: getMark)
        return cell
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

        let user = defaults.dictionary(forKey: "test2")
        
//        for (key, value) in user! {
//            print("key:\(key) value:\(value)")
//        }
    }
    
}

