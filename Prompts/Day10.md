# Day 10 开发提示词

## 今日目标
**测试修复 + UI打磨 + 上架准备**

这是开发的最后一天，重点是测试、修复问题、完善细节，并准备App Store上架所需的所有资源。

---

## 任务清单

### 1. 全面功能测试

**测试清单**：

#### 用户系统
- [ ] Apple ID 登录流程
- [ ] 登录状态持久化
- [ ] 退出登录
- [ ] 个人中心信息显示
- [ ] 语言切换（中/英文）

#### 心灵地图
- [ ] GPS 权限请求
- [ ] 后台定位正常
- [ ] 轨迹记录开始/结束
- [ ] 出行方式自动识别
- [ ] 能量线正确渲染
- [ ] 不同出行方式显示不同颜色
- [ ] 心绪节点创建
- [ ] 情绪选择器
- [ ] 照片添加
- [ ] 节点在地图上显示
- [ ] 节点详情查看
- [ ] 轨迹列表查看

#### 圣迹系统
- [ ] 星脉图显示
- [ ] 三层圣迹不同图标
- [ ] 圣迹列表按大洲分类
- [ ] 搜索功能
- [ ] 圣迹详情页
- [ ] 旅程规划器
- [ ] 导航跳转

#### 回响 & 意向
- [ ] 回响发布
- [ ] 隐私设置
- [ ] 匿名发布
- [ ] 回响列表显示
- [ ] 意向标记
- [ ] 月份选择
- [ ] 统计数字显示

#### 引路系统
- [ ] 先行者列表
- [ ] 先行者详情
- [ ] 星图列表
- [ ] 星图地图显示
- [ ] 共鸣行走模式进入
- [ ] 节点触发（需模拟位置）
- [ ] 音频播放
- [ ] 强制反思界面

#### 寻迹申请
- [ ] 5步流程完整
- [ ] 地图定位
- [ ] 照片上传
- [ ] 提交成功

#### 商业化
- [ ] 订阅页面显示
- [ ] 产品价格加载
- [ ] 购买流程（沙盒测试）
- [ ] 恢复购买
- [ ] 订阅状态影响功能解锁

#### 数据
- [ ] 本地存储正常
- [ ] 云端同步正常
- [ ] 离线模式正常

### 2. 边界情况测试

```
测试场景：
1. 无网络环境下的操作
2. GPS信号弱的情况
3. 长时间后台运行
4. 内存压力测试（多轨迹数据）
5. 首次使用（空数据状态）
6. 快速频繁操作
7. 中途切换语言
8. 中途登出再登入
```

### 3. Bug修复模板

**创建 `BugTracker.md`**：
```markdown
# Bug 追踪

## 严重级别
- P0: 阻断性问题，必须修复
- P1: 重要问题，影响体验
- P2: 一般问题，可以容忍
- P3: 小问题，后续修复

## Bug 列表

| ID | 级别 | 描述 | 复现步骤 | 状态 |
|----|------|------|----------|------|
| 001 | | | | |

## 状态
- 待修复
- 修复中
- 已修复
- 已验证
```

### 4. UI 细节打磨

**检查清单**：

#### 视觉一致性
- [ ] 所有颜色使用 `LeyhomeTheme`
- [ ] 所有间距使用 `LeyhomeTheme.Spacing`
- [ ] 所有圆角使用 `LeyhomeTheme.CornerRadius`
- [ ] 字体大小层次清晰
- [ ] 图标风格统一

#### 动画效果
- [ ] 页面转场流畅
- [ ] 按钮点击有反馈
- [ ] 列表滚动流畅
- [ ] 加载状态有指示
- [ ] 错误状态有提示

#### 触觉反馈
- [ ] 重要操作有震动反馈
- [ ] 开始/结束记录
- [ ] 节点创建
- [ ] 意向标记
- [ ] 到达共鸣节点

#### 空状态
- [ ] 轨迹列表空状态
- [ ] 回响列表空状态
- [ ] 圣迹搜索无结果
- [ ] 数据加载失败

### 5. 性能优化

**创建 `PerformanceChecklist.swift`**：
```swift
/*
性能检查清单：

1. 地图渲染
   - 轨迹点数量限制
   - 视口外数据不渲染
   - 图层复用

2. 图片处理
   - 压缩后再上传
   - 使用缩略图
   - 图片缓存

3. 数据库
   - 索引优化
   - 分页加载
   - 懒加载

4. 内存
   - 大数据及时释放
   - 图片内存管理
   - 避免循环引用

5. 电池
   - GPS采样频率优化
   - 后台活动最小化
   - 网络请求合并
*/
```

### 6. App Store 资源准备

#### 6.1 App 图标
确保 `Assets.xcassets/AppIcon.appiconset` 包含所有尺寸：
- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 等其他尺寸

#### 6.2 截图准备

**需要的截图尺寸**：
- 6.7" (iPhone 15 Pro Max): 1290 x 2796
- 6.5" (iPhone 14 Plus): 1284 x 2778
- 5.5" (iPhone 8 Plus): 1242 x 2208

**截图内容（6张）**：
1. 心灵地图主界面 + 能量线
2. 心绪节点创建/情绪选择
3. 星脉图/圣迹系统
4. 圣迹详情页
5. 先行者/共鸣行走
6. 数据洞察/个人报告

**创建截图文案**（中/英文）：

```
截图1:
中: 每一步，都是独特的能量线
英: Every step becomes a unique energy line

截图2:
中: 记录此刻的心绪，让感受有迹可循
英: Capture your mood, make feelings traceable

截图3:
中: 探索全球圣迹，连接地球脉搏
英: Explore sacred sites, connect with Earth's pulse

截图4:
中: 深度了解每一处圣迹的故事
英: Discover the story behind every sacred site

截图5:
中: 跟随先行者，踏上归途
英: Follow pathfinders on the journey home

截图6:
中: 了解你的行走模式与内心成长
英: Understand your walking patterns and inner growth
```

#### 6.3 App 描述

**中文描述**：
```
地脉归途 — 所有的出发，都是为了回家

将你的每一步转化为独特的能量线，绘制专属于你的心灵地图。

【心灵地图】
• 自动记录步行、骑行、驾车、飞行等所有出行轨迹
• 将轨迹转化为艺术化的"能量线"
• 在轨迹上添加心绪节点，记录此刻的感受

【圣迹探索】
• 发现全球的地脉圣迹，从金字塔到富士山
• 了解每处圣迹的灵性解读与历史传说
• 规划你的朝圣之旅

【回响共鸣】
• 在圣迹留下你的感悟
• 标记"我亦向往"，与全球行者共振
• 零风险的匿名连接

【跟随先行者】
• 体验先行者的行走路线
• 聆听他们在每个节点的感悟
• 在共鸣中找到自己的声音

订阅"深度行者"解锁：
• 无限云端存储
• 完整先行者内容
• 深度数据洞察
• 高级地图主题

开始你的归途，每一步都通往内心。
```

**英文描述**：
```
Leyhome — Every departure leads us home

Transform every step into a unique energy line, drawing your personal soul map.

【Soul Map】
• Auto-track walking, cycling, driving, and flying journeys
• Convert tracks into artistic "energy lines"
• Add mood nodes to record your feelings along the way

【Sacred Sites】
• Discover global ley line sites, from Pyramids to Mount Fuji
• Explore spiritual interpretations and historical legends
• Plan your pilgrimage journey

【Echoes & Resonance】
• Leave your reflections at sacred sites
• Mark "I Also Aspire" and resonate with global travelers
• Zero-risk anonymous connection

【Follow Pathfinders】
• Experience pathfinders' walking routes
• Listen to their insights at each node
• Find your own voice through resonance

Subscribe to "Deep Walker" to unlock:
• Unlimited cloud storage
• Full pathfinder content
• Deep data insights
• Premium map themes

Begin your journey home. Every step leads within.
```

#### 6.4 关键词

**中文关键词**（100字符以内）：
```
心灵地图,行走记录,正念,冥想,GPS轨迹,情绪日记,旅行,徒步,圣地,能量,自我探索,疗愈,减压
```

**英文关键词**：
```
soul map,walking tracker,mindfulness,meditation,GPS journey,mood diary,travel,hiking,sacred sites,energy,self-discovery,healing
```

#### 6.5 其他信息

**App 名称**：地脉归途 / Leyhome
**副标题**：所有的出发，都是为了回家 / Every departure leads us home
**类别**：健康健美 / Health & Fitness
**次要类别**：生活 / Lifestyle
**年龄分级**：4+

#### 6.6 隐私政策

确保准备好隐私政策页面 URL，内容需包含：
- 收集的数据类型（位置、照片等）
- 数据使用目的
- 数据存储和保护
- 用户权利
- 联系方式

### 7. Info.plist 最终检查

```xml
<!-- 必要的权限说明 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>地脉归途需要访问您的位置来记录行走轨迹，绘制专属于您的心灵地图。</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>地脉归途需要在后台持续记录您的位置，确保每一步都被转化为独特的能量线。即使应用在后台运行，我们也会安全地记录您的旅程。</string>

<key>NSCameraUsageDescription</key>
<string>地脉归途需要使用相机来拍摄照片，记录您旅途中的美好瞬间。</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>地脉归途需要访问您的相册来选择照片，添加到您的心绪记录中。</string>

<key>NSMicrophoneUsageDescription</key>
<string>地脉归途需要使用麦克风来录制语音胶囊，记录您此刻的感悟。</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>audio</string>
</array>
```

### 8. 最终构建检查

**Archive 前检查**：
- [ ] Version 设置为 1.0.0
- [ ] Build 设置为 1
- [ ] Scheme 设置为 Release
- [ ] 移除所有调试代码
- [ ] 移除测试账号
- [ ] 检查 API 密钥安全
- [ ] 签名证书正确

**Archive 命令**：
```
Product → Archive
```

**导出 IPA**：
```
选择 "App Store Connect" 分发方式
```

### 9. App Store Connect 提交

**提交清单**：
- [ ] 上传构建
- [ ] 填写 App 信息
- [ ] 上传截图（中英文）
- [ ] 填写描述（中英文）
- [ ] 设置关键词
- [ ] 设置价格（免费+内购）
- [ ] 填写隐私政策 URL
- [ ] 设置年龄分级
- [ ] 添加审核备注
- [ ] 提交审核

**审核备注示例**：
```
感谢审核团队的工作！

关于后台定位权限：
本应用需要后台定位权限来持续记录用户的行走轨迹。这是核心功能，用户在开始记录时会明确授权。我们使用智能采样算法优化电池消耗。

测试账号：
（如需要提供测试账号）

如有任何问题，请随时联系我们。
```

### 10. 完成检查

**最终确认**：
- [ ] 所有 P0/P1 Bug 已修复
- [ ] 所有文案已校对
- [ ] 中英文切换正常
- [ ] 性能满足要求
- [ ] 截图已准备
- [ ] 描述已准备
- [ ] 隐私政策已上线
- [ ] 支持邮箱已配置
- [ ] 提交审核

---

## 国际化最终检查

确保 `Localizable.xcstrings` 包含所有文案，中英文都已填写。

运行以下检查：
```swift
// 检查是否有遗漏的本地化字符串
// 在项目中搜索 ".localized" 确保都有对应翻译
```

---

## Day 11-12 审核期间

### 审核等待期工作
- 监控 App Store Connect 状态
- 准备常见审核问题的回复
- 如被拒绝，快速修复并重新提交

### 常见拒绝原因及应对
1. **后台定位说明不清** → 完善 NSLocationAlwaysAndWhenInUseUsageDescription
2. **隐私政策缺失** → 确保 URL 可访问且内容完整
3. **内购问题** → 确保恢复购买功能正常
4. **UI问题** → 修复指出的具体问题

### 审核通过后
- [ ] 设置发布日期
- [ ] 准备社交媒体公告
- [ ] 准备用户支持渠道
- [ ] 监控首日反馈

---

## 验收标准
- [ ] 所有核心功能测试通过
- [ ] P0/P1 Bug 全部修复
- [ ] UI 视觉一致性检查通过
- [ ] 性能满足 PRD 要求
- [ ] App Store 资源全部准备完成
- [ ] 成功上传到 App Store Connect
- [ ] 提交审核

---

## 完成后
提交代码到 GitHub，备注："Day 10: 测试修复 + UI打磨 + 上架准备 - Ready for App Store Review"

然后：
1. Archive 并上传到 App Store Connect
2. 填写所有元数据
3. 提交审核
4. 等待审核结果

---

**恭喜！你已完成10天的开发旅程。**

*"所有的出发，都是为了回家。"*
