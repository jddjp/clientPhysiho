
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';

class LoadingView extends StatelessWidget {
  final String sourceLoading;

  LoadingView({required this.sourceLoading});

  @override
  Widget build(BuildContext context) {
    changeStatusColor(primaryColor);
    return Scaffold(
      body: SafeArea(
          child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: spacing_standard_new),
            text(sourceLoading)
          ],
        ),
      )),
    );
  }
}
