import SwiftUI
//   image1 sleep!
class TaskBootcampViewModel: ObservableObject  {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    static private let nanoSecs: UInt64 = 1_000_000_000 * 100
    
    func fetchImage() async {
        do  {
            guard let url = URL(string: "https://www.pixelstalk.net/wp-content/uploads/2016/07/3840x2160-Images-Free-Download.jpg") else {
                print("guard let url failure")
                return
            }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            self.image = UIImage(data: data)
        } catch { 
            print("image1 Failure:")
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do  {
            try await Task.sleep(nanoseconds: TaskBootcampViewModel.nanoSecs)
            guard let url = URL(string: "https://www.pixelstalk.net/wp-content/uploads/2016/07/Download-Free-Pictures-4k.jpg") else {
                print("guard let url failure")
                return
            }
            let (data2, _) = try await URLSession.shared.data(from: url, delegate: nil)
            self.image2 = UIImage(data: data2)
        } catch { 
            print("image2 Failure:")
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcamp: View  {
    @StateObject private var viewModel = TaskBootcampViewModel()
    
    var body: some View  {
        VStack  {
            Text("VStack.images")
                .frame(alignment: .top)
                .font(.system(size: 18, weight: .bold, design: .default))
            if let image = viewModel.image {
                Image(uiImage: image) 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            if let image2 = viewModel.image2 {
                Image(uiImage: image2) 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear() {
            Task {
                try? await Task
                print("Task1")
//                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage()
            }
            Task {
                print("Task2")
                print(Task.currentPriority)
                await viewModel.fetchImage2()
            }
        }
    }
}


struct TaskBootcamp_Provider: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
            .preferredColorScheme(.dark)
    }
}

