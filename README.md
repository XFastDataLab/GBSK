# GBSK: Skeleton Clustering via Granular-Ball Computing and Multi-Sampling for Large-Scale Complex Data
[Yewang Chen](https://faculty.hqu.edu.cn/CYW1), [Junfeng Li](https://github.com/MarveenLee), [Shuyin Xia](https://orcid.org/0000-0001-5993-9563), [Qinghong Lai](https://orcid.org/0009-0003-0712-9229), [Xinbo Gao](https://see.xidian.edu.cn/faculty/xbgao/), [Guoyin Wang](https://orcid.org/0000-0002-8521-5232), [Dongdong Cheng](https://orcid.org/0000-0003-3500-5461), [Yi Liu](https://orcid.org/0009-0008-9668-7076), [Yi Wang](https://orcid.org/0000-0002-9013-7232)

<!-- [[`Paper`]()] -->
[[`Demo`](https://github.com/XFastDataLab/GBSK?tab=readme-ov-file#-getting-started)] [[`Datasets`](https://github.com/XFastDataLab/GBSK?tab=readme-ov-file#-datasets)]

**Granular-ball Skeleton Clustering (GBSK)** is a scalable clustering algorithm designed for large-scale, complex data. By constructing multi-grained granular-balls from sampled data, it approximates the underlying structure of data as a compact "skeleton," reducing computation while maintaining accuracy. With linear time complexity (O(n)), GBSK handles massive datasets—up to 100M points in 256 dimension. The adaptive variant, AGBSK, simplifies parameter tuning for ease of use.

![GBSK framework](assets/Framework_boxes.png)

## 🔍 Overview
Traditional clustering methods often struggle with large and complex datasets due to computational constraints and sensitivity to noise. GBSK addresses these challenges by:

- Employing **granular-ball computing** to capture local data structures,
- Utilizing **multi-sampling** to enhance robustness and scalability,
- Constructing a **skeleton** that represents the core structure of the data, facilitating efficient clustering.

## 📁 Repository Structure

 `Algorithms/`: Contains the core implementation of the GBSK algorithm and competing algorithms.
 
 `Datasets/`: Some datasets for testing and demonstration purpose.
 
 `experiment_records/`: Logs and results from various experimental run.
 
 `README.md`: This documentation file.
 
 `LICENSE`: GPL-3.0 license information.

## 🚀 Getting Started

### Prerequisites
- MATLAB (recommended version R2021a or later)

### Installation

1. Clone the repositoy:
   ```bash
   git clone https://github.com/XFastDataLab/GBSK.git
   ```


2. Add the `Algorithms/` directory to your MATLAB path:
   ```matlab
   addpath(genpath('path_to_GBSK/Algorithms'));
   ```


## ⚙️ Usage

1. Prepare your dataset in `.mat` or `.txt` format, ensuring it contains a variable representing an $N \times D$ matrix (N instances, D feature).

2. Place your dataset in the `Datasets/` directoy.

3. Navigate to the `Algorithms/` directory in MATLB.

4. Run the main scrit: `main.m` for a dataset that does not exceed memory. Otherwise, edit and run `main_big.m`. 

5. Adjust parameters within the script as needed:
  - `num_samples`: Number of sample sets (default: 30)
  - `alpha`: Sampling proportion (default: $\frac{1}{\sqrt{n}}$ )
  - `k`: Number of peak balls or desired clusters
  - `target_ball_count`: Target number of balls per sample set (default: $10 \times k$ )

## 📊 Outpt

Upon execution, results are stored in the `experiment_records/` directory, organized by dataset name and parameter settings. Each run includes:
- `labels.txt`: Cluster labels assigned to each data pont.
- `all_peaks.txt`: Coordinates of the final key balls.
- `ori_all_peaks.txt`: Original peaks before deduplicaton.
- `log.txt`: Detailed log of the run, including timing and parameter settigs.

## 📈 Performace

GBSK is designed for efficiency and scalabiity:

- **Time Complexity**: $O(n)$, significantly reduced compared to traditional clustering methods on large dataets.
- **Scalability**: Capable of handling datasets with millions of instances.
- **Robustness**: Effective in the presence of noise and outliers due to multi-sampling and density-based techniues.

## 📄 Licnse

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.tml).

## 🤝 Acknowledgents

Developed and maintained by [XFastDataLab](https://github.com/XFastDataLab). For questions or collaborations, please contact [MarveenLee](mailto:G2219100349@gmail.com).
---

For more information and updates, visit the [GBSK GitHub repository](https://github.com/XFastDataLab/GBSK/treemain).

--- 
