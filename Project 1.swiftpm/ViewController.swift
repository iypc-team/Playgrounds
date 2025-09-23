import UIKit

class ViewController: UIViewController {
    var fm: FileManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        printContent(fm)
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
    }
}


