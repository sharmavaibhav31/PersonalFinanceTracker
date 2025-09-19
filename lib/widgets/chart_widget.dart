import 'package:flutter/material.dart';

class PlaceholderPieChart extends StatelessWidget {
  final Map<String, double> data; // label -> value
  const PlaceholderPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Placeholder pie chart using a simple wrap of colored chips
    final total = data.values.fold<double>(0, (p, c) => p + c);
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.green,
    ];
    int colorIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: data.entries.map((e) {
            final color = colors[colorIndex++ % colors.length];
            final percent = total == 0 ? 0 : (e.value / total * 100);
            return Chip(
              avatar: CircleAvatar(backgroundColor: color),
              label: Text('${e.key}: ${percent.toStringAsFixed(0)}%'),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
          ),
          child: Row(
            children: data.entries.map((e) {
              final widthFactor = total == 0 ? 0.0 : e.value / total;
              final color = colors[data.keys.toList().indexOf(e.key) % colors.length];
              return Expanded(
                flex: (widthFactor * 1000).round().clamp(0, 1000),
                child: Container(color: color),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}


