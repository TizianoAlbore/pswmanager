import '../lib/utils/totp/totp.dart';
import 'package:test/test.dart';

void main(){
    final source = {
    DateTime.parse('2024-12-02T11:19:50Z'):{
      Algorithm.sha1: '724731',
    }
  };

  final algorithms = source.values.expand((element) => element.keys).toSet();
  late Totp totp;

  for (final algorithm in algorithms) {
    group(algorithm, () {
      setUp(() {
        totp = Totp(
          secret: 'JBSWY3DPEHPK3PXP'.codeUnits,
          digits: 6,
          period: 30,
          algorithm: algorithm,
        );
      });

      for (final DateTime dateTime in source.keys) {
        test("generate $dateTime", () {
          expect(totp.generate(dateTime), source[dateTime]![algorithm]);
        });

        test("validate $dateTime", () {
          expect(totp.validate(source[dateTime]![algorithm]!, dateTime), true);
        });
      }
    });
  }

}