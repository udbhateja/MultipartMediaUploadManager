# MultipartMediaUploadManager
Networking class used to upload Multipart data to web services using Alamofire

## Example

    import UIKit

    class TestViewController: UIViewController {
    
        @IBOutlet weak var commentTextView  : UITextView!
        @IBOutlet weak var userImageView    : UIImageView!
    
        private var mediaManager: MultipartMediaUploadManager!
    
        private func upload() {
            guard let data = userImageView.image?.pngData() else {
                return
        }
        
        let parameters = [
            "id"        : 1,
            "type"      : 5,
            "comment"   : commentTextView.text!
            ] as [String : Any]
            
        let dataComponent = MultiPartDataComponents(
            data: data, 
            key: "photo", 
            extension:".png", 
            mimeType: "image/png")
        
        mediaManager = MultipartMediaUploadManager(
            url: "yoururl.com", 
            parameters: parameters, 
            dataComponents: [dataComponent], 
            method: .post)
        
        mediaManager.onCompletion = { response in
            //Handle your response here
        }
        
        mediaManager.onError = { error in
            print(error?.localizedDescription)
            //Handle your error here
        }
    }
    
       @IBAction func uploadImage(_ sender: Any) {
          upload()
       }
    }
