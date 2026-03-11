import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/entities/chart_stats.dart';

/// Widget affichant les statistiques globales avec graphiques.
///
/// Ce widget affiche trois types de graphiques:
/// - Evolution des presences (ligne)
/// - Repartition par postes (camembert)
/// - Performance mensuelle (barres)
class StatsChartWidget extends StatefulWidget {
  /// Les donnees des graphiques.
  final ChartStats stats;

  /// Callback pour rafraichir les donnees.
  final VoidCallback? onRefresh;

  /// Callback pour changer la periode.
  final void Function(ChartPeriod)? onPeriodChanged;

  /// Periode actuellement selectionnee.
  final ChartPeriod selectedPeriod;

  /// Indique si les donnees sont en cours de chargement.
  final bool isLoading;

  const StatsChartWidget({
    super.key,
    required this.stats,
    this.onRefresh,
    this.onPeriodChanged,
    this.selectedPeriod = ChartPeriod.month,
    this.isLoading = false,
  });

  @override
  State<StatsChartWidget> createState() => _StatsChartWidgetState();
}

class _StatsChartWidgetState extends State<StatsChartWidget> {
  /// Cle globale pour capturer le widget en image.
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  /// Index du graphique actuellement affiche.
  int _currentChartIndex = 0;

  /// Liste des titres des graphiques.
  static const List<String> _chartTitles = [
    'Evolution des Presences',
    'Repartition par Postes',
    'Performance Mensuelle',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildPeriodSelector(context),
          _buildChartContent(context),
          _buildChartNavigation(context),
          _buildExportButtons(context),
        ],
      ),
    );
  }

  /// Construit l'en-tete du widget.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Statistiques Globales',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.onRefresh != null)
            IconButton(
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: widget.isLoading ? null : widget.onRefresh,
              tooltip: 'Rafraichir',
            ),
        ],
      ),
    );
  }

  /// Construit le selecteur de periode.
  Widget _buildPeriodSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<ChartPeriod>(
        segments: const [
          ButtonSegment(
            value: ChartPeriod.month,
            label: Text('Mois'),
            icon: Icon(Icons.calendar_today, size: 18),
          ),
          ButtonSegment(
            value: ChartPeriod.quarter,
            label: Text('Trimestre'),
            icon: Icon(Icons.date_range, size: 18),
          ),
          ButtonSegment(
            value: ChartPeriod.season,
            label: Text('Saison'),
            icon: Icon(Icons.event, size: 18),
          ),
        ],
        selected: {widget.selectedPeriod},
        onSelectionChanged: widget.onPeriodChanged != null
            ? (Set<ChartPeriod> selection) {
                widget.onPeriodChanged!(selection.first);
              }
            : null,
      ),
    );
  }

  /// Construit le contenu du graphique actuel.
  Widget _buildChartContent(BuildContext context) {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: widget.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildCurrentChart(context),
      ),
    );
  }

  /// Construit le graphique actuellement selectionne.
  Widget _buildCurrentChart(BuildContext context) {
    if (widget.stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnee disponible',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    switch (_currentChartIndex) {
      case 0:
        return _PresenceEvolutionChart(data: widget.stats.presenceEvolution);
      case 1:
        return _RepartitionPostesChart(data: widget.stats.repartitionPostes);
      case 2:
        return _PerformanceMensuelleChart(
          data: widget.stats.performanceMensuelle,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Construit la navigation entre les graphiques.
  Widget _buildChartNavigation(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _chartTitles[_currentChartIndex],
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _chartTitles.length,
            (index) => GestureDetector(
              onTap: () => setState(() => _currentChartIndex = index),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentChartIndex == index
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construit les boutons d'export.
  Widget _buildExportButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: widget.stats.isEmpty ? null : () => _exportToPdf(),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
          ),
          ElevatedButton.icon(
            onPressed: widget.stats.isEmpty ? null : () => _exportToImage(),
            icon: const Icon(Icons.image),
            label: const Text('Export Image'),
          ),
        ],
      ),
    );
  }

  /// Exporte les graphiques en PDF.
  Future<void> _exportToPdf() async {
    try {
      // Capturer le widget en image
      final image = await _captureWidget();

      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la capture')),
          );
        }
        return;
      }

      // Creer le PDF
      final pdf = pw.Document();

      // Convertir l'image pour le PDF
      final pdfImage = pw.MemoryImage(image);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Statistiques Pepites Academy',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Periode: ${widget.selectedPeriod.toApiValue()}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Genere le: ${DateTime.now().toString()}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain)),
              ],
            );
          },
        ),
      );

      // Sauvegarder le fichier
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/stats_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Partager le fichier
      if (mounted) {
        await Share.shareXFiles([
          XFile(file.path),
        ], subject: 'Statistiques Pepites Academy');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  /// Exporte les graphiques en image.
  Future<void> _exportToImage() async {
    try {
      // Capturer le widget en image
      final image = await _captureWidget();

      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la capture')),
          );
        }
        return;
      }

      // Sauvegarder le fichier
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/stats_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(image);

      // Partager le fichier
      if (mounted) {
        await Share.shareXFiles([
          XFile(file.path),
        ], subject: 'Statistiques Pepites Academy');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  /// Capture le widget en image PNG.
  Future<Uint8List?> _captureWidget() async {
    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}

/// Graphique en ligne pour l'evolution des presences.
class _PresenceEvolutionChart extends StatelessWidget {
  final List<PresenceEvolutionPoint> data;

  const _PresenceEvolutionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Presences'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index].date.split('-').last,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxValue(data.map((e) => e.count).toList()),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= data.length) {
                  return null;
                }
                return LineTooltipItem(
                  '${data[index].date}: ${spot.y.toInt()}',
                  const TextStyle(fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getMaxValue(List<int> values) {
    if (values.isEmpty) return 10;
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'Aucune donnee de presence',
        style: TextStyle(color: Theme.of(context).disabledColor),
      ),
    );
  }
}

/// Graphique en camembert pour la repartition par postes.
class _RepartitionPostesChart extends StatelessWidget {
  final List<RepartitionPostePoint> data;

  const _RepartitionPostesChart({required this.data});

  static const List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((e) => e.count == 0)) {
      return _buildEmptyState(context);
    }

    final total = data.fold<int>(0, (sum, e) => sum + e.count);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final percentage = total > 0
                    ? ((item.count / total) * 100).toStringAsFixed(1)
                    : '0';

                return PieChartSectionData(
                  value: item.count.toDouble(),
                  title: '$percentage%',
                  color: _colors[index % _colors.length],
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(child: _buildLegend(context)),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _colors[index % _colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.poste} (${item.count})',
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'Aucune donnee de repartition',
        style: TextStyle(color: Theme.of(context).disabledColor),
      ),
    );
  }
}

/// Graphique en barres pour la performance mensuelle.
class _PerformanceMensuelleChart extends StatelessWidget {
  final List<PerformanceMensuellePoint> data;

  const _PerformanceMensuelleChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (group.x < 0 || group.x >= data.length) {
                return null;
              }
              return BarTooltipItem(
                '${data[group.x.toInt()].mois}: ${rod.toY.toStringAsFixed(1)}/5',
                const TextStyle(fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Note /5'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index].mois.substring(0, 3),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.moyenne,
                color: _getBarColor(entry.value.moyenne),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getBarColor(double value) {
    if (value >= 4) return Colors.green;
    if (value >= 3) return Colors.lightGreen;
    if (value >= 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'Aucune donnee de performance',
        style: TextStyle(color: Theme.of(context).disabledColor),
      ),
    );
  }
}
