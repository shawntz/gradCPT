<h1 align="center">WIP gradCPT (native macOS version) 🧑‍💻</h1>

> [!NOTE]
> A macOS-native remake of the Esterman gradual continuous onset performance task (gradCPT; Esterman et al., 2013).
> 
> Critically, this remake leverages Apple's low-level Metal API to take advance of hardware-accelerated 3D graphics, specifically with the aim of providing future-proofing and capatability for running this task on Apple Silicon (M-chips).

## ⚠️ Problem Statement
- Current best-practices for running and collecting data on the gradCPT are to use Esterman's original MATLAB program which leverages the popular Psychtoolbox-3 (PTB) software package; this PTB-based gradCPT program is available both as an open source MATLAB script as well as a standalone Windows `.exe` (i.e., executable MATLAB program).
- While these original versions of the gradCPT have been useful since their creation, changes in computing architectures over the past decade have led to compatibility issues:
  - First, the MATLAB-/PTB-based version is limited to Intel-/AMD-based machines (specifically, the `x86_64` architecture) prior to the switch to Apple Silicon (M-Chips; pre-ARM `AArch64`/`ARM64` architecture). PTB only recently (on [December 13, 2024](http://psychtoolbox.org/PTB-3.0.20-Released.html)) pushed out `beta` quality macOS Apple Silicon Mac support. PTB's initial macOS Apple Silicon beta is likely not trustworthy for data collection due to the known timing-related challenges that the PTB-team is working to remedy:
    - "Biggest challenge: Apples proprietary graphics chip breaks all visual timing / time stamping mechanisms normally employed on Intel based Macs. Needed a completely different approach.", and ... "Requires a whole new set of mex files and libraries, and various modifications."
    - Source: [VSS 2024 Talk](https://www.youtube.com/watch?v=05gpkP_EMoc)
  - Despite the PTB team's efforts to provide Apple Silicon support, their VSS Talk (linked above) indicated that a new pay-to-play model would be implemented for future access to compiled PTB mex files on some operating systems; this approach is intended to provide financial support to the small number of individuals who make PTB possible, however, raised some questions about the future given the need to pay-to-play with so-called "open software".
    - See: [https://psychtoolbox.discourse.group/t/psychtoolbox-talk-at-vss-2024-satellite-on-psychophysics-software-with-matlab/5352/3](https://psychtoolbox.discourse.group/t/psychtoolbox-talk-at-vss-2024-satellite-on-psychophysics-software-with-matlab/5352/3)
- Currently, our lab ([Stanford Memory Lab](https://memorylab.stanford.edu/)) collects in-person data using the classic gradCPT task implementation discussed above on >100s of participants a year. We have had to resort to using legacy hardware, including old MacBook Pros with Intel processors, to run the gradCPT. We have also dabbled in running the other standalone Windows-based gradCPT `.exe`, however, we have faced various reliability issues with setup, cross-machine inconsistencies, and clunky configurations. Furthermore, each year, our lab's legacy hardware is getting worse and worse, lessening reliability of the original gradCPT script-based MATLAB implementation, and essentially placing us at a fork in the road.

## ❓ Why not rebuild the gradCPT in PsychoPy?

### 1. Recommended hardware...
> [!WARNING]  
> The minimum requirement for PsychoPy® is a computer with a graphics card that supports OpenGL. Many newer graphics cards will work well. Ideally the graphics card should support OpenGL version 2.0 or higher. Certain visual functions run much faster if OpenGL 2.0 is available, and some require it (e.g. ElementArrayStim).
> 
> If you already have a computer, you can install PsychoPy® and the Configuration Wizard will auto-detect the card and drivers, and provide more information. It is inexpensive to upgrade most desktop computers to an adequate graphics card. High-end graphics cards can be very expensive but are only needed for very intensive use.
> 
> Generally NVIDIA and ATI (AMD) graphics chips have higher performance than Intel graphics chips so try and get one of those instead.
>
> https://psychopy.org/download.html#recommended-hardware

### 2. Timing-related issues on Apple Silicon...
> [!IMPORTANT]
> See the following discussion threads that capture the primary issues present with Apple Silicon.
> - https://discourse.psychopy.org/t/psychopy-native-version-for-apple-silicon/43105/9
> - https://discourse.psychopy.org/t/discussion-frame-timing-on-macos/42375
> - https://psychtoolbox.discourse.group/t/using-toolbox-on-macos-for-apple-silicon-macs/3599/24

### 3. PTB as a dependency for PsychoPy...
> [!CAUTION]
> "We generally strongly recommend Linux as the operating system of choice for demanding experimental setups which require the highest timing precision, precision for color or luminance displays, general performance and flexibility. Our support for fixing bugs and other issues on other operating systems than Linux will be limited, as proprietary operating systems like Windows or macOS pose many obstacles to diagnosing bugs and make it impossible to fix bugs in them or make improvements to them."
> 
> http://psychtoolbox.org/requirements.html

## 🤔 So where does this put us?
It goes without saying that we'd probably be better off just moving away from MacOS for running experiments, however, logistically as well as environmentally speaking, this isn't feasible as our lab is already fully-stocked with Apple Silicon Macs and -- for most of the types of tasks our lab runs -- having the precise frame-by-frame timing achievable with PTB or PsychoPy on non-Apple hardware doesn't justify changing architectures / buying new hardware to run this one gradCPT task that actually depends on precise frame-by-frame timing.

Based on a variety of discussions within our lab group over the past ~3 years, we've decided the following approach:
1. Continue using legacy hardware with the legacy gradCPT until this is no longer possible (this is important because we have numerous on-going longitudinal studies where data from this task are collected from participants across multiple visits).
2. Spend some time attempting to rebuild the gradCPT from the bottom-up using lower-level Apple-centric approaches with the goal of building a comparable alternative that can be used as we phase out legacy hardware/software.
3. If this effort ultimately takes too much time and/or ends up not being reliable timing-wise, then other options moving forward can be considered. **Yet, for now, it doesn't hurt to give the Apple Metal API a try for ourselves.**

### ⛔ Cons
#### 1. Potential to encounter some timing-related issues documented on Metal for complex graphics + Apple's ProMotion variable refresh rate technology
  - https://forums.developer.apple.com/forums/thread/698630

#### 2. Potentially trying to rework the wheel of past efforts by experts in this space, such as Mario Kleiner (primary developer/maintainer of PTB); for instance:
> [!CAUTION]
> "According to Apple propaganda, Metal is the greatest invention since sliced bread and the one true way to do graphics on macOS. According to my results after just spending 174 utterly depressing hours of work, trying to get Metal to behave even half-way reasonable wrt. presentation timing and timestamping, my assessment so far is that this is even a bigger dumpster fire than Apples OpenGL implementation when it comes to stimulus timing and timestamping. A lot of time was spent making sure the failures i see are not caused by any bugs or limitations in PTB, or the open-source MoltenVK Vulkan-to-Metal driver, or of the general approach which works nicely on both Linux and Windows-10, so these are again macOS bugs and problems courtesy of Apple, only fixable by Apple, with no known workarounds. My tests are limited to a MacBookPro 2017 running macOS 10.15.7 with both AMD and Intel graphics so far. Who knows, maybe macOS 11 on M1 is less broken in that area than macOS 10 – although that would be the first time anything would be better on the dumpster fire that Big Sur seems to be, even compared to the temple of sadness that was recent macOS 10?"
> 
> https://psychtoolbox.discourse.group/t/using-toolbox-on-macos-for-apple-silicon-macs/3599/24

#### 3. ✏️ Have to rebuild a handful of basic modules with frame-by-frame precise timing:
- [ ] keyboard/response input monitoring
- [ ] shaders/geometry + image handlers
- [ ] trial-level stimulus generator/experiment handlers

### ✅ Pros / 🎯 Motivation to try
- We aren't in the precarious position that the PTB/PsychoPy stakeholders face of trying to rebuild an entire massive library/suite of general tools and modules for running all types of psychology experiments
- We don't need to worry about timing integrations with other hardware (like eyetrackers, etc.)
- If this works, we should have relatively long-term support and will not need to rely on other developers/frameworks getting OpenGL replacements working/correct for the general public/use cases.
- Furthermore, we will have an internal framework to expand upon if needed in the future.

### ℹ️ What is Metal?
> [!NOTE]
> "Metal is a low-level, low-overhead hardware-accelerated 3D graphic and compute shader API created by Apple, debuting in iOS 8. Metal combines functions similar to OpenGL and OpenCL in one API. It is intended to improve performance by offering low-level access to the GPU hardware for apps on iOS, iPadOS, macOS, and tvOS. It can be compared to low-level APIs on other platforms such as Vulkan and DirectX 12. Metal is an object-oriented API that can be invoked using the Swift, Objective-C or C++17[2] programming languages. Full-blown GPU execution is controlled via the Metal Shading Language. According to Apple promotional materials: "MSL [Metal Shading Language] is a single, unified language that allows tighter integration between the graphics and compute programs. Since MSL is C++-based, you will find it familiar and easy to use."[3]"
>
> https://en.wikipedia.org/wiki/Metal_(API)
>
> "Metal is a modern, tightly integrated graphics and compute API coupled with a powerful shading language that is designed and optimized for Apple platforms. Its low-overhead model gives you direct control over each task the GPU performs, enabling you to maximize the efficiency of your graphics and compute software. Metal also includes an unparalleled suite of GPU profiling and debugging tools to help you improve performance and graphics quality."
>
> https://developer.apple.com/metal/

---

### References
- Michael Esterman, Sarah K. Noonan, Monica Rosenberg, Joseph DeGutis, In the Zone or Zoning Out? Tracking Behavioral and Neural Fluctuations During Sustained Attention, Cerebral Cortex, Volume 23, Issue 11, November 2013, Pages 2712–2723, https://doi.org/10.1093/cercor/bhs261 
