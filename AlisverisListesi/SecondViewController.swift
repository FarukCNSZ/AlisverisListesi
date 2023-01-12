//
//  SecondViewController.swift
//  AlisverisListesi
//
//  Created by Faruk CANSIZ on 25.12.2022.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var addButtonn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var fiyatTextField: UITextField!
    @IBOutlet weak var bedenTextField: UITextField!
    
    var secilenUrunİsmi = ""
    var secilenUrunUUID : UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if secilenUrunİsmi != "" {
            
            addButtonn.isHidden = true //gizlenmiş
            
            if let uuidString = secilenUrunUUID?.uuidString {
                //klasik appDelegate kod blokları
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let context = appDelegate?.persistentContainer.viewContext
                
                //veri çekme(fetchReguest) öncesi hazırlık
                let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchReguest.predicate = NSCompoundPredicate(format: "id = %@", uuidString)
                fetchReguest.returnsObjectsAsFaults = false
            
                do {
                    let sonuclar = try context?.fetch(fetchReguest)

                    //sonuclar any geliyor ve NSManagedObject'e dönüştürmemiz gerekiyor
                    if sonuclar!.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            //yine any döndürdüğü için as ile String döndürüyoruz
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                isimTextField.text = isim
                            }
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                fiyatTextField.text = String(fiyat)
                            }
                            if let beden = sonuc.value(forKey: "beden") as? String {
                                bedenTextField.text = beden
                            }
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                        }
                    }
                    
                    
                } catch {
                    print("hata")
                }
                
                
                
            }
            
        } else {
            addButtonn.isEnabled = false //Tıklanamaz
            addButtonn.isHidden = false
            isimTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeGitti))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        //Görsele tıklanabilsin
        
        let imageGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        //görsel seçe tıklanınca ne olsun
        imageView.addGestureRecognizer(imageGestureRecognize)
        //gestureRecognizerı imageView'a ekledik
        
    }
    
    @objc func gorselSec () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        //görsel seçe tıklanınca aşağıdan yukarı animasyonlu bir şekilde photoLibrary gelsin
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        addButtonn.isEnabled = true
        self.dismiss(animated: true)
        //photoLibrary geldi fotoğrafı seçtik peki ya sonra? sonrasında bu seçtiğimiz fotoğrafı imageView'a atadık ve animasyonlu bir şekilde photoLibrary'i dismiss ettik
    }
    
    @objc func klavyeGitti() {
        view.endEditing(true)
        
    }
    
    @IBAction func kaydetButton(_ sender: Any) {
        
        //CoreData için adımlar:
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        
        alisveris.setValue(isimTextField.text, forKey: "isim")
        alisveris.setValue(bedenTextField.text, forKey: "beden")
        
        if let fiyat = Int(fiyatTextField.text!) {
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        
        alisveris.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        alisveris.setValue(data, forKey: "gorsel")
        
        
        //Kaydetme İşlemi
        do {
            try context.save()
            print("veriler kaydedildi")
        }   catch {
            print("hata")
        }
        
        //bir önce ki viewController'a data da değişiklik olduğunu bildiriyor
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        //popViewController ile bir önceki viewController'a götürüyor, secondviewcontrollerdan view controllera
        self.navigationController?.popViewController(animated: true)
    }
}
