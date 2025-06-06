# yosys-sta

使用开源EDA工具进行ASIC综合, 时序分析和功耗分析, 用于了解前端RTL设计的PPA并快速迭代.
用到的开源EDA工具包括:
* 开源综合器Yosys
* iEDA团队自研的开源EDA工具集, 这些工具会被编译成一个二进制文件`iEDA`, 本项目中用到的子工具包括
  * 网表优化工具iNO
  * 静态时序分析(STA)工具iSTA
  * 功耗分析工具iPA

* 根据iEDA团队的介绍, iSTA有以下优势
  1. 通过TCL命令操作, 使用简单, 能满足常用的时序分析需求
  1. 开源协议限制少: 相对地, OpenRoad项目的OpenSTA项目由于开源协议限制，不能随意修改和发布
  1. 代码结构清晰, 可修改和扩展性强: 团队将持续迭代更新, 以更好支撑开源芯片设计
* iSTA的一些参考资源:
  * [iSTA的源代码](https://github.com/OSCC-Project/iEDA/tree/master/src/operation/iSTA)
  * iSTA的报告解读可参考[这个视频](https://www.bilibili.com/video/BV1a14y1B7uz/?t=1006)
  * iSTA的内部技术可参考[第一期iEDA Tutorial](https://www.bilibili.com/video/BV1a14y1B7uz)
* iEDA团队的完整工作可参考以下文章
  * [Xingquan Li, Simin Tao, Zengrong Huang, et al. An Open-Source Intelligent Physical Implementation Toolkit and Library[C]. International Symposium of EDA, 2023.](https://github.com/OSCC-Project/iEDA/blob/master/docs/paper/ISEDA'23-iEDA-final.pdf)
* 目前支持开源PDK nangate45, 具体可在安装依赖(见下文)后阅读nangate45的README

## 安装依赖

安装yosys, 版本要求不低于0.48. 建议从[这个链接][oss-cad-suite]下载相应的工具包.
解压缩后, 将`path-to-oss-cad-suite/bin`加入到环境变量`PATH`中, 即可调用工具包中的yosys.

[oss-cad-suite]: https://github.com/YosysHQ/oss-cad-suite-build/releases

安装其他依赖并下载组件:
```shell
apt install libunwind-dev liblzma-dev # iEDA的依赖库
# or
yum install libunwind liblzma
make init # 下载预编译的iEDA和nangate45工艺库
```
完成后, 测试iEDA能否运行:
```
echo exit | ./bin/iEDA -v  # 若运行成功, 终端将输出iEDA的版本号
```

若依赖库版本不一致, 或使用其他架构(如ARM), 建议自行构建iEDA:
```
git submodule update --init --recursive
cd iEDA
vim README.md  # 请参考iEDA项目的README中的操作进行构建
```

## 评估样例设计

项目包含一个样例设计GCD, 可通过以下命令进行综合, 并评估其在nangate45工艺上的时序表现.

```shell
make sta
```

运行后, 可在`result/gcd-500MHz/`目录下查看评估结果. 部分文件说明如下:
* `gcd.netlist.syn.v` - Yosys综合的网表文件
* `synth_stat.txt` - Yosys综合的面积报告
* `synth_check.txt` - Yosys综合的检查报告, 用户需仔细阅读并决定是否需要排除相应警告
* `yosys.log` - Yosys综合的完整日志
* `gcd.netlist.fixed.v` - iNO优化扇出后的网表文件
* `fix-fanout.log` - iNO优化扇出的日志
* `synth_stat_fixed.txt` - 优化扇出后Yosys综合的面积报告
* `synth_check_fixed.txt` - 优化扇出后Yosys综合的检查报告
* `yosys-fixed.log` - 优化扇出后Yosys综合的完整日志
* `gcd.rpt` - iSTA的时序分析报告, 包含WNS, TNS和时序路径
* `gcd.cap` - iSTA的电容违例报告
* `gcd.fanout` - iSTA的扇出违例报告
* `gcd.trans` - iSTA的转换时间违例报告
* `gcd_hold.skew` - iSTA的hold模式下时钟偏斜报告
* `gcd_setup.skew` - iSTA的setup模式下时钟偏斜报告
* `gcd.pwr` - iSTA的总体功耗报告
* `gcd_instance.pwr` - iSTA的标准单元级别功耗报告
* `gcd_instance.csv` - iSTA的标准单元级别功耗报告, CSV格式
* `sta.log` - iSTA的日志

## 评估其他设计

有两种操作方式：
1. 命令行传参方式, 在命令行中指定其他设计的信息
   ```shell
   make -C /path/to/this_repo sta \
       DESIGN=mydesign SDC_FILE=/path/to/my.sdc \
       CLK_FREQ_MHZ=100 CLK_PORT_NAME=clk O=/path/to/pwd \
       RTL_FILES="/path/to/mydesign.v /path/to/xxx.v ..."
   ```
1. 修改变量方式, 在`Makefile`中修改上述变量, 然后运行`make sta`

注意:
* 在`RTL_FILES`的文件中必须包含一个名为`DESIGN`的module
* sdc文件中的时钟端口名称需要与设计文件保持一致, 具体内容可参考样例设计GCD中的相应文件

## Bug报告

如果在运行时遇到bug, 可在issue中报告问题, 并提供如下信息:
1. 相应的RTL设计
1. sdc文件
1. yosys生成的网表文件
1. iEDA的版本号
