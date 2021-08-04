# Flutter知识点
## Flutter核心原理
### Flutter UI系统
#### 硬件绘图基本原理：  
CPU和GPU各司其职，CPU用于基本数学和逻辑计算，GPU执行图形处理相关复杂数学，最终确定输送给显示器各个像素点的色值
- 操作系统绘制API的封装  
  - 最终的图形计算和绘制都是由相应的硬件来完成，而直接操作硬件的指令通常都会有操作系统屏蔽
  - 正因如此，一般都是将操作系统原生API封装在一个编程框架和模型中，然后定义一种简单的开发规则来开发GUI应用程序，而这一层抽象，正是我们所说的“UI”系统
- 系统  
  - 简单概括就是：组合和响应式。
  - 我们要开发一个UI界面，需要通过组合其它Widget来实现，Flutter中，一切都是Widget
  - 当UI要发生变化时，我们不去直接修改DOM，而是通过更新状态，让Flutter UI系统来根据新的状态来重新构建UI
### Element简介  
  - 最终的UI树其实是由一个个独立的Element节点构成
  - 组件最终的Layout、渲染都是通过RenderObject来完成的
  - 创建到渲染的大体流程是：根据Widget生成Element -> 创建相应的RenderObject并关联到Element.renderObject属性上 -> 再通过RenderObject来完成布局排列和绘制
  - Element就是Widget在UI树具体位置的一个实例化对象，大多数Element只有唯一的renderObject，但还有一些Element会有多个子节点，如继承自RenderObjectElement的一些类，比如MultiChildRenderObjectElement
  - “渲染树”：所有Element的RenderObject构成一棵树，我们称之为”Render Tree“即”渲染树“
  - 我们可以认为Flutter的UI系统包含三棵树：Widget树、Element树、渲染树。他们的依赖关系是：Element树根据Widget树生成，而渲染树又依赖于Element树
### Element的生命周期
- Framework 调用 **Widget.createElement** 创建一个Element实例，记为element 
- Framework 调用 **element.mount(parentElement,newSlot)** ，mount方法中首先调用element所对应Widget的**createRenderObject**方法创建与element相关联的RenderObject对象，然后调用**element.attachRenderObject**方法将element.renderObject添加到渲染树中插槽指定的位置（这一步不是必须的，一般发生在Element树结构发生变化时才需要重新attach）。插入到渲染树后的element就处于“active”状态，处于“active”状态后就可以显示在屏幕上了（可以隐藏）
- 当有父Widget的配置数据改变时，同时其**State.build**返回的Widget结构与之前不同，此时就需要重新构建对应的Element树。为了进行Element复用，在Element重新构建前会先尝试是否可以复用旧树上相同位置的element，element节点在更新前都会调用其对应Widget的canUpdate方法，如果返回true，则复用旧Element，旧的Element会使用新Widget配置数据更新，反之则会创建一个新的Element。**Widget.canUpdate**主要是判断newWidget与oldWidget的runtimeType和key是否同时相等，如果同时相等就返回true，否则就会返回false。根据这个原理，当我们需要强制更新一个Widget时，可以通过指定不同的Key来避免复用
- 当有祖先Element决定要移除element 时（如Widget树结构发生了变化，导致element对应的Widget被移除），这时该祖先Element就会调用**deactivateChild**方法来移除它，移除后**element.renderObject**也会被从渲染树中移除，然后Framework会调用**element.deactivate**方法，这时element状态变为“inactive”状态
- “inactive”态的element将不会再显示到屏幕。为了避免在一次动画执行过程中反复创建、移除某个特定element，“inactive”态的element在当前动画最后一帧结束前都会保留，如果在动画执行结束后它还未能重新变成“active”状态，Framework就会调用其unmount方法将其彻底移除，这时element的状态为defunct,它将永远不会再被插入到树中
- 如果element要重新插入到Element树的其它位置，如element或element的祖先拥有一个GlobalKey（用于全局复用元素），那么Framework会先将element从现有位置移除，然后再调用其activate方法，并将其renderObject重新attach到渲染树
### BuildContext