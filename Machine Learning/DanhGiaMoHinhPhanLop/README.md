# Đánh giá hiệu quả của một số mô hình phân lớp phổ biến
Ở dự án này mình tập trung vào việc đánh giá các mô hình phân lớp phổ biến: <br>
**_Quy trình_**: <br>
* Thử đánh giá các mô hình trên dataset mất cân bằng có sử dụng phương pháp trích chọn đặc trưng. <br>
* Sử dụng nhiều phương pháp cân bằng dữ liệu của Python và đánh giá mô hình trên mỗi phương pháp cân bằng dữ liệu. <br>
* Đưa ra các mô hình tốt nhất theo từng tiêu chí đánh giá. <br>
<br>
___
Cụ thể: <br>
Các mô hình phân lớp được dùng để đánh giá: <br>
- 'KNN', 'Logistic Regression', 'Random Forest', 'Naive Bayes', "Neural Network", "Linear Support Vector Machine". <br> 
Các chỉ số đánh giá: <br>
- (Accuracy, Precision, Recall, F1-score, AUC, ROC, Running time) <br>
___ 
Các File liên quan <br>
Dataset: bank-additional-full.csv: Dataset về chiến dịch tiếp thị của một ngân hàng Bồ Đào Nha. <br>
ModelsEvaluation.ipynb: File ipynb đánh giá mô hình trên dataset mất cân bằng. <br>
ChooseImbalanceMethod.ipynb: File ipynb đánh giá mô hình với dữ liệu được áp dụng nhiều phương pháp xử lý mất cân bằng. <br>
DanhGiaMoHinh.pdf: File pdf diễn giải kết quả.
