# Textfile directory (lite)

`node_exporter` reads `*.prom` files from the directory you pass as `--collector.textfile.directory`. Confirm the flag for your version. Check upstream docs.

The project docs say the collector parses the Prometheus text format and does not support timestamps. These scripts omit timestamps. Write to a temporary file in the same directory, then `mv` it into place, so a scrape is less likely to see a partial file.

`pending_updates.sh` counts lines in an `fixture-format: apt-upgradable-v1` file. It does not run apt. `service_heartbeat.sh` reads `fixture-format: heartbeat-v1` and writes up and age gauges. Pass `--now EPOCH` for a fixed age. Both refuse paths under `/dev`, `/sys`, and `/proc`.

The sample cron uses `/var/lib/node_exporter/textfile`. That path is an install example, not a default claimed for every release.

## 说明

`node_exporter` 从 `--collector.textfile.directory` 指向的目录读取 `*.prom`。参数以你的版本为准。Check upstream docs.

上游说明是：解析 Prometheus 文本格式，并且不支持时间戳。这些脚本不写时间戳。先写到同一目录的临时文件，再 `mv` 到位，抓取时不太容易看到半截文件。

`pending_updates.sh` 统计 `fixture-format: apt-upgradable-v1` 文件里的行，不运行 apt。`service_heartbeat.sh` 读取 `fixture-format: heartbeat-v1`，写出存活和年龄。需要固定年龄时传 `--now`。两者都拒绝 `/dev`、`/sys`、`/proc` 下的路径。

示例 cron 使用 `/var/lib/node_exporter/textfile`。这是安装示例，不是本包对所有版本宣称的默认值。
