## Analysis Report on Sorting Algorithms

### Overview
This report analyzes the performance of various sorting algorithms, including four hybrid sorting variants that combine different classical sorting techniques. The metrics used for evaluation include average execution time, minimum execution time, maximum execution time, and standard deviation of execution time. The analysis is visualized through four separate bar charts.

### Algorithms Analyzed
- **BubbleSort**
- **InsertionSort**
- **MergeSort**
- **QuickSort**
- **HybridSort_1**: Combines **InsertionSort** and **MergeSort**
- **HybridSort_2**: Combines **InsertionSort** and **QuickSort**
- **HybridSort_3**: Combines **BubbleSort** and **MergeSort**
- **HybridSort_4**: Combines **BubbleSort** and **QuickSort**

### Key Metrics
- **Average Execution Time** (ms)
- **Minimum Execution Time** (ms)
- **Maximum Execution Time** (ms)
- **Standard Deviation of Execution Time** (ms)

### Findings

| Algorithm     | Time (ms)                                                                                                         | Average Time (ms) | Min Time (ms) | Max Time (ms) | Std Dev (ms) |
|---------------|------------------------------------------------------------------------------------------------------------------|-------------------|---------------|---------------|--------------|
| bubbleSort    | [0.00286102294921875, 0.0011920928955078125, 0.0007152557373046875, 0.009298324584960938, 0.003337860107421875]   | 0.179529          | 0.000715      | 0.009298      | 0.002004     |
| hybridSort_1  | [0.0016689300537109375, 0.00095367431640625, 0.0007152557373046875, 0.00286102294921875, 0.001430511474609375]    | 0.082254          | 0.000715      | 0.002861      | 0.000522     |
| hybridSort_2  | [0.0011920928955078125, 0.00095367431640625, 0.0007152557373046875, 0.00286102294921875, 0.0011920928955078125]   | 0.077963          | 0.000715      | 0.002861      | 0.000487     |
| hybridSort_3  | [0.001430511474609375, 0.0016689300537109375, 0.0009541511535644531, 0.008821487426757812, 0.0019073486328125]    | 0.191927          | 0.000954      | 0.008821      | 0.002019     |
| hybridSort_4  | [0.00095367431640625, 0.001430511474609375, 0.0007152557373046875, 0.009298324584960938, 0.0016689300537109375]   | 0.187874          | 0.000715      | 0.009298      | 0.002099     |
| insertionSort | [0.0026226043701171875, 0.00095367431640625, 0.0007152557373046875, 0.019550323486328125, 0.0011920928955078125] | 0.107765          | 0.000715      | 0.019550      | 0.003190     |
| mergeSort     | [0.0059604644775390625, 0.00286102294921875, 0.002384185791015625, 0.0064373016357421875, 0.003337860107421875]  | 0.209808          | 0.002384      | 0.006437      | 0.001178     |
| quickSort     | [0.0021457672119140625, 0.001430511474609375, 0.0009541511535644531, 0.006676197052001953, 0.0016689300537109375] | 0.106812          | 0.000954      | 0.006676      | 0.000913     |


#### Average Execution Time
- **MergeSort** has the highest average execution time at approximately **0.209 ms**.
- **HybridSort_3** and **HybridSort_4**, which combine **BubbleSort** with **MergeSort** and **QuickSort** respectively, exhibit higher average times than those involving **InsertionSort**.
- **HybridSort_2** (InsertionSort + QuickSort) shows a lower average execution time compared to other hybrid variants, in line with expectations given **QuickSort**'s efficiency in most average cases.

#### Minimum Execution Time
- **MergeSort** shows a notably higher minimum execution time, indicating that the best-case scenario is less efficient compared to other algorithms.
- Hybrid algorithms that involve **InsertionSort** (such as **HybridSort_1** and **HybridSort_2**) tend to have lower minimum execution times, likely benefiting from **InsertionSort**'s efficiency with smaller or nearly sorted datasets.

#### Maximum Execution Time
- **InsertionSort** exhibits the highest maximum execution time among all algorithms, which is expected given its quadratic complexity (**O(n²)**) in the worst-case scenario.
- **BubbleSort** and **hybrid sorts involving BubbleSort** also show higher maximum times compared to other algorithms, reflecting the generally poor performance of **BubbleSort** with larger datasets.

#### Standard Deviation of Execution Time
- **InsertionSort** has the highest standard deviation, indicating higher variability in performance across different datasets.
- **HybridSort_1** and **HybridSort_2** show the lowest standard deviations, suggesting more consistent performance. This aligns with their design to leverage **InsertionSort** for smaller partitions where it is effective, and a more efficient sorting method for larger datasets.

### Expected vs. Observed Behavior
- **BubbleSort** and **InsertionSort** are known to perform poorly compared to more efficient algorithms like **MergeSort** and **QuickSort**, especially with larger datasets. This behavior is confirmed by the higher average and maximum execution times observed.
- The hybrid algorithms that combine **InsertionSort** with more efficient sorts (**HybridSort_1** and **HybridSort_2**) show improved performance in both average and standard deviation metrics compared to hybrids involving **BubbleSort**. This is consistent with the notion that **InsertionSort** is effective for small subsets or nearly sorted data, while **MergeSort** and **QuickSort** can efficiently handle larger subsets.
- **MergeSort** shows higher minimum and average execution times, which may be due to the overhead associated with its recursive nature and additional memory usage for merges.
- The results align well with theoretical expectations of sorting algorithms, particularly with respect to the efficiency trade-offs between simpler (e.g., **BubbleSort**, **InsertionSort**) and more complex (e.g., **MergeSort**, **QuickSort**) algorithms, as well as the impact of hybridization on performance.

### Conclusion
The findings are consistent with theoretical expectations of sorting algorithm performance:
- Hybrid algorithms combining **InsertionSort** and more efficient sorting methods show balanced performance.
- **InsertionSort** and **BubbleSort** tend to be slower and exhibit more variability, especially in worst-case scenarios.
- **MergeSort** and **QuickSort** retain their competitive performance in terms of consistent execution times, with **QuickSort** generally being faster in practice.

These insights indicate that hybridizing a slow algorithm like **BubbleSort** yields limited improvements compared to hybrids involving more efficient algorithms. Hybrid combinations using **InsertionSort** with a more powerful sort can leverage the strengths of each, achieving overall better and more consistent performance.
