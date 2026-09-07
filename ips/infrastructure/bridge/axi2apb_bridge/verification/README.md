# verification_template

## 1. 目录说明

本目录为通用 UVM 验证环境模板，所有组件直接继承自 UVM 标准类库。

```text
verification_template/
├── env/                        # 验证环境目录
│   ├── x2p_env.sv               # 环境顶层组件
│   ├── x2p_env_cfg.sv           # 环境配置
│   ├── x2p_env_dec.sv           # 环境声明（枚举、参数）
│   ├── x2p_rm.sv                # 参考模型
│   ├── x2p_rm_cfg.sv            # 参考模型配置
│   ├── x2p_checker.sv           # 检查器/Scoreboard
│   ├── x2p_checker_cfg.sv       # 检查器配置
│   ├── x2p_dut_cfg.sv           # DUT 配置
│   ├── x2p_virtual_sequencer.sv # 虚拟序列器
│   ├── x2p_virtual_sequence.sv  # 虚拟序列
│   ├── x2p_fcov.sv              # 功能覆盖率事务
│   ├── x2p_env.list             # 环境编译文件列表
│   └── utils/
│       └── axi_utils/           # 协议 Agent 目录
│           ├── src/
│           │   ├── axi_dec.sv              # 协议声明（参数、枚举）
│           │   ├── axi_interface.sv        # 协议接口
│           │   ├── axi_xaction.sv          # 事务类
│           │   ├── axi_driver.sv           # 主驱动
│           │   ├── axi_driver_cfg.sv       # 主驱动配置
│           │   ├── axi_slave_driver.sv     # 从驱动
│           │   ├── axi_slave_driver_cfg.sv # 从驱动配置
│           │   ├── axi_monitor.sv          # 监控器
│           │   ├── axi_monitor_cfg.sv      # 监控器配置
│           │   ├── axi_monitor_cov.sv      # 监控器覆盖率
│           │   ├── axi_sequencer.sv        # 序列器
│           │   ├── axi_interface_agent.sv  # Agent 顶层
│           │   ├── axi_interface_agent_cfg.sv # Agent 配置
│           │   ├── axi_sequence_library.svp   # 序列库
│           │   └── axi_package.sv          # 协议包
│           ├── unit_test/        # Agent 单元测试
│           └── axi_interface_agent.list  # Agent 编译文件列表
├── tc/                         # 测试用例目录
│   ├── tc_base.sv              # 基础测试类
│   ├── tc_sanity.sv            # Sanity 测试用例
│   ├── tc_define.sv            # 测试宏定义
│   ├── tc_undef.sv             # 宏清理
│   └── tc.list                 # 测试编译文件列表
├── th/                         # 测试 harness 目录
│   └── harness.sv              # 顶层测试平台
├── verification.list           # 主编译文件列表
└── README.md                   # 本文档
```

## 2. 命名约定

| 占位符 | 含义 | 示例 |
|---|---|---|
| xx | interface / agent 名称 | apb, axi, irq |
| yy | DUT / subsystem 名称 | dma, sram_ctrl, sysctrl |
| tc | testcase | tc_sanity |

## 3. 分层结构

```mermaid
graph TD
    A[UVM base class] --> B[XX protocol agent]
    B --> C[YY verification env]
    C --> D[TC testcase]
```

### 3.1 继承关系图

```mermaid
graph TD
    subgraph UVM["UVM 标准类库"]
        uvm_object
        uvm_component
        uvm_driver
        uvm_monitor
        uvm_test
        uvm_sequencer
        uvm_sequence
        uvm_agent
        uvm_subscriber
    end

    subgraph XX["XX 协议 Agent 层"]
        axi_xaction
        axi_driver
        axi_monitor
        axi_interface_agent
        axi_sequence
        axi_sequencer
        axi_slave_driver
        axi_monitor_cov
    end

    subgraph YY["YY 验证环境层"]
        x2p_env
        x2p_env_cfg
        x2p_rm
        x2p_checker
        x2p_virtual_sequence
        x2p_virtual_sequencer
        x2p_fcov
    end

    subgraph TC["测试用例层"]
        tc_base
        tc_sanity
        tc_xxx
    end

    uvm_object --> axi_xaction
    uvm_driver --> axi_driver
    uvm_driver --> axi_slave_driver
    uvm_monitor --> axi_monitor
    uvm_agent --> axi_interface_agent
    uvm_sequencer --> axi_sequencer
    uvm_sequence --> axi_sequence
    uvm_subscriber --> axi_monitor_cov

    axi_interface_agent --> x2p_env
    x2p_env_cfg --> x2p_env
    x2p_rm --> x2p_env
    x2p_checker --> x2p_env
    x2p_virtual_sequencer --> x2p_env

    x2p_env --> tc_base
    tc_base --> tc_sanity
    tc_base --> tc_xxx
```

## 4. 主要组件

### 4.1 env/utils/axi_utils - 协议 Agent

协议 Agent 提供完整的总线协议验证组件。

#### 4.1.1 axi_dec.sv - 协议声明

定义协议参数和枚举类型：

```systemverilog
// 协议参数
parameter int AXI_ADDR_WIDTH = 32;
parameter int AXI_DATA_WIDTH = 32;

// Agent 模式常量
parameter bit AXI_MASTER_MODE = 1'b0;
parameter bit AXI_SLAVE_MODE  = 1'b1;
parameter bit AXI_AGENT_ACTIVE  = 1'b1;
parameter bit AXI_AGENT_PASSIVE = 1'b0;

// 命令类型枚举
typedef enum bit {
  AXI_READ  = 1'b0,
  AXI_WRITE = 1'b1
} axi_cmd_e;

// 响应类型枚举
typedef enum bit [1:0] {
  AXI_RESP_OKAY  = 2'b00,
  AXI_RESP_ERROR = 2'b01
} axi_resp_e;
```

#### 4.1.2 axi_interface.sv - 协议接口

定义协议信号和 clocking block：

```systemverilog
interface axi_interface(input logic clk, input logic rst_n);
  logic valid, ready, write;
  logic [AXI_ADDR_WIDTH-1:0] addr;
  logic [AXI_DATA_WIDTH-1:0] wdata, rdata;
  
  clocking drv_cb @(posedge clk);  // 主驱动 clocking block
  clocking slv_cb @(posedge clk);  // 从驱动 clocking block
  clocking mon_cb @(posedge clk);  // 监控 clocking block
  
  modport master  (clocking drv_cb, input clk, input rst_n);
  modport slave   (clocking slv_cb, input clk, input rst_n);
  modport monitor (clocking mon_cb, input clk, input rst_n);
endinterface
```

#### 4.1.3 axi_xaction.sv - 事务类

```systemverilog
class axi_xaction extends uvm_sequence_item;
  rand axi_cmd_e cmd;
  rand bit [AXI_ADDR_WIDTH-1:0] addr;
  rand bit [AXI_DATA_WIDTH-1:0] data;
  axi_resp_e resp;
  
  `uvm_object_utils_begin(axi_xaction)
    `uvm_field_enum(axi_cmd_e, cmd, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_enum(axi_resp_e, resp, UVM_ALL_ON)
  `uvm_object_utils_end
endclass
```

#### 4.1.4 axi_driver.sv - 主驱动

```systemverilog
class axi_driver extends uvm_driver #(axi_xaction);
  virtual axi_interface bus;
  axi_driver_cfg cfg;
  
  // 从 config_db 获取虚拟接口
  // 实现 send_stimulus_data() 驱动事务
endclass
```

#### 4.1.5 axi_monitor.sv - 监控器

```systemverilog
class axi_monitor extends uvm_monitor;
  virtual axi_interface bus;
  axi_monitor_cfg cfg;
  uvm_analysis_port #(axi_xaction) ap;
  
  // 监控总线事务并通过 ap 广播
endclass
```

#### 4.1.6 axi_interface_agent.sv - Agent 顶层

```systemverilog
class axi_interface_agent extends uvm_agent;
  axi_interface_agent_cfg cfg;
  virtual axi_interface vif;
  
  axi_sequencer    sqr;
  axi_driver       mst_drv;
  axi_slave_driver slv_drv;
  axi_monitor      mon;
  axi_monitor_cov  cov;
  uvm_analysis_port #(axi_xaction) ap;
  
  // build_phase: 根据 cfg.active/mode 创建子组件
  // connect_phase: 连接 driver-sequencer, monitor-coverage
endclass
```

### 4.2 env - 验证环境

#### 4.2.1 x2p_env.sv - 环境顶层

```systemverilog
class x2p_env extends uvm_env;
  x2p_env_cfg cfg;
  axi_interface_agent axi_agent;
  x2p_rm rm;
  x2p_checker checker;
  x2p_virtual_sequencer v_sqr;
  
  // build_phase: 创建 agent, rm, checker, v_sqr
  // connect_phase: 连接 TLM 端口
endclass
```

#### 4.2.2 x2p_rm.sv - 参考模型

```systemverilog
class x2p_rm extends uvm_component;
  uvm_analysis_imp #(axi_xaction, x2p_rm) in_export;
  uvm_analysis_port #(axi_xaction) exp_ap;
  
  // 接收输入事务，生成期望输出
  virtual function axi_xaction process_transaction(axi_xaction tr);
endclass
```

#### 4.2.3 x2p_checker.sv - 检查器

```systemverilog
class x2p_checker extends uvm_component;
  uvm_analysis_imp_act #(axi_xaction, x2p_checker) act_export;
  uvm_analysis_imp_exp #(axi_xaction, x2p_checker) exp_export;
  
  // FIFO 匹配比较 actual 和 expected 事务
endclass
```

### 4.3 tc - 测试用例

#### 4.3.1 tc_base.sv - 基础测试类

```systemverilog
class tc_base extends uvm_test;
  x2p_env env;
  x2p_env_cfg env_cfg;
  
  virtual function void configure_env();
    env_cfg.axi_agent_cfg.active = AXI_AGENT_ACTIVE;
    env_cfg.axi_agent_cfg.mode   = AXI_MASTER_MODE;
    env_cfg.enable_rm           = 1;
    env_cfg.enable_checker      = 1;
    env_cfg.enable_cov          = 1;
  endfunction
endclass
```

#### 4.3.2 tc_sanity.sv - Sanity 测试

```systemverilog
class tc_sanity extends tc_base;
  virtual task run_phase(uvm_phase phase);
    x2p_sanity_vseq vseq;
    phase.raise_objection(this);
    vseq = x2p_sanity_vseq::type_id::create("vseq");
    vseq.start(env.v_sqr);
    phase.drop_objection(this);
  endtask
endclass
```

### 4.4 th - 测试 Harness

#### 4.4.1 harness.sv - 顶层测试平台

```systemverilog
module harness;
  logic clk, rst_n;
  axi_interface axi_if (.clk(clk), .rst_n(rst_n));
  
  // 时钟生成：100MHz
  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end
  
  // 复位生成：10 个时钟周期
  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end
  
  // UVM 配置
  initial begin
    uvm_config_db #(virtual axi_interface)::set(
      null, "uvm_test_top.env.axi_agent", "vif", axi_if
    );
    run_test();
  end
endmodule
```

## 5. 编译方式

### 5.1 VCS 编译

```bash
vcs -sverilog -ntb_opts uvm -f verification.list
```

### 5.2 Xcelium 编译

```bash
xrun -sv -uvm -f verification.list
```

### 5.3 编译文件结构

`verification.list` 内容：

```text
+incdir+./env
+incdir+./env/utils/axi_utils/src
+incdir+./tc
+incdir+./th

-f ./env/utils/axi_utils/axi_interface_agent.list
-f ./env/x2p_env.list
-f ./tc/tc.list

./th/harness.sv
```

## 6. 运行方式

### 6.1 基本运行

```bash
./simv +UVM_TESTNAME=tc_sanity
```

### 6.2 指定波形输出

```bash
./simv +UVM_TESTNAME=tc_sanity -l sim.log +vcd+all
```

### 6.3 指定 UVM 详细度

```bash
./simv +UVM_TESTNAME=tc_sanity +UVM_VERBOSITY=UVM_HIGH
```

## 7. Agent 替换方法

### 7.1 协议 Agent 替换

将模板中的 `xx` 替换为具体协议名，例如：

```text
axi_driver.sv        -> apb_driver.sv
axi_xaction.sv       -> apb_xaction.sv
axi_interface_agent.sv -> apb_interface_agent.sv
axi_interface.sv     -> apb_interface.sv
axi_package.sv       -> apb_package.sv
```

### 7.2 DUT 环境替换

将模板中的 `yy` 替换为 DUT 名称，例如：

```text
x2p_env.sv           -> dma_env.sv
x2p_env_cfg.sv       -> dma_env_cfg.sv
x2p_checker.sv       -> dma_checker.sv
x2p_rm.sv            -> dma_rm.sv
x2p_virtual_sequence.sv -> dma_virtual_sequence.sv
```

### 7.3 替换步骤

1. **复制模板文件**
   ```bash
   cp -r verification_template my_verification
   cd my_verification
   ```

2. **替换协议名称 (xx -> apb)**
   ```bash
   find . -name "axi_*" -exec rename 's/axi_/apb_/' {} \;
   find . -type f -name "*.sv" -exec sed -i 's/axi_/apb_/g' {} \;
   ```

3. **替换 DUT 名称 (yy -> dma)**
   ```bash
   find . -name "x2p_*" -exec rename 's/x2p_/dma_/' {} \;
   find . -type f -name "*.sv" -exec sed -i 's/x2p_/dma_/g' {} \;
   ```

4. **修改协议定义**
   - 修改 `apb_dec.sv` 中的协议参数和枚举
   - 修改 `apb_interface.sv` 中的信号定义
   - 修改 `apb_xaction.sv` 中的事务字段
   - 实现 `apb_driver.sv` 的驱动逻辑
   - 实现 `apb_monitor.sv` 的监控逻辑

5. **修改 harness.sv**
   - 取消注释 DUT 实例化
   - 修改端口连接
   - 添加更多接口实例化

6. **编译验证**
   ```bash
   vcs -sverilog -ntb_opts uvm -f verification.list
   ./simv +UVM_TESTNAME=tc_sanity
   ```

## 8. 使用示例

### 8.1 创建 APB Agent

```systemverilog
// apb_dec.sv
parameter int APB_ADDR_WIDTH = 32;
parameter int APB_DATA_WIDTH = 32;

typedef enum bit { APB_READ = 1'b0, APB_WRITE = 1'b1 } apb_cmd_e;

// apb_interface.sv
interface apb_interface(input logic clk, input logic rst_n);
  logic [APB_ADDR_WIDTH-1:0] paddr;
  logic [APB_DATA_WIDTH-1:0] pwdata, prdata;
  logic                      psel, penable, pwrite, pready;
  // ...
endinterface

// apb_xaction.sv
class apb_xaction extends uvm_sequence_item;
  rand apb_cmd_e cmd;
  rand bit [APB_ADDR_WIDTH-1:0] addr;
  rand bit [APB_DATA_WIDTH-1:0] data;
  // ...
endclass

// apb_driver.sv
class apb_driver extends uvm_driver #(apb_xaction);
  virtual apb_interface bus;
  
  task send_stimulus_data(apb_xaction tr);
    bus.drv_cb.paddr  <= tr.addr;
    bus.drv_cb.pwrite <= (tr.cmd == APB_WRITE);
    bus.drv_cb.psel   <= 1'b1;
    bus.drv_cb.penable <= 1'b0;
    @(bus.drv_cb);
    bus.drv_cb.penable <= 1'b1;
    if (tr.cmd == APB_WRITE) bus.drv_cb.pwdata <= tr.data;
    wait(bus.drv_cb.pready);
    bus.drv_cb.psel   <= 1'b0;
    bus.drv_cb.penable <= 1'b0;
  endtask
endclass
```

### 8.2 创建自定义测试

```systemverilog
// tc_mytest.sv
class tc_mytest extends tc_base;
  `uvm_component_utils(tc_mytest)
  
  virtual function void configure_env();
    super.configure_env();
    env_cfg.enable_cov = 0;  // 关闭覆盖率
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    my_vseq vseq;
    phase.raise_objection(this);
    vseq = my_vseq::type_id::create("vseq");
    vseq.start(env.v_sqr);
    phase.drop_objection(this);
  endtask
endclass
```

## 9. 最佳实践

### 9.1 命名规范

- 文件名使用小写下划线：`apb_driver.sv`
- 类名使用小写下划线：`apb_driver`
- 宏使用大写下划线：`APB_DRIVER__SV`
- 实例名使用小写下划线：`u_apb_agent`

### 9.2 代码组织

- 每个文件只包含一个类
- 使用 `ifndef/define/endif` 防止重复包含
- 使用 Doxygen 风格注释
- 参数化类提高复用性

### 9.3 配置管理

- 使用 `uvm_config_db` 传递配置
- 在 `build_phase` 中获取配置
- 配置对象继承自 `uvm_object`

### 9.4 事务处理

- 事务类继承自 `uvm_sequence_item`
- 使用 `uvm_field_*` 宏实现自动化
- 在 sequence 中使用 `start_item()` / `finish_item()`

## 10. 常见问题

### Q1: 如何添加新的协议 Agent？

1. 在 `env/utils/axi_utils` 基础上创建新 Agent
2. 修改 `axi_dec.sv` 定义协议参数和枚举
3. 修改 `axi_interface.sv` 定义协议信号
4. 修改 `axi_xaction.sv` 定义事务字段
5. 实现 `axi_driver.sv` 的驱动逻辑
6. 实现 `axi_monitor.sv` 的监控逻辑
7. 在 `harness.sv` 中配置虚拟接口

### Q2: 如何添加新的测试用例？

1. 继承 `tc_base` 创建新测试类
2. 重写 `configure_env()` 自定义配置
3. 重写 `run_phase()` 执行测试序列
4. 在 `tc.list` 中包含新测试文件

### Q3: 如何调试 UVM 环境问题？

1. 使用 `+UVM_VERBOSITY=UVM_HIGH` 查看详细日志
2. 使用 `+UVM_CONFIG_DB_TRACE` 跟踪配置
3. 检查虚拟接口是否正确配置

## 11. 版本历史

| 版本 | 日期 | 说明 |
|---|---|---|
| 3.0 | 2025 | 合并入 ip-development-suite；升级 UVM 1.2（`-ntb_opts uvm-1.2`）；统一 `verification/` 目录布局 |
| 2.0 | 2025 | 移除 stb 基类依赖，直接使用 UVM 标准类 |
| 1.0 | 2024 | 初始版本 |

## 12. 联系方式

如有问题或建议，请联系验证团队。
