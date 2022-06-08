/* blood pressure chart widget */

import 'package:bp_notepad/db/bp_databaseProvider.dart';
import 'package:bp_notepad/localization/appLocalization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BPLineChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BPLineChartState();
}

class _BPLineChartState extends State<BPLineChart> {
  static const double minx = 0;
  static const double maxx = 9;

  int segmentedControlGroupValue = 10;

  double sbpAvg = 0; //高压平均值
  double dbpAvg = 0; //低压平均值
  double sbpAll = 0; //用于计算平均值的高压总值
  double dbpAll = 0; //用于计算平均值的高压总值
  int max = 120; //用于找出最大的值
  int min = 70; //用于找出最小的值

  List<FlSpot> sbpSpotsData = [];
  List<FlSpot> dbpSpotsData = [];
  bool showAvg = false;

  //获得平均值的点
  List<FlSpot> getSBPAvgData() {
    List<FlSpot> avgSBPSpotDatas = []; //一个growable的List必须使用.add进行数据装填
    for (int x = 0; x <= maxx; x++) {
      avgSBPSpotDatas.add(FlSpot(x.toDouble(), sbpAvg));
    }
    return avgSBPSpotDatas;
  }

  //获得平均值的点
  List<FlSpot> getDBPAvgData() {
    List<FlSpot> avgDBPSpotDatas = []; //一个growable的List必须使用.add进行数据装填
    for (int x = 0; x <= maxx; x++) {
      avgDBPSpotDatas.add(FlSpot(x.toDouble(), dbpAvg));
    }
    return avgDBPSpotDatas;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: FutureBuilder<List>(
          future: BpDataBaseProvider.db.getGraphData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int showLength = 0;
              int addLength = 0;
              if ((snapshot.data[0].length - segmentedControlGroupValue) > 0) {
                showLength =
                    snapshot.data[0].length - segmentedControlGroupValue;
                addLength = segmentedControlGroupValue;
              } else {
                addLength = snapshot.data[0].length;
              }
              if (snapshot.data[0].length >= 10) {
                sbpSpotsData.clear();
                dbpSpotsData.clear();
                sbpAll = 0;
                dbpAll = 0;
                for (int x = 0; x < addLength; x++) {
                  // 获取最大值和最小值
                  if (snapshot.data[0][x + showLength] > max) {
                    max = snapshot.data[0][x + showLength];
                  } else if (snapshot.data[1][x + showLength] < min) {
                    min = snapshot.data[1][x + showLength];
                  }
                  sbpSpotsData.add(FlSpot(x.toDouble(),
                      snapshot.data[0][x + showLength].toDouble()));
                  // 加上最近十次的高压
                  sbpAll += snapshot.data[0][x + showLength].toDouble();
                  dbpSpotsData.add(FlSpot(x.toDouble(),
                      snapshot.data[1][x + showLength].toDouble()));
                  // 加上最近十次的低压
                  dbpAll += snapshot.data[1][x + showLength].toDouble();
                }
                sbpAvg = sbpAll / addLength;
                dbpAvg = dbpAll / addLength;
              } else {
                if (sbpSpotsData.isEmpty && dbpSpotsData.isEmpty) {
                  for (int x = 0; x < snapshot.data[0].length; x++) {
                    //获取最大值和最小值
                    if (snapshot.data[0][x] > max) {
                      max = snapshot.data[0][x];
                    } else if (snapshot.data[1][x] < min) {
                      min = snapshot.data[1][x];
                    }
                    sbpSpotsData.add(
                        (FlSpot(x.toDouble(), snapshot.data[0][x].toDouble())));
                    sbpAll += snapshot.data[0][x].toDouble();
                    dbpSpotsData.add(
                        (FlSpot(x.toDouble(), snapshot.data[1][x].toDouble())));
                    dbpAll += snapshot.data[1][x].toDouble();
                  }
                  sbpAvg = sbpAll / snapshot.data[0].length;
                  dbpAvg = dbpAll / snapshot.data[1].length;
                }
              }
              return Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    // gradient: LinearGradient(
                    //   //渐变色
                    //   colors: [
                    //     const Color(0xff2c274c),
                    //     const Color(0xff46426c),
                    //   ],
                    //   begin: Alignment.bottomCenter,
                    //   end: Alignment.topCenter,
                    // ),
                    color: const Color(0xFF241f48)),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        CupertinoSlidingSegmentedControl(
                            thumbColor: const Color(0xFF1d193a),
                            groupValue: segmentedControlGroupValue,
                            children: <int, Widget>{
                              10: Text(
                                AppLocalization.of(context)
                                    .translate('chart_range_10'),
                                style: TextStyle(
                                    color: CupertinoColors.systemGrey),
                              ),
                              20: Text(
                                AppLocalization.of(context)
                                    .translate('chart_range_20'),
                                style: TextStyle(
                                    color: CupertinoColors.systemGrey),
                              ),
                              30: Text(
                                AppLocalization.of(context)
                                    .translate('chart_range_30'),
                                style: TextStyle(
                                    color: CupertinoColors.systemGrey),
                              )
                            },
                            onValueChanged: (i) {
                              setState(() {
                                segmentedControlGroupValue = i;
                              });
                            }),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          AppLocalization.of(context)
                              .translate('bp_chart_tittle'),
                          style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 16.0, left: 6.0),
                            child: LineChart(
                              showAvg ? avgData() : mainData(),
                              swapAnimationDuration:
                                  const Duration(milliseconds: 250),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 34,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    showAvg = !showAvg;
                                  });
                                },
                                child: Text(
                                  AppLocalization.of(context)
                                      .translate('bs_chart_subtittle'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: showAvg
                                        ? const Color(0xFFFFFFFF)
                                            .withOpacity(0.5)
                                        : const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return CupertinoActivityIndicator();
            }
          },
        ));
  }

  LineChartData mainData() {
    // getSpotData();
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: const Color(0XFF607D8B).withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
            color: const Color(0xB3FFFFFF),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '1';
              case 4:
                return '5';
              case 9:
                return '10';
              case 14:
                return '15';
              case 19:
                return '20';
              case 24:
                return '25';
              case 29:
                return '30';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: const Color(0xB3FFFFFF),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 40:
                return '40';
              case 60:
                return '60';
              case 80:
                return '80';
              case 100:
                return '100';
              case 120:
                return '120';
              case 140:
                return '140';
              case 160:
                return '160';
              case 180:
                return '180';
              case 200:
                return '200';
              case 220:
                return '220';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: const Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: minx,
      maxX: (segmentedControlGroupValue - 1).toDouble(),
      maxY: (((max.toInt()) ~/ 10) * 10 + 10).toDouble(),
      minY: (((min.toInt()) ~/ 10) * 10 - 10).toDouble(),
      lineBarsData: linesBarData1(),
    );
  }

  //血压记录主界面的绘图线条颜色
  List<LineChartBarData> linesBarData1() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: sbpSpotsData,
      isCurved: true,
      curveSmoothness: 0,
      colors: [
        const Color(0xffaa4cfc),
        const Color(0xffFF1493),
      ],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(show: true, colors: [
        const Color(0xffaa4cfc).withOpacity(0.3),
        const Color(0xffFF1493).withOpacity(0.2),
      ]),
    );
    final LineChartBarData lineChartBarData2 = LineChartBarData(
      spots: dbpSpotsData,
      isCurved: true,
      curveSmoothness: 0,
      colors: [
        const Color(0xff00FA9A),
        const Color(0xff4af699),
      ],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(show: true, colors: [
        const Color(0xff00FA9A).withOpacity(0.2),
        const Color(0xff4af699).withOpacity(0.2),
      ]),
    );
    return [
      lineChartBarData1,
      lineChartBarData2,
    ];
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: false,
      ),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
            color: const Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: const Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 40:
                return '40';
              case 60:
                return '60';
              case 80:
                return '80';
              case 100:
                return '100';
              case 120:
                return '120';
              case 140:
                return '140';
              case 160:
                return '160';
              case 180:
                return '180';
              case 200:
                return '200';
              case 220:
                return '220';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(
              color: const Color(0xff4e4965),
              width: 4,
            ),
            left: BorderSide(
              color: Colors.transparent,
            ),
            right: BorderSide(
              color: Colors.transparent,
            ),
            top: BorderSide(
              color: Colors.transparent,
            ),
          )),
      minX: minx,
      maxX: maxx,
      maxY: (((max.toInt()) ~/ 10) * 10 + 10).toDouble(),
      minY: (((min.toInt()) ~/ 10) * 10 - 10).toDouble(),
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
    return [
      LineChartBarData(
        spots: getSBPAvgData(),
        isCurved: true,
        colors: [
          const Color(0xffaa4cfc),
          const Color(0xffFF1493),
        ],
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(show: true, colors: [
          const Color(0xffaa4cfc).withOpacity(0.3),
          const Color(0xffFF1493).withOpacity(0.2),
        ]),
      ),
      LineChartBarData(
        spots: getDBPAvgData(),
        isCurved: true,
        colors: [
          const Color(0xff00FA9A),
          const Color(0xff4af699),
        ],
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(show: true, colors: [
          const Color(0xff00FA9A).withOpacity(0.2),
          const Color(0xff4af699).withOpacity(0.2),
        ]),
      ),
    ];
  }
}
