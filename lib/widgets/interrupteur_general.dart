import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class InterrupteurGeneralBloc extends StatelessWidget {
  const InterrupteurGeneralBloc({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ALIM GÉNÉRALE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Switch(
                value: provider.mainSwitchOn,
                onChanged: (v) => provider.setMainSwitchOn(v),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
