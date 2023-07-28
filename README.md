# yosys-sta

使用开源综合器Yosys和iEDA团队自研的静态时序分析(STA)工具iSTA进行ASIC综合和时序分析,
用于了解前端RTL设计的时序情况并快速迭代.

* 根据iEDA团队的介绍, iSTA有以下优势
  1. 通过TCL命令操作, 使用简单, 能满足常用的时序分析需求
  1. 开源协议限制少: OpenRoad项目的OpenSTA项目由于开源协议限制，不允许随意修改和发布
  1. 代码结构清晰, 可修改和扩展性强: 团队将持续迭代更新, 以更好支撑开源芯片设计
* iEDA团队的完整工作可参考以下文章
  * [Xingquan Li, Simin Tao, Zengrong Huang, et al. An Open-Source Intelligent Physical Implementation Toolkit and Library[C]. International Symposium of EDA, 2023.](https://github.com/OSCC-Project/iEDA/blob/master/docs/paper/ISEDA'23-iEDA-final.pdf)
* 目前支持开源PDK nangate45, 具体可阅读[nangate45的README](nangate45/README.md)

## 安装依赖

```shell
apt install yosys
apt install libunwind-dev libgomp1 # iSTA的依赖库
make init
```

## 评估样例设计

项目包含一个样例设计GCD, 可通过以下命令进行综合, 并评估其在nangate45工艺上的时序表现.

```shell
make sta
```

运行后, 可在`result/gcd-500MHz/`目录下查看评估结果. 部分文件说明如下:
* `gcd.netlist.v` - Yosys综合的网表文件
* `synth_stat.txt` - Yosys综合的面积报告
* `synth_check.txt` - Yosys综合的检查报告, 用户需仔细阅读并决定是否需要排除相应警告
* `yosys.log` - Yosys综合的完整日志
* `gcd.rpt` - iSTA的时序分析报告

## 评估其他设计

有两种操作方式：
1. 命令行传参方式, 在命令行中指定其他设计的信息
   ```shell
   make sta DESIGN=mydesign SDC_FILE=/path/to/my.sdc RTL_FILES="/path/to/mydesign.v /path/to/xxx.v ..." CLK_FREQ_MHZ=100
   ```
   其中在`RTL_FILES`的文件中必须包含一个名为`DESIGN`的module, sdc文件内容可参考样例设计GCD中的相应文件
1. 修改变量方式, 在`Makefile`中修改上述变量, 然后运行`make sta`
