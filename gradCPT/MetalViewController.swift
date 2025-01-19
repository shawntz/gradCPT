// MARK: - Metal View Controller
class MetalViewController: NSViewController {
    var metalView: MTKView!
    var renderer: Renderer!
    var debugLabel: NSTextField!



    override func loadView() {
//        metalView = MTKView(frame: NSRect(x: 0, y: 0, width: 1024, height: 1024))
//        view = metalView
        print("load view")
        let mainView = NSView(frame: NSRect(x: 0, y: 0, width: 1512, height: 982))
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = .white
        view = mainView

        // Add debug label
                debugLabel = NSTextField(labelWithString: "Metal View Test")
                debugLabel.textColor = .black
                debugLabel.font = .systemFont(ofSize: 24)
                debugLabel.alignment = .center
                debugLabel.backgroundColor = .clear
                view.addSubview(debugLabel)

        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }

        metalView = MTKView(frame: .zero, device: device)
        metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.framebufferOnly = true
        metalView.preferredFramesPerSecond = 120 //60

        view.addSubview(metalView)

        // Use Auto Layout to center the metal view with fixed size
        metalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            metalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            metalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            metalView.widthAnchor.constraint(equalToConstant: 1024),
            metalView.heightAnchor.constraint(equalToConstant: 1024)
        ])

        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()

//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device")
//        }

//        metalView.device = device
//        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        metalView.colorPixelFormat = .bgra8Unorm
//        metalView.framebufferOnly = true
//        metalView.enableSetNeedsDisplay = true  // Enable explicit rendering
//        metalView.isPaused = false  // Make sure the view isn't paused
//        metalView.preferredFramesPerSecond = 60  // Set desired frame rate
//
//        // Create the MTKView with no frame at first
//        metalView = MTKView(frame: .zero, device: device)
//        metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
//        metalView.colorPixelFormat = .bgra8Unorm
//        metalView.framebufferOnly = true
//        metalView.preferredFramesPerSecond = 60

//        // Add metalView as a subview
//        view.addSubview(metalView)
//
//        // Use Auto Layout to fill the entire view
//        metalView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            metalView.topAnchor.constraint(equalTo: view.topAnchor),
//            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//
//        renderer = Renderer(metalView: metalView)
//        metalView.delegate = renderer
//    }
}