//
//  ViewController.swift
//  AlisverisListesi
//
//  Created by Faruk CANSIZ on 25.12.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var secilenİsim = ""
    var secilenUUID : UUID?
    
    //verileri al fonksiyonu altında kullanılacak
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
      
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        verileriAl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //viewWillAppera ile yeni kaydedilen verileri uygulamayı kapatıp tekrar açmadan kaydettikten hemen sonra görebiliriz.
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }

    @objc func verileriAl() {
        
        //tableView'da ki tüm verileri silip yenileriyle birlikte tekrar yazdıran kodlar
        isimDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        
        //klasik appDelegate kod blokları
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        //veri çekme(fetchReguest) öncesi hazırlık
        let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
        fetchReguest.returnsObjectsAsFaults = false
        
        //veri çekme de hangi verileri çekiyoruz hangi verileri işliyoruz aşamaları
        do {
            let sonuclar = try context?.fetch(fetchReguest)
            
            //sonuclar any geliyor ve NSManagedObject'e dönüştürmemiz gerekiyor
            if sonuclar!.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject] {
                    //yine any döndürdüğü için as ile String döndürüyoruz
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
                
                //Data da her yenilik olunca tableView da yenile
                tableView.reloadData()
            }
            
            
        } catch {
            print("hata")
        }
    }
    
    @objc func addButton(){
        secilenİsim = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    //tableView fonksiyonları, bunları yapmadan önce tableView sınıflarını eklemek gerekiyor
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! SecondViewController
            destinationVC.secilenUrunİsmi = secilenİsim
            destinationVC.secilenUrunUUID = secilenUUID
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenİsim = isimDizisi[indexPath.row]
        secilenUUID = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil) 
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //klasik appDelegate kod blokları
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            //veri çekme(fetchReguest) öncesi hazırlık
            let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchReguest.predicate = NSCompoundPredicate(format: "id = %@", uuidString)
            fetchReguest.returnsObjectsAsFaults = false
        
            do {
                let sonuclar = try context?.fetch(fetchReguest)

                //sonuclar any geliyor ve NSManagedObject'e dönüştürmemiz gerekiyor
                if sonuclar!.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject] {
                        //yine any döndürdüğü için as ile String döndürüyoruz
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row] {
                                context?.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do {
                                    try context?.save()
                                } catch {
                                    print("hata")
                                }
                                    break
                            }
                        }
                    }
                }
                
                
            } catch {
                print("hata")
            }
        }
    }

}
