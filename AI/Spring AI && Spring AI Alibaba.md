## 前期准备  
  
- 本文所需的环境和平台  
>jdk 21  
>   
>node 22.21.1  
>   
>ollama server (本地服务器均可)  
>   
>阿里百炼平台api-key (避免明文使用，建议加入到环境变量)  
>   
>向量数据库 redis-stack (拥有pgsql所有功能 拓展了向量存储功能)  
>   
>向量数据库 pgvector (拥有redis所有功能 拓展了向量存储功能)  
  
  
- pgvector docker 快速安装  
```bash  
docker run -d \  --name pgvector \  --restart unless-stopped \  -p 5432:5432 \  -e POSTGRES_USER=postgres \  -e POSTGRES_PASSWORD=postgres \  -v ./data/postgresql:/var/lib/postgresql/data \  pgvector/pgvector:pg16```  
或者 docker compose  
```yml  
services:  
  pgvector:    image: pgvector/pgvector:pg16    container_name: pgvector    restart: unless-stopped    ports:      - "5432:5432"    volumes:      - ./data/postgresql:/var/lib/postgresql/data      #- ./conf/postgresql.conf:/var/lib/postgresql/data/postgresql.conf      #- ./conf/pg_hba.conf:/var/lib/postgresql/data/pg_hba.conf    environment:      # POSTGRES_DB: postgres      POSTGRES_USER: postgres      POSTGRES_PASSWORD: postgres  
```  
  
- redis-stack docker 快速安装  
```bash  
docker run -d \  --name redis-stack \  --restart unless-stopped \  -p 6380:6379 \  -p 18001:8001 \  -v ./data/redis:/data \  redis/redis-stack:latest```  
或者docker compose  
```yml  
services:  
  redis-stack:    image: redis/redis-stack:latest    container_name: redis-stack    restart: unless-stopped    ports:      - "6380:6379"      - "18001:8001"   
    volumes:  
      - ./data/redis:/data      # - ./config/redis-stack.conf:/redis-stack.conf:ro    # command: ["redis-server", "/redis-stack.conf"]    healthcheck:      test: ["CMD", "redis-cli", "ping"]      interval: 10s      timeout: 5s      retries: 3  
```  
  
  
## 一、基础问答  
这里的基础问答指的是 **无状态** 的、一次性的问答交互。  
在这种模式下，每一次用户请求都被视为一个独立的会话，模型在处理当前问题时，不会保留或记住之前任何一次交互的内容和上下文。  
  
### 1.1 依赖  
基础对话所需依赖项目  
```xml  
    <dependencies>        <dependency>            <groupId>org.springframework.boot</groupId>            <artifactId>spring-boot-starter-web</artifactId>        </dependency>        <!--spring-ai-alibaba dashscope-->        <dependency>            <groupId>com.alibaba.cloud.ai</groupId>            <artifactId>spring-ai-alibaba-starter-dashscope</artifactId>        </dependency>        <!--ollama-->        <!--        <dependency>            <groupId>org.springframework.ai</groupId>            <artifactId>spring-ai-starter-model-ollama</artifactId>            <version>1.0.0</version>        </dependency>        -->        <!--lombok-->        <dependency>            <groupId>org.projectlombok</groupId>            <artifactId>lombok</artifactId>            <optional>true</optional>        </dependency>        <!--hutool-->        <dependency>            <groupId>cn.hutool</groupId>            <artifactId>hutool-all</artifactId>            <version>5.8.22</version>        </dependency>        <dependency>            <groupId>org.springframework.boot</groupId>            <artifactId>spring-boot-starter-test</artifactId>            <scope>test</scope>        </dependency>    </dependencies>  
```  
  
### 1.2 配置api key  
获取api key ： [获取地址](https://bailian.console.aliyun.com/?apiKey=1&tab=api#/api)  
```yml  
spring:  
  datasource:    url: jdbc:postgresql://127.0.0.1:5432/postgres    username: postgres    password: postgres    driver-class-name: org.postgresql.Driver  application:    name: chat-memory  data:    redis:      host: localhost      port: 6379      password:      database: 1      connect-timeout: 3      timeout: 3  ai:    # ====SpringAIAlibaba Config=============    dashscope:      # 必选 配置环境变量 DASH_SCOPE_API_KEY=你的apiky  
      api-key: ${DASH_SCOPE_API_KEY}      # 可选   
      base-url: "https://dashscope.aliyuncs.com/compatible-mode/v1"  
      # 可选，可在config中配置多个模型  
      chat:        options:          model: "qwen-plus-2025-09-11"     # ====SpringAI Config=============    #openai:      #api-key: ${OPENAI_API_KEY}      #base-url: "https://api.openai.com/v1"      #chat:        #ptions:          #model: "gpt-3.5-turbo"  
```  
  
  
### 1.3 ChatModel 方式  
`ChatModel` 是 Spring AI 提供的最低级别、最基础的抽象接口，用于与底层大语言模型（LLM）进行交互。  
#### 1.3.1 创建ChatModel  
```java  
    @Bean    public DashScopeApi dashScopeApi() {        return DashScopeApi.builder()                .apiKey(System.getenv("DASH_SCOPE_API_KEY"))                .build();    }  
```  
#### 1.3.2 基础使用  
使用 `ChatModel` 实现消息的流式返回和阻塞返回  
```java  
@RestController  
@RequestMapping("/chat")  
public class ChatHelloController {  
    @Resource  
    private ChatModel chatModel;  
    @GetMapping(value = "/block")  
    public String doChat(@RequestParam(name = "question", defaultValue = "你是谁") String question) {  
        return chatModel.call(question);  
    }    @GetMapping(value = "/stream")  
    public Flux<String> stream(@RequestParam(name = "question", defaultValue = "你是谁") String question) {  
        return chatModel.stream(question);  
    }}  
```  
  
### 1.4 ChatClient 使用  
`ChatClient` 是 Spring AI 应用程序中最常用的交互接口。它在底层 `ChatModel` 之上提供了易用性、集成性和扩展性，让开发者能够专注于业务逻辑，而不是底层 API 的细节。  
#### 1.4.1 官方解释  
`ChatClient` 提供了与 AI 模型通信的 Fluent API，它支持同步和反应式（Reactive）编程模型。与 `ChatModel`、`Message`、`ChatMemory` 等原子 API 相比，使用 `ChatClient` 可以将与 LLM 及其他组件交互的复杂性隐藏在背后，因为基于 LLM 的应用程序通常要多个组件协同工作（例如，提示词模板、聊天记忆、LLM Model、输出解析器、RAG 组件：嵌入模型和存储），并且通常涉及多个交互，因此协调它们会让编码变得繁琐。当然使用 `ChatModel` 等原子 API 可以为应用程序带来更多的灵活性，成本就是您需要编写大量样板代码。  
ChatClient 类似于应用程序开发中的服务层，它为应用程序直接提供 `AI 服务`，开发者可以使用 ChatClient Fluent API 快速完成一整套 AI 交互流程的组装。  
  
包括一些基础功能，如：  
- 定制和组装模型的输入（Prompt）  
- 格式化解析模型的输出（Structured Output）  
- 调整模型交互参数（ChatOptions）  
  
还支持更多高级功能：  
- 聊天记忆（Chat Memory）  
- 工具/函数调用（Function Calling）  
- RAG  
  
#### 1.4.2 创建ChatClient  
`ChatClient` 默认情况下不会被 Spring Boot 自动配置为可直接 `@Autowired` 或 `@Resource` 注入的 `Bean`。 这是因为 `ChatClient` 需要通过其 `Builder` 模式来构建，并且必须依赖于一个或多个底层 `ChatModel` 实例。  
有两种注入方式  
  
1. 自定义 `@Bean` (推荐方式)  
  
   这是最常用且最符合 Spring 规范的做法。通过定义一个 `@Bean` 方法，您可以清晰地指定 `ChatClient` 依赖于哪个具体的 `ChatModel`（例如，这里依赖于 `dashscopeChatModel`），并可以在构建时应用默认配置（如默认系统指令、默认工具等）。  
```java  
@Bean  
public ChatClient chatClient(ChatModel dashscopeChatModel) {  
    return ChatClient.builder(dashscopeChatModel).build();}  
```  
2. 构造方法注入依赖并手动构建  
  
   这种方式适用于您只想在特定组件中使用 `ChatClient`，而不希望将其暴露为全局 `Bean` 的场景。您可以在组件的构造函数中注入所需的 `ChatModel`，然后手动完成 `ChatClient` 的构建。  
```java  
private final ChatClient dashScopeChatClient;  
public ChatClientController(ChatModel dashScopeChatModel) {  
    this.dashScopeChatClient = ChatClient.builder(dashScopeChatModel).build();}  
```  
  
#### 1.4.3 基础使用  
使用 `ChatClient` 实现消息的流式返回和阻塞返回  
```java  
@Resource  
private ChatClient dashScopeChatClient;  
@GetMapping("/client")  
public String chatClientBlock(@RequestParam(name = "question", defaultValue = "2加9等于几") String question) {  
    return dashScopeChatClient.prompt().user(question).call().content();  
}  
@GetMapping("/client")  
public Flux<String> chatClientStream(@RequestParam(name = "question", defaultValue = "2加9等于几") String question) {  
    return dashScopeChatClient.prompt().user(question).stream().content();  
}  
```  
  
### 1.5 使用本地模型(ollama) 实现基础对话  
选择本地模型是为了在数据隐私、离线运行、长期免费和低延迟方面取得优势，特别适用于不能联网或对敏感数据有严格要求的项目。  
#### 1.5.1 引入依赖  
  
```xml  
<!--ollama-->  
<dependency>  
    <groupId>org.springframework.ai</groupId>    <artifactId>spring-ai-starter-model-ollama</artifactId>    <version>1.0.0</version></dependency>  
```  
  
#### 1.5.2 编辑配置  
```yml  
spring:  
  application:    name: ollama  ai:    ollama:      base-url: "http://192.168.187.166:11434"      chat:        model: "qwen3:8b"  
```  
  
#### 1.5.3 基础使用  
`ChatModel` && `ChatClient` 流试阻塞方式调用。  
```java  
    @Resource    private ChatModel chatModel;    
        
    public final ChatClient chatClient;    
    public OllamaController(ChatClient.Builder builder) {    
        this.chatClient = builder.build();    
    }  
  
    // ChatModel 方式  
    @GetMapping("/stream")    public Flux<String> stream(@RequestParam(name = "question", defaultValue = "你是谁") String question) {  
        // 阻塞方式  
        //return chatModel.call(question);        // 流式方式  
        return chatModel.stream(question);    }        // ChatClient方式  
    @GetMapping("/client")    public Flux<String> client(@RequestParam(name = "question", defaultValue = "你是谁") String question) {  
        // 阻塞方式  
        //return chatClient.prompt().user(question).call().content();        // 流式方式  
        return chatClient.prompt().user(question).stream().content();    }  
```  
### 1.6 多模型共存  
多模型共存是为了实现成本、性能和合规性的最佳平衡，允许项目根据任务需求灵活选择和切换本地、线上或不同厂商的模型。  
  
`ChatClient` 通过 `ChatModel` 创建，`ChatModel`（对于spring-ai-alibaba来说）也可通过`DashScopeChatModel` 创建不同模型的`ChatModel`，外部的依赖也可以引入相关的`ChatModel`如`ollama`。 这样我门就可以在一个项目中使用多个模型。下面是示例：  
```java  
@Configuration  
public class SaaLLMConfig {  
    private final String DEEPSEEK_MODEL = "deepseek-v3.1";    private final String QWEN_MODEL = "qwen-plus-2025-09-11";    @Bean(name = "deepseek")  
    public ChatModel deepSeek() {  
        return DashScopeChatModel.builder()                .dashScopeApi(DashScopeApi.builder().apiKey(System.getenv("DASH_SCOPE_API_KEY")).build())  
                .defaultOptions(DashScopeChatOptions.builder().withModel(DEEPSEEK_MODEL).build())  
                .build();    }  
    @Bean(name = "qwen")  
    public ChatModel qwen() {  
        return DashScopeChatModel.builder()                .dashScopeApi(DashScopeApi.builder().apiKey(System.getenv("DASH_SCOPE_API_KEY")).build())  
                .defaultOptions(DashScopeChatOptions.builder().withModel(QWEN_MODEL).build())  
                .build();    }  
    @Bean(name = "deepseekChatClient")  
    public ChatClient deepseekChatClient(@Qualifier("deepseek") ChatModel deepseek) {  
        return ChatClient.builder(deepseek)                        .defaultOptions(ChatOptions.builder().model(DEEPSEEK_MODEL).build())  
                        .build();    }  
    @Bean(name = "qwenChatClient")  
    public ChatClient qwenChatClient(@Qualifier("qwen") ChatModel qwen) {  
        return ChatClient.builder(qwen)                        .defaultOptions(ChatOptions.builder().model(QWEN_MODEL).build())  
                        .build();    }  
    @Bean(name = "ollamaChatClient")  
    public ChatClient ollamaChatClient(@Qualifier("ollamaChatModel") ChatModel ollama) {  
        return ChatClient.builder(ollama)                .defaultOptions(ChatOptions.builder().model("qwen3:8b").build())                .build();    }}  
```  
  
  
  
## 二、记忆存储  
  
**记忆存储**是为了打破基础对话的**无状态限制**，使 AI Agent 能够**记住先前交互的上下文**，从而实现连贯且自然的**多轮对话**。  
  
---  
  
这里主要介绍 **redis** 和 **postgres** 两种方式作为记忆存储方式，其他类型的存储方式请参考 spring-ai 文档，这不需要向量库，普通的redis和postgres就可以。  
  
### 2.1 引入依赖  
````xml  
    <!--spring-ai-alibaba dashscope-->    <dependency>        <groupId>com.alibaba.cloud.ai</groupId>        <artifactId>spring-ai-alibaba-starter-dashscope</artifactId>    </dependency>    <!-- redis 存储所需依赖 经过spring ai alibaba 又封装了一层 -->    <!--spring-ai-alibaba memory-redis-->    <dependency>        <groupId>com.alibaba.cloud.ai</groupId>        <artifactId>spring-ai-alibaba-starter-memory-redis</artifactId>    </dependency>    <!--jedis-->    <dependency>        <groupId>redis.clients</groupId>        <artifactId>jedis</artifactId>    </dependency>    <!--  postgresql 存储所需依赖 没有封装的 spring ai 原生支持的 -->    <!--spring-ai memory-jdbc-->    <dependency>        <groupId>org.springframework.ai</groupId>        <artifactId>spring-ai-starter-model-chat-memory-repository-jdbc</artifactId>    </dependency>    <dependency>        <groupId>org.postgresql</groupId>        <artifactId>postgresql</artifactId>        <version>42.5.0</version>    </dependency>  
````  
  
### 2.2 添加配置  
```yml  
spring:  
  datasource:    url: jdbc:postgresql://127.0.0.1:5432/postgres    username: postgres    password: postgres    driver-class-name: org.postgresql.Driver  application:    name: chat-memory  data:    redis:      host: localhost      port: 6379      password:      database: 1      connect-timeout: 3      timeout: 3  ai:    chat:      memory:        repository:          jdbc:            initialize-schema: always  
```  
  
### 2.3 构造Bean  
文档中主要介绍ollama + Jdbc存储方式，其他方式chat-memory模块中有示例代码。  
#### 2.3.1 配置 JDBC 聊天记忆仓库（PostgresMemoryConfig）  
 这个配置类负责创建并注册 `JdbcChatMemoryRepository` 实例，它依赖于 Spring Boot 自动配置的 `JdbcTemplate` 来与 PostgreSQL 数据库交互。  
```java  
@Configuration  
public class PostgresMemoryConfig {  
    // 依赖注入：通过构造函数获取 JdbcTemplate    private final JdbcTemplate jdbcTemplate;  
    // 推荐使用构造函数注入，确保依赖不可变  
    public PostgresMemoryConfig(JdbcTemplate jdbcTemplate) {  
        this.jdbcTemplate = jdbcTemplate;    }    /**     * 定义 JdbcChatMemoryRepository Bean。  
     * 它是 ChatMemoryRepository 接口的实现，负责将聊天记录存储到数据库中。  
     *     * @return 配置好的 JdbcChatMemoryRepository 实例  
     */    @Bean  
    // 标记为 @Primary 以解决可能的歧义，确保在需要默认 ChatMemoryRepository 时优先选择 JDBC 实现。  
    @Primary  
    public JdbcChatMemoryRepository jdbcChatMemoryRepository() {  
        return JdbcChatMemoryRepository.builder()                // 注入之前获取的 JdbcTemplate                .jdbcTemplate(jdbcTemplate)  
                .build();    }}  
```  
**关键点解释：** - `@Primary`: 该注解用于解决歧义性。当应用中存在多个 `ChatMemoryRepository` 接口的实现（例如，同时存在 `JDBC` 和 `Redis` 实现）时，`@Primary`告诉 Spring，这是默认或首选的实现。  
  
  
#### 2.3.2 集成到 ChatClient（SaaLLMConfig）  
   这个配置类展示了如何将上一步定义的聊天记忆仓库连接到特定的 ChatModel（此处为 Ollama），从而为该模型提供有状态（带记忆）的会话能力。  
```java  
@Configuration  
public class SaaLLMConfig {  
    private final String OLLAMA_MODEL = "qwen3:8b";    /**     * 定义 Ollama 聊天客户端 Bean，并集成 JDBC 聊天记忆。  
     *     * @param ollamaChatModel 依赖注入的 Ollama ChatModel 实例 (使用 @Qualifier 区分)  
     * @param jdbcChatMemoryRepository 依赖注入的 JDBC 聊天记忆仓库  
     * @return 配置了记忆功能的 ChatClient 实例  
     */    @Bean(name = "ollamaChatClient")  
    public ChatClient ollamaChatClient(@Qualifier("ollamaChatModel") ChatModel ollamaChatModel,  
                                       JdbcChatMemoryRepository jdbcChatMemoryRepository) {        // 1. 构造 MessageWindowChatMemory（消息窗口记忆）  
        // 它负责维护一个固定大小（窗口）的对话历史。  
        MessageWindowChatMemory windowChatMemory = MessageWindowChatMemory                .builder()                // 关联具体的持久化仓库（这里是 JDBC）  
                .chatMemoryRepository(jdbcChatMemoryRepository)                // 设置最大消息数，超过此限制旧消息将被移除  
                .maxMessages(100)                .build();        // 2. 构造 ChatClient        return ChatClient                .builder(ollamaChatModel)                // 设置默认模型选项  
                .defaultOptions(ChatOptions.builder().model(OLLAMA_MODEL).build())  
                // 添加 MessageChatMemoryAdvisor，它是实现记忆功能的核心组件  
                // Advisor 会在每次请求时读取历史记录，并在响应后写入新记录。  
                .defaultAdvisors(MessageChatMemoryAdvisor.builder(windowChatMemory).build())                .build();    }}  
```  
**关键组件解释：**  
- **`MessageWindowChatMemory`**: **记忆策略**。它定义了如何管理对话历史，例如只保留最近的 N 条消息（此处为 100 条）。  
  
- **`jdbcChatMemoryRepository`**: **记忆仓库 (Repository)**。它是 `MessageWindowChatMemory` 实际存储和读取数据的地方（PostgreSQL 数据库）。  
  
- **`MessageChatMemoryAdvisor`**: **AOP 切面/建议器**。它是 Spring AI 机制的核心，负责在 ChatModel 调用前后自动执行记忆的**读取**和**写入**操作，从而将无状态的模型调用转化为有状态的对话。  
  
### 2.4 记忆对话交互  
为了确保多用户和多会话之间记忆的隔离性和准确性，我们需要在每次调用时，向 `ChatClient` 明确传递一个唯一的会话标识符。Spring AI 通过 `ConversationHistoryAdvisor`（在底层自动启用）和 `CONVERSATION_ID` 参数来实现这一点。  
```java  
@RestController  
@RequestMapping("/memory")  
public class ChatMemoryController {  
    @Resource(name = "ollamaChatClient")  
    private ChatClient ollamaChatClient;  
    @GetMapping("/chat3")  
    public Flux<String> ollamaMemory(@RequestParam(name = "question", defaultValue = "1+1等于几") String question,  
                                     String userId,                                     String conversationId) {        return ollamaChatClient.prompt(question).advisors(  
                        // 构造唯一的会话标识符  
                        advisorSpec -> advisorSpec.param(CONVERSATION_ID, userId + "-" + conversationId))  
                .stream().content();    }}  
  
```  
  
### 2.5 其他记忆方式说明  
除了 JDBC 外，chat-memory 模块还支持其他几种持久化方式。  
除了 JDBC 外，`chat-memory` 模块还支持其他几种持久化方式。您可以参考项目中的示例代码来配置：  
  
|**记忆仓库**|**描述**|**适用场景**|  
|---|---|---|  
|**`RedisChatMemoryRepository`**|使用 Redis 存储。|高并发、需要低延迟读写、数据量适中。|  
|**`InMemoryChatMemoryRepository`**|数据存储在应用程序内存中。|测试、开发环境；不适合生产环境（数据不持久化）。|  
  
您只需要替换 `jdbcChatMemoryRepository` 为相应的实现，并在其 Bean 上添加 `@Primary` (如果需要) 即可  
  
## 三、提示词  
提示词（Prompt）是与大语言模型（LLM）交互的核心载体和指令集。它本质上是提供给模型的一段输入文本，用于引导模型执行特定的任务、遵循特定的规则，并产生期望的输出。  
  
在 Spring AI 中，与大型语言模型（LLM）的交互是通过 **`Prompt`** 对象完成的，而 `Prompt` 内部由一系列不同角色的 **消息 (Message)** 组成。掌握这些消息类型是精确控制模型行为的关键。  
  
### 3.1 消息类型  
  
| **消息类型**               | **角色 (Role)**  | **目的**                                     | **使用场景**                                                                                                                                    |  
| ---------------------- | -------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |  
| **`SystemMessage`**    | System (系统)    | 设定模型的**身份、行为、约束**和**通用指令**。它定义了 LLM 的“人设”。 | **设定角色：** “你是一个法律助手”。 **格式要求：** “请以 JSON 格式返回”。                                                                                             |  
| **`UserMessage`**      | User (用户)      | 包含用户的**实际问题、请求或输入**。                       | 用户的提问、指令。                                                                                                                                   |  
| **`AssistantMessage`** | Assistant (助手) | 包含模型**历史的回复**。                             | 用于在构建 `Prompt` 时，手动加入历史对话（通常由 `ChatMemory` 自动管理）。                                                                                           |  
| **`ToolMessage`**        | Tool (工具)      | 包含 LLM 请求调用的**外部工具执行后的结果或输出**。             | LLM 决定调用一个函数（例如：`get_weather(location)`）。<br>应用执行该函数得到结果（例如：`{"temperature": "25°C"}`）。<br>**`ToolMessage`** 将这个结果反馈给 LLM，让其基于此结果生成最终的用户回复。 |  
  
### 3.2 使用示例
下面分别是 `ChatClient` 和 `ChatModel` 的使用方式：  
```java  
@RestController  
@RequestMapping("/prompt")  
public class PromptController {  
    @Resource(name = "deepseek")  
    private ChatModel deepseekChatModel;  
    @Resource(name = "deepseekChatClient")  
    private ChatClient deepseekChatClient;  
  
    @GetMapping("/law")  
    public Flux<String> law(@RequestParam(name = "question", defaultValue = "你是谁") String question) {  
        return deepseekChatClient.prompt()  
                // 能力边界  
                .system("你是一个法律助手，只回答法律问题，其它问题回复，我只能回答法律相关问题，其它无可奉告")  
                .user(question)                .stream()                .content();    }    @GetMapping("/story/html")  
    public Flux<String> storyHtml(@RequestParam(name = "question", defaultValue = "讲个故事") String question) {  
        // 系统消息  
        SystemMessage systemMessage = new SystemMessage("你是一个讲故事的助手,每个故事控制在600字以内且以HTML格式返回");  
        // 用户消息  
        UserMessage userMessage = new UserMessage(question);        Prompt prompt = new Prompt(userMessage, systemMessage);        return deepseekChatModel.stream(prompt)  
                .mapNotNull(response ->                        response.getResults().getFirst().getOutput().getText()                );    }}  
```  
  
### 3.3 提示词模板  
**提示词模板**是 Spring AI 中用于创建动态、可复用提示词的核心工具。它允许开发者将固定的指令（如角色设定、格式要求）与动态的运行时参数（如用户输入、主题、字数）结合起来，从而灵活地构造出发送给 LLM 的 `Prompt` 对象。  
  
| **类名**                         | **描述**                                               | **作用**                                   |  
| ------------------------------ | ---------------------------------------------------- | ---------------------------------------- |  
| **`PromptTemplate`**           | 最基础的模板类，用于构造 **`UserMessage`** 或简单的**单条 `Message`**。 | 接收一个包含占位符（如 `{topic}`）的字符串，并根据 Map 参数填充。 |  
| **`SystemPromptTemplate`**     | 专用于构造 **`SystemMessage`** 的模板类。                      | 确保生成的 `Message` 具有系统角色的语义，用于设置模型身份或约束。   |  
| **`@Value("classpath:/...")`** | Spring Resource Loader。                              | 允许将复杂的提示词内容存储在外部文件（如 `.txt`）中，使代码更清晰。    |  
  
#### 3.3.1 使用示例  
##### 3.3.1.1 字符串内联模板  
```java  
public Flux<String> story() {  
    // 模板定义在代码中  
    PromptTemplate promptTemplate = new PromptTemplate(                     "讲一个关于{topic}的故事" +  
                    "并以{output_format}格式输出，" +  
                    "字数在{word_count}左右");  
    // 创建 Prompt 对象  
    Prompt prompt = promptTemplate.create(Map.of(            "topic", topic,            "output_format", outputFormat,            "word_count", wordCount));    // 流式调用  
    return deepseekChatClient.prompt(prompt).stream().content();}  
```  
- **特点：** 最直接的使用方式，适用于模板内容较短的场景。  
  
- **调用方式：** 使用 `ChatClient.prompt(Prompt)` 进行流式调用 (`.stream().content()`)，简洁高效。  
##### 3.3.1.2 外部文件模板  
此示例展示了如何将模板内容外置到文件 (`template.txt`) 中，并通过 Spring Resource 加载。  
```java  
@Value("classpath:/prompt-template/template.txt")  
private org.springframework.core.io.Resource userTemplate;  
public Flux<String> story() {  
    // 使用 Resource 构造 PromptTemplate    PromptTemplate promptTemplate = new PromptTemplate(userTemplate);  
    // 创建 Prompt 对象  
    Prompt prompt = promptTemplate.create(Map.of("topic", topic, "output_format", outputFormat, "word_count", wordCount));  
    // 流式调用 (使用 ChatModel)    return deepseekChatModel.stream(prompt).mapNotNull(            chatResponse -> chatResponse.getResult().getOutput().getText()    );}  
```  
- **特点：** 模板内容（如故事格式、字数要求）存储在外部文件，便于维护和修改，代码更整洁。  
  
- **调用方式：** 使用 `ChatModel.stream(Prompt)`，需要手动通过 `.mapNotNull(...)` 提取文本内容。  
##### 3.3.1.3 系统模板 + 用户模板  
此示例是最完整的提示词构建模式，它分离了系统指令和用户输入，分别使用对应的模板类构建消息，最后组合成一个 `Prompt`。  
```java  
public Flux<String> story() {  
    // 1. SystemPromptTemplate：创建 SystemMessage    SystemPromptTemplate systemPromptTemplate = new SystemPromptTemplate("你是{system_topic}助手，只回答{system_topic}其它无可奉告，以HTML格式的结果。");  
    Message sysMessage = systemPromptTemplate.createMessage(Map.of("system_topic", sysTopic));    // 2. PromptTemplate：创建 UserMessage    PromptTemplate userPromptTemplate = new PromptTemplate("解释一下{user_topic}");  
    Message userMessage = userPromptTemplate.createMessage(Map.of("user_topic", userTopic));    // 3. 组合：将 SystemMessage 和 UserMessage 组合成 Prompt    Prompt prompt = new Prompt(List.of(sysMessage, userMessage));    // 4. 调用 LLM    return deepseekChatModel.stream(prompt).mapNotNull(            chatResponse -> chatResponse.getResult().getOutput().getText()    );}  
```  
  
## 四、结构化输出  
  
**结构化输出**功能允许开发者定义 Java 对象（如 `Record` 或 POJO）的结构，并让 LLM 的回复直接映射到该对象实例上。这通过将 JSON Schema 注入到提示词中实现，有效地将 LLM 的文本生成任务转化为**数据生成任务**  
### 4.1 核心机制与优势  
| **机制**             | **描述**                                                                                                   | **优势**                          |  
| ------------------ | -------------------------------------------------------------------------------------------------------- | ------------------------------- |  
| **JSON Schema 注入** | Spring AI 库将目标 Java 类（例如 `StudentRecord.class`）转化为 **JSON Schema** 定义，并将其作为 `SystemMessage` 的一部分发送给 LLM。 | 强制模型输出符合该 Schema 的 JSON 字符串。    |  
| **数据绑定**           | LLM 返回 JSON 字符串后，Spring AI 自动将该 JSON 字符串反序列化（Deserialization）绑定到您指定的 Java 类实例上。                          | 无需手动编写 JSON 解析代码，确保数据的类型安全和准确性。 |  
| **`Record` 类支持**   | 推荐使用 Java 14+ 的 `Record` 类型，它们简洁、不可变且自动提供了构造函数和访问器。                                                      | 简化数据模型的创建。                      |  
### 4.2 使用示例  
**前提：数据模型定义 (StudentRecord)**  
  
假设您有一个用于接收结构化数据的 Java Record 类（或其他 POJO）：  
```java  
// 假设 StudentRecord 包含 LLM 需要填充的字段  
public record StudentRecord(  
    String id,    String name,   
    String major,   
    String email  
) {}  
```  
```java  
@RestController  
@RequestMapping("/struct")  
public class StructureOutputController {  
    @Resource(name = "qwenChatClient")  
    private ChatClient qwenChatClient;  
  
    @GetMapping("/chat2")  
    public StudentRecord chat2(@RequestParam(name = "name", defaultValue = "王一狗") String name,  
                               @RequestParam(name = "email", defaultValue = "ice@jlau.com") String email) {  
        String stringTemplate = """                学号1002，我叫{name},大学专业软件工程,邮箱{email}  
                """;        return qwenChatClient.prompt()  
                .user(                        promptUserSpec ->                                // 这里的参数 name 和 email 会被替换成对应的值，但并不是返回的值，具体的值还需靠模型的理解能力。  
                                promptUserSpec.text(stringTemplate).param("name", name).param("email", email)  
                        // 这里返回的结果主要靠模型的理解能力，所以结果可能不准确，可以拿下面的例子测试一下。  
                        //promptUserSpec.text("学号001，我是武汉市长江大桥,大学专业计算机科学与技术,邮箱xxx.ice@gmail.com")  
                        //promptUserSpec.text("学号001，我是李四不对我是张三的哥哥王五的弟弟武汉市长江大桥的哥哥王麻子的叔叔你爸爸,大学专业计算机科学与技术,邮箱xxx.ice@gmail.com")  
                        //promptUserSpec.text("学号001，我是李四不对我是张三,大学专业计算机科学与技术,邮箱xxx.ice@gmail.com")  
                        //promptUserSpec.text("学号001，我是李四李四的爸爸李鬼,大学专业计算机科学与技术,邮箱xxx.ice@gmail.com")  
                )                .call()                .entity(StudentRecord.class); // 指定返回的结构化 Java 对象类型  
    }}  
```  
### 4.3 注意事项  
- **模型能力依赖**：结构化输出的成功率高度依赖于底层 LLM（如 Qwen-Plus/GPT-4 等）对 **JSON Schema** 和 **函数调用（Function Calling）** 的支持及理解能力。对于较弱的模型，结果可能不准确或返回非 JSON 文本。  
- **提示词质量**：用户提示词（`stringTemplate`）应包含足够且明确的信息，以便模型能够准确地将信息提取并映射到 `StudentRecord` 的字段上。  
  
## 五、文本向量化 存储 检索  
文本向量化（也称为文本嵌入，Embedding）是将人类可读的文本信息转换为计算机可以理解和处理的数值形式（即高维向量）的过程。  
文本向量化将文本的含义（语义）映射到向量空间中的位置。在向量空间中，语义相似的词语或句子（例如“狗”和“宠物”）会彼此靠近，而语义不相关的会彼此远离。  
传统的全文检索（如关键词匹配）无法理解“意思”。通过向量化，我们可以计算用户问题向量与知识库中文本向量的距离（相似度），从而实现基于含义的检索，这是 RAG 机制的基石。  
将文本转换为向量后，计算机可以使用成熟的线性代数和距离算法（如余弦相似度）进行快速、大规模的量化分析和搜索，极大地提高了处理效率。  
  
### 5.1 前提条件  
1. 准备向量数据库实例：  
- 你需要准备至少一种向量数据库  
   您需要准备一个正在运行的向量数据库实例，例如：  - **PostgreSQL + PgVector 扩展**  
  - **Redis + RediSearch 模块**  
  - **Chroma、Milvus** 等专用向量数据库。  
- 安装要求： 请确保您已按照先前文档或官方指南完成了所选数据库的安装和配置。  
2. 准备 **Embedding** 模型 (Embedding Model)：  
- 向量存储要求将文本数据转换为数值向量（即嵌入）。因此，您必须配置一个可用的 Embedding 模型：  
    - **Ollama Embedding Model：** 适合本地开发和测试。  
    - **DashScope Embedding Model：** 阿里云通义千问的 Embedding 服务。  
    - **OpenAI、Mistral** 等其他供应商的 Embedding 模型。  
  
- **配置要求：** 确保您的 `application.properties`/`application.yml` 中已配置相应的 API Key 或 Base URL。  
  
### 5.2 相关依赖  
```xml  
<!-- 添加 Redis (RedisStack) 向量数据库依赖 --><dependency>  
    <groupId>org.springframework.ai</groupId>    <artifactId>spring-ai-starter-vector-store-redis</artifactId></dependency>  
<!-- 添加 postgres 向量数据库依赖 --><dependency>  
    <groupId>org.springframework.ai</groupId>    <artifactId>spring-ai-starter-vector-store-pgvector</artifactId></dependency>  
<!-- ollama -->  
<dependency>  
    <groupId>org.springframework.ai</groupId>    <artifactId>spring-ai-starter-model-ollama</artifactId>    <version>1.0.0</version></dependency>  
```  
  
### 5.3 相关配置  
```yaml  
spring:  
  application:    name: vector  # pgvector (不是普通的postgres)  
  datasource:    url: jdbc:postgresql://127.0.0.1:5432/postgres    username: postgres    password: postgres    driver-class-name: org.postgresql.Driver  data:    # redis stack (不是普通的redis)  
    redis:      host: localhost      port: 6380      database: 0      connect-timeout: 3      timeout: 3  ai:    dashscope:      api-key: ${DASH_SCOPE_API_KEY}      chat:        options:          model: qwen-plus-2025-09-11      # embedding模型  
      embedding:        options:          model: text-embedding-v4    ollama:      base-url: http://192.168.187.166:11434      # embedding模型  
      embedding:        options:          model: bge-m3:latest    # 向量数据库配置   
    vectorstore:  
      redis:        index-name: custom-index        prefix: custom-prefix        initialize-schema: true      pgvector:        initialize-schema: true        index-type: HNSW        distance-type: COSINE_DISTANCE        dimensions: 1024        max-document-batch-size: 10000  
```  
  
### 5.4 解决多 Vector Store 冲突的方案  
Spring AI 为每个支持的向量数据库提供了 **自动配置（AutoConfiguration）** 类。在配置了相应的连接信息后，这些自动配置类会尝试创建一个名为 **`vectorStore`** 的 Bean。  
  
如果您的项目中同时引入了多个向量数据库的依赖（例如，同时引入了 Redis 和 PgVector 的依赖），Spring Boot 将尝试执行以下操作：  
  
1. **PgVector 自动配置** 尝试注册一个名为 **`vectorStore`** 的 Bean。  
  
2. **Redis 自动配置** 随后也尝试注册一个名为 **`vectorStore`** 的 Bean。  
  
  
由于 Spring Boot 默认禁止覆盖已注册的 Bean 定义，这会导致底层的 **Bean 名称注册冲突**，应用程序会抛出错误并**启动失败**：  
  
> **错误信息示例:** The bean 'vectorStore' ... could not be registered. A bean with that name has already been defined... and overriding is disabled.  
  
**Bean 定义名称冲突**会直接阻止 Spring 容器完成初始化。  
  
**解决方案：手动排除自动配置并创建 Bean**  
  
为了避免这种底层的名称冲突，最健壮的方法是阻止 Spring Boot 自动加载所有冲突的 `VectorStore` 自动配置类，然后手动创建您需要的那个 Bean。  
  
1. **禁用自动配置：** 在主启动类上使用 `@SpringBootApplication(exclude = ...)` 注解，明确禁用冲突的 `AutoConfiguration` 类。  
  
```java  
@SpringBootApplication(exclude = {  
        // 排除 Redis 的自动配置  
        RedisVectorStoreAutoConfiguration.class,        // 排除 PgVector 的自动配置  
        PgVectorStoreAutoConfiguration.class})  
public class VectorApplication {  
    // ...}  
```  
  
2. **手动创建 Bean：** 在您的自定义配置类中，手动创建并注册您想使用的 `VectorStore` 实例（例如 PgVectorStore）。  
  
   因为引入了阿里的DashScope有多个 `EmbeddingModel` ，需要手动指定一些用哪个 `EmbeddingModel`  
```java  
@Configuration  
public class VectorStoreConfig {  
    @Resource  
    @Qualifier("ollamaEmbeddingModel")  
    private EmbeddingModel ollamaEmbeddingModel;  
    @Resource  
    private JedisPooled jedisClient;  
    @Bean("redisVectorStore")  
    public VectorStore redisVectorStore() {  
        return RedisVectorStore.builder(jedisClient, ollamaEmbeddingModel)  
                .indexName("custom-index")                .prefix("custom-prefix:")                .initializeSchema(true)                .vectorAlgorithm(HSNW)                .build();    }    @Bean("pgVectorStore")  
    public VectorStore pgVectorStore(JdbcTemplate jdbcTemplate) {  
        return PgVectorStore.builder(jdbcTemplate, ollamaEmbeddingModel)  
                // 如果不指定默认是public  
                .schemaName("embedding_vector")                .vectorTableName("vector_store")                .dimensions(1024)                .maxDocumentBatchSize(1000)                .build();    }}  
```  
### 5.5 文本向量化实现  
文本向量化的实现原理是通过深度学习模型（即 Embedding Model）将文本输入映射到高维空间中的一个密集数值向量，确保语义相似的文本在向量空间中彼此靠近。  
**示例代码：**  
```java  
@RestController  
@RequestMapping("/vector")  
public class VectorController {  
    @Resource  
    @Qualifier("ollamaEmbeddingModel")  
    private EmbeddingModel ollamaEmbeddingModel;  
    @GetMapping("/text2embed")  
    public EmbeddingResponse text2Embed(@RequestParam(name = "text", defaultValue = "你好") String text) {  
        EmbeddingResponse embeddingResponse = ollamaEmbeddingModel.call(new EmbeddingRequest(List.of(text),  
                DashScopeEmbeddingOptions.builder().withModel("bge-m3:latest").build()));        System.out.println(Arrays.toString(embeddingResponse.getResult().getOutput()));  
        return embeddingResponse;    }}  
```  
  
### 5.6 向量存储  
为什么需要向量存储？向量存储是为了高效地存储和检索大量的高维文本向量，它是实现 RAG（检索增强生成）机制中语义检索功能的核心基础设施。  
  
如果你是 `pgvector`，需要如下检查。需要检查你创建的 `vector` 类型和 `embedding` 模型所使用的向量维度是否一致。  
```sql  
--查看是否有 'vector' 拓展  
SELECT name, default_version, installed_version  
FROM pg_available_extensions  
WHERE name = 'vector';  
-- 当前数据库中创建 vector 拓展。vector 扩展（即 PgVector）提供了 vector 数据类型和相关的索引（如 HNSW、IVFFlat）操作符，是 PostgreSQL 能够存储和高效检索向量数据的核心。  
CREATE  
EXTENSION IF NOT EXISTS vector;  
-- 创建 hstore 扩展。 hstore 扩展提供了用于存储键值对数据的 hstore 数据类型。在 PgVector 存储中，它常被用来存储向量关联的 Metadata（元数据），例如文档来源、作者、时间戳等信息。  
CREATE  
EXTENSION IF NOT EXISTS hstore;  
-- 创建 uuid-ossp 扩展。 该扩展提供了生成 UUID (Universally Unique Identifier) 的函数，例如 uuid_generate_v4()。这在创建表时用作主键，保证每条记录 ID 的唯一性。  
CREATE  
EXTENSION IF NOT EXISTS "uuid-ossp";  
-- 查看名为 'vector' 的扩展是否已经被安装到当前数据库中  
SELECT extname, extversion, extnamespace::regnamespace AS schema  
FROM pg_extension  
WHERE extname = 'vector';  
-- 创建一个名为 vector_store 的表，用于存储您的向量数据。  
CREATE TABLE IF NOT EXISTS vector_store  
(  
    id        uuid DEFAULT uuid_generate_v4() PRIMARY KEY,    content   text,    metadata  json,    embedding vector(1536)    );-- 修改 vector_store 表中 embedding 列的定义。将向量列的期望维度从 1536 修改为 1024。这条语句是用来解决您上一个错误 "expected 1536 dimensions, not 1024" 的核心操作。它确保数据库的表结构与您的 Embedding Model (Ollama/DashScope) 实际生成的 1024 维向量相匹配。  
ALTER TABLE vector_store  
ALTER COLUMN embedding TYPE vector(1024);  
```  
**示例代码：**  
```java  
public void add() {  
    List<Document> documents = List.of(            new Document("咖啡豆的最佳烘焙温度通常在 200°C 左右。"),  
            new Document("今天的会议将在下午三点开始，主要讨论季度预算。"),  
            new Document("大型语言模型（LLM）在自然语言处理领域取得了突破性进展。"),  
            new Document("我最喜欢在清晨的湖边散步，那里的空气十分清新。"),  
            new Document("红烧肉的秘诀在于小火慢炖和适量的冰糖。"),  
            new Document("向量数据库是存储和检索高维向量数据的关键技术。"),  
            new Document("如何通过梯度下降法优化神经网络的权重？"),  
            new Document("制作美味拿铁的关键是牛奶的完美发泡。"),  
            new Document("机器学习和深度学习是人工智能的两个主要分支。"),  
            new Document("本年度的财务报告将于本周五前提交给董事会审阅。"));  
    // 使用redis stack存储  
    redisVectorStore.add(documents);    // 使用pgvector 存储  
    pgVectorStore.add(documents);}  
```  
  
### 5.7 相似度检索  
**相似度检索**的原理是计算用户查询文本（已向量化）与向量存储中所有文档向量之间的**距离或夹角**（如余弦相似度），以找出向量空间中**距离最近**（即语义最相关）的 $k$ 个文档片段。  
  
**使用示例：**  
  
该示例展示了如何使用 SearchRequest 向配置好的 Redis 和 PgVector 向量存储发起检索请求，并获取最相似的 Top K 文档。  
```java  
public Map<String, List<Document>> getAll(@RequestParam(name = "text", defaultValue = "AI 技术的核心发展方向是什么？") String text) {  
    SearchRequest searchRequest = SearchRequest.builder().query(text).topK(2).build();    redisVectorStore.similaritySearch(searchRequest);    pgVectorStore.similaritySearch(searchRequest);    HashMap<String, List<Document>> map = new HashMap<>();    map.put("redisVectorStore", redisVectorStore.similaritySearch(searchRequest));    map.put("pgVectorStore", pgVectorStore.similaritySearch(searchRequest));    return map;}  
```  
## 六、RAG增加检索  
上面我们已经实现了**向量存储**和**向量检索**的基础，下面我们将核心实现**RAG（Retrieval-Augmented Generation）**，即给大模型外挂一个自定义“知识库”。  
  
RAG的流程是：用户提出问题后，系统先从知识库中检索出**最相关**的内容片段（即**Context**），然后将这些内容和用户的问题一起喂给大模型（LLM），引导大模型基于这些上下文来生成回答。  
  
依赖和配置与之前相同，此处不再赘述。  
  
### 6.1 知识库内容示例  
我们将使用以下自定义运维错误码作为我们的知识库：  
`classpath:/knowledge-base/ops.txt`位置的文本内容如下  
```text  
00000 系统OK正确执行后的返回  
A0001 用户端错误一级宏观错误码  
A0100 用户注册错误二级宏观错误码  
B1111 支付接口超时  
C2222 Kafka消息解压严重  
```  
正常情况下，大模型并不知道我们自定义的这些错误码的含义。通过 RAG 机制，我们可以确保大模型在回答相关问题时能够查阅并引用这些专业知识。  
### 6.2 知识库加载与向量存储初始化  
这一步骤负责将本地的知识文本（`ops.txt`）读取、分割、并将其嵌入（Embedding）后存入向量数据库（这里是 PostgreSQL 和 Redis），以便后续进行语义检索。  
  
> **核心组件：**  
>  
> - `TextReader`：读取文件内容。  
>  
> - `TokenTextSplitter`：将大块文本分割成适合嵌入的小块 `Document`。  
>  
> - `VectorStore`：存储嵌入后的向量。  
>  
> - **防重复加载机制：** 利用 Redis 的 `setIfAbsent` 确保在服务重启时不会重复加载相同的知识库。  
>  
  
```java  
@Configuration  
public class InitVectorDatabaseConfig {  
    @Resource  
    @Qualifier("pgVectorStore")  
    private VectorStore pgVectorStore;  
    @Resource  
    @Qualifier("redisVectorStore")  
    private VectorStore redisVectorStore;  
    private final RedisTemplate<String, String> redisTemplate;  
    public InitVectorDatabaseConfig(RedisTemplate<String, String> redisTemplate) {  
        this.redisTemplate = redisTemplate;    }    // 这里是外挂知识库的位置  
    @Value("classpath:/knowledge-base/ops.txt")  
    private org.springframework.core.io.Resource opsFile;  
  
    @PostConstruct  
    public void init() {  
        TextReader textReader = new TextReader(opsFile);  
        textReader.setCharset(Charset.defaultCharset());        List<Document> list = new TokenTextSplitter().transform(textReader.read());        String sourceMetadata = (String) textReader.getCustomMetadata().get("source");        String textHash = SecureUtil.md5(sourceMetadata);        // 为 PostgreSQL 和 Redis 分别设置防重复键  
        String pgRedisKey = "vector-pg:" + textHash;        String redisRedisKey = "vector-redis:" + textHash;        // PostgreSQL 防重复检查  
        Boolean pgFlag = redisTemplate.opsForValue().setIfAbsent(pgRedisKey, "1");  
        if (Boolean.TRUE.equals(pgFlag)) {  
            pgVectorStore.add(list);  
            System.out.println("PostgreSQL 向量数据初始化完成");  
        } else {            System.out.println("PostgreSQL 向量数据已存在，跳过初始化");  
        }        // Redis 防重复检查  
        Boolean redisFlag = redisTemplate.opsForValue().setIfAbsent(redisRedisKey, "1");  
        if (Boolean.TRUE.equals(redisFlag)) {  
            redisVectorStore.add(list);  
            System.out.println("Redis 向量数据初始化完成");  
        } else {            System.out.println("Redis 向量数据已存在，跳过初始化");  
        }    }}  
```  
### 6.3 实现 RAG 检索增强  
我们使用 Spring AI 提供的 `RetrievalAugmentationAdvisor` 来实现 RAG 机制。这个 Advisor 会在发送请求给大模型**之前**自动执行检索，并将检索结果作为上下文（Context）注入到最终的 Prompt 中。  
```java  
public Flux<String> redisRag(String code) {  
    // 1. 定义系统角色和指令  
    String systemInfo = """            你是一个专业的运维工程师,你的任务是根据提供的编码给出对应故障解释。  
            你必须严格根据检索到的知识库内容进行回答,如果知识库中找不到匹配的信息,则回复“抱歉,知识库中未找到该故障码的解释。”  
            """;    // 2. 配置检索增强 Advisor    RetrievalAugmentationAdvisor advisor = RetrievalAugmentationAdvisor.builder()            // 绑定知识库检索器：这里指定使用 RedisVectorStore 进行检索  
            .documentRetriever(VectorStoreDocumentRetriever.builder().vectorStore(redisVectorStore).build())            .build();    // 3. 构建并发送请求  
    return chatClient            .prompt()            .system(systemInfo) // 设置系统角色  
            .user(code)        // 用户提问 (即查询的错误码)  
            .advisors(advisor) // 关键：注入 RAG 检索增强 Advisor            .stream()            .content();}  
```  
  
当用户调用 `redisRag("A0100")` 时：  
  
1. `RetrievalAugmentationAdvisor` 会根据用户输入的 `"A0100"` 到 `redisVectorStore` 中进行**语义检索**。  
  
2. 检索结果（例如：`A0100 用户注册错误二级宏观错误码`）被提取出来，作为 **Context**。  
  
3. Advisor 将 Context、`systemInfo` 和用户问题 `"A0100"` 组合成一个**最终的 Prompt** 发送给大模型。  
  
4. 大模型根据这个增强后的 Prompt，结合 Context 给出准确的回答。  
  
## 七、工具调用  
**工具调用**机制允许大语言模型（LLM）在理解用户的意图后，识别并调用外部定义的函数或服务，从而获取实时信息、执行特定操作或访问外部系统。它极大地扩展了 LLM 的能力边界。  
### 7.1 为什么需要工具调用？  
大模型的知识通常截止于其训练数据的截止日期，它无法：  
1. **获取实时信息：** 例如，当前时间、天气、实时股价等。  
2. **执行外部操作：** 例如，发送邮件、调用支付接口、查询数据库等。  
  
工具调用机制通过以下方式解决了这些限制：  
  
|**机制**|**描述**|**示例**|  
|---|---|---|  
|**功能描述暴露**|开发者将外部函数（工具）的名称、用途和参数通过 JSON Schema 格式**描述**给 LLM。|告诉 LLM 有一个名为 `getCurrentTime` 的函数，用来“获取当前时间”。|  
|**意图推理**|LLM 根据用户输入，**推理**出用户是否需要调用某个工具，并决定调用哪个工具及其所需参数。|用户问“现在几点？”，LLM 推理出需要调用 `getCurrentTime()`。|  
|**执行与生成**|应用接收到 LLM 的调用指令后，**执行**该工具，将工具的**结果**作为新的上下文返回给 LLM，LLM 再基于结果生成最终回复。|应用执行 `getCurrentTime()` 返回 `2025-12-02T17:28:23.123`，LLM 回复：“现在是 2025 年 12 月 2 日下午 5 点 28 分。”|  
  
  
### 7.2 定义工具类  
在 Spring AI 中，您只需要在 Java 方法上使用` @Tool` 注解，即可将其暴露为 LLM 可以理解的工具。  
```java  
public class DateTimeTools {  
    /**     * 获取当前系统时间。  
     * @Tool 注解将此方法注册为可供大模型调用的工具。  
     * returnDirect = false: 表示工具结果将返回给大模型进行总结和生成。  
     */    @Tool(description = "获取当前时间", returnDirect = false)  
    public String getCurrentTime() {        return LocalDateTime.now().toString();    }}  
```  
### 7.3 调用工具  
Spring AI 提供了两种主要方式来集成和调用工具：基于低级 `ChatModel` 和基于高级 `ChatClient`。  
#### 7.3.1 基于 `ChatModel` 实现的工具调用  
这种方式需要手动构造 `ToolCallbacks` 数组，并将其注入到 `ChatOptions` 中，然后传递给 `ChatModel`。  
```java  
@RequestMapping("/tool")  
public class ToolCallingController {  
    @Resource  
    private ChatModel qwenChatModel;  
    @GetMapping("/model")  
    public Flux<String> chat(@RequestParam(name = "question", defaultValue = "你是谁现在几点?") String question) {  
        // 1. 工具注册到工具集合里（ToolCallbacks负责将Java对象转换为LLM可读的工具描述）  
        ToolCallback[] tools = ToolCallbacks.from(new DateTimeTools());        // 2. 将工具集配置进ChatOptions对象，启用工具调用模式  
        ChatOptions options = ToolCallingChatOptions.builder().toolCallbacks(tools).build();        // 3. 构建提示词，携带工具配置  
        Prompt prompt = new Prompt(question, options);        // 4. 调用大模型并流式处理结果  
        // ChatModel 会自动处理工具调用循环：LLM返回调用指令 -> 应用执行工具 -> 应用将结果返回给LLM  
        return qwenChatModel.stream(prompt).mapNotNull(  
                chatResponse -> chatResponse.getResult().getOutput().getText()        );    }    // ...}  
```  
#### 7.3.2 基于 `ChatClient` 实现的工具调用  
`ChatClient` 提供了更简洁的流式 API，它在底层自动封装了工具注册和配置的细节。  
```java  
// ...  
@Resource  
private ChatClient qwenChatClient;  
// ...  
@GetMapping("/client")  
public Flux<String> chat2(@RequestParam(name = "question", defaultValue = "你是谁现在几点?") String question) {  
    return qwenChatClient.prompt(question)            // 通过 tools() 方法直接传入工具实例  
            .tools(new DateTimeTools())            .stream()  
            .content(); // 流式获取最终回答内容  
}  
```  
## 八、MCP  
**MCP (Model-Powered Control Plane)** 是一种架构，利用 AI Agent 的推理能力，将**自然语言指令转化为对复杂系统的编排和管理**。**工具调用 (Tool Calling)** 则是实现 MCP 的**底层机制**，它为 LLM 提供了调用外部函数的能力；简单来说，工具调用是 LLM 的“手脚”，而 MCP 是利用这些“手脚”去管理复杂系统的 “大脑”和框架。  
### 8.1 MCP 服务端  
#### 8.1.1依赖  
```xml  
<dependencies>  
    <!--注意事项  
        spring-ai-starter-mcp-server-webflux不能和<artifactId>spring-boot-starter-web</artifactId>依赖并存，  
        否则会使用tomcat启动,而不是netty启动，从而导致mcpserver启动失败，但程序运行是正常的，mcp客户端连接不上。  
    -->    <dependency>        <groupId>org.springframework.boot</groupId>        <artifactId>spring-boot-starter</artifactId>    </dependency>    <!--mcp-server-webflux-->    <dependency>        <groupId>org.springframework.ai</groupId>        <artifactId>spring-ai-starter-mcp-server-webflux</artifactId>    </dependency>    <!--lombok-->    <dependency>        <groupId>org.projectlombok</groupId>        <artifactId>lombok</artifactId>        <version>1.18.38</version>    </dependency>    <!--hutool-->    <dependency>        <groupId>cn.hutool</groupId>        <artifactId>hutool-all</artifactId>        <version>5.8.22</version>    </dependency>    <dependency>        <groupId>org.springframework.boot</groupId>        <artifactId>spring-boot-starter-test</artifactId>        <scope>test</scope>    </dependency></dependencies>  
```  
#### 8.1.2 配置文件  
```yaml  
spring:  
  application:    name: mcp-server  ai:    mcp:      server:        type: async        name: mcp-server        version: 1.0.0  
```  
#### 8.1.3 工具定义与暴露  
在模型驱动控制平面（MCP）架构中，**服务端**负责定义并暴露一系列具体的业务功能或操作（即**工具**）。这些工具将被 AI Agent 或 MCP 客户端调用，以执行复杂任务。  
  
##### 8.1.3.1 编写服务类并暴露工具方法  
  
我们通过在服务类方法上使用 Spring AI 的 `@Tool` 注解，将方法标记为可供大模型调用的工具。  
  
##### 8.1.3.2 示例：城市旅游新闻服务  
  
以下是一个模拟的在线旅游新闻服务，它接受城市名称作为参数，并返回该城市的今日旅游新闻摘要。  
  
```java  
/**  
 * 城市旅游新闻服务：为AI Agent提供今日城市旅游头条信息。  
 */@Service  
public class TourismNewsService {  
    /**     * 根据城市名称获取今日热门旅游头条新闻或活动信息。  
     * * @param city 城市名称，如“北京”、“上海”、“深圳”  
     *     * @return 城市今日旅游头条新闻摘要  
     */    @Tool(description = "根据城市名称获取今日热门旅游头条新闻或活动信息")  
    public String getCityTourismNews(String city) {        // 使用 Map 模拟数据库或外部 API 返回的今日头条数据  
        Map<String, String> newsMap = Map.of(                "北京", "今日头条：故宫博物院启动秋季“清代宫廷生活艺术”特展，限量门票现已开放线上预约。",  
                "上海", "今日头条：外滩举办国际艺术周，多家知名美术馆延长开放时间，黄浦江游船票预订火爆。",  
                "深圳", "今日头条：欢乐谷主题公园推出五折特惠活动，庆祝深圳特区成立周年，吸引大量家庭出游。"  
        );        return newsMap.getOrDefault(city, "抱歉：未查询到该城市今日旅游热门新闻！");  
    }}  
```  
#### 8.1.4 将工具注册到 MCP 框架  
为了让 MCP 客户端（即调用大模型的应用）能够访问和使用这些工具，我们需要通过 Spring AI 的配置机制，将这些服务实例注册为一个**工具回调提供者**（`ToolCallbackProvider`）。  
  
> **核心组件：**  
>  
> - **`ToolCallbackProvider`：** 这是 Spring AI 中用于集中管理和暴露所有工具定义的接口。  
>  
> - **`MethodToolCallbackProvider`：** 默认实现，它通过反射机制扫描传入的 Java 对象（`toolObjects`）中所有带有 `@Tool` 注解的方法，并将它们转换成大模型能够理解的 **JSON Schema** 格式。  
```java  
@Configuration  
public class McpServerConfig {  
    public final WeatherService weatherService;  
    public final TourismNewsService tourismNewsService;  
    public McpServerConfig(WeatherService weatherService,  
                           TourismNewsService tourismNewsService) {        this.weatherService = weatherService;        this.tourismNewsService = tourismNewsService;    }    /**     * 将工具方法暴露给外部 mcp client 调用  
     *     * @return ToolCallbackProvider     */    @Bean  
    public ToolCallbackProvider weatherTools() {  
        return MethodToolCallbackProvider.builder()                .toolObjects(weatherService, tourismNewsService)  
                // .toolObjects(tourismNewsService)                .build();    }}  
```  
  
### 8.2 MCP 客户端  
MCP 客户端是 AI Agent 侧的应用程序，它负责连接到 MCP 服务端，获取工具的定义（JSON Schema），并在需要时发起对远程工具的实际调用。  
#### 8.2.1 客户端依赖  
```xml  
  <!-- 2.mcp-clent 依赖 --><dependency>  
    <groupId>org.springframework.ai</groupId>    <artifactId>spring-ai-starter-mcp-client</artifactId></dependency>  
```  
#### 8.2.2 客户端配置文件  
```yaml  
spring:  
  application:    name: mcp-client  ai:    dashscope:      api-key: ${DASH_SCOPE_API_KEY}      base-url: "https://dashscope.aliyuncs.com/compatible-mode/v1"      chat:        options:          model: "qwen-plus-2025-09-11"    mcp:      client:        type: async        name: mcp-client        version: 1.0.0        request-timeout: 60s        toolcallback:          enabled: true        sse:          connections:            # 你的服务端地址  
            mcp-server1:              url: http://localhost:801  
```  
#### 8.2.3 客户端配置：集成远程工具到 ChatClient  
为了让 `ChatClient` 在每次调用时都知晓并携带可用的工具定义，我们需要将 MCP 客户端获取到的远程工具注入为 `ChatClient` 的默认工具回调。  
```java  
@Configuration  
public class SaaLLMConfig {  
    @Bean  
    public ChatClient chatClient(ChatModel chatModel, ToolCallbackProvider tools) {  
        return ChatClient.builder(chatModel)                .defaultToolCallbacks(tools.getToolCallbacks())                .build();    }}  
```  
  
#### 8.2.4 调用MCP服务  
一旦 ChatClient 被配置了 MCP 提供的远程工具，客户端的调用代码就变得极其简洁。开发者无需关心工具在本地还是远程，只需像调用普通 LLM 一样发起请求。  
```java  
@Resource  
private ChatClient chatClient;  
public Flux<String> chat(@RequestParam(name = "question", defaultValue = "北京") String question) {  
    return chatClient.prompt(question).stream().content();  
}  
```  
  
### 8.3 调用其他的MCP服务(postgres mcp)  
除了连接远程 HTTP/SSE 服务外，Spring AI 的 MCP 客户端还支持通过**标准输入/输出（`stdio`）**方式，启动并连接本地进程运行的 MCP 服务（如用于数据库查询的 MCP）。  
这将赋予大模型直接**查询本地数据库结构和数据**的能力，无需编写传统的 SQL 代码。  
  
依赖用上面mcp 客户端依赖  
  
#### 8.3.1 准备服务 JSON 文件 (classpath:/mcp.json)  
  
我们使用一个 JSON 文件来定义需要通过本地进程启动和管理的 MCP 服务。这里我们配置一个名为 `postgres` 的服务。  
  
> **注意：** 这里的配置是指示 Spring AI 客户端如何通过 Node.js (`npx`) 启动并连接 PostgreSQL MCP 服务。你需要确保本地环境有 Node.js 和 `npx` 可用。  
  
这里可以添加多个mcp，可访问[mcp server](https://mcp.so/)获取更多mcp服务。  
  
```json5  
{  
  "mcpServers": {    "postgres": {      "command": "npx",      "args": [        "-y",        "@modelcontextprotocol/server-postgres",        "postgresql://postgres:postgres@127.0.0.1:5432/postgres"      ],      "env": {        "PATH": "/home/ice/.nvm/versions/node/v22.21.1/bin:/usr/local/bin:/usr/bin:/bin"      }    }  }}  
```  
#### 8.3.2 配置文件  
```yaml  
spring:  
  application:    name: mcp-client  ai:    dashscope:      api-key: ${DASH_SCOPE_API_KEY}      chat:        options:          model: "qwen-plus-2025-09-11"    mcp:      client:        request-timeout: 60s        toolcallback:          enabled: true        stdio:          # 刚刚的json 文件位置  
          servers-configuration: classpath:/mcp.json        enabled: true        root-change-notification: true  
```  
#### 8.3.3 注册到 ChatClient  
与集成远程 HTTP/SSE 服务一样，我们需要将 MCP 客户端获取到的所有工具（包括 PostgreSQL 查询工具）注册给 `ChatClient`。  
```java  
@Configuration  
public class SaaLLMConfig {  
    @Bean  
    public ChatClient chatClient(ChatModel chatModel, ToolCallbackProvider tools) {  
        return ChatClient.builder(chatModel)                //mcp协议，配置见yml文件，此处只赋能给ChatClient对象  
                .defaultToolCallbacks(tools.getToolCallbacks())                .build();    }}  
```  
#### 8.3.4 调用 MCP 服务（数据库查询）  
一旦配置完成，大模型就获得了查询数据库的能力。您可以向它提出关于数据库结构的自然语言问题，它将通过调用 PostgreSQL MCP 工具来获取数据并生成回答。  
```java  
public Flux<String> chat(String question) {  
    return chatClient.prompt(question).stream().content();}  
```