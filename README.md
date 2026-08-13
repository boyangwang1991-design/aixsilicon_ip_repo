# aixsilicon_ip_repo - IP Unified Repository

统一 IP 仓库（monorepo）。承载所有 IP 内容，按 `ips/<vendor>/<ip>/<version>/` 组织，
内嵌 `registry.yaml` 索引。FuseSoC 只 add 这一个仓即可发现全部 IP。

本仓命名空间：`aixsilicon:ip:<ip>:<version>`（ADR-0003 统一 VLNV vendor；组织名 `boyangwang1991-design` 仅作为 remote URL 归属）

> 迁移注记：历史发布的 `boyangwang1991-design:ip:*` 核心进入 deprecated 别名窗口，
> 由 `ipkg` 下次发布时统一改写为 `aixsilicon:ip:*`；已锁定旧 VLNV 的 Lockfile 需同步更新。

## 用法

### 添加统一仓（消费者，一次性）

```bash
fusesoc library add aixsilicon_ip_repo https://github.com/boyangwang1991-design/aixsilicon_ip_repo.git
```

### 搜索 IP

```bash
ipkg search gpio
ipkg list
ipkg info <ip> <version>
```

### 入库新 IP / 新版本（发布侧）

```bash
# 1. 从构建结果入库
ipkg stage <ip-workspace> --unified . --then-index

# 2. 提交推送（含 tag）
ipkg publish .
```

索引与内容在同一提交中更新，无需独立 PR。

## 结构

```
aixsilicon_ip_repo/
├── README.md
├── ipkg.yaml                     # ipkg 配置
├── registry.yaml                 # 内嵌索引（全部 IP 元数据）
├── docs/                         # 仓库级文档（如构建清单）
├── ips/
│   └── <vendor>/<ip>/<version>/  # 每个版本一个目录（含 ip-package.yaml）
└── .github/workflows/
    └── ci.yml                    # 统一仓 CI：扫描全部 core 做 lint
```

## registry.yaml 条目格式

```yaml
schema_version: "2.0"
unified_repo: "https://github.com/boyangwang1991-design/aixsilicon_ip_repo.git"
ips:
  - name: <ip>
    vendor: boyangwang1991-design
    library: ip
    description: "..."
    license: "Apache-2.0"
    path: "ips/boyangwang1991-design/<ip>"
    versions:
      - version: "1.0.0"
        tag: "<ip>-v1.0.0"
        path: "ips/boyangwang1991-design/<ip>/1.0.0"
        gates: {G0: pass, G1: pass, G2: pass, G3: pass, G4: pass, G5: pass}
        fusesoc:
          core: "boyangwang1991-design:ip:<ip>:1.0.0"
```

## 与 FuseSoC 集成

```bash
fusesoc library add aixsilicon_ip_repo https://github.com/boyangwang1991-design/aixsilicon_ip_repo.git
fusesoc run --target sim boyangwang1991-design:ip:<ip>:1.0.0
```
