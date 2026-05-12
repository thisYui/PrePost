# Đồ án 2 - Khai thác tập phổ biến bằng thuật toán PrePost

## 1. Thông tin chung

- **Môn học:** Khai thác dữ liệu và ứng dụng - CSC14004
- **Đồ án:** Frequent Itemset Mining - Nghiên cứu, Cài đặt & Đánh giá
- **Thuật toán được chọn:** PrePost
- **Ngôn ngữ cài đặt:** Julia >= 1.9

## 2. Thành viên nhóm

| MSSV | Họ và tên |
|---|---|
| 22120187 | Trần Thiên Lộc |
| 23120095 | Lưu Đức Toàn |
| 23120245 | Nguyễn Quang Duy |
| 23120258 | Lưu Trọng Hiếu |
| 23120260 | Văn Đình Hiếu |

## 3. Giới thiệu

Dự án này cài đặt lại thuật toán **PrePost** cho bài toán **Frequent Itemset Mining** từ đầu bằng ngôn ngữ **Julia**.

PrePost là thuật toán khai thác tập phổ biến dựa trên cấu trúc **PPC-tree** và **N-list**. Thuật toán không sinh candidate theo kiểu Apriori, mà mã hóa các node trên cây bằng cặp thứ tự duyệt **pre-order** và **post-order**. Từ đó, support của itemset được tính thông qua thao tác kết hợp các N-list thay vì quét lại toàn bộ cơ sở dữ liệu giao dịch.

Mục tiêu chính của đồ án:

- Cài đặt thuật toán PrePost từ đầu.
- Hỗ trợ đọc dữ liệu theo định dạng SPMF.
- Xuất tất cả frequent itemsets cùng support tương ứng.
- Kiểm tra độ đúng bằng cách so sánh với expected output và SPMF.
- Đánh giá thời gian chạy, bộ nhớ và khả năng mở rộng.
- Ứng dụng kết quả frequent itemset vào sinh luật kết hợp.

## 4. Cấu trúc thư mục

```text
PrePost/
│
├── README.md
├── Project.toml
├── Manifest.toml
│
├── src/
│   ├── PrePostFIM.jl
│   ├── cli.jl
│   │
│   ├── algorithm/
│   │   ├── prepost.jl
│   │   ├── mining.jl
│   │   └── output.jl
│   │
│   ├── structures/
│   │   ├── ppc_tree.jl
│   │   ├── nlist.jl
│   │   └── transaction_db.jl
│   │
│   └── utils/
│       ├── io_spmf.jl
│       ├── preprocessing.jl
│       ├── metrics.jl
│       └── timer.jl
│
├── tests/
│   ├── runtests.jl
│   ├── test_correctness.jl
│   ├── test_ppc_tree.jl
│   ├── test_nlist.jl
│   ├── test_io.jl
│   ├── test_benchmark.jl
│   └── test_optimization.jl
│
├── data/
│   ├── toy/
│   │   ├── example_basic.txt
│   │   ├── example_special_single_path.txt
│   │   └── expected/
│   │       ├── example_basic_minsup2.out
│   │       └── example_special_minsup2.out
│   │
│   ├── benchmark/
│   │   ├── chess.txt
│   │   ├── mushroom.txt
│   │   ├── retail.txt
│   │   └── T10I4D100K.txt
│   │
│   ├── subsets/
│   │   ├── retail_10.txt
│   │   ├── retail_25.txt
│   │   ├── retail_50.txt
│   │   ├── retail_75.txt
│   │   └── retail_100.txt
│   │
│   └── application/
│       ├── groceries.txt
│       └── groceries_metadata.md
│
├── cmd/                 # PowerShell scripts for Windows
│   ├── setup_datasets.ps1
│   ├── setup_julia_env.ps1
│   ├── create_retail_subsets.ps1
│   ├── check_project.ps1
│   ├── run_tests.ps1
│   ├── check_algorithms.ps1
│   ├── run_optimization_check.ps1
│   ├── run_benchmarks.ps1
│   └── clean_outputs.ps1
│
├── scripts/             # Bash scripts for Linux/macOS and helper Julia scripts
│   ├── setup_datasets.sh
│   ├── setup_julia_env.sh
│   ├── create_retail_subsets.sh
│   ├── check_project.sh
│   ├── run_tests.sh
│   ├── check_algorithms.sh
│   ├── run_optimization_check.sh
│   ├── run_benchmarks.sh
│   ├── clean_outputs.sh
│   └── optimization_check.jl
│
├── outputs/             # Generated outputs, ignored by Git
├── results/             # Generated experiment summaries, ignored by Git
├── logs/                # Generated logs, ignored by Git
│
├── notebooks/
│   ├── demo.ipynb
│   └── manual_example.ipynb
│
└── docs/
    ├── Report.tex
    ├── references.bib
    ├── chapters/
    │   ├── chapter1_theory.tex
    │   ├── chapter2_manual_examples.tex
    │   ├── chapter3_implementation.tex
    │   ├── chapter4_experiments.tex
    │   └── chapter5_application.tex
    └── figures/
```

## 5. Cài đặt và chạy project

### 5.1. Yêu cầu hệ thống

- Julia >= 1.9
- Git
- PowerShell 7 trên Windows, hoặc Bash trên Linux/macOS
- Java >= 8 nếu cần chạy SPMF tham chiếu

Kiểm tra Julia:

```bash
julia --version
```

### 5.2. Setup trên Windows

Từ thư mục gốc project, chạy lần lượt:

```powershell
.\cmd\setup_datasets.ps1
```

```powershell
.\cmd\setup_julia_env.ps1
```

Sau khi dữ liệu đã được setup, tạo các subset của Retail dùng cho thực nghiệm scalability:

```powershell
.\cmd\create_retail_subsets.ps1
```

Kiểm tra lại cấu trúc project, dữ liệu, source code và các file cần thiết:

```powershell
.\cmd\check_project.ps1
```

Sau đó chạy kiểm thử:

```powershell
.\cmd\run_tests.ps1
```

Kiểm tra thuật toán trên hai toy datasets:

```powershell
.\cmd\check_algorithms.ps1
```

Kiểm tra so sánh phiên bản cơ bản và tối ưu cho Level 3:

```powershell
.\cmd\run_optimization_check.ps1
```

Nếu muốn chạy benchmark cho Chương 4:

```powershell
.\cmd\run_benchmarks.ps1
```

Dọn các file output sinh ra:

```powershell
.\cmd\clean_outputs.ps1
```

### 5.3. Setup trên Linux/macOS

Cấp quyền chạy cho các script nếu cần:

```bash
chmod +x scripts/*.sh
```

Chạy lần lượt:

```bash
bash scripts/setup_datasets.sh
```

```bash
bash scripts/setup_julia_env.sh
```

Sau khi dữ liệu đã được setup, tạo các subset của Retail:

```bash
bash scripts/create_retail_subsets.sh
```

Kiểm tra lại project:

```bash
bash scripts/check_project.sh
```

Chạy kiểm thử:

```bash
bash scripts/run_tests.sh
```

Kiểm tra thuật toán trên hai toy datasets:

```bash
bash scripts/check_algorithms.sh
```

Kiểm tra so sánh phiên bản cơ bản và tối ưu:

```bash
bash scripts/run_optimization_check.sh
```

Nếu muốn chạy benchmark cho Chương 4:

```bash
bash scripts/run_benchmarks.sh
```

Dọn các file output sinh ra:

```bash
bash scripts/clean_outputs.sh
```

## 6. Định dạng dữ liệu đầu vào

Chương trình hỗ trợ định dạng dữ liệu giống SPMF.

Ví dụ:

```text
1 2 3
1 3 4
2 3 5
1 2 3 5
2 3 4
```

Quy ước:

- Mỗi dòng là một transaction.
- Item là số nguyên.
- Các item trong cùng transaction cách nhau bằng khoảng trắng.
- Các dòng rỗng sẽ được bỏ qua.
- Nếu một dòng có phần sau ký tự `#`, phần đó được xem như chú thích và được bỏ qua.

## 7. Cách chạy thuật toán PrePost bằng CLI

Chạy trên dữ liệu toy:

```bash
julia --project=. src/cli.jl --input data/toy/example_basic.txt --minsup 2 --output outputs/toy/output_basic.out
```

Chạy trên dữ liệu benchmark:

```bash
julia --project=. src/cli.jl --input data/benchmark/chess.txt --minsup 2000 --output outputs/benchmark/our/chess_minsup2000.out
```

### Tham số dòng lệnh

| Tham số | Ý nghĩa | Bắt buộc |
|---|---|---|
| `--input` | Đường dẫn file dữ liệu đầu vào | Có |
| `--minsup` | Ngưỡng support tuyệt đối | Có |
| `--output` | Đường dẫn file kết quả | Có |

## 8. Định dạng kết quả đầu ra

File output lưu frequent itemsets theo định dạng:

```text
1 #SUP: 3
2 #SUP: 4
3 #SUP: 5
1 2 #SUP: 2
1 3 #SUP: 3
1 2 3 #SUP: 2
```

Trong đó:

- Phần trước `#SUP:` là itemset.
- Phần sau `#SUP:` là support tuyệt đối của itemset.
- Các item trong mỗi itemset được sắp xếp tăng dần.
- Kết quả được chuẩn hóa để dễ so sánh với expected output.

## 9. Kiểm thử

Dự án có bộ unit test tự động trong thư mục `tests/`.

Chạy trên Windows:

```powershell
.\cmd\run_tests.ps1
```

Chạy trực tiếp bằng Julia:

```bash
julia --project=. tests/runtests.jl
```

Chạy trên Linux/macOS:

```bash
bash scripts/run_tests.sh
```

Các nhóm test chính:

| File test | Nội dung |
|---|---|
| `test_ppc_tree.jl` | Kiểm tra xây dựng PPC-tree và mã `pre`, `post` |
| `test_nlist.jl` | Kiểm tra tạo N-list, support và phép join N-list |
| `test_io.jl` | Kiểm tra đọc/ghi định dạng SPMF |
| `test_correctness.jl` | Kiểm tra độ đúng trên toy datasets và các trường hợp biên |
| `test_benchmark.jl` | Kiểm tra sự tồn tại của dữ liệu benchmark và benchmark helper |
| `test_optimization.jl` | Kiểm tra hai phiên bản basic và optimized cho cùng kết quả |

### Output kiểm thử gần nhất

```text
Running Julia tests...
Precompiling PrePostFIM finished.
  1 dependency successfully precompiled in 1 seconds
Starting PrePostFIM test suite...
Test Summary: | Pass  Total  Time
PrePostFIM    |   81     81  5.7s
Finished PrePostFIM test suite.
```

## 10. Kiểm tra thuật toán trên toy datasets

Chạy trên Windows:

```powershell
.\cmd\check_algorithms.ps1
```

Chạy trên Linux/macOS:

```bash
bash scripts/check_algorithms.sh
```

Kết quả gần nhất:

```text
Checking PrePost Algorithm

[1/5] Checking required files...
Required files found.

[2/5] Running basic toy dataset...
Frequent itemsets: 13

[3/5] Running special single-path dataset...
Frequent itemsets: 15

[5/5] Comparing results...
[PASSED] Basic dataset output matches expected.
[PASSED] Special dataset output matches expected.

Algorithm check PASSED
```

## 11. Level 3 - So sánh phiên bản cơ bản và tối ưu

Dự án cung cấp hai phiên bản:

- `prepost_basic`: phiên bản cơ bản.
- `prepost_optimized`: phiên bản tối ưu.
- `prepost`: mặc định gọi phiên bản tối ưu.

Tối ưu hiện tại:

- Phiên bản tối ưu áp dụng tỉa nhánh sớm trong quá trình khai thác N-list.
- Sau khi join N-list, nếu support của itemset mới nhỏ hơn `minsup`, itemset này bị loại bỏ ngay và không được mở rộng tiếp.
- Kỹ thuật này dựa trên tính chất Apriori/downward closure.

Chạy kiểm tra tối ưu trên Windows:

```powershell
.\cmd\run_optimization_check.ps1
```

Chạy trên Linux/macOS:

```bash
bash scripts/run_optimization_check.sh
```

Kết quả được ghi vào:

```text
results/optimization_summary.csv
```

Kết quả gần nhất:

```text
toy_basic minsup=2 itemsets=13 match=true basic=0.531s optimized=0.001s speedup=531.039x
toy_special_single_path minsup=2 itemsets=15 match=true basic=0.151s optimized=0.000s speedup=Inf
```

Lưu ý: Hai toy datasets có kích thước nhỏ nên thời gian chạy của phiên bản tối ưu có thể gần bằng 0 giây. Kết quả này chủ yếu dùng để kiểm tra rằng hai phiên bản sinh cùng itemset và support. Phần đánh giá hiệu năng đầy đủ được thực hiện ở Chương 4.

## 12. Benchmark datasets

Các tập dữ liệu dùng trong thực nghiệm:

| Dataset | Số transaction | Số item | Độ dài trung bình | Đặc điểm |
|---|---:|---:|---:|---|
| Chess | 3,196 | 75 | 37.0 | Dày đặc, itemset dài |
| Mushroom | 8,124 | 119 | 23.0 | Dày đặc, nhiều item |
| Retail | 88,162 | 16,470 | 10.3 | Thưa, dữ liệu thực tế |
| T10I4D100K | 100,000 | 870 | 10.1 | Tổng hợp, thưa |

Các file hiện được đặt trong:

```text
data/benchmark/
```

Các subset của Retail dùng cho thực nghiệm scalability:

```text
data/subsets/retail_10.txt
data/subsets/retail_25.txt
data/subsets/retail_50.txt
data/subsets/retail_75.txt
data/subsets/retail_100.txt
```

## 13. Chạy benchmark cho Chương 4

Chạy trên Windows:

```powershell
.\cmd\run_benchmarks.ps1
```

Chạy trên Linux/macOS:

```bash
bash scripts/run_benchmarks.sh
```

Các kết quả sinh ra được lưu trong:

```text
outputs/
results/
logs/
```

Các thư mục này là output sinh tự động và thường được ignore bởi Git.

## 14. Ứng dụng thực tế

Nhóm chọn ứng dụng:

```text
Market Basket Analysis
```

Dữ liệu ứng dụng:

```text
data/application/groceries.txt
data/application/groceries_metadata.md
```

Quy trình:

1. Chạy PrePost để tìm frequent itemsets.
2. Từ frequent itemsets, sinh luật kết hợp dạng `X => Y`.
3. Lọc các luật thỏa:
   - `support(X ∪ Y) >= minsup`
   - `confidence(X => Y) >= minconf`
4. Sắp xếp luật theo `lift`.
5. Báo cáo top-10 luật có lift cao nhất.

Công thức:

```text
confidence(X => Y) = support(X ∪ Y) / support(X)

lift(X => Y) = confidence(X => Y) / support(Y)
```

## 15. So sánh với SPMF

SPMF chỉ được sử dụng làm chương trình tham chiếu để kiểm tra độ đúng. Nhóm không sử dụng hoặc sao chép mã nguồn từ SPMF.

Quy trình so sánh:

1. Chạy thuật toán của nhóm trên cùng input và cùng `minsup`.
2. Chạy SPMF trên cùng input và cùng `minsup`.
3. Chuẩn hóa output.
4. So sánh:
   - số lượng frequent itemsets;
   - support của từng itemset;
   - tỉ lệ itemset khớp hoàn toàn.

## 16. Reproducibility

Để đảm bảo kết quả có thể tái sản xuất:

- Chạy setup bằng script trong `cmd/` hoặc `scripts/`.
- Ghi rõ phiên bản Julia.
- Dữ liệu toy và expected output được lưu trong repository.
- Các file output sinh ra nằm trong `outputs/`, `results/`, `logs/`.
- Không chỉnh sửa thủ công các file kết quả thực nghiệm.

Trước khi nộp bài, chạy lại:

Windows:

```powershell
.\cmd\clean_outputs.ps1
.\cmd\setup_datasets.ps1
.\cmd\setup_julia_env.ps1
.\cmd\create_retail_subsets.ps1
.\cmd\check_project.ps1
.\cmd\run_tests.ps1
.\cmd\check_algorithms.ps1
.\cmd\run_optimization_check.ps1
```

Linux/macOS:

```bash
bash scripts/clean_outputs.sh
bash scripts/setup_datasets.sh
bash scripts/setup_julia_env.sh
bash scripts/create_retail_subsets.sh
bash scripts/check_project.sh
bash scripts/run_tests.sh
bash scripts/check_algorithms.sh
bash scripts/run_optimization_check.sh
```

## 17. Tài liệu tham khảo

1. Deng, Z. H., Wang, Z., & Jiang, J. J. PrePost: A new method for mining frequent itemsets based on N-lists.
2. Deng, Z. H., & Lv, S. PrePost+: An efficient N-lists-based algorithm for mining frequent itemsets via children-parent equivalence pruning.
3. Agrawal, R., & Srikant, R. Fast Algorithms for Mining Association Rules.
4. Han, J., Pei, J., & Yin, Y. Mining Frequent Patterns without Candidate Generation.
5. SPMF Open-Source Data Mining Library.
6. FIMI Repository.
