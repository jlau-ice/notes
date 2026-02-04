
首先，官方文档非常值得细细品味，看完官方文档倒也可以考虑不用看其他的文章了（针对skill，mcp这一块感觉描述一般，mcp太多东西了）：

[# Agent Skills](https://code.claude.com/docs/zh-CN/skills)

[# Agent Skills概览](https://platform.claude.com/docs/zh-CN/agents-and-tools/agent-skills/overview)

## 通过 MCP 将 Claude Code 连接到工具

---

## 一、Token 占用对比，这个大家应该都知道，不过多描述

### 1.1 MCP：全量加载模式

MCP 在会话启动时**全量加载**所有工具定义到上下文：

`会话启动 → 加载所有 MCP 服务器 → 注入全部工具定义（JSON-Schema）`

**就拿我使用的mcp来说**：

|MCP 服务器|工具数|Token 占用|
|---|---|---|
|auggie-mcp|1|~1k|
|grok-search|5|~3k|
|memory|9|~5k|
|sequential-thinking|1|~2k|
|**多服务器叠加**|-|**轻松突破 10k+**|

随便用几个占用就非常大了

### 1.2 Skill：按需加载模式

Skill 采用**渐进式披露**，仅在需要时加载：

|阶段|加载内容|Token 占用|
|---|---|---|
|启动时|仅 `name` + `description` 索引|~10-100 tokens/skill|
|触发时|完整 `SKILL.md` 内容|~1,000-5,000 tokens/skill|

**我使用的skill**：90K 的 Skills 目录，`/context` 仅显示 **513 tokens**，和mcp对比起来，非常直观。

### 1.3 简单对比

|维度|MCP|Skill|
|---|---|---|
|启动时占用|全量（10k+ tokens）|索引（~500 tokens）|
|使用时增量|无（已加载）|按需逐步加载|

---

## 二、设计模式对比

### 2.1 MCP：全量注入 + JSON-Schema

#### 什么是 MCP？

MCP（Model Context Protocol）即模型上下文协议，采用 **Host-Client-Server** 三层架构：

`Host (Claude Code)     │     ├── Client ←──JSON-RPC──→ context7 Server                   ├── Client ←──JSON-RPC──→ sequential-thinking Server        └── Client ←──JSON-RPC──→ your Server`                  

|角色|是什么|
|---|---|
|**Host**|AI 应用程序（比如Claude Code、VS Code、Cursor 等）|
|**Client**|通信管道，负责与 Server 建立连接、发送 JSON-RPC 请求、接收响应|
|**Server**|提供工具/上下文的程序（==日常说的「安装 MCP」就是安装 Server==）|
|**JSON-RPC**|Client 与 Server 之间传输的数据格式（所有 MCP 都遵守此协议）|
|**Tool Schema**|启动时 Server 返回的「工具说明书」，告诉 Claude 有哪些工具、怎么调用|

> Host 和 Client 由应用自动管理，**开发者/使用者只需关注 Server**。再比如 FastMCP 框架会自动处理协议细节。

#### MCP Server 目录结构（这里以Python为例）

`my-mcp-server/ ├── pyproject.toml            # 包定义（必需） │   ├── name = "mcp-server-xxx" │   └── version = "1.0.0" ├── src/ │   ├── server.py             # 入口，初始化 FastMCP │   ├── tools.py              # Tool 定义（单文件，适合 <10 个工具） │   ├── tools/                # Tool 定义（多文件，按功能拆分） │   │   ├── __init__.py │   │   ├── search.py │   │   └── fetch.py │   └── resources.py          # Resource 提供者（可选） └── README.md`

> `tools.py` 和 `tools/` 二选一，可根据数量决定。

#### Tool 定义示例

从这里就可以看出，其实和接口非常像，请求->回调数据，实际上多数的mcp也都可以理解成三方接口。

`from mcp.server.fastmcp import FastMCP  mcp = FastMCP("weather")  @mcp.tool() async def get_weather(location: str) -> str:     """Get weather for a location."""     return f"Weather in {location}: 72°F, Sunny"  if __name__ == "__main__":     mcp.run(transport="stdio")`

#### 客户端配置结构（mcpServers）

**配置示例**：

`{   "args": [     "-y",     "@upstash/context7-mcp"   ],   "command": "npx",   "type": "stdio" }`

> mcp服务器的json格式，让配置起来非常方便，cv万岁

### 2.2 Skill：渐进式披露 + Markdown

#### 什么是 Skill？

Skill 是 Claude Code 的**知识/流程包**，本质是一个 Markdown 文件夹，用于：

- 注入领域知识（如代码规范、业务逻辑）
- 定义工作流程（如代码审查 SOP、部署流程）
- 封装可复用的脚本和模板 ==（这直接导致 Skill 与 MCP 在使用体验上趋于相似）==

**额外说明：**

Skill 只能提供指导，无法执行外部 API 调用、网络请求、会话管理等操作，毕竟只是md文件夹，但是能指导cc运行脚本，包括但不限于自带的脚本资源，这句话应该会有嚼头。

#### Skill 目录结构（双层架构）

> 以下规范取自 `skill-creator` Skill,我觉得配置比cc官方文档里面的描述更详细

`skill-name/ ├── SKILL.md (必需) │   ├── YAML frontmatter ──→ 索引层（始终加载，~100 words） │   │   ├── name: (必需) │   │   └── description: (必需，唯一触发机制) │   └── Markdown 正文 ────→ 内容层（触发时加载，建议 <500 行） └── Bundled Resources (可选) ──→ 内容层（按需加载）     ├── scripts/      - 可执行脚本（Python/Bash）     ├── references/   - 参考文档（Claude 判断需要时加载）     └── assets/       - 输出资源（模板、图片，不加载到上下文）`

**双层架构说明**：

- **索引层**：YAML frontmatter 中的 name/description，始终在上下文中
- **内容层**：SKILL.md 正文 + 捆绑资源，仅在触发时选择性加载

#### 核心设计原则

**description 是唯一触发机制**

`# ✅ 好的 description（包含触发场景） description: >   Comprehensive document creation and editing with tracked changes.   Use when Claude needs to work with .docx files for:   (1) Creating new documents, (2) Modifying content,   (3) Working with tracked changes, (4) Adding comments # ❌ 差的 description（太模糊） description: A useful document tool`

#### 渐进式披露模式

> 是不是觉得模式1,3非常相似？我也觉得。不过 `skill-creator` 还是分成了这三种，就全罗列出来了

**模式 1：高层指南 + 引用**

`# PDF Processing  ## Quick start [核心代码示例]  ## Advanced features - **Form filling**: See [FORMS.md](references/FORMS.md) - **API reference**: See [REFERENCE.md](references/REFERENCE.md)`

Claude 仅在需要时加载 FORMS.md 或 REFERENCE.md。

**模式 2：按领域/变体组织**

`cloud-deploy/ ├── SKILL.md (工作流 + 选择指南) └── references/     ├── aws.md    ← 用户选 AWS 时才加载     ├── gcp.md     └── azure.md`

**模式 3：条件详情**

`## Editing documents For simple edits, modify XML directly.  **For tracked changes**: See [REDLINING.md](references/REDLINING.md) **For OOXML details**: See [OOXML.md](references/OOXML.md)`

#### 工作流程

`用户请求 → Claude 扫描所有 Skill 的 description → 匹配 → 加载 SKILL.md 正文 → 按需加载 references → 执行`

**特点**：

- **宽松定义**：Markdown 格式，自然语言描述
- **懒加载**：渐进式加载
- **可编排**：Markdown 可表达流程顺序和条件分支
- **本质**：流程/知识包（SOP 手册）

---

## 三、版本管理与更新便利性

**结论先行**：MCP 在版本管理上**绝对优于** Skill。

### 3.1 MCP：成熟的包管理生态

#### 核心机制

MCP 直接复用 npm/PyPI 成熟生态，版本管理由包管理器自动处理。

**工作原理**：

- MCP 服务器以 npm 包（js/ts）或 PyPI 包（Python）形式发布
- 使用 `npx` 或 `uvx` 命令启动时，包管理器会自动处理下载和缓存
- 版本号定义在 `package.json`（npm）或 `pyproject.toml`（PyPI）中

**更新行为**：

|模式|行为|启动速度|适用场景|
|---|---|---|---|
|**默认**|使用本地缓存，不查询 registry|快|日常使用|
|**强制更新**|每次查询 registry，版本变化时才下载（`@latest` 或 `--refresh`）|慢|需要最新版本时|

**获取方式对比**：

|获取方式|配置示例|更新机制|
|---|---|---|
|**npx (npm)**|`npx -y @pkg/server`|默认用缓存，需 `@latest` 或清缓存强制更新|
|**uvx (pip)**|`uvx mcp-server-fetch`|默认用缓存，需 `--refresh` 或清缓存强制更新|
|**本地命令**|`auggie --mcp`|需手动 `pip install --upgrade`|

**配置示例**：

`// ~/.claude.json {   "mcpServers": {     "memory": {       "command": "npx",       "args": ["-y", "@modelcontextprotocol/server-memory"]     }   } }`

#### 如何更新

**推荐方式：手动清理缓存**

当 MCP 服务器有新版本时，清理缓存即可：

`# 清理 npx 缓存 rm -rf ~/.npm/_npx #（不推荐！不推荐！不推荐！）  # 清理 uvx 缓存 uv cache clean #（不推荐！不推荐！不推荐！）  # 上述的清理会清理系统中所有的缓存，但mcp的缓存位置各有不同，需要主动寻找，且无规律可言，最好还是让cc自己来吧`

**工作流程**：

1. 清理缓存
2. 重启 Claude Code
3. 自动下载最新版本

**优点**：日常启动快，需要更新时才清理缓存

**不推荐使用 @latest 或 --refresh**

虽然可以自动更新，但会显著影响启动速度（每次都查询 registry）。

配置示例：

`{   "mcpServers": {     "memory": {       "command": "npx",       "args": ["-y", "@modelcontextprotocol/server-memory@latest"]  // npx 使用 @latest     },     "fetch": {       "command": "uvx",       "args": ["--refresh", "mcp-server-fetch"]  // uvx 使用 --refresh     }   } }`

---

### 3.2 Skill：普遍缺乏版本管理

#### 现状：一般来说 Skill 没有版本管理

与 MCP 不同，**一般来说 Skill 没有任何版本管理机制**：

- 没有版本号定义
- 没有版本锁定
- 手动管理

Skill在某些时候更像可以随意定制的小玩具，在原本的基础上又能随意修改

**Skill 的获取与更新方式**：

|获取方式|更新方式|版本控制|
|---|---|---|
|GitHub 克隆|`git pull` 手动更新|依赖 Git commit hash|
|下载ZIP文件|手动替换文件|**无**|
|CC直接生成|即时生效|**无**|

**问题**：

- 用户不知道 Skill 是否有新版本
- 无法回滚到特定版本（除非使用 Git）

---

#### 例外：官方 Marketplace（需登录）

**唯一的版本管理方案**是官方 Marketplace，但有严格限制：

- **必须登录**：API Key 用户无法使用
- **非标准化**：没有强制的版本号格式

**Marketplace 版本管理示例**：

`// marketplace.json {   "name": "my-plugins",   "plugins": [     {       "name": "review-plugin",       "source": "./plugins/review-plugin",       "version": "2.1.0"  // ← 需要手动维护     }   ] }`

**限制**：

- 仅适用于官方 Marketplace 中的 Skill
- 无法用于自定义或第三方 Skill
- API Key 用户完全无法使用

ps：这一块应该是这样的吧，没有官号诶

---

#### [](https://linux.do/t/topic/1485159#p-12803168-skill-25)Skill 的独特优势

尽管缺乏版本管理，Skill 还有一个 MCP 无法比拟的优势：

**即时生效**：修改 Skill 文件后无需重启服务，下次触发时自动加载最新内容。

**对比 MCP**：

- **MCP**：修改后需重启 Claude Code 才能生效
- **Skill**：适合快速迭代和调试，改完即用

**适用场景**：

- 个人定制化 Skill（频繁调整）
- 快速原型验证

---

## 四、我推荐：使用 Slash Command 稳定触发

**事先声明：** 这里的/ccg不是使用的skill，我才发现，哎呀！！

但是我都按照这个写了，不想再改了。

`/ccg`的工作流程是 /cmd → 自己的脚本  
请你们假装 是 /cmd → skill → skill的脚本

### 4.1 Skill 的触发不确定性问题

Skill 依赖 Claude **自动匹配描述**，存在以下问题：

- 该触发时未触发（描述不够精准）
- 不该触发时误触发（描述过于宽泛）

**实际体验**：虽然 Skill 理论上能够自动触发，但实际触发率较低。比如我即使在 CLAUDE.md 中明确写了"让 Codex 和 Gemini 参与协作"，Claude 偶尔还是会忽略。所以之前我都会主动在需求后面添加这句话。

**解决方案**：使用 cmd 可以 **100% 稳定触发**。例如：`/ccg:feat 需求描述` 总比主动描述或者期待cc记得安心。

### 4.2 最佳实践：Skill + Command 工作流组合

**为什么需要 Command**：

Skill 可能包含复杂的命令调用和参数配置，这些细节难以通过自然语言稳定触发。例如：

- 外部工具调用：`/home/nobug/.claude/bin/codeagent-wrapper --backend gemini`
- 带参数的指令：`--backend codex`、`--SESSION_ID xxx`
- 多阶段工作流：需要按特定顺序执行多个步骤

这些精确的指令和参数通过语言描述很难稳定触发，而 Command 可以将这些细节明确定义在文件中。

**模式 1 示例**（简单流程）：

`场景：应用主题到 Artifact  ├── ~/.claude/skills/theme-factory/ │   └── SKILL.md                    # 主题定义、应用指南 └── ~/.claude/commands/     └── theme-factory.md            # 内容："Execute the theme-factory skill"  用户输入 /theme-factory 应用深色主题     ↓ Command 触发 → Claude 加载 SKILL.md → 自主执行`

**模式 2 示例**（复杂流程）：

`场景：前端专项开发  └── ~/.claude/commands/ccg/     └── frontend.md                 # 完整工作流定义  用户输入 /ccg:frontend 实现响应式导航栏     ↓ Claude 加载 frontend.md 内容     ↓ 按照 Command 中定义的 6 个阶段执行：   1. Prompt 增强（可选）   2. 研究（代码检索）   3. 构思（调用 Gemini 分析）   4. 计划（调用 Gemini 规划）   5. 执行（Claude 实施）   6. 优化（调用 Gemini 审查）`

**外部工具说明**：像 `codeagent-wrapper` 这样的工具是**外部可执行文件**（位于 `~/.claude/bin/`），不是 Skill。Skill 只能提供指导，无法执行外部 API 调用、网络请求、会话管理等操作，这些必须由外部工具完成。

**核心原则**：

- **稳定性优先**：复杂流程用 Command 定义，确保稳定执行
- **外部工具必须用 Command**：Skill 无法执行外部命令
- **简单场景用 Skill**：减少维护成本，提高灵活性