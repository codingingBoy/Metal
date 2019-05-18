### Basic Texturing

本篇主要内容是图片的渲染，图片渲染相对于图形渲染，不同之处在于samplesShader过程，和texture coordinate。图片渲染流程为：

1、和图形渲染一样，初始化pipeline，赋值顶点着色和片元着色函数

2、顶点着色函数除了做顶点坐标转换，还有一个顶点textureCoordinate

3、片元着色主要主要的操作是根据在图片中sample得到的颜色，返回出去

4、在每一帧绘制过程中，给pipeline指定texture，设置顶点数据、fragmentTexture（encoder属性）

5、接下来就是简单的绘制了
