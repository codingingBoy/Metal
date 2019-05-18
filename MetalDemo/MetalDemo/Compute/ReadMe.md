### Hello Compute

在图片绘制基础上，本篇针对采样之后的颜色进行转灰度的计算，rgb转灰度的处理是通过MTLComputePipelineState来实现，主要操作包括如下几步：

1、在.metal 文件中创建用于将rgba转灰度的 kernal function，kenral function 将输入的texture 取到对应的 gid 的rbba，然后通过dot函数转灰度，将回度写到输出到texture

2、创建MTLComputePipelineState，用上述 kernal function来初始化

3、MTLComputePipelineState的指令是在每一帧回调中处理的，通过 `makeComputeCommandEncoder` 创建用于compute处理的encoder。

4、MTLComputeCommandEncoder进行的处理包括四部：设置compute pipeline、设置inputTexture、设置outputTexture、配置线程组（` public func dispatchThreadgroups(_ threadgroupsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize)`），最后endEncoding就结束了，后续是渲染的操作。
