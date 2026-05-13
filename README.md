# Đồ án 2 - Khai thác tập phổ biến bằng thuật toán PrePost

## 1. Thông tin chung

- **Môn học:** Khai thác dữ liệu và ứng dụng - CSC14004
- **Đồ án:** Frequent Itemset Mining - Nghiên cứu, Cài đặt & Đánh giá
- **Thuật toán được chọn:** PrePost
- **Ngôn ngữ cài đặt chính:** Julia >= 1.9
- **Ứng dụng minh họa:** Market Basket Analysis trên dữ liệu groceries

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
- Ứng dụng kết quả frequent itemset vào sinh luật kết hợp trong bài toán Market Basket Analysis.

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
│   ├── synthetic/
│   │   ├── synthetic_avg5.txt
│   │   ├── synthetic_avg10.txt
│   │   ├── synthetic_avg20.txt
│   │   ├── synthetic_avg40.txt
│   │   └── synthetic_avg80.txt
│   │
│   └── application/
│       ├── groceries.txt
│       └── groceries_metadata.md
│
├── cmd/                 # PowerShell scripts cho Windows
├── scripts/             # Bash scripts cho Linux/macOS và helper Julia scripts
├── outputs/             # Output sinh tự động, thường được ignore bởi Git
├── logs/                # Log chạy thực nghiệm, thường được ignore bởi Git
│
├── notebooks/
│   ├── demo.ipynb
│   ├── experiment_analysis.ipynb
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

## 5. Yêu cầu hệ thống

Cần cài đặt:

- Julia >= 1.9
- Git
- PowerShell 7 trên Windows, hoặc Bash trên Linux/macOS
- Java >= 8 nếu cần chạy SPMF tham chiếu
- Python >= 3.9 nếu cần chạy notebook phân tích hoặc trực quan hóa
- Jupyter Notebook hoặc JupyterLab nếu cần mở notebook

Kiểm tra Julia:

```bash
julia --version
```

Kiểm tra Java, nếu muốn chạy SPMF:

```bash
java -version
```

## 6. Cài đặt và chạy project

### 6.1. Setup trên Windows

Từ thư mục gốc project, chạy lần lượt:

```powershell
.\cmd\setup_datasets.ps1
```

```powershell
.\cmd\setup_julia_env.ps1
```

Kiểm tra lại cấu trúc project, dữ liệu, source code và các file cần thiết:

```powershell
.\cmd\check_project.ps1
```

Chạy kiểm thử:

```powershell
.\cmd\run_tests.ps1
```

Kiểm tra thuật toán trên 5 toy datasets:

```powershell
.\cmd\check_algorithms.ps1
```

Kiểm tra so sánh phiên bản cơ bản và tối ưu:

```powershell
.\cmd\run_optimization_check.ps1
```

Nếu cần tải SPMF và sinh output tham chiếu bằng FP-Growth:

```powershell
.\cmd\download_and_run_spmf_fpgrowth.ps1
```

Nếu muốn chạy benchmark cho Chương 4:

```powershell
.\cmd\run_benchmarks.ps1
```

Dọn các file output sinh ra:

```powershell
.\cmd\clean_outputs.ps1
```

### 6.2. Setup trên Linux/macOS

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

Kiểm tra lại project:

```bash
bash scripts/check_project.sh
```

Chạy kiểm thử:

```bash
bash scripts/run_tests.sh
```

Kiểm tra thuật toán trên 5 toy datasets:

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

## 7. Định dạng dữ liệu đầu vào

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

## 8. Cách chạy thuật toán PrePost bằng CLI

Chạy trên dữ liệu toy:

```bash
julia --project=. src/cli.jl --input data/toy/example_basic.txt --minsup 2 --output outputs/toy/output_basic.out
```

Chạy trên dữ liệu benchmark:

```bash
julia --project=. src/cli.jl --input data/benchmark/chess.txt --minsup 2000 --output outputs/benchmark/our/chess_minsup2000.out
```

### 8.1. Tham số dòng lệnh

| Tham số | Ý nghĩa | Bắt buộc |
|---|---|---|
| `--input` | Đường dẫn file dữ liệu đầu vào | Có |
| `--minsup` | Ngưỡng support tuyệt đối | Có |
| `--output` | Đường dẫn file kết quả | Có |

## 9. Định dạng kết quả đầu ra

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
- Kết quả được chuẩn hóa để dễ so sánh với expected output và SPMF.

## 10. Kiểm thử

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

Output kiểm thử gần nhất:

```text
Running Julia tests...
Starting PrePostFIM test suite...
Test Summary: | Pass  Total  Time
PrePostFIM    |  103    103  3.9s
Finished PrePostFIM test suite.
```

## 11. Kiểm tra thuật toán trên toy datasets

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

[2/5] Running 5 toy datasets...
Running Basic dataset...
Frequent itemsets: 13
Running Special dataset...
Frequent itemsets: 15
Running Sparse dataset...
Frequent itemsets: 5
Running Infrequent-items dataset...
Frequent itemsets: 6
Running Duplicates-long dataset...
Frequent itemsets: 15
All toy datasets finished.

[3/5] Normalizing outputs...
Normalization finished.

[4/5] Comparing results...
[PASSED] Basic dataset output matches expected.
[PASSED] Special dataset output matches expected.
[PASSED] Sparse dataset output matches expected.
[PASSED] Infrequent-items dataset output matches expected.
[PASSED] Duplicates-long dataset output matches expected.

[5/5] Final status...
Algorithm check PASSED
```

Bộ toy datasets dùng cho Level 2:

| Dataset | Tình huống kiểm thử | minsup | Số FI |
|---|---|---:|---:|
| `example_basic.txt` | Ví dụ cơ sở ở Chương 2 | 2 | 13 |
| `example_special_single_path.txt` | PPC-tree một nhánh | 2 | 15 |
| `example_sparse.txt` | Dữ liệu thưa, ít giao nhau | 2 | 5 |
| `example_with_infrequent_items.txt` | Có item không phổ biến cần bị loại | 2 | 6 |
| `example_duplicates_long.txt` | Giao dịch trùng và itemset dài | 2 | 15 |

## 12. Level 3 - So sánh phiên bản cơ bản và tối ưu

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
toy_basic minsup=2 itemsets=13 match=true basic=0.189s optimized=0.0s speedup=Infx
toy_special_single_path minsup=2 itemsets=15 match=true basic=0.081s optimized=0.0s speedup=Infx
toy_sparse minsup=2 itemsets=5 match=true basic=0.0s optimized=0.0s speedup=Infx
toy_with_infrequent_items minsup=2 itemsets=6 match=true basic=0.0s optimized=0.0s speedup=Infx
toy_duplicates_long minsup=2 itemsets=15 match=true basic=0.0s optimized=0.0s speedup=Infx
```

Lưu ý: các toy datasets có kích thước nhỏ nên thời gian chạy của phiên bản tối ưu có thể gần bằng 0 giây. Kết quả này chủ yếu dùng để kiểm tra rằng hai phiên bản sinh cùng itemset và support. Phần đánh giá hiệu năng đầy đủ được thực hiện ở Chương 4.

## 13. Benchmark datasets

Các tập dữ liệu dùng trong thực nghiệm:

| Dataset | Số transaction | Số item | Độ dài trung bình | Đặc điểm |
|---|---:|---:|---:|---|
| Chess | 3,196 | 75 | 37.0 | Dày đặc, itemset dài |
| Mushroom | 8,124 | 119 | 23.0 | Dày đặc, nhiều item |
| Retail | 88,162 | 16,470 | 10.3 | Thưa, dữ liệu thực tế |
| T10I4D100K | 100,000 | 870 | 10.1 | Tổng hợp, thưa |

Các file benchmark được đặt trong:

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

## 14. Chạy benchmark cho Chương 4

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

## 15. Ứng dụng thực tế - Market Basket Analysis

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
4. Tính các chỉ số đánh giá luật:
   - support
   - confidence
   - lift
   - leverage
   - conviction
5. Sắp xếp luật theo `lift`.
6. Báo cáo các luật nổi bật và phân tích ý nghĩa kinh doanh.

Công thức:

```text
confidence(X => Y) = support(X ∪ Y) / support(X)

lift(X => Y) = confidence(X => Y) / support(Y)
```

Ý nghĩa ứng dụng:

- Tìm các mặt hàng thường được mua cùng nhau.
- Gợi ý bố trí sản phẩm trong cửa hàng.
- Hỗ trợ tạo combo khuyến mãi.
- Hỗ trợ đề xuất sản phẩm mua kèm.
- Phân tích hành vi mua sắm của khách hàng.

Ví dụ luật kết hợp:

```text
root vegetables, whole milk => other vegetables
```

Luật này có thể được hiểu là: khi khách hàng mua `root vegetables` và `whole milk`, họ có xu hướng mua thêm `other vegetables`. Cửa hàng có thể tận dụng kết quả này để bố trí sản phẩm liên quan gần nhau hoặc đề xuất mua kèm.

## 16. Hướng dẫn chạy notebook

Dự án có thư mục `notebooks/` chứa các notebook dùng để minh họa thuật toán, phân tích thực nghiệm và ứng dụng thực tế.

```text
notebooks/
├── demo.ipynb
├── experiment_analysis.ipynb
└── manual_example.ipynb
```

### 16.1. Mục đích từng notebook

| Notebook | Mục đích |
|---|---|
| `manual_example.ipynb` | Minh họa từng bước cách thuật toán PrePost hoạt động trên ví dụ nhỏ, bao gồm PPC-tree, mã `pre`, mã `post` và N-list. |
| `demo.ipynb` | Demo quy trình ứng dụng PrePost cho Market Basket Analysis trên dữ liệu groceries. Notebook này đọc dữ liệu giao dịch, khai thác frequent itemsets, sinh luật kết hợp, tính các chỉ số đánh giá và trực quan hóa kết quả. |
| `experiment_analysis.ipynb` | Phân tích kết quả thực nghiệm, đọc các file trong `results/`, tổng hợp thời gian chạy, số lượng itemset và trực quan hóa benchmark. |

### 16.2. Cài đặt package để chạy notebook

Cài Jupyter và các thư viện Python thường dùng:

```bash
pip install pandas numpy matplotlib seaborn mlxtend jupyter
```

Nếu muốn chạy notebook với kernel Julia, cài thêm `IJulia`:

```bash
julia --project=.
```

Sau đó trong Julia REPL:

```julia
using Pkg
Pkg.add("IJulia")
```

### 16.3. Cách mở notebook

Từ thư mục gốc của project, chạy:

```bash
jupyter notebook
```

hoặc:

```bash
jupyter lab
```

Sau đó mở file trong thư mục:

```text
notebooks/
```

Nên mở Jupyter từ **thư mục gốc project** thay vì mở trực tiếp trong thư mục `notebooks/`, vì nhiều đường dẫn trong notebook có thể tham chiếu đến `data/`, `src/`, `outputs/` hoặc `results/`.

### 16.4. Chuẩn bị dữ liệu trước khi chạy notebook

Trước khi chạy notebook, nên setup dữ liệu và môi trường Julia.

Trên Windows:

```powershell
.\cmd\setup_datasets.ps1
.\cmd\setup_julia_env.ps1
.\cmd\create_retail_subsets.ps1
```

Trên Linux/macOS:

```bash
bash scripts/setup_datasets.sh
bash scripts/setup_julia_env.sh
bash scripts/create_retail_subsets.sh
```

Nếu notebook phân tích benchmark, cần chạy benchmark trước để sinh dữ liệu trong `results/`:

Windows:

```powershell
.\cmd\run_benchmarks.ps1
```

Linux/macOS:

```bash
bash scripts/run_benchmarks.sh
```

### 16.5. Thông tin về `demo.ipynb`

Notebook `demo.ipynb` minh họa ứng dụng của frequent itemset mining vào bài toán **Market Basket Analysis**.

Quy trình chính trong notebook gồm:

1. Đọc dữ liệu giao dịch từ tập groceries.
2. Tiền xử lý dữ liệu thành danh sách transaction.
3. Khám phá dữ liệu ban đầu, ví dụ:
   - số lượng transaction;
   - số lượng item khác nhau;
   - độ dài trung bình của giỏ hàng;
   - các item phổ biến nhất.
4. Chạy thuật toán PrePost hoặc phiên bản fallback để tìm frequent itemsets.
5. Sinh luật kết hợp từ frequent itemsets.
6. Tính các chỉ số đánh giá luật:
   - support;
   - confidence;
   - lift;
   - leverage;
   - conviction.
7. Trực quan hóa kết quả:
   - biểu đồ item phổ biến;
   - phân bố kích thước giỏ hàng;
   - ma trận co-occurrence;
   - heatmap lift;
   - bubble chart cho luật kết hợp.
8. Phân tích ý nghĩa kinh doanh của các luật kết hợp.

Notebook này giúp trả lời các câu hỏi:

- Những mặt hàng nào thường được mua cùng nhau?
- Những itemset nào xuất hiện phổ biến trong dữ liệu?
- Luật kết hợp nào có độ tin cậy cao?
- Những luật nào có lift cao và có thể dùng để gợi ý mua kèm?
- Có thể áp dụng kết quả vào bố trí sản phẩm hoặc khuyến mãi như thế nào?

### 16.6. Kết quả chính trong notebook demo

Với dữ liệu groceries, notebook thực hiện phân tích trên dữ liệu giao dịch bán lẻ gồm nhiều mặt hàng tiêu dùng hằng ngày.

Một số mặt hàng phổ biến thường xuất hiện trong dữ liệu gồm:

- `whole milk`
- `other vegetables`
- `rolls/buns`
- `soda`
- `yogurt`
- `root vegetables`

Một số hướng ứng dụng từ các luật kết hợp:

- Đặt các sản phẩm thường mua cùng nhau ở vị trí gần nhau.
- Tạo combo khuyến mãi.
- Đề xuất sản phẩm mua kèm.
- Hỗ trợ phân tích hành vi mua sắm của khách hàng.

Ví dụ, nếu luật có dạng:

```text
root vegetables, whole milk => other vegetables
```

thì có thể hiểu rằng khi khách hàng mua `root vegetables` và `whole milk`, họ có xu hướng mua thêm `other vegetables`.

### 16.7. Lưu ý khi chạy notebook

- Nếu notebook gọi trực tiếp Julia CLI, cần đảm bảo lệnh `julia` đã có trong `PATH`.
- Nếu notebook đọc file trong `data/`, cần chạy các script setup dữ liệu trước.
- Nếu notebook đọc kết quả trong `outputs/` hoặc `results/`, cần chạy thuật toán hoặc benchmark trước để sinh file.
- Nếu chạy trên Windows, cần chú ý khác biệt giữa dấu `/` và `\` trong đường dẫn.
- Nếu notebook không chạy được do thiếu package Python, cài thêm bằng `pip install`.
- Nếu notebook không nhận kernel Julia, cần cài `IJulia`.
- Nên chạy notebook theo thứ tự từ trên xuống dưới để tránh lỗi thiếu biến hoặc thiếu file trung gian.

### 16.8. Thứ tự chạy khuyến nghị

Để tái hiện đầy đủ kết quả, nên chạy theo thứ tự:

```text
1. Setup dữ liệu
2. Setup môi trường Julia
3. Chạy test để kiểm tra project
4. Chạy thuật toán hoặc benchmark nếu cần
5. Mở notebook
6. Chạy notebook từ trên xuống dưới
```

Trên Windows:

```powershell
.\cmd\setup_datasets.ps1
.\cmd\setup_julia_env.ps1
.\cmd\run_tests.ps1
jupyter notebook
```

Trên Linux/macOS:

```bash
bash scripts/setup_datasets.sh
bash scripts/setup_julia_env.sh
bash scripts/run_tests.sh
jupyter notebook
```

## 17. So sánh với SPMF

SPMF chỉ được sử dụng làm chương trình tham chiếu để kiểm tra độ đúng. Nhóm không sử dụng hoặc sao chép mã nguồn từ SPMF.

Trong project này, SPMF được đặt trong thư mục riêng:

```text
spmf/
├── spmf.jar
└── reference_outputs/
```

Trong đó:

- `spmf/spmf.jar` là file chạy chính của SPMF.
- `spmf/reference_outputs/` chứa các output tham chiếu do SPMF sinh ra.
- Thuật toán SPMF dùng để sinh reference output là **FP-Growth** cho bài toán frequent itemset mining.
- Output của SPMF chỉ dùng để so sánh độ đúng, không dùng trong quá trình cài đặt thuật toán PrePost.

### 17.1. Tải SPMF và sinh output tham chiếu bằng FP-Growth

Trên Windows, chạy script:

```powershell
.\cmd\download_and_run_spmf_fpgrowth.ps1
```

Script này thực hiện các bước:

1. Kiểm tra Java có sẵn trong `PATH` hay không.
2. Tạo thư mục `spmf/` nếu chưa tồn tại.
3. Tải `spmf.jar` nếu file này chưa có.
4. Tạo thư mục `spmf/reference_outputs/`.
5. Chạy FP-Growth của SPMF trên các benchmark datasets.
6. Ghi output tham chiếu vào `spmf/reference_outputs/`.

Các output tham chiếu được đặt tên theo dataset và minsup, ví dụ:

```text
spmf/reference_outputs/chess_fpgrowth_minsup2557.out
spmf/reference_outputs/mushroom_fpgrowth_minsup2438.out
spmf/reference_outputs/retail_fpgrowth_minsup441.out
spmf/reference_outputs/T10I4D100K_fpgrowth_minsup1000.out
```

### 17.2. Minsup dùng khi chạy SPMF

Cài đặt Julia của nhóm nhận `minsup` là **support tuyệt đối**. Vì vậy khi chạy SPMF để so sánh, nhóm cũng dùng cùng giá trị minsup tuyệt đối.

| Dataset | Số transaction | Mức chọn tương ứng | minsup tuyệt đối |
|---|---:|---:|---:|
| Chess | 3,196 | 80% | 2,557 |
| Mushroom | 8,124 | 30% | 2,438 |
| Retail | 88,162 | 0.5% | 441 |
| T10I4D100K | 100,000 | 1% | 1,000 |

Công thức quy đổi nếu cần:

```text
minsup_abs = ceil(minsup_percent * số_giao_dịch)
```

Ví dụ với Chess:

```text
ceil(0.80 * 3196) = 2557
```

### 17.3. Lệnh chạy FP-Growth thủ công

Nếu không dùng script, có thể chạy trực tiếp như sau trên Windows PowerShell:

```powershell
java -jar spmf\spmf.jar run FPGrowth_itemsets `
  data\benchmark\chess.txt `
  spmf\reference_outputs\chess_fpgrowth_minsup2557.out `
  2557
```

Các dataset còn lại:

```powershell
java -jar spmf\spmf.jar run FPGrowth_itemsets `
  data\benchmark\mushroom.txt `
  spmf\reference_outputs\mushroom_fpgrowth_minsup2438.out `
  2438

java -jar spmf\spmf.jar run FPGrowth_itemsets `
  data\benchmark\retail.txt `
  spmf\reference_outputs\retail_fpgrowth_minsup441.out `
  441

java -jar spmf\spmf.jar run FPGrowth_itemsets `
  data\benchmark\T10I4D100K.txt `
  spmf\reference_outputs\T10I4D100K_fpgrowth_minsup1000.out `
  1000
```

Ví dụ chạy Julia trên Chess với cùng `minsup = 2557`:

```powershell
julia --project=. src\cli.jl `
  --input data\benchmark\chess.txt `
  --minsup 2557 `
  --output outputs\benchmark\ours\chess_minsup2557.out
```

Lưu ý: Nếu SPMF báo lỗi khi truyền `minsup` dạng số nguyên, có thể đổi sang dạng phần trăm tương ứng, ví dụ `80%`. Khi báo cáo, cần ghi rõ hai cách biểu diễn này là tương đương trên cùng dataset.

## 18. Reproducibility

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
.\cmd\download_and_run_spmf_fpgrowth.ps1
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

Nếu cần tái hiện notebook:

```text
1. Chạy setup dữ liệu.
2. Chạy setup môi trường Julia.
3. Chạy test để kiểm tra project.
4. Chạy benchmark nếu notebook cần đọc file trong results/.
5. Mở Jupyter từ thư mục gốc project.
6. Chạy notebook từ trên xuống dưới.
```

## 19. Tài liệu tham khảo

1. Deng, Z. H., Wang, Z., & Jiang, J. J. PrePost: A new method for mining frequent itemsets based on N-lists.
2. Deng, Z. H., & Lv, S. PrePost+: An efficient N-lists-based algorithm for mining frequent itemsets via children-parent equivalence pruning.
3. Agrawal, R., & Srikant, R. Fast Algorithms for Mining Association Rules.
4. Han, J., Pei, J., & Yin, Y. Mining Frequent Patterns without Candidate Generation.
5. SPMF Open-Source Data Mining Library.
6. FIMI Repository.
