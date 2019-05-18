### Hello Triangle

本篇主要内容是关于屏幕图形渲染的主要流程，也就是render pipeline的三个过程：Vertex function、Rasterization、Fragment function。

1、为了更方便地表示顶点数据，引入SIMD数据类型，类似于矩阵，矩阵中是数值类型（float、int等）

2、Vertex function的主要功能是将输入的顶点数据转为viewport中渲染的位置，viewport坐标是[-1, 1]，中心点为(0,0)，做坐标的映射

3、Vertex function和后续的fragment function都是在metal文件中编写的，语法与C/C++ 类似，但执行在GPU

4、Rasterization之后，通过 Fragment function 将输入的fragment添加对应的颜色

5、完成上述流程之后进行渲染，在基本的commandQueue、commandBuffer、commandEncoder准备好之后，给encoder设置pipeline，而pipeline需要先通过 MTLLibrary 通过函数名称加载metal中对应函数

6、将顶点数据和viewport渲染size数据赋值给encoder之后，执行`drawPrimitives`绘制就完成了。