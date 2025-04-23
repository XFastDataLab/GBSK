# GBSK: Skeleton Clustering via Granular-Ball Computing and Multi-Sampling

**GBSK** is a scalable clustering algorithm designed for large-scale, complex datasets. It integrates granular-ball computing with multi-sampling strategies to efficiently uncover the intrinsic skeleton of data distributions.

## 🔍 Overview
Traditional clustering methods often struggle with large and complex datasets due to computational constraints and sensitivity to noise. GBSK addresses these challenges by

-Employing **granular-ball computing** to capture local data structures
-Utilizing **multi-sampling** to enhance robustness and scalability
-Constructing a **skeleton** that represents the core structure of the data, facilitating efficient clustering

## 📁 Repository Structure

 `Algorithms/`: Contains the core implementation of the GBSK algorith.
 `Datasets/`: Sample datasets for testing and demonstration purpose.
 `experiment_records/`: Logs and results from various experimental run.
 `README.md`: This documentation fil.
 `LICENSE`: GPL-3.0 license informatio.

## 🚀 Getting Started

### Prerequisites
- MATLAB (recommended version R2020a or latr)- Required MATLAB toolboxs:
 - Statistics and Machine Learning Toolox
 - Parallel Computing Toolbox (optional for parallel processig)

### Installation

. Clone the repositoy:
   ```bash
   git clone https://github.com/XFastDataLab/GBSK.git
   ``


. Add the `Algorithms/` directory to your MATLAB pah:
   ```matlab
   addpath(genpath('path_to_GBSK/Algorithms'));
   ``


## ⚙️ Usage

. Prepare your dataset in `.mat` format, ensuring it contains a variable representing an \( N \times D \) matrix (N samples, D feature).

. Place your dataset in the `Datasets/` directoy.

. Navigate to the `Algorithms/` directory in MATLB.

. Run the main scrit:
   ```matlab
   main_GBSK.m
   ``


. Adjust parameters within the script as needd:
  - `num_samples`: Number of sample sets (default: 0)
  - `alpha`: Sampling proportion (default: 0, which uses \( 1/\sqrt{N} ))
  - `k`: Number of peak balls or desired clusters (default: 0)
  - `target_ball_count`: Target number of balls per sample set (default: \( 10 \times k ))

## 📊 Outpt

Upon execution, results are stored in the `experiment_records/` directory, organized by dataset name and parameter settings. Each run inclues:
- `labels.txt`: Cluster labels assigned to each data pont.
- `all_peaks.txt`: Coordinates of the final peak bals.
- `ori_all_peaks.txt`: Original peaks before deduplicaton.
- `log.txt`: Detailed log of the run, including timing and parameter settigs.

## 📈 Performace

GBSK is designed for efficiency and scalabiity:

- **Time Complexity**: Significantly reduced compared to traditional clustering methods on large dataets
- **Scalability**: Capable of handling datasets with millions of samles
- **Robustness**: Effective in the presence of noise and outliers due to multi-sampling and density-based techniues.

## 📄 Licnse

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.tml).

## 🤝 Acknowledgents

Developed and maintained by [XFastDataLab](https://github.com/XFastDataLab). For questions or collaborations, please contact [XFastData@HQU](mailto:XFastDat@HQU).
---

For more information and updates, visit the [GBSK GitHub repository](https://github.com/XFastDataLab/GBSK/treemain).

--- 
