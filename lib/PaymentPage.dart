import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final String orderId;

  const PaymentPage({super.key, required this.totalAmount, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  @override
  void initState() {
    super.initState();

    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
      customerKey: "a1b2c3d4e5f67890",
    );

    _paymentWidget.renderPaymentMethods(
      selector: 'methods',
      amount: Amount(value: widget.totalAmount, currency: Currency.KRW, country: "KR"),
    ).then((control) {
      _paymentMethodWidgetControl = control;
    });

    _paymentWidget.renderAgreement(selector: 'agreement').then((control) {
      _agreementWidgetControl = control;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("결제하기")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // ✅ 결제 수단 선택 UI
                  PaymentMethodWidget(paymentWidget: _paymentWidget, selector: 'methods'),
                  const SizedBox(height: 16),
                  // ✅ 약관 동의 UI
                  AgreementWidget(paymentWidget: _paymentWidget, selector: 'agreement'),
                  const SizedBox(height: 16),
                  // ✅ 결제하기 버튼
                  ElevatedButton(
                    onPressed: () async {
                      final paymentResult = await _paymentWidget.requestPayment(
                        paymentInfo: PaymentInfo(orderId: widget.orderId, orderName: '항공편 결제',
                ),
                      );

                      if (paymentResult.success != null) {
                        print("성공");
                        // ✅ 결제 성공 처리
                        // Navigator.pushNamed(context, "/payment-success");
                        Navigator.pop(context, {"status": "success", "orderId": widget.orderId});
                      } else if (paymentResult.fail != null) {
                        // ❌ 결제 실패 처리
                        // Navigator.pushNamed(context, "/payment-fail");
                        print("실패");
                        Navigator.pop(context, {"status": "fail"});
                      }
                    },
                    child: Text('${widget.totalAmount.toStringAsFixed(0)}원 결제하기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}