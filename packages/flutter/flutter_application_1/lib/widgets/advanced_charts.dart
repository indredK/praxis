import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/mock_data_service.dart';

class AdvancedCharts {
  // 炫酷的价格对比柱状图
  static Widget buildPriceComparisonChart(List<Product> products) {
    return SfCartesianChart(
      title: ChartTitle(
        text: '价格对比',
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: '产品'),
        labelRotation: -45,
        labelIntersectAction: AxisLabelIntersectAction.multipleRows,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: '价格 (\$)'),
        numberFormat: NumberFormat.currency(symbol: '\$'),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '产品信息',
        canShowMarker: true,
        color: Colors.black87,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries>[
        ColumnSeries<Product, String>(
          name: '价格',
          dataSource: products,
          xValueMapper: (Product product, _) => product.name,
          yValueMapper: (Product product, _) => product.price,
          pointColorMapper: (Product product, _) =>
              _parseColor(MockDataService.getCompanyColor(product.company)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          animationDuration: 2000,
          enableTooltip: true,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ],
    );
  }

  // 炫酷的性能雷达图
  static Widget buildPerformanceRadarChart(List<Product> products) {
    return SfCartesianChart(
      title: ChartTitle(
        text: '性能分析',
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: '性能指标'),
        labelRotation: 0,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: '评分'),
        minimum: 0,
        maximum: 100,
        interval: 20,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '性能详情',
        canShowMarker: true,
        color: Colors.black87,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries>[
        for (int i = 0; i < products.length; i++)
          LineSeries<Product, String>(
            name: products[i].name,
            dataSource: [products[i]],
            xValueMapper: (Product product, _) => '性能',
            yValueMapper: (Product product, _) =>
                MockDataService.calculatePerformanceScore(product),
            pointColorMapper: (Product product, _) =>
                _parseColor(MockDataService.getCompanyColor(product.company)),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            animationDuration: 2000 + (i * 500),
            enableTooltip: true,
            markerSettings: MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              shape: DataMarkerType.circle,
              color: _parseColor(
                MockDataService.getCompanyColor(products[i].company),
              ),
            ),
          ),
      ],
    );
  }

  // 炫酷的散点图 - 价格vs性能
  static Widget buildPriceVsPerformanceChart(List<Product> products) {
    return SfCartesianChart(
      title: ChartTitle(
        text: '价格 vs 性能分析',
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      primaryXAxis: NumericAxis(
        title: AxisTitle(text: '价格 (\$)'),
        numberFormat: NumberFormat.currency(symbol: '\$'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: '性能评分'),
        minimum: 0,
        maximum: 100,
        interval: 20,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '产品分析',
        canShowMarker: true,
        color: Colors.black87,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries>[
        ScatterSeries<Product, double>(
          name: '产品',
          dataSource: products,
          xValueMapper: (Product product, _) => product.price,
          yValueMapper: (Product product, _) =>
              MockDataService.calculatePerformanceScore(product),
          pointColorMapper: (Product product, _) =>
              _parseColor(MockDataService.getCompanyColor(product.company)),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.auto,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            builder:
                (
                  dynamic data,
                  dynamic point,
                  dynamic series,
                  int pointIndex,
                  int seriesIndex,
                ) {
                  return Text(
                    products[pointIndex].name,
                    style: const TextStyle(fontSize: 8),
                  );
                },
          ),
          animationDuration: 2000,
          enableTooltip: true,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 8,
            width: 8,
            shape: DataMarkerType.circle,
          ),
        ),
      ],
    );
  }

  // 炫酷的饼图 - 市场份额
  static Widget buildMarketShareChart(List<Product> products) {
    // 按公司分组计算市场份额
    final Map<String, double> companyShares = {};
    for (final product in products) {
      companyShares[product.company] =
          (companyShares[product.company] ?? 0) + 1;
    }

    final List<ChartDataPoint> chartData = companyShares.entries.map((entry) {
      return ChartDataPoint(
        entry.key,
        entry.value.toDouble(),
        _parseColor(MockDataService.getCompanyColor(entry.key)),
      );
    }).toList();

    return SfCircularChart(
      title: ChartTitle(
        text: '市场份额分布',
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '市场份额',
        canShowMarker: true,
        color: Colors.black87,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CircularSeries>[
        PieSeries<ChartDataPoint, String>(
          name: '市场份额',
          dataSource: chartData,
          xValueMapper: (ChartDataPoint data, _) => data.x,
          yValueMapper: (ChartDataPoint data, _) => data.y,
          pointColorMapper: (ChartDataPoint data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          animationDuration: 2000,
          enableTooltip: true,
          explode: true,
          explodeOffset: '10%',
        ),
      ],
    );
  }

  // 炫酷的折线图 - 价格趋势
  static Widget buildPriceTrendChart(List<Product> products) {
    return SfCartesianChart(
      title: ChartTitle(
        text: '价格趋势分析',
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: '产品'),
        labelRotation: -45,
        labelIntersectAction: AxisLabelIntersectAction.multipleRows,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: '价格 (\$)'),
        numberFormat: NumberFormat.currency(symbol: '\$'),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '价格信息',
        canShowMarker: true,
        color: Colors.black87,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries>[
        LineSeries<Product, String>(
          name: '价格趋势',
          dataSource: products,
          xValueMapper: (Product product, _) => product.name,
          yValueMapper: (Product product, _) => product.price,
          pointColorMapper: (Product product, _) =>
              _parseColor(MockDataService.getCompanyColor(product.company)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.auto,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          animationDuration: 2000,
          enableTooltip: true,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
          ),
        ),
      ],
    );
  }

  static Color _parseColor(String colorString) {
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}

// 图表数据模型
class ChartDataPoint {
  final String x;
  final double y;
  final Color color;

  ChartDataPoint(this.x, this.y, this.color);
}
