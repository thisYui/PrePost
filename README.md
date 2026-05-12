# Đồ án 2 - Khai thác tập phổ biến bằng thuật toán PrePost

## 1. Thông tin chung

- **Môn học:** Khai thác dữ liệu và ứng dụng - CSC14004
- **Đồ án:** Frequent Itemset Mining - Nghiên cứu, Cài đặt & Đánh giá
- **Thuật toán được chọn:** PrePost
- **Ngôn ngữ cài đặt:** Julia >= 1.9

## 2. Thành viên nhóm

| MSSV     | Họ và tên |
|----------|---|---|
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
- Kiểm tra độ đúng bằng cách so sánh với SPMF.
- Đánh giá thời gian chạy, bộ nhớ và khả năng mở rộng.
- Ứng dụng kết quả frequent itemset vào sinh luật kết hợp.

## 4. Cấu trúc thư mục

```text
Group_ID/
│
├── README.md
├── Project.toml
├── Manifest.toml
│
├── src/
│   ├── PrePost.jl
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
│   ├── utils/
│   │   ├── io_spmf.jl
│   │   ├── preprocessing.jl
│   │   ├── metrics.jl
│   │   └── timer.jl
│   │
│   └── cli.jl
│
├── tests/
│   ├── runtests.jl
│   ├── test_correctness.jl
│   ├── test_ppc_tree.jl
│   ├── test_nlist.jl
│   ├── test_io.jl
│   └── test_benchmark.jl
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
│   │   ├── accidents.txt
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
├── experiments/
│   ├── run_correctness.jl
│   ├── run_runtime.jl
│   ├── run_memory.jl
│   ├── run_scalability.jl
│   ├── run_transaction_length.jl
│   └── generate_plots.jl
│
├── results/
│   ├── correctness/
│   │   ├── correctness_summary.csv
│   │   └── diff_logs/
│   │
│   ├── runtime/
│   │   ├── runtime_prepost.csv
│   │   ├── runtime_spmf.csv
│   │   └── runtime_comparison.csv
│   │
│   ├── memory/
│   │   ├── memory_basic.csv
│   │   └── memory_optimized.csv
│   │
│   ├── scalability/
│   │   └── scalability_retail.csv
│   │
│   ├── application/
│   │   ├── frequent_itemsets.csv
│   │   ├── association_rules.csv
│   │   └── top10_rules_by_lift.csv
│   │
│   └── figures/
│       ├── runtime_vs_minsup.png
│       ├── itemsets_vs_minsup.png
│       ├── memory_usage.png
│       ├── scalability.png
│       └── transaction_length_effect.png
│
├── notebooks/
│   ├── demo.ipynb
│   ├── manual_example.ipynb
│   └── experiment_analysis.ipynb
│
├── docs/
│   ├── Report.pdf
│   ├── Report.tex
│   ├── references.bib
│   │
│   ├── chapters/
│   │   ├── chapter1_theory.tex
│   │   ├── chapter2_manual_examples.tex
│   │   ├── chapter3_implementation.tex
│   │   ├── chapter4_experiments.tex
│   │   └── chapter5_application.tex
│   │
│   └── figures/
│       ├── ppc_tree_example.png
│       ├── prepost_order_example.png
│       ├── nlist_construction.png
│       └── algorithm_workflow.png
│
├── scripts/
│   ├── download_datasets.sh
│   ├── run_all_tests.sh
│   ├── run_all_experiments.sh
│   └── clean_outputs.sh
│
└── spmf/
    ├── spmf.jar
    ├── run_spmf_reference.sh
    └── reference_outputs/
        ├── chess/
        ├── mushroom/
        ├── retail/
        ├── accidents/
        └── T10I4D100K/
```

## 5. Cài đặt môi trường

### 5.1. Yêu cầu hệ thống

- Julia >= 1.9
- Java >= 8, dùng để chạy SPMF tham chiếu
- Git
- Hệ điều hành: Windows, Linux hoặc macOS

### 5.2. Cài đặt package Julia

Từ thư mục gốc của project, chạy:

```bash
julia --project=.
```

Trong Julia REPL, chạy:

```julia
using Pkg
Pkg.instantiate()
```

Hoặc chạy trực tiếp bằng lệnh:

```bash
julia --project=. -e "using Pkg; Pkg.instantiate()"
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
- Item là số nguyên dương.
- Các item trong cùng transaction cách nhau bằng khoảng trắng.
- Một transaction không chứa item trùng lặp.
- Các dòng rỗng sẽ được bỏ qua.

## 7. Cách chạy thuật toán PrePost

### 7.1. Chạy trên dữ liệu toy

```bash
julia --project=. src/cli.jl \
  --input data/toy/example_basic.txt \
  --minsup 2 \
  --output results/toy/example_basic_output.txt
```

### 7.2. Chạy trên benchmark

Ví dụ với tập dữ liệu Chess:

```bash
julia --project=. src/cli.jl \
  --input data/benchmark/chess.txt \
  --minsup 2000 \
  --output results/chess_output.txt
```

Ví dụ với tập dữ liệu Mushroom:

```bash
julia --project=. src/cli.jl \
  --input data/benchmark/mushroom.txt \
  --minsup 1000 \
  --output results/mushroom_output.txt
```

### 7.3. Tham số dòng lệnh

| Tham số | Ý nghĩa | Bắt buộc |
|---|---|---|
| `--input` | Đường dẫn file dữ liệu đầu vào | Có |
| `--minsup` | Ngưỡng support tuyệt đối | Có |
| `--output` | Đường dẫn file kết quả | Có |
| `--optimized` | Chạy phiên bản tối ưu hóa nếu có | Không |

Ví dụ chạy phiên bản tối ưu:

```bash
julia --project=. src/cli.jl \
  --input data/benchmark/retail.txt \
  --minsup 500 \
  --output results/retail_output.txt \
  --optimized
```

## 8. Định dạng kết quả đầu ra

File output lưu frequent itemsets theo định dạng:

```text
1 #SUP: 4
2 #SUP: 4
3 #SUP: 5
1 3 #SUP: 3
2 3 #SUP: 4
1 2 3 #SUP: 2
```

Trong đó:

- Phần trước `#SUP:` là itemset.
- Phần sau `#SUP:` là support tuyệt đối của itemset.

## 9. Chạy kiểm thử

Dự án có bộ unit test tự động trong thư mục `tests/`.

Chạy toàn bộ test:

```bash
julia --project=. tests/runtests.jl
```

Hoặc chạy bằng script:

```bash
bash scripts/run_all_tests.sh
```

Các nhóm test chính:

| File test | Nội dung |
|---|---|
| `test_ppc_tree.jl` | Kiểm tra xây dựng PPC-tree |
| `test_nlist.jl` | Kiểm tra tạo và kết hợp N-list |
| `test_io.jl` | Kiểm tra đọc/ghi định dạng SPMF |
| `test_correctness.jl` | So sánh output với kết quả mong đợi trên toy dataset |
| `test_benchmark.jl` | So sánh output với SPMF trên benchmark |

Sau khi chạy test, kết quả lần chạy cuối cần được ghi lại trong phần dưới đây.

### 9.1. Output kiểm thử lần cuối

```text
[Điền output của lần chạy tests/runtests.jl vào đây trước khi nộp bài]
```

## 10. So sánh với SPMF

SPMF chỉ được sử dụng làm chương trình tham chiếu để kiểm tra độ đúng. Nhóm không sử dụng hoặc sao chép mã nguồn từ SPMF.

### 10.1. Chạy SPMF tham chiếu

Ví dụ:

```bash
java -jar spmf/spmf.jar run PrePost \
  data/benchmark/chess.txt \
  spmf/reference_outputs/chess/output_minsup2000.txt \
  2000
```

Lưu ý: cú pháp chạy SPMF có thể thay đổi tùy phiên bản SPMF. Nếu lệnh trên không phù hợp, xem hướng dẫn chính thức của file `spmf.jar` đang sử dụng.

### 10.2. Chạy kiểm tra correctness

```bash
julia --project=. experiments/run_correctness.jl
```

Kết quả được lưu tại:

```text
results/correctness/correctness_summary.csv
```

Các chỉ số correctness:

- Số lượng frequent itemsets của nhóm.
- Số lượng frequent itemsets của SPMF.
- Tỉ lệ itemset khớp hoàn toàn.
- Số itemset thiếu.
- Số itemset dư.
- Số itemset sai support.

## 11. Chạy thực nghiệm

### 11.1. Thời gian chạy theo minsup

```bash
julia --project=. experiments/run_runtime.jl
```

Kết quả:

```text
results/runtime/runtime_prepost.csv
results/runtime/runtime_spmf.csv
results/runtime/runtime_comparison.csv
```

### 11.2. Đo bộ nhớ

```bash
julia --project=. experiments/run_memory.jl
```

Kết quả:

```text
results/memory/memory_basic.csv
results/memory/memory_optimized.csv
```

### 11.3. Thực nghiệm scalability

```bash
julia --project=. experiments/run_scalability.jl
```

Kết quả:

```text
results/scalability/scalability_retail.csv
```

### 11.4. Ảnh hưởng của độ dài giao dịch trung bình

```bash
julia --project=. experiments/run_transaction_length.jl
```

### 11.5. Sinh biểu đồ

```bash
julia --project=. experiments/generate_plots.jl
```

Các biểu đồ được lưu tại:

```text
results/figures/
```

## 12. Benchmark datasets

Các tập dữ liệu dùng trong thực nghiệm:

| Dataset | Số transaction | Số item | Độ dài trung bình | Đặc điểm |
|---|---:|---:|---:|---|
| Chess | 3,196 | 75 | 37.0 | Dày đặc, itemset dài |
| Mushroom | 8,124 | 119 | 23.0 | Dày đặc, nhiều item |
| Retail | 88,162 | 16,470 | 10.3 | Thưa, dữ liệu thực tế |
| Accidents | 340,183 | 468 | 33.8 | Rất lớn, dày đặc |
| T10I4D100K | 100,000 | 870 | 10.1 | Tổng hợp, thưa |

Nếu file benchmark vượt quá giới hạn dung lượng nộp bài, nhóm sẽ tải dữ liệu lên Google Drive và cung cấp link tại đây:

```text
[Điền link Google Drive chứa benchmark datasets nếu cần]
```

## 13. Ứng dụng thực tế

Nhóm chọn ứng dụng:

```text
Market Basket Analysis
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

Chạy ứng dụng:

```bash
julia --project=. experiments/run_application.jl
```

Kết quả:

```text
results/application/frequent_itemsets.csv
results/application/association_rules.csv
results/application/top10_rules_by_lift.csv
```

## 14. Tối ưu hóa

Phiên bản cơ bản:

- Đọc database.
- Lọc item không phổ biến.
- Xây dựng PPC-tree.
- Gán pre-order và post-order.
- Tạo N-list.
- Khai thác frequent itemsets từ N-list.

Phiên bản tối ưu dự kiến:

- Sử dụng cấu trúc dữ liệu gọn cho node của PPC-tree.
- Sắp xếp item theo support giảm dần để tăng khả năng nén cây.
- Tái sử dụng N-list trong quá trình khai thác.
- Giảm cấp phát bộ nhớ trong vòng lặp nóng.
- Dùng `@inbounds` tại các vị trí truy cập mảng an toàn.
- Tránh global variables không có kiểu cụ thể.

Kết quả so sánh bản cơ bản và bản tối ưu được lưu tại:

```text
results/memory/
results/runtime/
```

## 15. Reproducibility

Để đảm bảo kết quả có thể tái sản xuất:

- Cố định seed ngẫu nhiên trong các thí nghiệm tạo dữ liệu tổng hợp.
- Ghi rõ phiên bản Julia.
- Lưu toàn bộ tham số chạy thực nghiệm.
- Lưu output của lần chạy test cuối cùng trong README.
- Không chỉnh sửa thủ công các file kết quả thực nghiệm.

Kiểm tra phiên bản Julia:

```bash
julia --version
```

## 16. Tài liệu tham khảo

1. Deng, Z. H., Wang, Z., & Jiang, J. J. PrePost: A new method for mining frequent itemsets based on N-lists.
2. Tài liệu SPMF - Frequent Itemset Mining Algorithms.
3. Tài liệu FIMI Repository.
4. Giáo trình Khai thác dữ liệu và ứng dụng - CSC14004.
