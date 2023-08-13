#!/usr/bin/env bash

set_sysctl() {
  key="$1"
  value="$2"
  file="/etc/sysctl.conf"

  # 检查给定的key是否存在
  if grep -q "^${key}" "${file}"; then
    # 如果存在，则修改它
    sed -i "s|^${key}.*|${key} = ${value}|" "${file}"
  else
    # 如果不存在，则追加它
    echo "${key} = ${value}" >>"${file}"
  fi
}

# 为给定的sysctl项设置值
set_sysctl "net.ipv6.conf.all.disable_ipv6" "0"
set_sysctl "net.ipv6.conf.default.disable_ipv6" "0"
set_sysctl "net.ipv6.conf.lo.disable_ipv6" "0"

sysctl -p /etc/sysctl.conf
