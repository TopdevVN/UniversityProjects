# Xây dựng mô hình phát hiện tin tuyển dụng giả
Ở dự án này mình xây dựng và đánh giá đồng thời ba mô hình phân lớp phổ biến (Naive Bayes. Random Forest và Logistic Regression), sau đó chọn ra mô hình tốt nhất để dự đoán tin tuyển dụng giả. <br>
<br>
**_Về dữ liệu_**: <br>
Dữ liệu bao gồm 17880 bài đăng tuyển dụng việc làm với 866 tin tuyển dụng là giả. <br>
___ 
**Các chỉ số đánh giá**: <br>
'Accuracy', 'Precision', 'Recall', 'F1-score', 'ROC-AUC' <br>
___ 
**_Quy trình_**: <br>
* Tiền xử lý dữ liệu. <br>
* Xử lý mất cân bằng. <br>
* Tiền xử lý văn bản với các thư viện NLP. <br>
* Xây dựng pipeline gồm 3 mô hình học máy. <br>
* Đánh giá các mô hình và chọn ra mô hình tốt nhất để dự đoán. <br>

Các file liên quan: <br>
  FinalMLModel.ipynb: File xây dựng các mô hình học máy. <br>
  fake_job_postings.csv: dataset về các tin tuyển dụng việc làm.
