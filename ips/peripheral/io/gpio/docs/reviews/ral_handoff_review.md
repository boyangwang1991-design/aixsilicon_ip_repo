# GPIO RAL 交接核对

用户已委托本次全流程无需额外人工审核。核对对象为原生 gpio_ral_pkg 的 RDL 来源、APB adapter、显式 monitor predictor、环境连接与真实运行日志。唯一预测方式为 monitor→uvm_reg_predictor，关闭 auto_predict；地址为字节单位，PSTRB 对应四个字节。

OUTPUT 用例使用 RAL frontdoor write/mirror；APB 用例验证字节使能、权限与非法访问；SECURITY/RESET 检查保护与复位；LOWPOWER 检查休眠期间正常寄存器更新。寄存器状态为 external 实现，不交付未经验证的通用 backdoor；特殊 W1C/别名行为仍由独立语义检查核对。未覆盖的 race/side-effect 不自动宣称完成。
