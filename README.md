# Node Exporter Textfile Collectors (Lite)

## English

Pending apt updates and one service heartbeat. Both scripts write a `*.prom` file from a fixture. They do not run apt and they do not open block devices.

Not in this subset: the SMART stub, the yum fixture, the runner, the systemd unit, and the longer notes.

`deliverables/TEXTFILE_NOTES.md` still explains `--collector.textfile.directory`. Check upstream docs before you point `node_exporter` at the output directory. The sample cron is a `/etc/cron.d` line and calls the two scripts directly.

### Deliverables

- `deliverables/common.sh` — path refusal and atomic write
- `deliverables/pending_updates.sh` — apt fixture line count
- `deliverables/service_heartbeat.sh` — up and age gauges
- `deliverables/textfile-collector.cron` — sample cron for those two scripts
- `deliverables/TEXTFILE_NOTES.md` — short English and Chinese flag notes
- `examples/apt-pending.txt` — three package lines
- `examples/heartbeat-web.txt` — service `web` up
- `examples/apt-pending.prom` — count 3 for host `example.com`

```bash
bash deliverables/pending_updates.sh \
  --fixture examples/apt-pending.txt \
  --manager apt \
  --host example.com \
  --out /tmp/apt-pending.prom
```

## 中文

这里只有 apt 待更新数量和一个服务心跳。两个脚本都从夹具写出 `*.prom`。它们不运行 apt，也不打开块设备。

精简版不含：SMART 桩、yum 夹具、总跑脚本、systemd 单元，以及更长的说明。

`deliverables/TEXTFILE_NOTES.md` 仍解释 `--collector.textfile.directory`。把目录交给 `node_exporter` 之前，以官方文档为准（check upstream docs）。示例 cron 是 `/etc/cron.d` 的写法，直接调用这两个脚本。

### 交付文件

- `deliverables/common.sh`
- `deliverables/pending_updates.sh`
- `deliverables/service_heartbeat.sh`
- `deliverables/textfile-collector.cron`
- `deliverables/TEXTFILE_NOTES.md`
- `examples/apt-pending.txt`
- `examples/heartbeat-web.txt`
- `examples/apt-pending.prom`

Full version: GUMROAD_URL
