//
//  Renderer.swift
//  gradCPT
//
//  Created by Shawn Schwartz on 1/17/25.
//

import MetalKit

// MARK: - Renderer
class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState!
    var texture1: MTLTexture!
    var texture2: MTLTexture!
    var vertexBuffer: MTLBuffer!
    var scaleBuffer: MTLBuffer!
    var startTime: Date

    // Timing parameters
    let frameRate: Float = 24.0  // FramesPer
    let desiredRate: Float = 0.05  // Rate in seconds
    var lastTransitionTime: Date  // Track when last transition started

    // Calculated properties
    var refresh: Float = 0
    var adjustedRate: Float = 0

    init(metalView: MTKView) {
        self.device = metalView.device!
        self.commandQueue = device.makeCommandQueue()!
        self.startTime = Date()
        self.lastTransitionTime = Date()

        // Adjust Rate and HoldTime to be multiples of refresh rate
        refresh = 1.0 / frameRate
        adjustedRate = round(desiredRate / refresh) * refresh

        super.init()

        createPipelineState(metalView: metalView)
        createVertexBuffer()
        createScaleBuffer()
        createTextures()
    }

    func createScaleBuffer() {
        let scale: Float = 0.3  // Base scale for circle size
        let scaleValues: [Float] = [scale, scale]

        scaleBuffer = device.makeBuffer(bytes: scaleValues, length: MemoryLayout<SIMD2<Float>>.size, options: [])
    }

    func createPipelineState(metalView: MTKView) {
        let library = device.makeDefaultLibrary()!

        guard let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            fatalError("Shader functions not found")
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }
    }

    func createVertexBuffer() {
        let vertices: [Float] = [
            -1,  1, 0, 0,  // position, texCoords
             1,  1, 1, 0,
            -1, -1, 0, 1,
             1, -1, 1, 1
        ]

        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
    }

    func createTextures() {
        let textureLoader = MTKTextureLoader(device: device)
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
        ]

        // MARK: testing with 2 mountain scene images
        guard let image1URL = Bundle.main.url(forResource: "land13", withExtension: "jpg"),
              let image2URL = Bundle.main.url(forResource: "land145", withExtension: "jpg") else {
            print("Error: Couldn't find image files in bundle")
            return
        }

        do {
            texture1 = try textureLoader.newTexture(URL: image1URL, options: textureLoaderOptions)
            texture2 = try textureLoader.newTexture(URL: image2URL, options: textureLoaderOptions)
        } catch {
            print("Error loading textures: \(error)")
        }
    }

    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        let elapsed = Float(Date().timeIntervalSince(startTime))

        // Calculate continuous fade parameters
        let cycleTime = adjustedRate * frameRate * 2  // double the cycle time to handle both directions
        let cycle = fmod(elapsed, cycleTime)
        let normalizedCycle = cycle / cycleTime

        // Continuous sine wave that goes smoothly from 0 to 1 and back
        var blend = (sin(normalizedCycle * 2 * .pi) + 1) / 2

        // Hold blend at the extremes
        if blend > 0.95 {
            blend = 1.0
        } else if blend < 0.05 {
            blend = 0.0
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(scaleBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(texture1, index: 0)
        renderEncoder.setFragmentTexture(texture2, index: 1)
        renderEncoder.setFragmentBytes(&blend, length: MemoryLayout<Float>.size, index: 0)

        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()

        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }

        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
}
