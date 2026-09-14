"""兼容旧导入入口；当前规划唯一事实源为 registry.yaml。"""
from pathlib import Path
import yaml

def all_ip_entries():
    return yaml.safe_load((Path(__file__).resolve().parents[2] / "registry.yaml").read_text(encoding="utf-8"))["ips"]
