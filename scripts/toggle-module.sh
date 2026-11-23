#!/usr/bin/env bash
# 注释或取消注释 init.el 中的指定模块
# 用法：bash scripts/toggle-module.sh dart
#
# 在其他脚本中批量切换多个模块：
#   module_names=(
#     velocity-script
#     textcraft
#   )
#
#   for module_name in "${module_names[@]}"; do
#     bash "$(git rev-parse --show-toplevel)/scripts/toggle-module.sh" "$module_name"
#   done

init_file="$(git rev-parse --show-toplevel)/init.el"
# 匹配 "dart" 与 "(dart"，不匹配 "dart-ext"
module_token="\(?$1([[:space:])]|\$)"

line_number="$(sed -n -E "/^[[:space:]]*(;+[[:space:]]*)?${module_token}/=" "$init_file")"
# 仅当恰好匹配一行时才进行修改
if [[ ! "$line_number" =~ ^[0-9]+$ ]]; then
  echo "$1 命中的行数不是 1, 未修改" >&2
  exit 1
fi

if [[ -n "$(sed -n "${line_number}{/^[[:space:]]*;/p}" "$init_file")" ]]; then
  # 删除模块名前的 ";;"
  sed -i -E "${line_number}s/;+[[:space:]]*(${module_token})/\1/" "$init_file"
else
  # 在模块名前添加 ";;"
  sed -i -E "${line_number}s/${module_token}/;;&/" "$init_file"
fi
