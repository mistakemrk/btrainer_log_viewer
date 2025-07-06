## ステップ2のリファクタリングにおける既知のバグ (テストカバレッジ向上)

このドキュメントは、リファクタリングのステップ2でテストが失敗する原因となっている既知のバグを列挙しています。このステップの主な目的はテストカバレッジを確立し、将来のバグ修正のための領域を特定することであるため、これらのバグは意図的に修正されていません。

---

### 1. `calculateNMEAChecksum` のバグ

*   **説明:** `calculateNMEAChecksum` 関数は、`$` と `*` の間にデータがないNMEAセンテンス（例: `'$*54'`）に対して誤って `null` を返します。期待される動作は、このようなケースで `'00'` を返すことです。
*   **影響を受けるテスト:** `test/utils/nmea_parser_test.dart` - `NmeaParser calculateNMEAChecksum should handle sentence with no data between $ and *`

---

### 2. NMEAパーサー関数 (`parsePSNYWOL`, `parsePSNYMMP`) のバグ

*   **説明:** `parsePSNYWOL` および `parsePSNYMMP` 関数（および場合によっては `parsePSNYEHR`）は、パースする前にNMEAセンテンスの末尾にあるチェックサム部分（`*XX`）を正しく除去していません。このため、最後のデータフィールドにチェックサムが含まれてしまいます。
*   **影響を受けるテスト:**
    *   `test/utils/nmea_parser_test.dart` - `NmeaParser parsePSNYWOL should correctly parse a valid PSNYWOL sentence`
    *   `test/utils/nmea_parser_test.dart` - `NmeaParser parsePSNYMMP should correctly parse a valid PSNYMMP sentence`
    *   `test/utils/nmea_parser_test.dart` - `NmeaParser parsePSNYMMP should handle missing parts`

---

### 3. `calculateDistance` のバグ

*   **説明:** `calculateDistance` 関数は、東京駅と新宿駅間の距離を計算する際に、期待される値（約6.1km）とわずかに異なる値を返します。これは、計算の精度、または期待値の厳密さの問題である可能性があります。
*   **影響を受けるテスト:** `test/logic_test.dart` - `Top-level functions from main.dart calculateDistance should calculate the correct distance between two points`