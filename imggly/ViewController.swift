import UIKit
import MobileCoreServices
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //IB = Interface Builder; UIKit framework'ü içerisinde bulunan nesnelerin arayüzde kullanımını sağlamaya dair kullanım amacı taşır.
    //weak, referans türüdür; weak referans ile tanımlı değerler, bellek israfını önler.
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var clickCounterLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var showSolutionButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var difficultyControl: UISegmentedControl!
    @IBOutlet weak var muteToggle: UISwitch!
     
    //CG = Core Graphics
    //CGFloat, ekranda görüntülenebilir nesnenin büyüklüğü ve konumunu temsil etmek amacıyla kullanılır.
    var gameViewWidth : CGFloat!
    var blockWidth : CGFloat!
    var visibleBlocks : Int!
    var rowSize : Int!
    var xCenter : CGFloat!
    var yCenter : CGFloat!
    var finalBlock : MyBlock!
    //NSMutableArray, Foundation framework'ü içerisindedir; farklı tür nesneler alabilen bir dizidir ve burada boş dizi olarak tanımlanmıştır.
    var blockArray: NSMutableArray = []
    var centersArray: NSMutableArray = []
    
    //UIImage veri tipli bir dizi tanımı yapılıyor; resim dizileri için kullanılır ve UIKit framework'ü içinde tanımlıdır.
    var images: [UIImage] = []
    var gameImage : UIImage!
    var empty: CGPoint!
    var clickCount : Int = 0
    var gameOver : Bool = false
    var audioPlayer = AVAudioPlayer()

    
    //arayüz yüklendiğinde çalışacak ilk kod bloğu
    override func viewDidLoad() {
        super.viewDidLoad()
        gameImage = #imageLiteral(resourceName: "nature")
        rowSize = 3
        difficultyControl.selectedSegmentIndex =  0
        scaleToScreen()
        makeBlocks()
        playBackgroundMusic()
        muteToggle.addTarget(self, action: #selector(toggleMusic), for: UIControlEvents.valueChanged)
        self.ResetButton(Any.self)
    }
    
    func scaleToScreen() {
        //kare ayarı
        gameView.frame.size.height = gameView.frame.size.width
        timerLabel.frame.size.width = gameView.frame.size.width
        uploadImageButton.frame.size.width = (gameView.frame.size.width / 2) - 5
        showSolutionButton.frame.size.width = (gameView.frame.size.width / 2) - 10
        resetButton.frame.size.width = gameView.frame.size.width
    }
    
    func makeBlocks() {
        blockArray = []
        centersArray = []
        visibleBlocks = (rowSize * rowSize) - 1
        
        gameViewWidth = gameView.frame.size.width
        blockWidth = gameViewWidth / CGFloat(rowSize) //case'e bağlı bölme işlemi
        
        //blokların ekrana tam olarak oturması sağlanıyor
        xCenter = blockWidth / 2
        yCenter = blockWidth / 2
        
        images = slice(image: gameImage, into:rowSize)
        var picNum = 0
        
        for _ in 0..<rowSize {
            for _ in 0..<rowSize {
                //4 parametreli CGRect fonksiyonu sayesinde blockFrame'e blockların tanımı atanıyor.
                let blockFrame : CGRect = CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth)
                let block: MyBlock = MyBlock (frame: blockFrame)
                //CGPoint özelliklere sahip thisCenter sabiti tanımlanıyor
                let thisCenter : CGPoint = CGPoint(x: xCenter, y: yCenter)
                
                //true yaptığımız için kullanıcıya bloklar üzerinde hareket imkanı sağlıyoruz
                block.isUserInteractionEnabled = true
                block.image = images[picNum]
                picNum += 1
                //for döngüsü içinde tek tek gezerek her bir bloğa thisCenter'da tanımlı point değerleri atanıyor
                block.center = thisCenter
                //thisCenter'daki değer, block nesnesinin merkezine alınıyor
                block.originalCenter = thisCenter
                //gameView nesnesine block sabiti ekleniyor ve bu sayede view'de görünüm sağlanıyor
                gameView.addSubview(block)
                //blockArray dizisine block nesnesi ekleniyor
                blockArray.add(block)
                
                xCenter = xCenter + blockWidth
                centersArray.add(thisCenter)
            }
            xCenter = blockWidth / 2
            yCenter = yCenter + blockWidth
        }
        //son resim bloğunun silinmesi işlemi
        //as! = nesne türünde dönüşüm için kullanılır; finalBlock MyBlock türünde olduğu için blockArray'in de aynı türe dönüşümünü sağlamamız gerekiyor.
        finalBlock = blockArray[visibleBlocks] as! MyBlock
        finalBlock.removeFromSuperview()
        blockArray.removeObject(identicalTo: finalBlock)
    }
    
    func slice(image: UIImage, into howMany: Int) -> [UIImage] {
        //image'in genişliği ve yüksekliği alınmaktadır.
        let width: CGFloat = image.size.width
        let height: CGFloat = image.size.height
        
        //tileWidth ve tileHeight adlı değişkenlere, resmin genişliği ve yüksekliği howMany adlı değişkene bölünmektedir.
        let tileWidth = Int(width / CGFloat(howMany)) //rowSize
        let tileHeight = Int(height / CGFloat(howMany)) //rowSize
        
        //imageSections isimli bir dizi oluşturulmaktadır; bu dizi, bölünmüş parçaları saklama amacı taşır
        let scale = Int(image.scale)
        var imageSections = [UIImage]()
        
        //cgImage isimli değişkene, image adlı resmin cgImage özelliği atanmaktadır.
        let cgImage = image.cgImage!
        var adjustedHeight = tileHeight //etkileşime girilen son parçanın yükseklik konumu
        //sütun bölme
        var y = 0
        for row in 0 ..< howMany {
            if row == (howMany - 1) {
                adjustedHeight = Int(height) - y
            }
            var adjustedWidth = tileWidth  //etkileşime girilen son parçanın genişlik konumu
            //satır bölme
            var x = 0
            for column in 0 ..< howMany {
                if column == (howMany - 1) {
                    adjustedWidth = Int(width) - x
                }
                let origin = CGPoint(x: x * scale, y: y * scale) //etkileşime girilen son parçanın koordinatlarını saklamak için kullanılıyor
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale) //etk. gir. son pr. büyüklüğünü saklamak için k.
                //tileCgImage değişkeni, o anki parçayı tutar. Bu değer, cgImage nesnesinin cropping(to:) metodu kullanılarak elde edilir ve origin ve size değerlerini kullanarak belirlenir.
                let tileCgImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                //O anki parça, imageSections dizisine eklenir. bu işlem, UIImage nesnesi oluşturularak yapılır ve tileCgImage, scale ve orientation değerlerini kullanarak gerçekleştirilir
                imageSections.append(UIImage(cgImage: tileCgImage, scale: image.scale, orientation: image.imageOrientation))
                x += tileWidth
            }
            y += tileHeight
            //x ve y değerleri, o anki sütun ve satırın genişliği ve yüksekliğine göre güncellenir. Bu sayede, bir sonraki parça için doğru koordinat değerleri elde edilir
        }
        //bölünmüş resim parçalarını içerir ve döngüler bittikten sonra return edilir -- gameOver true olana kadar da çalışır
        return imageSections
    }
    //arayüz öğesiyle ilgilendiğimiz için @IB kullanmamız gerekiyor, Interface Builder
    @IBAction func ResetButton(_ sender: Any) {
        clickCount = 0
        clickCounterLabel.text = String.init(format: "%d", clickCount)
        //UIKit - UIView
        finalBlock.removeFromSuperview() //oyun sonunda gösterilen son bloktur ve sınıf tipinde bir fonksiyon olduğu için bu şekilde kaldırılıyor
        gameOver = false
        setUserInteractionStateForAllBlocks(state: true)
        scramble()
    }
    //tıklama anında çalışır; bir butona ya da başka yapıya bağlı değil, çünkü gameOver = true olduğunda tetikleneceği şekilde bir yapı kuruldu
    @IBAction func showEndAlert(_ sender: Any) {
        //alert değişkeni, bir UIAlertController nesnesi oluşturur. bu nesne, bir uyarı kutusu oluşturur ve özelliklerini ayarlar.
        let alert = UIAlertController(title: "Tebrikler!", message: "\(clickCount) adımda bulmacayı çözdün!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    //tüm blokları rastgele bir şekilde yeniden düzenler.
    
    func scramble() {
        //centersArray nesnesinin bir kopyası oluşturulur, bu da tempCArray sabitine atanır; bu atama NSMutableArray tipine dönüştürülerek yapılır.
        let temporaryCentersArray: NSMutableArray = centersArray.mutableCopy() as! NSMutableArray
        //blockArray'in tamamında gezilmesi üzerine anyBlock isminde count+1 yapılacak şekilde bir for döngüsü
        for anyBlock in blockArray {
            //randomIndex değişkeni, temporaryCentersArray dizisinden rastgele bir elemanı seçer; seçimin rastgele olması, random sayı fonksiyonuyla mevcut dizinin eleman sayısının modunun alınması ile gerçeklenir
            let randomIndex: Int = Int(arc4random()) % temporaryCentersArray.count
            //randomCenter değişkenine, temporaryCentersArray dizisinden seçilen rastgele bir eleman atanır. atama işlemi CGPoint tipinde olduğu için noktasal ilerler, dizi içindeki randomIndex bölümüne noktasal atama yapılır.
            let randomCenter: CGPoint = temporaryCentersArray[randomIndex] as! CGPoint
            
            //(anyBlock as! MyBlock) nesnesinin center özelliğine, randomCenter değişkeni atanır; bu sayede anyBlock değişkenini temsil eden blok, randomCenter değişkenini temsil eden pozisyona taşınır ve ilgili blok rastgele bir pozisyona yerleştirilmiş olur.
            (anyBlock as! MyBlock).center = randomCenter
            //atama işlemi sonrasında, geçici olarak tanımlanan dizideki işlem yapılan blok silinir.
            temporaryCentersArray.removeObject(at: randomIndex)
        }
        empty = temporaryCentersArray[0] as? CGPoint
    }
    
    func clearBlocks(){
        for i in 0..<visibleBlocks {
            (blockArray[i] as! MyBlock).removeFromSuperview()
        }
        finalBlock.removeFromSuperview()
        blockArray = []
    }
    //ekrana dokunulduğunda çağrılır ve kullanıcının dokunduğu nesneyi alıp bu nesne üzerinde işlem yapar.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touches seti sayesinde kullanıcının yaptığı ilk tıklama, myTouch sabitine atılır
        let myTouch : UITouch = touches.first!
        //blockArray dizisinin içeriğinde myTouch.view nesnesinin olup olmadığını kontrol edilir; eğer myTouch.view nesnesi, blockArray dizisinde varsa bu bloğun içeriği çalıştırılır
        if (blockArray.contains(myTouch.view as Any)){
            
            let touchView: MyBlock = (myTouch.view)! as! MyBlock
            
            //xOffset ve yOffset değişkenleri, touchView nesnesinin boş alandan (empty) uzaklıklarını temsil eder. bu değişkenler, touchView nesnesinin x ve y koordinatlarını, empty noktasının x ve y koordinatlarına göre hesaplanır
            let xOffset: CGFloat = touchView.center.x - empty.x
            let yOffset: CGFloat = touchView.center.y - empty.y
            
            //distanceBetweenCenters değişkeni, touchView nesnesinin boş alana (empty) olan uzaklığını temsil eder. bu değişken, xOffset ve yOffset değişkenleri kullanılarak hesaplanır
            //sqrt((x2-x1)^2 + (y2-y1)^2; formül buradan geliyor ama ikinci bir x ve y noktası olmadığı için tek x ve y üzerinde işlem yapmamız yeterli
            let distanceBetweenCenters : CGFloat = sqrt(pow(xOffset, 2) + pow(yOffset, 2))
            
            //if bloğu, distanceBetweenCenters değişkeninin değerini kontrol eder; eğer bu değer blokların genişliği ile eşitse, bu if bloğunun içeriği çalıştırılır
            if (Int(distanceBetweenCenters) == Int(blockWidth)) {
                //temporaryCenter değişkeni, touchView nesnesinin merkez noktasını temsil eder. bu değişken, daha sonra bu noktanın boş alan (empty) noktasına atanacağı için bir geçici değişken olarak kullanılır.
                
                let temporaryCenter : CGPoint = touchView.center
                
                //UIView.beginAnimations() ve UIView.setAnimationDuration() fonksiyonları, bir animasyon başlatmak için kullanılır.
                //tıklama sonrasındaki hareket animasyonu bu fonksiyonlarla gerçeklenir; 0.2 değeri saniye cinsindedir ve bu değerin artışını gameView'da görebiliriz
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(0.2)
                
                //touchView.center değerini empty noktasına atar. Bu sayede, touchView nesnesi boş alana (empty) taşınmış olur ve bu nesne ekrandaki görüntüsü değişir.
                touchView.center = empty
                
                //UIView.commitAnimations() fonksiyonu, başlatılan animasyonu tamamlar ve geçiş animasyonu gerçekleşir.
                UIView.commitAnimations()
                
                //clickAction() fonksiyonu çağrılır. Bu fonksiyon, tıklamaları sayar ve bu sayaç ekranda görüntülenir.
                self.clickAction()
                
                //temporaryCenter değişkeni, empty değişkenine atanır. bu sayede, empty değişkeni eski değerini kaybeder ve yeni değeri temporaryCenter değişkenidir.
                empty = temporaryCenter
                
                //bu fonksiyon, blokların düzenlenip düzenlenmediğini kontrol eder ve eğer bloklar düzenlenmişse bu fonksiyon gameOver değişkenini true yapar.
                //resim, olması gerektiği gibi mi kontrolü
                checkBlocks()
                
                //if bloğu, gameOver değişkenini kontrol eder. eğer bu değişken true ise bu bloğun içeriği çalıştırılır.
                if gameOver == true {
                    //bu fonksiyon, tüm bloklar için kullanıcı etkileşimini devre dışı bırakır ve bu sayede kullanıcı bu bloklara dokunamaz.
                    setUserInteractionStateForAllBlocks(state: false)
                    
                    //Bu fonksiyon, oyunun sonunda görüntülenecek olan son blok nesnesini ekrana getirir.
                    displayFinalBlock()
                    
                    //bu fonksiyon, oyunun sonunda görüntülenecek olan uyarı mesajını ekrana getirir. uyarı mesajı, oyunun bittiğini ve tıklama sayısını gösterir.
                    displayGameOverAlert()
                }
            }
        }
    }
    
    @objc func clickAction() {
        //bu değişken, oyuncunun oyun süresince yaptığı hareket sayısını tutan bir sayaç değişkenidir. her bir tıklamada bu değişkenin değeri 1 arttırılır.
        clickCount += 1
        //sayacı ekrana basan bir obj-c kodu; format bu yüzden %d tanımlamasıyla gidiyor, çünkü clickCount Int tipinde
        clickCounterLabel.text = String.init(format: "%d", clickCount)
    }
    //bu fonksiyon, oyun süresince oyun alanındaki blokların yerlerini kontrol eder
    func checkBlocks() {
        //bu değişken, oyun alanındaki blokların doğru yerlerine yerleştirilip yerleştirilmediğini kontrol etmek üzere tanımlanan bir sayaç değişkendir.
        var correctBlockCounter = 0
        
        //oyun alanındaki blokların her birini tek tek gezerek, blokların orijinal yerlerine yerleştirilip yerleştirilmediğini kontrol edecek olan for döngüsü.
        //eğer bir blok, orijinal yerine yerleştirilmişse, correctBlockCounter değişkeninin değeri bir arttırılır.
        for i in 0..<visibleBlocks {
            //blockArray dizisinin içindeki tüm bloklar kontrol edilir. her bir blok için, bloğun mevcut koordinatı (center) ve orijinal koordinatı (originalCenter) karşılaştırılır. Eğer iki koordinat birbirine eşitse, sayaç değişkeni 1 artırılır.
            if (blockArray[i] as! MyBlock).center == (blockArray[i] as! MyBlock).originalCenter {
                correctBlockCounter += 1
            }
        }
        //correctBlockCounter isimli sayaç değişkeninin amacı, oyun bittiğinde blokların doğru yerleştirilip yerleştirilmediğini kontrol etmek için kullanılmaktır. eğer tüm bloklar doğru yerleştirilmişse, correctBlockCounter değişkeninin değeri visibleBlocks değişkeninin değerine eşit olacaktır. bu durum da oyunun bittiği anlamına gelecek ve gameOver değişkeninin değeri true olarak değiştirilecektir ve uyarı mesajı gösterilecek.
        
        if correctBlockCounter == visibleBlocks {
            gameOver = true
        } else {
            gameOver = false
        }
    }
    //false olarak ayarlandıgında kullanıcı tıklamalarını yok sayar.
    //state isimli bir parametre alır ve bu parametre, blokların kullanıcı tarafından etkilenebilirliğini (isUserInteractionEnabled) üzerine işlem yapar. fonksiyon içinde, visibleBlocks adlı bir döngü tanımlanmış ve bu döngü içinde, blockArray dizisinin içindeki blokların isUserInteractionEnabled değerleri state parametresine göre değiştirilir.
    func setUserInteractionStateForAllBlocks(state: Bool) {
        for i in 0..<visibleBlocks {
            (blockArray[i] as! MyBlock).isUserInteractionEnabled = state
        }
    }
    //oyun bittiğinde çağrılır ve finalBlock nesnesini gösterir. finalBlock nesnesi de son bloğu temsil ediyordu; bu sayede kullanıcı, oyunu tamamladığını anlar.
    func displayFinalBlock() {
        gameView.addSubview(finalBlock)
    }
    //oyun bittiğinde bir uyarı mesajı gösterir.
    // self.showEndAlert(Any.self) işlemi, showEndAlert adlı bir fonksiyonu çağırır.
    func displayGameOverAlert() {
        self.showEndAlert(Any.self)
    }
    //Çözümü Göster butonuna tıklandığında aktifleşir.
    @IBAction func showSolutionTapped(_ sender: Any) {
        showSolutionButton.isUserInteractionEnabled = false
               difficultyControl.isUserInteractionEnabled = false
               resetButton.isUserInteractionEnabled = false
               
               if (gameOver == false) {
                   let tempCentersArray : NSMutableArray = []
                   (self.finalBlock).center = self.empty
               
                   for i in 0..<visibleBlocks {
                       tempCentersArray.add((blockArray[i] as! MyBlock).center)
                   }
               
                   UIView.animate(withDuration: 1, animations: {
                       for i in 0..<self.visibleBlocks {
                           (self.self.blockArray[i] as! MyBlock).center = (self.blockArray[i] as! MyBlock).originalCenter
                       }
                       self.gameView.addSubview(self.finalBlock)
                       (self.finalBlock).center = (self.finalBlock).originalCenter
                   }) { _ in
                       UIView.animate(withDuration: 2, delay: 1, animations: {
                           for i in 0..<self.visibleBlocks {
                               (self.blockArray[i] as! MyBlock).center = (tempCentersArray[i] as! CGPoint)
                           }
                           (self.finalBlock).center = self.empty
                       }) { _ in
                           UIView.animate(withDuration: 2, animations: {
                               self.finalBlock.removeFromSuperview()
                               (self.finalBlock).center = (self.finalBlock).originalCenter
                           }) { _ in
                               self.difficultyControl.isUserInteractionEnabled = true
                               self.resetButton.isUserInteractionEnabled = true
                               self.showSolutionButton.isUserInteractionEnabled = true
                           }
                       }
                   }
               }
      
        }
    
    @objc func toggleMusic(switchState: UISwitch) {
            if switchState.isOn {
                audioPlayer.play()
            } else {
                audioPlayer.stop()
            }
        }
    
        func setBoard(board: inout [[Int]], row: Int, col: Int, state: Int) -> Bool {
            board[row][col] = state
            return true
        }
        
        //UISegmentedControl nesnesinin değerini kontrol ediyor ve bu değere göre rowSize değişkenini ayarlıyor.
        //değişiklikte baz alınan değer, segmented control'ün index değeri olduğu için bu kontrol selectedSegmentIndex methodu ile gerçekleniyor; örneğin kullanıcı 'orta' segmentini seçtiyse bu segmentin index'i olan 1 işleme alınıyor; 1'e bağlı case'in içeriği olarak da 4x4'lük bir parçalama oluyor.
        //sonrasında visibleBlocks ve makeBlocks() çağrılarak ekrandaki blokların sayısı ve blokların oluşturulması sağlanıyor.
        @IBAction func difficultyTapped(_ sender: Any) {
            clearBlocks()
            switch difficultyControl.selectedSegmentIndex
            {
            case 0:
                rowSize = 3
            case 1:
                rowSize = 4
            case 2:
                rowSize = 5
            default:
                rowSize = 3
            }
            //visibleBlocks, ekrandan kaldırılacak olan bloğu temsil ediyor.
            visibleBlocks = (rowSize * rowSize) - 1
            makeBlocks()
            //segmentin değiştiği her durumda bloklar resetlenir, bu da aşağıdaki fonksiyonla gerçeklenir.
            self.ResetButton(Any.self)
        }
        
        @IBAction func uploadImageTapped(_ sender: Any) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                //imagePicker nesnesinin delegate'si self (yani bu sınıf) olacak
                //delegate: tıklama durumundaki olaylara delegate ismi veriliyor, bunu da bildirim şeklinde yapıyor
                imagePicker.delegate = self
                //imagePicker için kaynak olarak fotoğraf kütüphanesini kullanma tanımlaması
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                //imagePicker için dosya türü olarak sadece resim dosyalarını kabul edecek
                imagePicker.mediaTypes = [kUTTypeImage as String]
                // Kullanıcının seçtiği resimleri düzenleme yetkisi olmayacak
                imagePicker.allowsEditing = false
                //photoLibrary'den aldıgın imagePicker nesnesine tanımlı image'i ekranda göster
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    
    func playBackgroundMusic() {
            let aSound = NSDataAsset(name: "background_music")
            do {
                audioPlayer = try AVAudioPlayer(data:(aSound?.data)!, fileTypeHint: "mp3")
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print("Dosya Bulunamadı")
            }
        }
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            //info ismini verdiğim Dictionary yapısı kullanılarak, seçilen resmin türü mediaType değişkenine atılır ve bu değeri NSString nesnesine dönüştürür.
            //NSString, unicode yapılı statik bir String değişken türüdür, Foundation kütüphanesine bağlıdır.
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            //Bu satırda, mediaType değişkeninin değerini kUTTypeImage sabitine karşılaştırıyoruz. eğer eşitse, bu koşul doğru olur ve içindeki işlemler çalıştırılır. kUTTypeImage, hareketsiz bir resim türünü temsil eder.
            if mediaType.isEqual(to: kUTTypeImage as String) {
                //Dictionary olarak tanımlanan info kullanılarak, seçilen resim gameImage'e atılır ve bu değer, UIImage nesnesine dönüştürülür.
                gameImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                //yeni resim alındığında mevcut blokları temizle.
                clearBlocks()
                //bloklara ayır ve parçalama işlemi sonrası random karıştırma yap
                makeBlocks()
                //sayacı sıfırla
                self.ResetButton(Any.self)
            }
            self.dismiss(animated: true, completion: nil)
        }
        //resim seçme denetleyicisini kaldır
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.dismiss(animated: true, completion: nil)
        }
        //eğer resim yükleme işleminde bir hata varsa, kullanıcıya bir "Hata" başlıklı alert gösterilir ve alert'te "Tamam" butonu bulunur. kullanıcı "Tamam" butonuna tıkladığında alert kapatılır.
        @objc func imageError (image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
            if error != nil {
                let alert = UIAlertController(title: "Hata", message: "Dosya Kaydedilemedi", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //UIImageView sınıfından türeyen MyBlock isimli originalCenter değişkeniyle CGPoint özelliğe sahip sınıf
    //CGPoint, bir noktanın x ve y koordinatlarını tutan bir veri türüdür; bu sayede bir nesnenin orijinal merkez noktası tutulur.
    class MyBlock : UIImageView {
        var originalCenter: CGPoint!
    }
