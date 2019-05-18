### Device and Commands

本篇及其 sample 主要介绍 Metal 基本使用流程，代码架构中核心类型包括两个：MTKView、CommandRenderer，前者是展示绘制结果的View，后者主要职责是响应 View Events：绘制区域size变化、响应每一帧内容绘制。

针对绘制内容的主要是在 ` func draw(in view: MTKView) ` 函数中，函数中的代码也就是Metal的主要流程：

1、要有一个给GPU执行command的 MTLCommandQueue，保证指令的顺序执行

2、针对每一帧的command，由 MTLCommandBuffer 来提供

3、commandBuffer中的指令需要针对GPU设备进行encode才能被GPU执行，因此需要一个 MTLRenderCommandEncoder

4、每一帧的 commandBuffer 都可以通过一个 MTKView 已有的 currentRenderPassDescriptor （MTLRenderPassDescriptor）来配置指令encode的过程。

5、sampleCode中只进行了clearColor的设置，encode完成之后，调用 endEncoding 将已有的指令encode到commandBuffer。

6、结束encode之后，commandBuffer只接收 prsent和commit两个指令，present是展示，commit是提交当前帧的command到commandQueue。`[commandBuffer presentDrawable:view.currentDrawable]` 函数调用保证GPU完成当前帧的指令之后再渲染和展示到屏幕。`[commandBuffer commit]` 也就是把commandBuffer中encode的指令提交到commandQueue给GPU执行。